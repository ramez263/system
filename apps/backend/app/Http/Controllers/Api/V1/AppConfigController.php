<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AppConfigController extends Controller
{
    /**
     * Returns remote config, feature flags, and version policies.
     */
    public function config(Request $request): JsonResponse
    {
        return response()->json([
            'status' => 'success',
            'message' => 'App configuration retrieved successfully.',
            'data' => [
                'min_supported_version' => '1.0.0',
                'latest_version' => '1.0.0',
                'force_update' => false,
                'maintenance_mode' => false,
                'maintenance_message' => null,
                'features' => [
                    'enable_openvpn' => true,
                    'enable_singbox' => true,
                    'enable_config_import' => true,
                    'enable_speed_test' => true,
                    'enable_split_tunneling' => true,
                ],
                'default_protocol' => 'ovpn',
                'support_email' => 'support@rameztunnel.com',
            ],
            'meta' => [
                'timestamp' => now()->toISOString(),
            ],
        ]);
    }
}
