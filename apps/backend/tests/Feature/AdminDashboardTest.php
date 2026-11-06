<?php

namespace Tests\Feature;

use App\Models\Device;
use App\Models\Server;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminDashboardTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_load_admin_dashboard(): void
    {
        Device::create([
            'device_uuid' => 'admin-test-dev',
            'is_active' => true,
        ]);

        $response = $this->get('/admin');

        $response->assertStatus(200)
            ->assertSee('Ramez Tunnel Plus')
            ->assertSee('Control Plane Admin MVP');
    }

    public function test_can_view_and_toggle_server_status(): void
    {
        $server = Server::create([
            'name' => 'Admin Toggle Server',
            'country_code' => 'DE',
            'country_name' => 'Germany',
            'flag_emoji' => '🇩🇪',
            'protocol' => 'ovpn',
            'ip_address' => '9.9.9.9',
            'port' => 1194,
            'is_active' => true,
        ]);

        $response = $this->get('/admin/servers');
        $response->assertStatus(200)->assertSee('Admin Toggle Server');

        // Toggle to disabled
        $toggleResponse = $this->post("/admin/servers/{$server->id}/toggle");
        $toggleResponse->assertRedirect();

        $server->refresh();
        $this->assertFalse($server->is_active);
    }

    public function test_can_load_devices_explorer(): void
    {
        Device::create([
            'device_uuid' => 'searchable-device-uuid',
            'device_name' => 'Pixel Explorer',
            'is_active' => true,
        ]);

        $response = $this->get('/admin/devices?search=Pixel');

        $response->assertStatus(200)
            ->assertSee('searchable-device-uuid')
            ->assertSee('Pixel Explorer');
    }

    public function test_can_load_api_documentation_viewer(): void
    {
        $response = $this->get('/api/documentation');

        $response->assertStatus(200)
            ->assertSee('SwaggerUIBundle');
    }
}
