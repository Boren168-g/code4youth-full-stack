<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Api\UserController;

Route::get('/', function () {
    return response()->json([
        'message' => 'Code4Youth API is Live!',
        'app_env' => config('app.env'),
        'php_version' => PHP_VERSION,
    ]);
});

Route::get('/api/status', function () {
    try {
        DB::connection()->getPdo();
        $tableCount = count(DB::select('SHOW TABLES'));
        $dbStatus = "Connected to Database (" . config('database.default') . ") - $tableCount tables found";
    } catch (\Exception $e) {
        $dbStatus = "Database Error: " . $e->getMessage();
    }

    return response()->json([
        'status' => 'Backend is running!',
        'database' => $dbStatus,
        'timestamp' => now()->toDateTimeString(),
    ]);
});

Route::post('/api/user/sync', [UserController::class, 'sync']);
