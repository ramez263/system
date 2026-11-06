<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\HandshakeRequest;
use App\Http\Requests\Api\V1\UpdatePushTokenRequest;
use App\Models\Device;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeviceController extends Controller
{
    /**
     * Handshake endpoint - registers or refreshes device identity.
     * No registration or login credentials required.
     */
    public function handshake(HandshakeRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $device = Device::updateOrCreate(
            ['device_uuid' => $validated['device_uuid']],
            [
                'device_name' => $validated['device_name'] ?? 'Android Device',
                'model' => $validated['model'] ?? null,
                'os_version' => $validated['os_version'] ?? null,
                'app_version' => $validated['app_version'] ?? null,
                'platform' => $validated['platform'] ?? 'android',
                'push_token' => $validated['push_token'] ?? null,
                'is_active' => true,
                'last_handshake_at' => now(),
            ]
        );

        $subscription = $device->activeSubscription;
        $isPremium = $device->is_premium || ($subscription !== null && $subscription->isValid());

        return response()->json([
            'status' => 'success',
            'message' => 'Device handshake successful.',
            'data' => [
                'device_uuid' => $device->device_uuid,
                'device_name' => $device->device_name,
                'is_active' => $device->is_active,
                'is_premium' => $isPremium,
                'tier' => $isPremium ? 'pro' : 'free',
                'max_devices' => $isPremium ? 5 : 1,
                'daily_bandwidth_limit_bytes' => $isPremium ? 0 : 5368709120, // 5GB for free, 0 for unlimited
                'bytes_uploaded' => $device->bytes_uploaded,
                'bytes_downloaded' => $device->bytes_downloaded,
                'last_handshake_at' => $device->last_handshake_at?->toIso8601String(),
                'active_subscription' => $subscription ? [
                    'plan' => $subscription->plan?->name,
                    'status' => $subscription->status,
                    'expires_at' => $subscription->expires_at?->toIso8601String(),
                ] : null,
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
                'api_version' => '1.0.0',
            ],
        ]);
    }

    /**
     * Returns details of the current device identified by X-Device-UUID header.
     */
    public function me(Request $request): JsonResponse
    {
        $deviceUuid = $request->header('X-Device-UUID') ?? $request->query('device_uuid');
        if (!$deviceUuid) {
            return response()->json([
                'status' => 'error',
                'message' => 'Missing X-Device-UUID header.',
                'data' => null,
                'errors' => ['device_uuid' => ['Header X-Device-UUID is required.']],
            ], 400);
        }

        $device = Device::where('device_uuid', $deviceUuid)->first();
        if (!$device) {
            return response()->json([
                'status' => 'error',
                'message' => 'Device not found.',
                'data' => null,
                'errors' => null,
            ], 404);
        }

        $subscription = $device->activeSubscription;
        $isPremium = $device->is_premium || ($subscription !== null && $subscription->isValid());

        return response()->json([
            'status' => 'success',
            'message' => 'Device profile retrieved.',
            'data' => [
                'device_uuid' => $device->device_uuid,
                'device_name' => $device->device_name,
                'model' => $device->model,
                'os_version' => $device->os_version,
                'app_version' => $device->app_version,
                'platform' => $device->platform,
                'is_active' => $device->is_active,
                'is_premium' => $isPremium,
                'tier' => $isPremium ? 'pro' : 'free',
                'bytes_uploaded' => $device->bytes_uploaded,
                'bytes_downloaded' => $device->bytes_downloaded,
                'last_handshake_at' => $device->last_handshake_at?->toIso8601String(),
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * Updates device FCM push notification token.
     */
    public function updatePushToken(UpdatePushTokenRequest $request): JsonResponse
    {
        $deviceUuid = $request->header('X-Device-UUID') ?? $request->input('device_uuid');
        if (!$deviceUuid) {
            return response()->json([
                'status' => 'error',
                'message' => 'Missing X-Device-UUID header.',
                'data' => null,
                'errors' => ['device_uuid' => ['Header X-Device-UUID is required.']],
            ], 400);
        }

        $device = Device::where('device_uuid', $deviceUuid)->first();
        if (!$device) {
            return response()->json([
                'status' => 'error',
                'message' => 'Device not found.',
                'data' => null,
                'errors' => null,
            ], 404);
        }

        $device->update(['push_token' => $request->validated('push_token')]);

        return response()->json([
            'status' => 'success',
            'message' => 'Push token updated successfully.',
            'data' => [
                'device_uuid' => $device->device_uuid,
                'push_token_saved' => true,
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }
}
