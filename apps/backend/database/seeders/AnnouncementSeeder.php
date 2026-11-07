<?php

namespace Database\Seeders;

use App\Models\Announcement;
use Illuminate\Database\Seeder;

class AnnouncementSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $announcements = [
            [
                'title' => 'Amsterdam Ultra-01 High-Speed Node Live',
                'body' => 'Amsterdam Ultra 01 is now online with 1 Gbps unthrottled port capacity and low latency routing.',
                'category' => 'updates',
                'icon' => 'dns',
                'target_tier' => null,
                'action_url' => null,
                'is_active' => true,
                'expires_at' => now()->addMonths(6),
            ],
            [
                'title' => 'Hardware Identity Protection Verified',
                'body' => 'Hardware UUID authentication active. No email, passwords, or personal credentials stored on servers.',
                'category' => 'security_alerts',
                'icon' => 'security',
                'target_tier' => null,
                'action_url' => null,
                'is_active' => true,
                'expires_at' => now()->addYear(),
            ],
            [
                'title' => 'VIP 50% Annual Discount Available',
                'body' => 'Upgrade to Pro Annual today to lock in 50% off lifetime renewals and get unlimited VIP nodes.',
                'category' => 'promotions',
                'icon' => 'card_giftcard',
                'target_tier' => 'free',
                'action_url' => '/plans',
                'is_active' => true,
                'expires_at' => now()->addMonths(3),
            ],
            [
                'title' => 'Frankfurt Core Maintenance Completed',
                'body' => 'Scheduled packet optimization on Frankfurt DE-01 completed. Ping times reduced by 15ms.',
                'category' => 'server_failure',
                'icon' => 'info',
                'target_tier' => null,
                'action_url' => null,
                'is_active' => true,
                'expires_at' => now()->addMonth(),
            ],
        ];

        foreach ($announcements as $item) {
            Announcement::updateOrCreate(['title' => $item['title']], $item);
        }
    }
}
