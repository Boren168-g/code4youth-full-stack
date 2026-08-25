# Admin backend contract

**Status: built and running end to end.** A real Firebase ID token has been
verified by Laravel, resolved to a `users` row, and answered with a session —
through nginx, from the app, in a browser.

| Piece | State |
| ----- | ----- |
| `MockAdminGateway` + console UI | done |
| Laravel schema, endpoints, authorization, audit | done, in `../../api` |
| `LaravelAdminGateway` (Dart HTTP client) | done, exercised against the live API |
| `firebase_auth` / `firebase_core` in the Flutter app | done |
| Firebase project + Admin SDK service-account key | done |
| Learner API (`/api/me`, curriculum, progress, sync) | done — see below |

This document describes the **admin** contract. The learner endpoints were
built afterwards to the same rules and are listed under
[The learner API](#the-learner-api).

Every rule named here is enforced twice — by `MockAdminGateway` for the
interface, and by Laravel for real. The client's copy is for the interface, not
for security: builds without `--dart-define=API_BASE_URL` still run on the mock.

## Division of responsibility

```
Firebase Authentication ──► who is this person?
Flutter client state    ──► are they signed in? what should the UI show?
Laravel                 ──► what is this person allowed to do?
Laravel database        ──► the authoritative user, role, status and audit
```

The client never decides a role and never sends one. `AdminSession`
(`fetchSession`) is the only place capabilities enter the app, and they come
from the server.

## Request flow

```
Flutter
  └─ FirebaseAuth.instance.currentUser.getIdToken()
       └─ Authorization: Bearer <JWT>   ──►  Laravel
                                              ├─ verify signature against Google's public keys
                                              ├─ check aud / iss / exp
                                              ├─ sub  ──►  users.firebase_uid
                                              ├─ load role + permissions
                                              ├─ run the endpoint's policy
                                              └─ 200 | 401 | 403 | 409 | 422
```

The ID token is verified on every request. It is short-lived (1 hour); the
client refreshes via the Firebase SDK and never caches an authorization
decision across requests.

## Database

The sketch that used to sit here proposed creating `users` from scratch. What
was built extends Laravel's own table instead, and the shape drifted in three
ways worth recording:

- **`grade` became `grade_id`**, a foreign key to a `grades` table whose
  `is_minor` column drives the consent gate. A grade band is the only age
  signal the app collects, so the rule lives on the band.
- **`guardian_email` and `consent_status` stayed on `users`** as cached
  projections of the current `guardian_consents` row, written in the same
  transaction. Two sources of truth that can disagree are worse than one join,
  so only that transition may write them.
- **XP, streak and lessons-completed left `users`** for `user_stats`, which
  owns them outright. They lived on `users` briefly and were dropped again.

`audit_logs` gained `actor_name` and `target_name` snapshots beside the ids, so
an entry still reads correctly after a rename or a deletion, and both foreign
keys null out on delete rather than cascading — the log outlives its subjects.

The full schema is drawn in [`erd.md`](erd.md); 26 tables, of which 23 exist.

No password column is written: Firebase owns credentials. The column itself
survives as nullable so Laravel's own session guard still works for anything
server-side, and no account that signs in through the app has one.

**Roles live in Laravel, not in Firebase custom claims.** One source of truth.
Claims would have to be re-minted and re-synced on every change, and a stale
claim is a live privilege. If claims are ever added, treat them as a cache for
routing only and never as an authorization input.

## Permissions

| Capability (Dart)  | Permission          | learner | teacher | moderator | admin |
| ------------------ | ------------------- | :-----: | :-----: | :-------: | :---: |
| `viewConsole`      | `console.view`      |    ·    |    ✓    |     ✓     |   ✓   |
| `viewLearners`     | `users.view`        |    ·    |    ·    |     ✓     |   ✓   |
| `moderateAccounts` | `users.suspend`     |    ·    |    ·    |     ✓     |   ✓   |
| `reviewConsent`    | `users.consent`     |    ·    |    ·    |     ✓     |   ✓   |
| `viewAudit`        | `audit.view`        |    ·    |    ·    |     ✓     |   ✓   |
| `manageRoles`      | `users.change_role` |    ·    |    ·    |     ·     |   ✓   |
| `manageSystem`     | `settings.update`   |    ·    |    ·    |     ·     |   ✓   |
| —                  | `cohorts.view`      |    ·    |    ✓    |     ·     |   ✓   |
| —                  | `cohorts.view_all`  |    ·    |    ·    |     ·     |   ✓   |
| —                  | `cohorts.manage`    |    ·    |    ✓    |     ·     |   ✓   |

Read the teacher column downwards: console access and cohorts, and nothing
else. A teacher holds no permission over accounts at all — not even
`users.view`. That is what makes the enrolment endpoint take an exact email
address instead of a search, and what keeps the roster payload free of consent
state and guardians' addresses.

The three cohort rows now have `AdminCapability` counterparts —
`viewCohorts`, `viewAllCohorts` and `manageCohorts` — and the console generates
its navigation from whichever of them the server returned. The server is still
the authority: an unknown permission string is dropped by the client's
`_permissionWire` map rather than guessed at.

A moderator can unblock and protect learners. Only an admin can grant
capabilities or take the app offline — `users.change_role` is the only
permission that can hand out permissions, which is why it sits alone.

There is no `maintainer` role. Nothing in this product currently needs one:
there are no deploys, integrations or infrastructure controls an operator
touches. Add it when there is a distinct job to do, not in advance.

## Endpoints

```php
// routes/api.php — as built
Route::middleware(['firebase', 'throttle:120,1'])->prefix('admin')->group(function () {
    Route::get('session',                 [AdminSessionController::class, 'show']);
    Route::get('overview',                [OverviewController::class, 'show']);
    Route::get('users',                   [AdminUserController::class, 'index']);
    Route::get('users/{user}',            [AdminUserController::class, 'show']);
    Route::post('users/{user}/status',    [AdminUserController::class, 'changeStatus']);
    Route::post('users/{user}/consent',   [AdminUserController::class, 'approveConsent']);
    Route::get('audit-logs',              [AuditController::class, 'index']);
    Route::get('settings/maintenance',    [SettingsController::class, 'showMaintenance']);
    Route::post('settings/maintenance',   [SettingsController::class, 'updateMaintenance']);

    // Privilege escalation gets its own, much tighter budget. It is the one
    // endpoint where a burst of attempts is never legitimate traffic.
    Route::post('users/{user}/role', [AdminUserController::class, 'changeRole'])
        ->middleware('throttle:10,1');
});
```

```php
// The teacher API, added after this document was first written.
Route::middleware(['firebase', 'throttle:120,1'])->prefix('teacher')->group(function () {
    Route::get('cohorts',                        [CohortController::class, 'index']);
    Route::post('cohorts',                       [CohortController::class, 'store']);
    Route::get('cohorts/{cohort}',               [CohortController::class, 'show']);
    Route::patch('cohorts/{cohort}',             [CohortController::class, 'update']);
    Route::delete('cohorts/{cohort}',            [CohortController::class, 'destroy']);

    Route::post('cohorts/{cohort}/learners',     [CohortEnrolmentController::class, 'store']);
    Route::delete('cohorts/{cohort}/learners/{user}', [CohortEnrolmentController::class, 'destroy']);
});
```

Its own prefix rather than a corner of `admin`, because a teacher is not an
administrator. Note what is absent: no route lists learners. A teacher enrols
someone whose email address they already have and reads the roster that
results; anything broader is the directory, and the directory is moderation's.

Four rules run through it, and they are the interesting part:

- **The owner is the caller.** `teacher_id` is not fillable and never read from
  a request body. A cohort created with someone else's id in the payload
  belongs to the caller anyway.
- **A cohort you cannot see is a 404.** Answering 403 for another teacher's
  cohort confirms the id exists, which is enumeration with extra steps. A
  cohort you *can* see but may not change — an admin holding
  `cohorts.view_all` — is a real 403, because there is nothing left to leak.
- **Oversight is not control.** `cohorts.view_all` lets an admin read any
  roster and change none. Editing a cohort requires owning it.
- **Withdrawal is not deletion.** `DELETE .../learners/{user}` stamps
  `left_at`; archiving a cohort soft-deletes it and keeps the roster. The class
  happened, and a delete is the one answer that cannot be given afterwards.

`POST .../learners` answers 404 both for an address with no account and for an
address belonging to staff. Distinguishing them would hand every teacher
account an oracle for "does this person have an account here".

Two differences from the sketch. The middleware alias is `firebase`, not
`auth.firebase`. And authorization is **not** expressed as `can:` middleware on
most routes: it lives in the FormRequest or the controller, next to the business
rules it belongs with, so a route added later cannot inherit an authorization
decision it never declared.

## The learner API

Built after this document, to the same rules. `firebase:provision` replaces
`firebase` — the first authenticated request creates the row — and everything
except `GET /api/me` sits behind `learner.ready`, which requires a verified
email and, for a minor, an approved guardian.

```php
Route::middleware(['firebase:provision', 'throttle:120,1'])->group(function () {
    Route::get('me', …);                    // session bootstrap; the only route
    Route::patch('me', …);                  //   reachable before the gates pass
    Route::get('lookups', …);               // grades + interests, for onboarding
    Route::post('guardian-consents', …);    // 202, queues the email
    Route::get('invites/{token}', …);       // landing route for deep links

    Route::middleware('learner.ready')->group(function () {
        Route::patch('preferences', …);
        Route::get('modules', …);
        Route::get('lessons/{slug}', …);
        Route::patch('progress', …);        // resume cursor, never rewinds
        Route::post('lessons/{slug}/complete', …);  // server grades the answer
        Route::post('sync', …);             // offline replay, idempotent by uuid
        Route::delete('me', …);

        Route::get('cohorts', …);           // the classes I am in
        Route::post('cohorts/join', …);     // join with code
        Route::get('invites', …);           // pending invitations
        Route::post('invites/{token}/accept', …);
        Route::post('invites/{token}/decline', …);
        Route::get('assignments', …);
        Route::post('assignments/{id}/submit', …);
    });
});
```

The guardian's own pages are unauthenticated web routes: `GET /consent/{token}`
shows a confirmation page and `POST` acts on it. A GET that granted consent
would be approved by any mail scanner that fetched the link.

## Token verification middleware

The sketch below was written before the middleware existed. Two things about
the real `VerifyFirebaseToken` differ, and both were learned by running it:

```php
// The container, not the verifier. Constructor-injecting FirebaseTokenVerifier
// builds the Firebase client — which opens and parses the service-account
// key — on every request to a guarded route, including requests carrying no
// token at all. A request that should be a two-line 401 came back as a 500
// until this changed.
public function __construct(private readonly Container $container) {}

public function handle(Request $request, Closure $next, ?string $mode = null): Response
{
    $idToken = $request->bearerToken();
    if ($idToken === null || $idToken === '') {
        return $this->deny('Not signed in.', 401);
    }

    $verifier = $this->container->make(FirebaseTokenVerifier::class);

    try {
        $identity = $verifier->verify($idToken);
    } catch (InvalidIdToken) {
        return $this->deny('Invalid or expired token.', 401);
    }

    $user = User::where('firebase_uid', $identity->uid)->first();

    if ($user === null) {
        // `firebase:provision` makes the first authenticated request create the
        // row, as the sign-up sequence draws it. It is applied to the learner
        // routes and deliberately not to the admin ones: staff accounts are
        // never a side effect of somebody registering with Firebase.
        if ($mode !== 'provision') {
            return $this->deny('No application account for this identity.', 401);
        }
        $user = $this->provision($identity);
    }

    if (! $user->isActive() && ! $user->isBlockedOnConsent()) {
        return $this->deny('This account is not active.', 403);
    }

    Auth::setUser($user);
    $this->syncFromToken($user, $identity);

    return $next($request);
}
```

Verification is behind a `FirebaseTokenVerifier` interface so the whole suite
runs without a Firebase project; the Kreait implementation passes
`checkIfRevoked: true`, because a token stays cryptographically valid for its
full hour and a revoked account would otherwise keep working.

The Firebase **Admin SDK service-account key is server-side only**. It belongs
in `storage/` or an environment secret, never in the repo, never in a build
artifact, and never in any response body. The client only ever holds the public
Firebase web/app config and its own short-lived ID token.

## The role endpoint

The high-risk one. Confirmation dialogs in the app are UX; this is the control.

```php
public function changeRole(ChangeRoleRequest $request, User $user)
{
    $actor = Auth::user();

    // 1. Authorization — not "is the UI showing the control".
    Gate::authorize('users.change_role');

    $role = $request->validated()['role'];   // enum-validated in the FormRequest

    // 2. Self-modification.
    if ($user->is($actor)) {
        return response()->json([
            'message' => 'You cannot change your own role.',
        ], 409);
    }

    // 3. Last-admin protection, inside a transaction with a row lock so two
    //    concurrent demotions cannot both observe "there are still two admins".
    return DB::transaction(function () use ($user, $actor, $role) {
        $activeAdmins = User::where('role', 'admin')
            ->where('status', 'active')
            ->lockForUpdate()
            ->count();

        if ($user->role === 'admin' && $user->status === 'active'
            && $role !== 'admin' && $activeAdmins <= 1) {
            return response()->json([
                'message' => 'This is the last active admin.',
            ], 409);
        }

        $previous = $user->role;
        $user->update(['role' => $role]);

        // 4. Audit, written here — inside the transaction, by the server.
        AuditLog::create([
            'actor_id'       => $actor->id,
            'action'         => 'role_changed',
            'target_id'      => $user->id,
            'previous_value' => $previous,
            'new_value'      => $role,
            'created_at'     => now(),
        ]);

        return new UserResource($user->fresh());
    });
}
```

`ChangeRoleRequest` validates `role` against the enum, so an unknown value is
422 before any of this runs. The client's typed-`ADMIN` confirmation is not sent
and not checked — it exists to slow a human down, and a server that trusted it
would be trusting the client.

Denied attempts are logged too:

```php
Gate::after(function ($user, $ability, $result) {
    if ($result === false) {
        AuditLog::create([
            'actor_id' => $user->id,
            'action'   => 'access_denied',
            'note'     => $ability,
            'created_at' => now(),
        ]);
    }
});
```

## Status codes the client already handles

| Code | Meaning                        | Client behaviour                    |
| ---- | ------------------------------ | ----------------------------------- |
| 401  | No/invalid/expired token       | `AdminDenied` → refresh, re-auth    |
| 403  | Authenticated, not permitted   | `AdminDenied` → toast, no state change |
| 404  | Unknown target                 | `AdminInvalid` → toast              |
| 409  | Invariant violation            | `AdminInvalid` → toast              |
| 422  | Validation failure             | `AdminInvalid` → toast              |
| 503  | Maintenance window, or no route to the server | `AdminInvalid` → toast |

`AdminService._map` performs this mapping today. Note what the last row admits:
503 now arrives from two unrelated places — `EnsureLearnerIsReady` refusing a
learner during a maintenance window, and the gateways' own catch-all when the
host cannot be reached — and nothing tells them apart. The refusal carries
`reason: maintenance`, which `AdminApiException` already parses and no caller
reads. See remaining item 1.

## Wiring the Flutter side

`Backend.resolve()` is the composition root — one place decides what the app
talks to, and nothing downstream has to ask:

```dart
// lib/data/backend.dart
final Backend backend = Backend.resolve(firebaseReady: firebaseReady);

AppState(
  auth: backend.auth,                    // FirebaseAuthService, or the demo one
  adminGateway: backend.adminGateway,    // LaravelAdminGateway, or the mock
  learnerGateway: backend.learnerGateway, // null without an API
);
```

Two independent switches. `--dart-define=API_BASE_URL=…` points the gateways at
Laravel; Firebase starting successfully selects the real identity service. That
independence is deliberate, and *real API, demo identity* was the useful
development combination, because the demo service issued the uids the seeder
wrote, so its tokens resolved to real rows.

That last part no longer holds. The seeder stopped writing uids, for the reason
in remaining item 3, and nothing updated the demo service to match: it still
issues `seed-admin` and `seed-learner`, and still carries a comment claiming
they match what the seeder writes. Nothing matches them now, so the combination
provisions a fresh learner on every sign-in. Link the seeds by hand first, or
expect that.

Neither gateway takes an actor id or a role on any method, by design: a client
that could name its own actor could name someone else's. `LearnerGateway` has
one asymmetry — `completeLesson` sends the learner's answer, because the server
grades it, and a client that skipped the challenge has nothing to send.

Run against a local API with:

```
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/
```

## Decisions worth knowing

- Maintenance mode is a row in `app_settings`, not `php artisan down` — the
  latter would take this API offline too, and this API is what turns it back on.
- Permissions are Gates registered from `UserRole::permissions()` in
  `AppServiceProvider`. No package, no roles table.
- `Gate::after` writes an `access_denied` entry for every failed permission
  check, so probing shows up in the log.
- The first admin is made with `php artisan user:role <email> admin`. A fresh
  database has no admin, and `users.change_role` requires one — shell access is
  the trust boundary, which is the same one that already allows `tinker`.
- The suite refuses to run unless it is pointed at a throwaway sqlite database.
  Laravel lets a real environment variable beat every setting in `phpunit.xml`,
  including `force="true"`, and the container exports `DB_CONNECTION=mysql` — so
  a plain `php artisan test` truncated the development database on every run
  until `TestCase` started failing loudly instead.

## Remaining work

Everything the original list named as blocking is done: the Firebase packages,
the project and service-account key, the token provider, and the suite re-run
against the real backend.

All items this section has carried are now built:

- **Maintenance mode is enforced and visible.** `EnsureLearnerIsReady` checks it
  last and only for learners. The learner app reads the switch and draws
  `_MaintenanceScreen` in `shell.dart`.
- **The directory is paged and filtered by the server.**
- **Invitations are delivered and handled.** `CohortInvitation` mailable is
  queued on invite creation, and deep links (`code4youth://invites/{token}`)
  are handled by the Flutter app.
- **The learner has a class list.** `GET /api/cohorts` returns the classes the
  learner is in, even if no work is set.
- **The teacher API exists.**

What is left:

1. **Seeded accounts start unlinked, and demo identity no longer reaches
   them.** The seeder deliberately writes no `firebase_uid`: a placeholder is
   worse than none, because it looks linked, occupies the unique index and
   resolves no real token, so the seeded account sits there looking usable
   while sign-in provisions a second one. Link the accounts you intend to sign
   in as with:

   ```
   php artisan user:firebase-uid <email> --email=<firebase account>
   ```

   The cost is that `DemoAuthService` was left behind — its uids and its
   comment both still describe the old seeder. Either link the seeds after
   every fresh `migrate:fresh --seed`, or teach the demo service to mint uids
   the seeder can be told about.

---

*Last checked against the tree at `d71f1aa`, then updated when the teacher API
landed.* This is the one document here describing behaviour rather than
structure, so it is the one that goes stale first and the one that cannot be
diffed against the schema to prove it. When this section and the code disagree,
the code is right; the point of the check is to find out which sentences are
lying before a release does it for you.
