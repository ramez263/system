<?php

namespace Tests\Feature;

use App\Models\Announcement;
use App\Models\AppRelease;
use App\Models\AppSetting;
use App\Models\AuditLog;
use App\Models\Configuration;
use App\Models\Device;
use App\Models\Plan;
use App\Models\PromoCode;
use App\Models\Server;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminControlPlaneTest extends TestCase
{
    use RefreshDatabase;

    private User $superAdmin;
    private User $viewer;

    protected function setUp(): void
    {
        parent::setUp();

        $this->superAdmin = User::create([
            'name' => 'Super Admin',
            'email' => 'superadmin@rameztunnel.com',
            'password' => bcrypt('secret123'),
            'role' => User::ROLE_SUPER_ADMIN,
            'is_active' => true,
        ]);

        $this->viewer = User::create([
            'name' => 'Viewer Only',
            'email' => 'viewer@rameztunnel.com',
            'password' => bcrypt('secret123'),
            'role' => User::ROLE_READ_ONLY,
            'is_active' => true,
        ]);
    }

    public function test_admin_authentication_and_audit_recording(): void
    {
        // 1. Login with valid credentials
        $response = $this->post(route('admin.login.submit'), [
            'email' => 'superadmin@rameztunnel.com',
            'password' => 'secret123',
        ]);

        $response->assertRedirect(route('admin.dashboard'));
        $this->assertAuthenticatedAs($this->superAdmin);

        // Verify login audit log
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'admin.login',
            'admin_email' => 'superadmin@rameztunnel.com',
        ]);

        // 2. Logout
        $logoutResponse = $this->post(route('admin.logout'));
        $logoutResponse->assertRedirect(route('admin.login'));
        $this->assertGuest();

        // Verify logout audit log
        $this->assertDatabaseHas('audit_logs', [
            'action' => 'admin.logout',
            'admin_email' => 'superadmin@rameztunnel.com',
        ]);
    }

    public function test_suspended_admin_cannot_access(): void
    {
        $suspended = User::create([
            'name' => 'Suspended Staff',
            'email' => 'suspended@rameztunnel.com',
            'password' => bcrypt('secret123'),
            'role' => User::ROLE_SUPPORT,
            'is_active' => false,
        ]);

        $response = $this->post(route('admin.login.submit'), [
            'email' => 'suspended@rameztunnel.com',
            'password' => 'secret123',
        ]);

        $response->assertRedirect(route('admin.login'));
        $this->assertGuest();
    }

    public function test_can_view_analytics_hub(): void
    {
        Server::create([
            'name' => 'Amsterdam Node',
            'country_code' => 'NL',
            'country_name' => 'Netherlands',
            'city' => 'Amsterdam',
            'flag_emoji' => '🇳🇱',
            'protocol' => 'ovpn',
            'ip_address' => '1.2.3.4',
            'port' => 1194,
            'ping_ms' => 28,
            'current_load' => 22,
            'is_active' => true,
        ]);

        $response = $this->actingAs($this->superAdmin)->get(route('admin.analytics'));
        $response->assertStatus(200)
            ->assertSee('Netherlands')
            ->assertSee('Network Usage');
    }

    public function test_device_suspend_reset_bandwidth_and_destroy(): void
    {
        $device = Device::create([
            'device_uuid' => 'test-device-uuid-999',
            'device_name' => 'Pixel 9 Pro',
            'model' => 'Pixel 9 Pro',
            'platform' => 'android',
            'os_version' => '15',
            'bytes_downloaded' => 50000000,
            'bytes_uploaded' => 10000000,
            'is_active' => true,
        ]);

        // 1. View device show page
        $showRes = $this->actingAs($this->superAdmin)->get(route('admin.devices.show', $device->id));
        $showRes->assertStatus(200)->assertSee('test-device-uuid-999');

        // 2. Suspend device
        $suspendRes = $this->actingAs($this->superAdmin)->post(route('admin.devices.toggle', $device->id));
        $suspendRes->assertRedirect();
        $device->refresh();
        $this->assertFalse($device->is_active);
        $this->assertDatabaseHas('audit_logs', ['action' => 'device.suspended']);

        // 3. Reset bandwidth
        $resetRes = $this->actingAs($this->superAdmin)->post(route('admin.devices.reset_bandwidth', $device->id));
        $resetRes->assertRedirect();
        $device->refresh();
        $this->assertEquals(0, $device->bytes_downloaded);
        $this->assertEquals(0, $device->bytes_uploaded);
        $this->assertDatabaseHas('audit_logs', ['action' => 'device.bandwidth_reset']);

        // 4. Destroy device
        $deleteRes = $this->actingAs($this->superAdmin)->delete(route('admin.devices.destroy', $device->id));
        $deleteRes->assertRedirect(route('admin.devices.index'));
        $this->assertDatabaseMissing('devices', ['id' => $device->id]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'device.deleted']);
    }

    public function test_server_crud_and_socket_probe(): void
    {
        // 1. Store Server
        $storeRes = $this->actingAs($this->superAdmin)->post(route('admin.servers.store'), [
            'name' => 'Zurich WireGuard Fast',
            'country_code' => 'CH',
            'country_name' => 'Switzerland',
            'city' => 'Zurich',
            'flag_emoji' => '🇨🇭',
            'protocol' => 'wireguard',
            'ip_address' => '195.201.10.25',
            'port' => 51820,
            'is_premium' => '1',
            'is_active' => '1',
            'ovpn_config' => '[Interface]\nPrivateKey = ...',
        ]);

        $storeRes->assertRedirect(route('admin.servers.index'));
        $server = Server::where('name', 'Zurich WireGuard Fast')->firstOrFail();
        $this->assertTrue($server->is_premium);
        $this->assertEquals('CH', $server->country_code);
        $this->assertDatabaseHas('audit_logs', ['action' => 'server.created']);

        // 2. Trigger probe
        $probeRes = $this->actingAs($this->superAdmin)->post(route('admin.servers.probe', $server->id));
        $probeRes->assertRedirect();
        $server->refresh();
        $this->assertNotNull($server->ping_ms);
        $this->assertDatabaseHas('audit_logs', ['action' => 'server.probed']);

        // 3. Toggle Server
        $toggleRes = $this->actingAs($this->superAdmin)->post(route('admin.servers.toggle', $server->id));
        $toggleRes->assertRedirect();
        $server->refresh();
        $this->assertFalse($server->is_active);

        // 4. Delete Server
        $deleteRes = $this->actingAs($this->superAdmin)->delete(route('admin.servers.destroy', $server->id));
        $deleteRes->assertRedirect(route('admin.servers.index'));
        $this->assertDatabaseMissing('servers', ['id' => $server->id]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'server.deleted']);
    }

    public function test_configuration_creation_and_locking(): void
    {
        $response = $this->actingAs($this->superAdmin)->post(route('admin.configurations.store'), [
            'name' => 'Cairo Orange High Speed',
            'description' => 'Direct TCP tunnel',
            'protocol' => 'ovpn',
            'config_data' => 'client\ndev tun\nproto tcp\nremote 1.1.1.1 443',
            'export_locked' => '1',
            'is_public' => '1',
            'is_active' => '1',
        ]);

        $response->assertRedirect(route('admin.configurations.index'));
        $config = Configuration::where('name', 'Cairo Orange High Speed')->firstOrFail();
        $this->assertTrue($config->export_locked);
        $this->assertNotEmpty($config->share_code);
        $this->assertDatabaseHas('audit_logs', ['action' => 'configuration.created']);

        // Toggle configuration
        $toggleRes = $this->actingAs($this->superAdmin)->post(route('admin.configurations.toggle', $config->id));
        $toggleRes->assertRedirect();
        $config->refresh();
        $this->assertFalse($config->is_active);
    }

    public function test_plans_and_promo_codes_flow(): void
    {
        // 1. Create plan
        $planRes = $this->actingAs($this->superAdmin)->post(route('admin.plans.store'), [
            'name' => 'VIP Lifetime Pass',
            'slug' => 'vip-lifetime',
            'google_play_product_id' => 'rtp_vip_lifetime',
            'description' => 'Unlimited VPN forever',
            'price_cents' => 9999,
            'currency' => 'USD',
            'duration_days' => 3650,
            'features' => 'All Nodes, Zero Logs, Ultra Fast',
            'is_featured' => '1',
            'is_active' => '1',
        ]);

        $planRes->assertRedirect(route('admin.plans.index'));
        $plan = Plan::where('slug', 'vip-lifetime')->firstOrFail();
        $this->assertEquals(9999, $plan->price_cents);
        $this->assertDatabaseHas('audit_logs', ['action' => 'plan.created']);

        // 2. Create promo voucher
        $promoRes = $this->actingAs($this->superAdmin)->post(route('admin.promo_codes.store'), [
            'code' => 'SUPERDEV2026',
            'plan_id' => $plan->id,
            'description' => 'Dev voucher',
            'duration_days' => 60,
            'max_uses' => 50,
            'expires_at' => now()->addDays(30)->toDateString(),
        ]);

        $promoRes->assertRedirect(route('admin.plans.index'));
        $promo = PromoCode::where('code', 'SUPERDEV2026')->firstOrFail();
        $this->assertEquals(60, $promo->duration_days);
        $this->assertDatabaseHas('audit_logs', ['action' => 'promo_code.created']);

        // Toggle promo
        $toggleRes = $this->actingAs($this->superAdmin)->post(route('admin.promo_codes.toggle', $promo->id));
        $toggleRes->assertRedirect();
        $promo->refresh();
        $this->assertFalse($promo->is_active);
    }

    public function test_announcements_broadcast(): void
    {
        $response = $this->actingAs($this->superAdmin)->post(route('admin.announcements.store'), [
            'title' => 'Critical Protocol Update',
            'body' => 'Please restart your VPN connection to apply the newest cipher.',
            'category' => 'security',
            'target_tier' => 'all',
            'action_url' => 'https://t.me/rameztunnel',
            'is_active' => '1',
        ]);

        $response->assertRedirect(route('admin.announcements.index'));
        $ann = Announcement::where('title', 'Critical Protocol Update')->firstOrFail();
        $this->assertEquals('security', $ann->category);
        $this->assertDatabaseHas('audit_logs', ['action' => 'announcement.created']);
    }

    public function test_remote_config_and_emergency_maintenance_toggle(): void
    {
        // 1. Update settings
        $settingsRes = $this->actingAs($this->superAdmin)->post(route('admin.remote_config.update'), [
            'min_app_version' => '1.2.5',
            'latest_app_version' => '1.3.0',
            'force_update' => '1',
            'maintenance_mode' => '0',
            'maintenance_message' => 'Servers undergoing maintenance',
            'announcement_ar' => 'تحديث مهم للخدمة',
            'announcement_en' => 'Important service update',
            'default_dns_servers' => '9.9.9.9, 149.112.112.112',
            'kill_switch_default' => '1',
            'enable_custom_config_import' => '1',
            'enable_split_tunneling' => '1',
        ]);

        $settingsRes->assertRedirect(route('admin.remote_config.index'));
        $this->assertEquals('1.2.5', AppSetting::get('min_app_version'));
        $this->assertTrue(AppSetting::get('force_update'));
        $this->assertEquals(['9.9.9.9', '149.112.112.112'], AppSetting::get('default_dns_servers'));

        // 2. Emergency maintenance toggle
        $maintRes = $this->actingAs($this->superAdmin)->post(route('admin.remote_config.maintenance'));
        $maintRes->assertRedirect();
        $this->assertTrue((bool) AppSetting::get('maintenance_mode'));
        $this->assertDatabaseHas('audit_logs', ['action' => 'system.maintenance_enabled']);

        // 3. Publish app release
        $releaseRes = $this->actingAs($this->superAdmin)->post(route('admin.remote_config.release'), [
            'version' => '1.3.0',
            'build_number' => 15,
            'platform' => 'android',
            'min_supported_version' => '1.2.0',
            'force_update' => '1',
            'download_url' => 'https://play.google.com/store/apps/details?id=com.rameztunnel.plus',
            'release_notes' => 'Ultra fast OpenVPN protocol support',
        ]);

        $releaseRes->assertRedirect(route('admin.remote_config.index'));
        $this->assertDatabaseHas('app_releases', [
            'version' => '1.3.0',
            'build_number' => 15,
            'force_update' => true,
        ]);
    }

    public function test_audit_logs_view_and_purge(): void
    {
        // Generate an audit log
        AuditLog::record(
            action: 'test.purge_target',
            details: ['test' => true]
        );

        $viewRes = $this->actingAs($this->superAdmin)->get(route('admin.audit_logs.index'));
        $viewRes->assertStatus(200)
            ->assertSee('test.purge_target');

        // Test purge
        $purgeRes = $this->actingAs($this->superAdmin)->post(route('admin.audit_logs.purge'));
        $purgeRes->assertRedirect(route('admin.audit_logs.index'));
        $this->assertDatabaseHas('audit_logs', ['action' => 'audit_log.purged']);
    }
}
