<?php

namespace Tests\Feature;

use App\Models\Announcement;
use App\Models\Device;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NotificationApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_get_default_notification_preferences(): void
    {
        $device = Device::create([
            'device_uuid' => 'notif-device-uuid',
            'is_active' => true,
        ]);

        $response = $this->withHeader('X-Device-UUID', $device->device_uuid)
            ->getJson('/api/v1/notifications/preferences');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'notify_connection' => true,
                    'notify_disconnection' => true,
                    'notify_server_failure' => true,
                    'notify_subscription_expiry' => true,
                    'notify_security_alerts' => true,
                    'notify_updates' => true,
                    'notify_promotions' => false,
                ],
            ]);
    }

    public function test_can_update_notification_preferences(): void
    {
        $device = Device::create([
            'device_uuid' => 'notif-update-device',
            'is_active' => true,
        ]);

        $payload = [
            'notify_connection' => false,
            'notify_promotions' => true,
        ];

        $response = $this->withHeader('X-Device-UUID', $device->device_uuid)
            ->postJson('/api/v1/notifications/preferences', $payload);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ]);

        $this->assertDatabaseHas('device_notification_preferences', [
            'device_id' => $device->id,
            'notify_connection' => false,
            'notify_promotions' => true,
        ]);
    }

    public function test_can_get_active_announcements(): void
    {
        Announcement::create([
            'title' => 'Important Maintenance',
            'body' => 'Server upgrades tonight at 02:00 UTC.',
            'category' => 'server_failure',
            'icon' => 'warning',
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/v1/notifications/announcements');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    [
                        'title' => 'Important Maintenance',
                        'category' => 'server_failure',
                    ],
                ],
            ]);
    }

    public function test_can_dispatch_test_notification(): void
    {
        $device = Device::create([
            'device_uuid' => 'dispatch-device-uuid',
            'push_token' => 'mock_fcm_token_123',
            'is_active' => true,
        ]);

        $response = $this->withHeader('X-Device-UUID', $device->device_uuid)
            ->postJson('/api/v1/notifications/test-dispatch', [
                'category' => 'security_alerts',
                'title' => 'Leak Check Passed',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'device_uuid' => 'dispatch-device-uuid',
                    'push_token_present' => true,
                    'category' => 'security_alerts',
                    'title' => 'Leak Check Passed',
                ],
            ]);
    }
}
