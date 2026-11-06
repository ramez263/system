<?php

namespace Database\Seeders;

use App\Models\Configuration;
use App\Models\Server;
use Illuminate\Database\Seeder;

class ConfigurationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $serverDe = Server::where('country_code', 'DE')->first();
        $serverNl = Server::where('country_code', 'NL')->first();

        $configs = [
            [
                'name' => 'Fast EU UDP Bypass',
                'description' => 'Low-latency gaming and streaming UDP tunnel with optimized MTU 1400.',
                'protocol' => 'ovpn',
                'config_data' => "client\ndev tun\nproto udp\nremote 185.120.40.12 1194\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\ntun-mtu 1400\nmssfix 1360\nverb 3",
                'share_code' => 'FAST-DE1',
                'is_public' => true,
                'is_active' => true,
                'export_locked' => false,
                'downloads_count' => 124,
                'server_id' => $serverDe?->id,
            ],
            [
                'name' => 'Netherlands TCP Stealth',
                'description' => 'TCP port 443 stealth configuration designed for restrictive firewall bypass.',
                'protocol' => 'ovpn',
                'config_data' => "client\ndev tun\nproto tcp\nremote 194.36.144.50 443\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\nverb 3",
                'share_code' => 'STLTH-NL',
                'is_public' => true,
                'is_active' => true,
                'export_locked' => false,
                'downloads_count' => 88,
                'server_id' => $serverNl?->id,
            ],
        ];

        foreach ($configs as $cfg) {
            Configuration::updateOrCreate(['share_code' => $cfg['share_code']], $cfg);
        }
    }
}
