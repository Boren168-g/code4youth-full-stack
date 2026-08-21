<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserLessonProgress;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class UserController extends Controller
{
    public function sync(Request $request)
    {
        Log::info('Sync request received from phone', $request->all());

        try {
            $validated = $request->validate([
                'uid' => 'required|string',
                'name' => 'required|string',
                'email' => 'required|email',
                'avatar' => 'nullable|string',
                'xp' => 'nullable|integer',
                'streak_days' => 'nullable|integer',
                'completed_lessons' => 'nullable|array',
                'language_code' => 'nullable|string',
                'consent_status' => 'nullable|string',
            ]);

            DB::beginTransaction();

            // 1. Update Profile in 'users' table
            $user = User::updateOrCreate(
                ['firebase_uid' => $validated['uid']],
                [
                    'name' => $validated['name'],
                    'email' => $validated['email'],
                    'avatar' => $validated['avatar'],
                    'xp' => $validated['xp'] ?? 0,
                    'streak_days' => $validated['streak_days'] ?? 0,
                    'lessons_completed' => count($validated['completed_lessons'] ?? []),
                    'language_code' => $validated['language_code'] ?? 'en',
                    'last_active_at' => now(),
                ]
            );

            // 2. Update 'user_stats' table
            DB::table('user_stats')->updateOrInsert(
                ['user_id' => $user->id],
                [
                    'xp' => $validated['xp'] ?? 0,
                    'streak_days' => $validated['streak_days'] ?? 0,
                    'updated_at' => now()
                ]
            );

            // 3. Update 'user_lesson_progress' table
            if (!empty($validated['completed_lessons'])) {
                // Ensure a default module exists for lessons to link to
                $moduleId = DB::table('modules')->value('id');

                foreach ($validated['completed_lessons'] as $slug) {
                    // Link to an existing lesson ID by its slug (e.g. 'm1l1')
                    $lessonId = DB::table('lessons')->where('slug', $slug)->value('id');

                    if ($lessonId) {
                        UserLessonProgress::updateOrCreate(
                            ['user_id' => $user->id, 'lesson_id' => $lessonId],
                            [
                                'last_step_index' => 99, // 99 means finished
                                'completed_at' => now(),
                                'updated_at' => now()
                            ]
                        );
                    }
                }
            }

            DB::commit();
            return response()->json(['message' => 'Full sync successful', 'user' => $user]);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Sync failed: ' . $e->getMessage());
            return response()->json(['message' => 'Sync failed', 'error' => $e->getMessage()], 500);
        }
    }
}
