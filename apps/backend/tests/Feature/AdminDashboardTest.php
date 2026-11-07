<?php

namespace Tests\Feature;

use App\Models\Device;
use App\Models\Server;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminDashboardTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = User::create([
            'name' => 'Test Super Admin',
            'email' => 'admin@test.com',
            'password' => bcrypt('password123'),
            'role' => User::ROLE_SUPER_ADMIN,
            'is_active' => true,
        ]);
    }

    public function test_unauthenticated_user_redirected_to_login(): void
    {
        $response = $this->get('/admin');
        $response->assertRedirect(route('admin.login'));
    }

    public function test_can_load_admin_dashboard(): void
    {
        Device::create([
            'device_uuid' => 'admin-test-dev',
            'is_active' => true,
        ]);

        $response = $this->actingAs($this->admin)->get('/admin');

        $response->assertStatus(200)
            ->assertSee('Ramez Tunnel+')
            ->assertSee('Control Plane Live Telemetry');
    }

    public function test_can_view_and_toggle_server_status(): void
    {
        $server = Server::create([
            'name' => 'Admin Toggle Server',
            'country_code' => 'DE',
            'country_name' => 'Germany',
            'city' => 'Frankfurt',
            'flag_emoji' => '🇩🇪',
            'protocol' => 'ovpn',
            'ip_address' => '9.9.9.9',
            'port' => 1194,
            'is_active' => true,
        ]);

        $response = $this->actingAs($this->admin)->get('/admin/servers');
        $response->assertStatus(200)->assertSee('Admin Toggle Server');

        // Toggle to disabled
        $toggleResponse = $this->actingAs($this->admin)->post("/admin/servers/{$server->id}/toggle");
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

        $response = $this->actingAs($this->admin)->get('/admin/devices?search=Pixel');

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
