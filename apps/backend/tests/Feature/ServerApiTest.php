<?php

namespace Tests\Feature;

use App\Models\Server;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ServerApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_fetch_active_server_catalog(): void
    {
        Server::create([
            'name' => 'Frankfurt Test Node',
            'country_code' => 'DE',
            'country_name' => 'Germany',
            'city' => 'Frankfurt',
            'flag_emoji' => '🇩🇪',
            'protocol' => 'ovpn',
            'ip_address' => '185.120.40.12',
            'port' => 1194,
            'ping_ms' => 25,
            'current_load' => 10,
            'is_active' => true,
            'is_premium' => false,
            'ovpn_config' => "client\ndev tun",
        ]);

        $response = $this->getJson('/api/v1/servers');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    [
                        'name' => 'Frankfurt Test Node',
                        'country_code' => 'DE',
                        'protocol' => 'ovpn',
                    ],
                ],
            ]);
    }

    public function test_can_filter_servers_by_country(): void
    {
        Server::create([
            'name' => 'DE Node',
            'country_code' => 'DE',
            'country_name' => 'Germany',
            'flag_emoji' => '🇩🇪',
            'protocol' => 'ovpn',
            'ip_address' => '1.1.1.1',
            'port' => 1194,
            'is_active' => true,
        ]);

        Server::create([
            'name' => 'NL Node',
            'country_code' => 'NL',
            'country_name' => 'Netherlands',
            'flag_emoji' => '🇳🇱',
            'protocol' => 'ovpn',
            'ip_address' => '2.2.2.2',
            'port' => 1194,
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/v1/servers?country=DE');

        $response->assertStatus(200);
        $data = $response->json('data');
        $this->assertCount(1, $data);
        $this->assertEquals('DE', $data[0]['country_code']);
    }

    public function test_can_download_raw_ovpn_configuration(): void
    {
        $server = Server::create([
            'name' => 'London Express Node',
            'country_code' => 'GB',
            'country_name' => 'United Kingdom',
            'flag_emoji' => '🇬🇧',
            'protocol' => 'ovpn',
            'ip_address' => '3.3.3.3',
            'port' => 1194,
            'is_active' => true,
            'ovpn_config' => "client\ndev tun\nproto udp\nremote 3.3.3.3 1194",
        ]);

        $response = $this->get('/api/v1/servers/' . $server->id . '/ovpn');

        $response->assertStatus(200)
            ->assertHeader('Content-Type', 'text/plain; charset=UTF-8')
            ->assertSee("remote 3.3.3.3 1194");
    }

    public function test_can_retrieve_available_countries_aggregation(): void
    {
        Server::create([
            'name' => 'FR Node 1',
            'country_code' => 'FR',
            'country_name' => 'France',
            'flag_emoji' => '🇫🇷',
            'protocol' => 'ovpn',
            'ip_address' => '4.4.4.4',
            'port' => 1194,
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/v1/servers/countries');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ]);

        $countries = $response->json('data');
        $this->assertNotEmpty($countries);
        $this->assertEquals('FR', $countries[0]['country_code']);
    }
}
