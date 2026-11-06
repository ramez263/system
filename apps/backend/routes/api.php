<?php

use App\Http\Controllers\Api\V1\AppConfigController;
use App\Http\Controllers\Api\V1\DeviceController;
use App\Http\Controllers\Api\V1\ServerController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    // Device identity handshake (No registration/login required)
    Route::post('/devices/handshake', [DeviceController::class, 'handshake']);

    // Curated OpenVPN & proxy server pool
    Route::get('/servers', [ServerController::class, 'index']);

    // Remote app configuration & feature flags
    Route::get('/app/config', [AppConfigController::class, 'config']);
});
