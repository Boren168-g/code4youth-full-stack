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
        Log::info('Sync request received', $request->all());

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
            ]);

            DB::beginTransaction();

            // 1. Ensure a System Admin exists (needed for lesson ownership)
            $adminId = DB::table('admins')->value('id');
            if (!$adminId) {
                $adminId = DB::table('admins')->insertGetId([
                    'name' => 'System',
                    'email' => 'system@code4youth.com',
                    'password' => bcrypt('secret'),
                    'role' => 'super',
                    'is_active' => true,
                    'created_at' => now(),
                    'updated_at' => now()
                ]);
            }

            // 2. Update/Create User
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

            // 3. Update User Stats
            DB::table('user_stats')->updateOrInsert(
                ['user_id' => $user->id],
                ['xp' => $user->xp, 'streak_days' => $user->streak_days, 'updated_at' => now()]
            );

            // 4. Sync Lesson Progress (Smart Mode)
            if (!empty($validated['completed_lessons'])) {
                foreach ($validated['completed_lessons'] as $slug) {
                    // 4a. Find the Module (or create if missing)
                    $moduleSlug = substr($slug, 0, 2); // e.g. 'm1'
                    $moduleId = DB::table('modules')->where('slug', $moduleSlug)->value('id');
                    if (!$moduleId) {
                        $moduleId = DB::table('modules')->insertGetId([
                            'slug' => $moduleSlug,
                            'title' => 'Module ' . strtoupper($moduleSlug),
                            'title_km' => 'ម៉ូឌុល ' . strtoupper($moduleSlug),
                            'description' => 'Automatically created',
                            'icon_key' => 'book',
                            'sort_order' => (int)filter_var($moduleSlug, FILTER_SANITIZE_NUMBER_INT),
                            'created_by_admin_id' => $adminId,
                            'created_at' => now()
                        ]);
                    }

                    // 4b. Find the Lesson (or create if missing)
                    $lessonId = DB::table('lessons')->where('slug', $slug)->value('id');
                    if (!$lessonId) {
                        $lessonId = DB::table('lessons')->insertGetId([
                            'slug' => $slug,
                            'module_id' => $moduleId,
                            'title' => 'Lesson ' . $slug,
                            'title_km' => 'មេរៀន ' . $slug,
                            'summary' => 'Synced from app',
                            'minutes' => 10,
                            'xp' => 30,
                            'sort_order' => 1,
                            'created_by_admin_id' => $adminId,
                            'created_at' => now()
                        ]);
                    }

                    // 4c. Log the Progress
                    UserLessonProgress::updateOrCreate(
                        ['user_id' => $user->id, 'lesson_id' => $lessonId],
                        ['last_step_index' => 99, 'completed_at' => now(), 'updated_at' => now()]
                    );
                }
            }

            DB::commit();
            return response()->json(['message' => 'Full Database Sync Complete', 'user' => $user]);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Sync Error: ' . $e->getMessage());
            return response()->json(['message' => 'Sync Error', 'error' => $e->getMessage()], 500);
        }
    }
}
