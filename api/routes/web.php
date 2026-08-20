<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Api\UserController;

Route::get('/', function () {
    $dbStatus = 'Testing...';
    $dbName = 'Unknown';

    try {
        DB::connection()->getPdo();
        $dbStatus = 'SUCCESS: Connected to Cloud Database!';
        $dbName = DB::connection()->getDatabaseName();
    } catch (\Exception $e) {
        $dbStatus = 'FAILED: ' . $e->getMessage();
    }

    return response()->json([
        'message' => 'Code4Youth API is Live!',
        'database_connection' => $dbStatus,
        'database_name' => $dbName,
        'diagnostics' => [
            'host' => config('database.connections.mysql.host'),
            'user' => config('database.connections.mysql.username'),
            'has_url' => !empty(config('database.connections.mysql.url')),
        ]
    ]);
});

Route::get('/api/status', function () {
    try {
        DB::connection()->getPdo();
        $tableCount = count(DB::select('SHOW TABLES'));
        $dbStatus = "Connected - $tableCount tables found";
    } catch (\Exception $e) {
        $dbStatus = "Error: " . $e->getMessage();
    }

    return response()->json([
        'status' => 'Backend is running!',
        'database' => $dbStatus,
        'timestamp' => now()->toDateTimeString(),
    ]);
});

Route::post('/api/user/sync', [UserController::class, 'sync']);
