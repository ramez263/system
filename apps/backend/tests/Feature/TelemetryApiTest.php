<?php

namespace Tests\Feature;

use App\Models\Device;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TelemetryApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_log_session_and_accumulate_device_bandwidth(): void
    {
        $device = Device::create([
            'device_uuid' => 'telemetry-device-uuid',
            'is_active' => true,
            'bytes_uploaded' => 100,
            'bytes_downloaded' => 200,
        ]);

        $payload = [
            'session_uuid' => 'session-uuid-999',
            'protocol' => 'ovpn',
            'bytes_in' => 5000,
            'bytes_out' => 2000,
            'duration_seconds' => 120,
            'disconnect_reason' => 'user_disconnect',
        ];

        $response = $this->withHeader('X-Device-UUID', $device->device_uuid)
            ->postJson('/api/v1/telemetry/session', $payload);

        $response->assertStatus(201)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'session_uuid' => 'session-uuid-999',
                    'bytes_in' => 5000,
                    'bytes_out' => 2000,
                    'device_total_downloaded' => 5200,
                    'device_total_uploaded' => 2100,
                ],
            ]);

        $device->refresh();
        $this->assertEquals(5200, $device->bytes_downloaded);
        $this->assertEquals(2100, $device->bytes_uploaded);
    }

    public function test_can_retrieve_device_telemetry_summary(): void
    {
        $device = Device::create([
            'device_uuid' => 'summary-device-uuid',
            'is_active' => true,
            'bytes_uploaded' => 1048576,
            'bytes_downloaded' => 5242880,
        ]);

        $response = $this->withHeader('X-Device-UUID', $device->device_uuid)
            ->getJson('/api/v1/telemetry/summary');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'device_uuid' => 'summary-device-uuid',
                    'bytes_uploaded' => 1048576,
                    'bytes_downloaded' => 5242880,
                    'total_bytes_transferred' => 6291456,
                ],
            ]);
    }
}
