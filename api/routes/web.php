<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Api\UserController;

Route::get('/', function () {
    $dbStatus = 'Testing...';
    $dbName = 'Unknown';
    $errorDetails = '';

    try {
        // Force a fresh connection attempt
        DB::purge('mysql');
        DB::connection()->getPdo();
        $dbStatus = 'SUCCESS: Connected to Cloud Database!';
        $dbName = DB::connection()->getDatabaseName();
    } catch (\Exception $e) {
        $dbStatus = 'FAILED';
        $errorDetails = $e->getMessage();
    }

    return response()->json([
        'message' => 'Code4Youth API is Live!',
        'database_connection' => $dbStatus,
        'error_details' => $errorDetails,
        'database_name' => $dbName,
        'diagnostics' => [
            'host' => config('database.connections.mysql.host'),
            'port' => config('database.connections.mysql.port'),
            'user' => config('database.connections.mysql.username'),
            'driver' => config('database.default'),
        ]
    ]);
});

Route::get('/api/status', function () {
    try {
        DB::connection()->getPdo();
        $tableCount = count(DB::select('SHOW TABLES'));
        return response()->json([
            'status' => 'Backend is running!',
            'database' => "Connected - $tableCount tables found",
            'timestamp' => now()->toDateTimeString(),
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'Backend is running!',
            'database' => "Error: " . $e->getMessage(),
        ], 500);
    }
});

Route::post('/api/user/sync', [UserController::class, 'sync']);
