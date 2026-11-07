<?php

use App\Http\Controllers\Admin\AdminAnnouncementController;
use App\Http\Controllers\Admin\AdminAuditLogController;
use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\AdminConfigurationController;
use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Admin\AdminDeviceController;
use App\Http\Controllers\Admin\AdminPlanController;
use App\Http\Controllers\Admin\AdminRemoteConfigController;
use App\Http\Controllers\Admin\AdminServerController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect('/admin');
});

// Admin Authentication (Public)
Route::prefix('admin')->group(function () {
    Route::get('/login', [AdminAuthController::class, 'showLogin'])->name('admin.login');
    Route::post('/login', [AdminAuthController::class, 'login'])->name('admin.login.submit');
    Route::post('/logout', [AdminAuthController::class, 'logout'])->name('admin.logout');
});

// Admin Control Plane (Protected by admin.auth)
Route::prefix('admin')->middleware(['admin.auth'])->group(function () {
    // 1. Dashboard & Analytics
    Route::get('/', [AdminDashboardController::class, 'index'])->name('admin.dashboard');
    Route::get('/analytics', [AdminDashboardController::class, 'analytics'])->name('admin.analytics');

    // 2. Hardware Devices Management
    Route::get('/devices', [AdminDeviceController::class, 'index'])->name('admin.devices.index');
    Route::get('/devices/{id}', [AdminDeviceController::class, 'show'])->name('admin.devices.show');
    Route::post('/devices/{id}/toggle', [AdminDeviceController::class, 'toggleStatus'])->name('admin.devices.toggle');
    Route::post('/devices/{id}/reset-bandwidth', [AdminDeviceController::class, 'resetBandwidth'])->name('admin.devices.reset_bandwidth');
    Route::delete('/devices/{id}', [AdminDeviceController::class, 'destroy'])->name('admin.devices.destroy');

    // 3. Curated & Dedicated Servers
    Route::get('/servers', [AdminServerController::class, 'index'])->name('admin.servers.index');
    Route::post('/servers', [AdminServerController::class, 'store'])->name('admin.servers.store');
    Route::put('/servers/{id}', [AdminServerController::class, 'update'])->name('admin.servers.update');
    Route::post('/servers/{id}/toggle', [AdminServerController::class, 'toggle'])->name('admin.servers.toggle');
    Route::post('/servers/{id}/probe', [AdminServerController::class, 'probe'])->name('admin.servers.probe');
    Route::delete('/servers/{id}', [AdminServerController::class, 'destroy'])->name('admin.servers.destroy');

    // 4. VPN Configurations & Export Locking
    Route::get('/configurations', [AdminConfigurationController::class, 'index'])->name('admin.configurations.index');
    Route::post('/configurations', [AdminConfigurationController::class, 'store'])->name('admin.configurations.store');
    Route::put('/configurations/{id}', [AdminConfigurationController::class, 'update'])->name('admin.configurations.update');
    Route::post('/configurations/{id}/toggle', [AdminConfigurationController::class, 'toggle'])->name('admin.configurations.toggle');
    Route::delete('/configurations/{id}', [AdminConfigurationController::class, 'destroy'])->name('admin.configurations.destroy');

    // 5. Subscription Plans & Promo Codes
    Route::get('/plans', [AdminPlanController::class, 'index'])->name('admin.plans.index');
    Route::post('/plans', [AdminPlanController::class, 'storePlan'])->name('admin.plans.store');
    Route::put('/plans/{id}', [AdminPlanController::class, 'updatePlan'])->name('admin.plans.update');
    Route::post('/plans/{id}/toggle', [AdminPlanController::class, 'togglePlan'])->name('admin.plans.toggle');
    Route::post('/promo-codes', [AdminPlanController::class, 'storePromo'])->name('admin.promo_codes.store');
    Route::post('/promo-codes/{id}/toggle', [AdminPlanController::class, 'togglePromo'])->name('admin.promo_codes.toggle');
    Route::delete('/promo-codes/{id}', [AdminPlanController::class, 'destroyPromo'])->name('admin.promo_codes.destroy');

    // 6. Broadcast Announcements
    Route::get('/announcements', [AdminAnnouncementController::class, 'index'])->name('admin.announcements.index');
    Route::post('/announcements', [AdminAnnouncementController::class, 'store'])->name('admin.announcements.store');
    Route::post('/announcements/{id}/toggle', [AdminAnnouncementController::class, 'toggle'])->name('admin.announcements.toggle');
    Route::delete('/announcements/{id}', [AdminAnnouncementController::class, 'destroy'])->name('admin.announcements.destroy');

    // 7. Remote Configuration, Feature Flags & App Releases
    Route::get('/remote-config', [AdminRemoteConfigController::class, 'index'])->name('admin.remote_config.index');
    Route::post('/remote-config/settings', [AdminRemoteConfigController::class, 'updateSettings'])->name('admin.remote_config.update');
    Route::post('/remote-config/maintenance', [AdminRemoteConfigController::class, 'toggleMaintenance'])->name('admin.remote_config.maintenance');
    Route::post('/remote-config/releases', [AdminRemoteConfigController::class, 'storeRelease'])->name('admin.remote_config.release');

    // 8. Security Audit Logs
    Route::get('/audit-logs', [AdminAuditLogController::class, 'index'])->name('admin.audit_logs.index');
    Route::post('/audit-logs/purge', [AdminAuditLogController::class, 'purge'])->name('admin.audit_logs.purge');
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
