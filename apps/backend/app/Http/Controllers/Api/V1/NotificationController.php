<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Announcement;
use App\Models\Device;
use App\Models\DeviceNotificationPreference;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * Get notification preferences for the device.
     */
    public function preferences(Request $request): JsonResponse
    {
        $device = $this->resolveDevice($request);
        if (!$device) {
            return $this->deviceNotFoundResponse();
        }

        $prefs = DeviceNotificationPreference::firstOrCreate(
            ['device_id' => $device->id],
            [
                'notify_connection' => true,
                'notify_disconnection' => true,
                'notify_server_failure' => true,
                'notify_subscription_expiry' => true,
                'notify_security_alerts' => true,
                'notify_updates' => true,
                'notify_promotions' => false,
            ]
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Notification preferences retrieved.',
            'data' => [
                'notify_connection' => (bool) $prefs->notify_connection,
                'notify_disconnection' => (bool) $prefs->notify_disconnection,
                'notify_server_failure' => (bool) $prefs->notify_server_failure,
                'notify_subscription_expiry' => (bool) $prefs->notify_subscription_expiry,
                'notify_security_alerts' => (bool) $prefs->notify_security_alerts,
                'notify_updates' => (bool) $prefs->notify_updates,
                'notify_promotions' => (bool) $prefs->notify_promotions,
            ],
            'meta' => ['timestamp' => now()->toIso8601String()],
        ]);
    }

    /**
     * Update notification preferences for the device.
     */
    public function updatePreferences(Request $request): JsonResponse
    {
        $device = $this->resolveDevice($request);
        if (!$device) {
            return $this->deviceNotFoundResponse();
        }

        $validated = $request->validate([
            'notify_connection' => ['sometimes', 'boolean'],
            'notify_disconnection' => ['sometimes', 'boolean'],
            'notify_server_failure' => ['sometimes', 'boolean'],
            'notify_subscription_expiry' => ['sometimes', 'boolean'],
            'notify_security_alerts' => ['sometimes', 'boolean'],
            'notify_updates' => ['sometimes', 'boolean'],
            'notify_promotions' => ['sometimes', 'boolean'],
        ]);

        $prefs = DeviceNotificationPreference::updateOrCreate(
            ['device_id' => $device->id],
            $validated
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Notification preferences updated.',
            'data' => $prefs,
            'meta' => ['timestamp' => now()->toIso8601String()],
        ]);
    }

    /**
     * List active system announcements and broadcast alerts.
     */
    public function announcements(Request $request): JsonResponse
    {
        $device = $this->resolveDevice($request);
        $tier = ($device && $device->is_premium) ? 'pro' : 'free';

        $announcements = Announcement::active()
            ->where(function ($q) use ($tier) {
                $q->whereNull('target_tier')
                  ->orWhere('target_tier', $tier);
            })
            ->orderBy('created_at', 'desc')
            ->limit(20)
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'Announcements retrieved.',
            'data' => $announcements->map(function (Announcement $item) {
                return [
                    'id' => $item->id,
                    'title' => $item->title,
                    'body' => $item->body,
                    'category' => $item->category,
                    'icon' => $item->icon,
                    'action_url' => $item->action_url,
                    'time' => $item->created_at->diffForHumans(),
                    'created_at' => $item->created_at->toIso8601String(),
                ];
            }),
            'meta' => ['timestamp' => now()->toIso8601String()],
        ]);
    }

    /**
     * Test notification dispatch endpoint for verification.
     */
    public function testDispatch(Request $request): JsonResponse
    {
        $device = $this->resolveDevice($request);
        if (!$device) {
            return $this->deviceNotFoundResponse();
        }

        $category = $request->input('category', 'security_alerts');
        $title = $request->input('title', 'Security Check Completed');
        $body = $request->input('body', 'DNS leak protection and split tunneling active.');

        return response()->json([
            'status' => 'success',
            'message' => 'Test notification dispatched.',
            'data' => [
                'device_uuid' => $device->device_uuid,
                'push_token_present' => !empty($device->push_token),
                'category' => $category,
                'title' => $title,
                'body' => $body,
                'dispatched_at' => now()->toIso8601String(),
            ],
            'meta' => ['timestamp' => now()->toIso8601String()],
        ]);
    }

    protected function resolveDevice(Request $request): ?Device
    {
        $deviceUuid = $request->header('X-Device-UUID') ?? $request->query('device_uuid') ?? $request->input('device_uuid');
        if (!$deviceUuid) {
            return null;
        }

        return Device::where('device_uuid', $deviceUuid)->first();
    }

    protected function deviceNotFoundResponse(): JsonResponse
    {
        return response()->json([
            'status' => 'error',
            'message' => 'Device not found. Ensure X-Device-UUID header is supplied.',
            'data' => null,
        ], 404);
    }
}
