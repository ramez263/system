<?php

namespace Database\Seeders;

use App\Models\AppSetting;
use Illuminate\Database\Seeder;

class AppSettingSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $settings = [
            [
                'key' => 'min_app_version',
                'value' => '1.0.0',
                'type' => 'string',
                'description' => 'Minimum supported mobile app version required before mandatory update',
            ],
            [
                'key' => 'force_update',
                'value' => '0',
                'type' => 'boolean',
                'description' => 'Whether force update modal is presented to users below min_app_version',
            ],
            [
                'key' => 'maintenance_mode',
                'value' => '0',
                'type' => 'boolean',
                'description' => 'Global maintenance mode toggle',
            ],
            [
                'key' => 'announcement_ar',
                'value' => 'مرحباً بك في رامز تنل بلس! استمتع باتصال مجاني وسريع عبر خوادم OpenVPN المختارة.',
                'type' => 'string',
                'description' => 'Arabic announcement message shown on home dashboard banner',
            ],
            [
                'key' => 'announcement_en',
                'value' => 'Welcome to Ramez Tunnel Plus! Enjoy fast & free connections across curated OpenVPN nodes.',
                'type' => 'string',
                'description' => 'English announcement message shown on home dashboard banner',
            ],
            [
                'key' => 'default_dns_servers',
                'value' => json_encode(['1.1.1.1', '1.0.0.1', '8.8.8.8']),
                'type' => 'json',
                'description' => 'Default DNS fallback servers pushed to mobile client',
            ],
            [
                'key' => 'kill_switch_default',
                'value' => '0',
                'type' => 'boolean',
                'description' => 'Default state for kill-switch setting on clean installs',
            ],
        ];

        foreach ($settings as $setting) {
            AppSetting::updateOrCreate(['key' => $setting['key']], $setting);
        }
    }
}
