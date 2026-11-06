<?php

namespace Tests\Feature;

use App\Models\Configuration;
use App\Models\Device;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ConfigApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_public_configurations(): void
    {
        Configuration::create([
            'name' => 'Fast Stealth Config',
            'protocol' => 'ovpn',
            'config_data' => 'client\ndev tun\nproto tcp',
            'is_public' => true,
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/v1/configs');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    [
                        'name' => 'Fast Stealth Config',
                        'protocol' => 'ovpn',
                    ],
                ],
            ]);
    }

    public function test_can_upload_and_share_configuration(): void
    {
        $device = Device::create([
            'device_uuid' => 'cfg-test-device-uuid',
            'is_active' => true,
        ]);

        $payload = [
            'name' => 'My Custom Config',
            'description' => 'Test tunnel config',
            'protocol' => 'ovpn',
            'config_data' => 'client\ndev tun\nremote 1.2.3.4 1194',
            'is_public' => true,
        ];

        $response = $this->withHeader('X-Device-UUID', $device->device_uuid)
            ->postJson('/api/v1/configs', $payload);

        $response->assertStatus(201)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'name' => 'My Custom Config',
                    'protocol' => 'ovpn',
                ],
            ]);

        $this->assertNotEmpty($response->json('data.share_code'));
        $this->assertDatabaseHas('configurations', [
            'name' => 'My Custom Config',
            'device_id' => $device->id,
        ]);
    }

    public function test_can_import_config_by_share_code(): void
    {
        $config = Configuration::create([
            'name' => 'Share Code Test',
            'protocol' => 'ovpn',
            'config_data' => 'client\ndev tun\nproto udp',
            'share_code' => 'TESTCODE',
            'is_public' => true,
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/v1/configs/share/TESTCODE');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'name' => 'Share Code Test',
                    'share_code' => 'TESTCODE',
                ],
            ]);

        $config->refresh();
        $this->assertEquals(1, $config->downloads_count);
    }
}
