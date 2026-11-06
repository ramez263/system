<?php

namespace Database\Seeders;

use App\Models\Server;
use Illuminate\Database\Seeder;

class ServerSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $servers = [
            [
                'name' => 'Frankfurt Fast OpenVPN 01',
                'country_code' => 'DE',
                'country_name' => 'Germany',
                'city' => 'Frankfurt',
                'flag_emoji' => '🇩🇪',
                'protocol' => 'ovpn',
                'ip_address' => '185.120.40.12',
                'port' => 1194,
                'ping_ms' => 28,
                'current_load' => 22,
                'is_active' => true,
                'is_premium' => false,
                'ovpn_config' => "client\ndev tun\nproto udp\nremote 185.120.40.12 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\nverb 3",
            ],
            [
                'name' => 'Amsterdam Ultra OpenVPN 01',
                'country_code' => 'NL',
                'country_name' => 'Netherlands',
                'city' => 'Amsterdam',
                'flag_emoji' => '🇳🇱',
                'protocol' => 'ovpn',
                'ip_address' => '194.36.144.50',
                'port' => 1194,
                'ping_ms' => 32,
                'current_load' => 35,
                'is_active' => true,
                'is_premium' => false,
                'ovpn_config' => "client\ndev tun\nproto udp\nremote 194.36.144.50 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\nverb 3",
            ],
            [
                'name' => 'London Express OpenVPN 01',
                'country_code' => 'GB',
                'country_name' => 'United Kingdom',
                'city' => 'London',
                'flag_emoji' => '🇬🇧',
                'protocol' => 'ovpn',
                'ip_address' => '89.238.150.10',
                'port' => 1194,
                'ping_ms' => 39,
                'current_load' => 18,
                'is_active' => true,
                'is_premium' => false,
                'ovpn_config' => "client\ndev tun\nproto udp\nremote 89.238.150.10 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\nverb 3",
            ],
            [
                'name' => 'New York East OpenVPN 01',
                'country_code' => 'US',
                'country_name' => 'United States',
                'city' => 'New York',
                'flag_emoji' => '🇺🇸',
                'protocol' => 'ovpn',
                'ip_address' => '198.51.100.88',
                'port' => 1194,
                'ping_ms' => 95,
                'current_load' => 40,
                'is_active' => true,
                'is_premium' => false,
                'ovpn_config' => "client\ndev tun\nproto udp\nremote 198.51.100.88 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\nverb 3",
            ],
            [
                'name' => 'Singapore Asia Hub 01',
                'country_code' => 'SG',
                'country_name' => 'Singapore',
                'city' => 'Singapore',
                'flag_emoji' => '🇸🇬',
                'protocol' => 'ovpn',
                'ip_address' => '103.253.14.9',
                'port' => 1194,
                'ping_ms' => 120,
                'current_load' => 25,
                'is_active' => true,
                'is_premium' => false,
                'ovpn_config' => "client\ndev tun\nproto udp\nremote 103.253.14.9 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\nverb 3",
            ],
        ];

        foreach ($servers as $server) {
            Server::updateOrCreate(
                ['name' => $server['name']],
                $server
            );
        }
    }
}
