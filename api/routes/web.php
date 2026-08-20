<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Api\UserController;

Route::get('/', function () {
    return response()->json([
        'message' => 'Code4Youth API is Live!',
        'app_env' => config('app.env'),
        'php_version' => PHP_VERSION,
        'diagnostics' => [
            'db_host' => config('database.connections.mysql.host'),
            'db_database' => config('database.connections.mysql.database'),
            'db_username' => config('database.connections.mysql.username'),
            'session_driver' => config('session.driver'),
        ]
    ]);
});

Route::get('/api/status', function () {
    $results = [
        'status' => 'Backend is running!',
        'laravel_connection' => 'failed',
        'pdo_connection' => 'failed',
        'errors' => []
    ];

    // Test 1: Laravel DB Facade
    try {
        DB::connection()->getPdo();
        $tableCount = count(DB::select('SHOW TABLES'));
        $results['laravel_connection'] = "Connected ($tableCount tables)";
    } catch (\Exception $e) {
        $results['errors'][] = 'Laravel DB Error: ' . $e->getMessage();
    }

    // Test 2: Raw PDO (most reliable test)
    try {
        $host = config('database.connections.mysql.host');
        $port = config('database.connections.mysql.port');
        $db   = config('database.connections.mysql.database');
        $user = config('database.connections.mysql.username');
        $pass = config('database.connections.mysql.password');

        $dsn = "mysql:host=$host;port=$port;dbname=$db;charset=utf8mb4";
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false,
        ];

        new PDO($dsn, $user, $pass, $options);
        $results['pdo_connection'] = 'Connected successfully via raw PDO';
    } catch (\Exception $e) {
        $results['errors'][] = 'Raw PDO Error: ' . $e->getMessage();
    }

    return response()->json($results);
});

Route::post('/api/user/sync', [UserController::class, 'sync']);
