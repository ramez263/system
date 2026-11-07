<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AppRelease;
use App\Models\AppSetting;
use App\Models\AuditLog;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdminRemoteConfigController extends Controller
{
    /**
     * Remote config, feature flags, and app releases manager.
     */
    public function index(): View
    {
        $settings = [
            'min_app_version' => AppSetting::get('min_app_version', '1.0.0'),
            'latest_app_version' => AppSetting::get('latest_app_version', '1.0.0'),
            'force_update' => (bool) AppSetting::get('force_update', false),
            'maintenance_mode' => (bool) AppSetting::get('maintenance_mode', false),
            'maintenance_message' => AppSetting::get('maintenance_message', 'Under scheduled infrastructure maintenance. We will be back online shortly.'),
            'announcement_ar' => AppSetting::get('announcement_ar', 'مرحباً بك في رامز تنل بلس'),
            'announcement_en' => AppSetting::get('announcement_en', 'Welcome to Ramez Tunnel Plus'),
            'default_dns_servers' => implode(', ', (array) AppSetting::get('default_dns_servers', ['1.1.1.1', '1.0.0.1', '8.8.8.8'])),
            'kill_switch_default' => (bool) AppSetting::get('kill_switch_default', false),
            'enable_custom_config_import' => (bool) AppSetting::get('enable_custom_config_import', true),
            'enable_split_tunneling' => (bool) AppSetting::get('enable_split_tunneling', true),
        ];

        $releases = AppRelease::latest('build_number')->get();

        return view('admin.remote_config.index', compact('settings', 'releases'));
    }

    /**
     * Update remote config settings & feature flags.
     */
    public function updateSettings(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'min_app_version' => ['required', 'string', 'max:20'],
            'latest_app_version' => ['required', 'string', 'max:20'],
            'force_update' => ['boolean'],
            'maintenance_mode' => ['boolean'],
            'maintenance_message' => ['nullable', 'string', 'max:255'],
            'announcement_ar' => ['nullable', 'string', 'max:255'],
            'announcement_en' => ['nullable', 'string', 'max:255'],
            'default_dns_servers' => ['required', 'string'],
            'kill_switch_default' => ['boolean'],
            'enable_custom_config_import' => ['boolean'],
            'enable_split_tunneling' => ['boolean'],
        ]);

        $dnsList = array_map('trim', explode(',', $validated['default_dns_servers']));

        AppSetting::set('min_app_version', $validated['min_app_version'], 'string');
        AppSetting::set('latest_app_version', $validated['latest_app_version'], 'string');
        AppSetting::set('force_update', $request->boolean('force_update'), 'boolean');
        AppSetting::set('maintenance_mode', $request->boolean('maintenance_mode'), 'boolean');
        AppSetting::set('maintenance_message', $validated['maintenance_message'] ?? '', 'string');
        AppSetting::set('announcement_ar', $validated['announcement_ar'] ?? '', 'string');
        AppSetting::set('announcement_en', $validated['announcement_en'] ?? '', 'string');
        AppSetting::set('default_dns_servers', $dnsList, 'json');
        AppSetting::set('kill_switch_default', $request->boolean('kill_switch_default'), 'boolean');
        AppSetting::set('enable_custom_config_import', $request->boolean('enable_custom_config_import'), 'boolean');
        AppSetting::set('enable_split_tunneling', $request->boolean('enable_split_tunneling'), 'boolean');

        AuditLog::record(
            action: 'remote_config.updated',
            resourceType: 'AppSetting',
            details: [
                'min_version' => $validated['min_app_version'],
                'force_update' => $request->boolean('force_update'),
                'maintenance_mode' => $request->boolean('maintenance_mode'),
            ]
        );

        return redirect()->route('admin.remote_config.index')->with('success', 'Remote configuration and feature flags successfully updated.');
    }

    /**
     * Emergency 1-click maintenance toggle.
     */
    public function toggleMaintenance(): RedirectResponse
    {
        $current = (bool) AppSetting::get('maintenance_mode', false);
        $new = !$current;

        AppSetting::set('maintenance_mode', $new, 'boolean');

        AuditLog::record(
            action: $new ? 'system.maintenance_enabled' : 'system.maintenance_disabled',
            resourceType: 'AppSetting',
            details: ['maintenance_mode' => $new]
        );

        $state = $new ? 'ENABLED' : 'DISABLED';
        return redirect()->back()->with('success', "Maintenance mode is now {$state}.");
    }

    /**
     * Store new application release version.
     */
    public function storeRelease(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'version' => ['required', 'string', 'max:20'],
            'build_number' => ['required', 'integer', 'min:1'],
            'platform' => ['required', 'string', 'in:android,ios'],
            'min_supported_version' => ['required', 'string', 'max:20'],
            'force_update' => ['boolean'],
            'download_url' => ['nullable', 'url', 'max:500'],
            'release_notes' => ['nullable', 'string'],
        ]);

        $validated['force_update'] = $request->boolean('force_update');
        $validated['is_active'] = true;

        $release = AppRelease::create($validated);

        // Synchronize with AppSetting
        AppSetting::set('latest_app_version', $release->version, 'string');
        AppSetting::set('min_app_version', $release->min_supported_version, 'string');
        if ($release->force_update) {
            AppSetting::set('force_update', true, 'boolean');
        }

        AuditLog::record(
            action: 'app_release.created',
            resourceType: 'AppRelease',
            resourceId: $release->id,
            details: [
                'version' => $release->version,
                'build_number' => $release->build_number,
                'force_update' => $release->force_update,
            ]
        );

        return redirect()->route('admin.remote_config.index')->with('success', "App release v{$release->version} (Build {$release->build_number}) published.");
    }
}
