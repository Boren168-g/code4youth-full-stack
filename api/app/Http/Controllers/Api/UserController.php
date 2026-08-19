<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
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

            $user = User::updateOrCreate(
                ['firebase_uid' => $validated['uid']],
                [
                    'name' => $validated['name'],
                    'email' => $validated['email'],
                    'avatar' => $validated['avatar'],
                    'grade' => $validated['grade'],
                    'interests' => $validated['interests'],
                    'xp' => $validated['xp'] ?? 0,
                    'streak_days' => $validated['streak_days'] ?? 0,
                    'completed_lessons' => $validated['completed_lessons'],
                    'language_code' => $validated['language_code'],
                    'consent_status' => $validated['consent_status'],
                    'status' => 'active',
                    'last_active_at' => now(),
                ]
            );

            Log::info('User data saved to Docker: ' . $user->email);

            return response()->json([
                'message' => 'User synced successfully',
                'user' => $user
            ]);
        } catch (\Exception $e) {
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
