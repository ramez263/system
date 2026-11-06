<?php

namespace Tests\Feature;

use Tests\TestCase;

class AppConfigTest extends TestCase
{
    public function test_can_fetch_remote_configuration(): void
    {
        $response = $this->getJson('/api/v1/app/config');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'min_supported_version' => '1.0.0',
                    'force_update' => false,
                    'features' => [
                        'enable_openvpn' => true,
                        'enable_singbox' => true,
                    ],
                ],
            ]);
    }
}
