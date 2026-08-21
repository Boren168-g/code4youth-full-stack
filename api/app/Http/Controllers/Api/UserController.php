<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Module;
use App\Models\Lesson;
use App\Models\UserLessonProgress;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class UserController extends Controller
{
    public function sync(Request $request)
    {
        Log::info('Sync request received', $request->all());

        try {
            $validated = $request->validate([
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
            ]);

            DB::beginTransaction();

            // 1. Update/Create User
            $user = User::updateOrCreate(
                ['firebase_uid' => $validated['uid']],
                [
                    'name' => $validated['name'],
                    'email' => $validated['email'],
                    'avatar' => $validated['avatar'],
                    'status' => 'active',
                    'consent_status' => $validated['consent_status'],
                    'xp' => $validated['xp'] ?? 0,
                    'streak_days' => $validated['streak_days'] ?? 0,
                    'lessons_completed' => count($validated['completed_lessons'] ?? []),
                    'language_code' => $validated['language_code'] ?? 'en',
                    'last_active_at' => now(),
                ]
            );

            // 2. Sync User Stats Table
            DB::table('user_stats')->updateOrInsert(
                ['user_id' => $user->id],
                [
                    'xp' => $validated['xp'] ?? 0,
                    'streak_days' => $validated['streak_days'] ?? 0,
                    'last_activity_date' => now(),
                    'updated_at' => now()
                ]
            );

            // 3. Sync Lesson Progress
            if (!empty($validated['completed_lessons'])) {
                // Ensure we have a default admin and module for dynamic lesson creation
                $adminId = DB::table('admins')->value('id');
                if (!$adminId) {
                    $adminId = DB::table('admins')->insertGetId([
                        'name' => 'System',
                        'email' => 'system@code4youth.com',
                        'password' => 'secret',
                        'role' => 'super',
                        'is_active' => true,
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                }

                $moduleId = DB::table('modules')->value('id');
                if (!$moduleId) {
                    $moduleId = DB::table('modules')->insertGetId([
                        'slug' => 'm1',
                        'title' => 'Getting Started',
                        'title_km' => 'ការចាប់ផ្តើម',
                        'description' => 'Basics',
                        'icon_key' => 'rocket',
                        'sort_order' => 1,
                        'created_by_admin_id' => $adminId,
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                }

                foreach ($validated['completed_lessons'] as $slug) {
                    // Find or create lesson
                    $lessonId = DB::table('lessons')->where('slug', $slug)->value('id');

                    if (!$lessonId) {
                        $lessonId = DB::table('lessons')->insertGetId([
                            'slug' => $slug,
                            'module_id' => $moduleId,
                            'title' => 'Lesson ' . $slug,
                            'title_km' => 'មេរៀន ' . $slug,
                            'summary' => 'Auto-generated',
                            'minutes' => 10,
                            'xp' => 30,
                            'sort_order' => 1,
                            'created_by_admin_id' => $adminId,
                            'created_at' => now(),
                            'updated_at' => now()
                        ]);
                    }

                    // Log progress
                    UserLessonProgress::updateOrCreate(
                        ['user_id' => $user->id, 'lesson_id' => $lessonId],
                        [
                            'last_step_index' => 99, // Represents finished
                            'completed_at' => now(),
                            'updated_at' => now()
                        ]
                    );
                }
            }

            DB::commit();

            Log::info('User data fully synced: ' . $user->email);

            return response()->json([
                'message' => 'User synced successfully',
                'user' => $user
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Sync failed: ' . $e->getMessage());
            return response()->json(['message' => 'Sync failed', 'error' => $e->getMessage()], 500);
        }
    }

    public function getProfile($uid)
    {
        $user = User::where('firebase_uid', $uid)->first();

        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        return response()->json($user);
    }
}
