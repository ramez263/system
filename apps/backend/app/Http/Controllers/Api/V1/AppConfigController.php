<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use Illuminate\Http\JsonResponse;

class AppConfigController extends Controller
{
    /**
     * Remote configuration, feature flags, and kill-switch defaults.
     */
    public function config(): JsonResponse
    {
        $minVersion = AppSetting::get('min_app_version', '1.0.0');
        $forceUpdate = (bool) AppSetting::get('force_update', false);
        $maintenance = (bool) AppSetting::get('maintenance_mode', false);
        $announcementAr = AppSetting::get('announcement_ar', 'مرحباً بك في رامز تنل بلس');
        $announcementEn = AppSetting::get('announcement_en', 'Welcome to Ramez Tunnel Plus');
        $defaultDns = AppSetting::get('default_dns_servers', ['1.1.1.1', '1.0.0.1', '8.8.8.8']);
        $killSwitchDefault = (bool) AppSetting::get('kill_switch_default', false);

        return response()->json([
            'status' => 'success',
            'message' => 'App configuration retrieved successfully.',
            'data' => [
                'min_app_version' => $minVersion,
                'latest_app_version' => '1.0.0',
                'force_update' => $forceUpdate,
                'maintenance_mode' => $maintenance,
                'announcement' => [
                    'ar' => $announcementAr,
                    'en' => $announcementEn,
                ],
                'default_dns_servers' => $defaultDns,
                'kill_switch_default' => $killSwitchDefault,
                'supported_protocols' => [
                    'ovpn',
                    'vless',
                    'vmess',
                    'trojan',
                    'rtp',
                    'ssh',
                ],
                'features' => [
                    'custom_config_import' => true,
                    'split_tunneling' => true,
                    'kill_switch' => true,
                    'dark_mode' => true,
                    'community_sharing' => true,
                ],
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
                'api_version' => '1.0.0',
            ],
        ]);
    }
}
