<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserLessonProgress;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class UserController extends Controller
{
    public function sync(Request $request)
    {
        Log::info('Global Sync started', $request->all());

        try {
            $v = $request->validate([
                'uid' => 'required|string',
                'name' => 'required|string',
                'email' => 'required|email',
                'avatar' => 'nullable|string',
                'grade' => 'nullable|string',
                'interests' => 'nullable|array',
                'xp' => 'nullable|integer',
                'streak_days' => 'nullable|integer',
                'completed_lessons' => 'nullable|array',
                'language_code' => 'nullable|string',
                'consent_status' => 'nullable|string',
                'guardian_email' => 'nullable|email',
            ]);

            DB::beginTransaction();

            // 1. Map Grade (Table: grades)
            $gradeId = null;
            if (!empty($v['grade'])) {
                $gradeId = DB::table('grades')->where('label', $v['grade'])->value('id');
                if (!$gradeId) {
                    $gradeId = DB::table('grades')->insertGetId([
                        'code' => Str::slug($v['grade']),
                        'label' => $v['grade'],
                        'is_minor' => !str_contains(strtolower($v['grade']), 'university'),
                        'sort_order' => 1
                    ]);
                }
            }

            // 2. Update User (Table: users)
            $user = User::updateOrCreate(
                ['firebase_uid' => $v['uid']],
                [
                    'name' => $v['name'],
                    'email' => $v['email'],
                    'avatar' => $v['avatar'],
                    'grade_id' => $gradeId,
                    'consent_status' => $v['consent_status'],
                    'language_code' => $v['language_code'] ?? 'en',
                    'xp' => $v['xp'] ?? 0,
                    'streak_days' => $v['streak_days'] ?? 0,
                    'lessons_completed' => count($v['completed_lessons'] ?? []),
                    'last_active_at' => now(),
                ]
            );

            // 3. Update Stats (Table: user_stats)
            DB::table('user_stats')->updateOrInsert(
                ['user_id' => $user->id],
                [
                    'xp' => $user->xp,
                    'streak_days' => $user->streak_days,
                    'last_activity_date' => now(),
                    'updated_at' => now(),
                    'created_at' => DB::raw('IFNULL(created_at, NOW())')
                ]
            );

            // 4. Update Preferences (Table: user_preferences)
            DB::table('user_preferences')->updateOrInsert(
                ['user_id' => $user->id],
                [
                    'locale' => substr($user->language_code, 0, 2),
                    'updated_at' => now(),
                    'created_at' => DB::raw('IFNULL(created_at, NOW())')
                ]
            );

            // 5. Update Interests (Tables: interests, interest_user)
            if (!empty($v['interests'])) {
                foreach ($v['interests'] as $interestName) {
                    $interestId = DB::table('interests')->where('name', $interestName)->value('id');
                    if (!$interestId) {
                        $interestId = DB::table('interests')->insertGetId([
                            'name' => $interestName, 'icon_key' => 'star', 'sort_order' => 1
                        ]);
                    }
                    DB::table('interest_user')->updateOrInsert([
                        'user_id' => $user->id, 'interest_id' => $interestId
                    ]);
                }
            }

            // 6. Update Guardian Consent (Table: guardian_consents)
            if (!empty($v['guardian_email'])) {
                DB::table('guardian_consents')->updateOrInsert(
                    ['user_id' => $user->id],
                    [
                        'guardian_email' => $v['guardian_email'],
                        'status' => $v['consent_status'] ?? 'pending',
                        'token' => Str::random(32),
                        'is_current' => true,
                        'requested_at' => now()
                    ]
                );
            }

            // 7. Update Lessons (Tables: modules, lessons, user_lesson_progress)
            if (!empty($v['completed_lessons'])) {
                $adminId = DB::table('admins')->value('id') ?? DB::table('admins')->insertGetId([
                    'name' => 'System', 'email' => 'sys@c4y.com', 'password' => 'secret', 'role' => 'super', 'is_active' => true
                ]);

                foreach ($v['completed_lessons'] as $slug) {
                    $modSlug = substr($slug, 0, 2);
                    $modId = DB::table('modules')->where('slug', $modSlug)->value('id') ?? DB::table('modules')->insertGetId([
                        'slug' => $modSlug, 'title' => "Module $modSlug", 'title_km' => "ម៉ូឌុល $modSlug",
                        'description' => 'Auto', 'icon_key' => 'book', 'sort_order' => 1, 'created_by_admin_id' => $adminId
                    ]);

                    $lesId = DB::table('lessons')->where('slug', $slug)->value('id') ?? DB::table('lessons')->insertGetId([
                        'slug' => $slug, 'module_id' => $modId, 'title' => "Lesson $slug", 'title_km' => "មេរៀន $slug",
                        'summary' => 'Auto', 'minutes' => 5, 'sort_order' => 1, 'created_by_admin_id' => $adminId
                    ]);

                    UserLessonProgress::updateOrCreate(
                        ['user_id' => $user->id, 'lesson_id' => $lesId],
                        ['last_step_index' => 99, 'completed_at' => now()]
                    );
                }
            }

            DB::commit();
            return response()->json(['message' => 'Global Database Sync Successful', 'user' => $user]);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Global Sync Error: ' . $e->getMessage());
            return response()->json(['message' => 'Sync error', 'error' => $e->getMessage()], 500);
        }
    }

    public function getProfile($uid)
    {
        $user = User::where('firebase_uid', $uid)->first();
        return $user ? response()->json($user) : response()->json(['message' => 'User not found'], 404);
    }
}
