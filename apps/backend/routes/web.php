<?php

use App\Http\Controllers\Admin\AdminDashboardController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect('/admin');
});

// Admin Panel MVP
Route::prefix('admin')->group(function () {
    Route::get('/', [AdminDashboardController::class, 'index'])->name('admin.dashboard');
    Route::get('/servers', [AdminDashboardController::class, 'servers'])->name('admin.servers');
    Route::post('/servers/{id}/toggle', [AdminDashboardController::class, 'toggleServer'])->name('admin.servers.toggle');
    Route::get('/devices', [AdminDashboardController::class, 'devices'])->name('admin.devices');
});

// Interactive API Documentation (Swagger UI)
Route::get('/api/documentation', function () {
    return view('docs.swagger');
});

Route::get('/docs/openapi.json', function () {
    $path = base_path('../../docs/openapi.json');
    if (!file_exists($path)) {
        abort(404, 'OpenAPI specification not found.');
    }
    return response()->file($path, ['Content-Type' => 'application/json']);
});
