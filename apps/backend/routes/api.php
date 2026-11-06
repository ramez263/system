<?php

use App\Http\Controllers\Api\V1\AppConfigController;
use App\Http\Controllers\Api\V1\ConfigController;
use App\Http\Controllers\Api\V1\DeviceController;
use App\Http\Controllers\Api\V1\ServerController;
use App\Http\Controllers\Api\V1\SubscriptionController;
use App\Http\Controllers\Api\V1\TelemetryController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    // 1. Device identity & Push token (Zero friction guest auth)
    Route::post('/devices/handshake', [DeviceController::class, 'handshake']);
    Route::get('/devices/me', [DeviceController::class, 'me']);
    Route::post('/devices/push-token', [DeviceController::class, 'updatePushToken']);

    // 2. Curated OpenVPN & proxy server pool
    Route::get('/servers', [ServerController::class, 'index']);
    Route::get('/servers/countries', [ServerController::class, 'countries']);
    Route::get('/servers/{id}', [ServerController::class, 'show']);
    Route::get('/servers/{id}/ovpn', [ServerController::class, 'downloadOvpn']);

    // 3. Configurations (Community & Custom)
    Route::get('/configs', [ConfigController::class, 'index']);
    Route::post('/configs', [ConfigController::class, 'store']);
    Route::get('/configs/share/{code}', [ConfigController::class, 'byShareCode']);
    Route::get('/configs/{id}', [ConfigController::class, 'show']);
    Route::get('/configs/{id}/download', [ConfigController::class, 'download']);

    // 4. Subscriptions & Billing
    Route::get('/plans', [SubscriptionController::class, 'plans']);
    Route::post('/subscriptions/verify', [SubscriptionController::class, 'verify']);
    Route::get('/subscriptions/status', [SubscriptionController::class, 'status']);

    // 5. Telemetry & Traffic Accounting
    Route::post('/telemetry/session', [TelemetryController::class, 'storeSession']);
    Route::get('/telemetry/summary', [TelemetryController::class, 'summary']);

    // 6. Remote app configuration & feature flags
    Route::get('/app/config', [AppConfigController::class, 'config']);
});
