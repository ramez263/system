<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AppConfigTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_fetch_remote_configuration(): void
    {
        $response = $this->getJson('/api/v1/app/config');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'min_app_version' => '1.0.0',
                    'force_update' => false,
                    'maintenance_mode' => false,
                    'features' => [
                        'custom_config_import' => true,
                        'split_tunneling' => true,
                        'kill_switch' => true,
                    ],
                ],
            ]);
    }
}
