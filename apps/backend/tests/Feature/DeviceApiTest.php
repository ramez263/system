<?php

namespace Tests\Feature;

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
}
