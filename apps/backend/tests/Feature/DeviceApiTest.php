<?php

namespace Tests\Feature;

use App\Models\Device;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DeviceApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_device_can_perform_handshake_without_credentials(): void
    {
        $payload = [
            'device_uuid' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'device_name' => 'Pixel 8 Pro',
            'model' => 'Pixel 8',
            'os_version' => 'Android 14',
            'app_version' => '1.0.0+1',
            'platform' => 'android',
        ];

        $response = $this->postJson('/api/v1/devices/handshake', $payload);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'device_uuid' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
                    'is_active' => true,
                    'tier' => 'free',
                ],
            ]);

        $this->assertDatabaseHas('devices', [
            'device_uuid' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'device_name' => 'Pixel 8 Pro',
        ]);
    }

    public function test_subsequent_handshake_updates_last_handshake_timestamp(): void
    {
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';

        $this->postJson('/api/v1/devices/handshake', ['device_uuid' => $uuid]);

        $response = $this->postJson('/api/v1/devices/handshake', [
            'device_uuid' => $uuid,
            'app_version' => '1.0.1+2',
        ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('devices', [
            'device_uuid' => $uuid,
            'app_version' => '1.0.1+2',
        ]);
    }

    public function test_can_retrieve_device_profile_via_x_device_uuid_header(): void
    {
        $device = Device::create([
            'device_uuid' => 'test-device-uuid-123',
            'device_name' => 'Galaxy S23',
            'model' => 'SM-S911B',
            'os_version' => 'Android 14',
            'is_active' => true,
        ]);

        $response = $this->withHeader('X-Device-UUID', $device->device_uuid)
            ->getJson('/api/v1/devices/me');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'device_uuid' => 'test-device-uuid-123',
                    'device_name' => 'Galaxy S23',
                ],
            ]);
    }

    public function test_can_update_device_push_token(): void
    {
        $device = Device::create([
            'device_uuid' => 'test-device-uuid-456',
            'device_name' => 'Xiaomi 13',
            'is_active' => true,
        ]);

        $response = $this->withHeader('X-Device-UUID', $device->device_uuid)
            ->postJson('/api/v1/devices/push-token', [
                'push_token' => 'fcm-token-sample-value-789',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'push_token_saved' => true,
                ],
            ]);

        $this->assertDatabaseHas('devices', [
            'device_uuid' => 'test-device-uuid-456',
            'push_token' => 'fcm-token-sample-value-789',
        ]);
    }
}
