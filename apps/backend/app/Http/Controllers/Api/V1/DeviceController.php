<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Device;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeviceController extends Controller
{
    /**
     * Handshake endpoint - registers or refreshes device identity.
     * No registration or login credentials required.
     */
    public function handshake(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'device_uuid' => 'required|string|max:64',
            'device_name' => 'nullable|string|max:100',
            'model' => 'nullable|string|max:100',
            'os_version' => 'nullable|string|max:50',
            'app_version' => 'nullable|string|max:50',
            'platform' => 'nullable|string|max:30',
        ]);

        $device = Device::updateOrCreate(
            ['device_uuid' => $validated['device_uuid']],
            [
                'device_name' => $validated['device_name'] ?? 'Unknown Device',
                'model' => $validated['model'] ?? null,
                'os_version' => $validated['os_version'] ?? null,
                'app_version' => $validated['app_version'] ?? null,
                'platform' => $validated['platform'] ?? 'android',
                'is_active' => true,
                'last_handshake_at' => now(),
            ]
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Device handshake successful.',
            'data' => [
                'device_uuid' => $device->device_uuid,
                'is_active' => $device->is_active,
                'tier' => 'free',
                'max_devices' => 1,
                'daily_bandwidth_limit_bytes' => 0, // 0 = unlimited
                'last_handshake_at' => $device->last_handshake_at->toISOString(),
            ],
            'meta' => [
                'timestamp' => now()->toISOString(),
                'api_version' => '1.0.0',
            ],
        ]);
    }
}
