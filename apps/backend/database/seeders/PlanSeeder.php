<?php

namespace Database\Seeders;

use App\Models\Plan;
use Illuminate\Database\Seeder;

class PlanSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $plans = [
            [
                'slug' => 'free',
                'google_play_product_id' => null,
                'name' => 'Free Guest Tier',
                'description' => 'Unlimited standard servers with speed capped at 10 Mbps and community OpenVPN support.',
                'price_cents' => 0,
                'currency' => 'USD',
                'duration_days' => 3650,
                'features' => [
                    'Curated public OpenVPN servers',
                    'Standard speed (up to 10 Mbps)',
                    'Single device usage',
                    'Custom .rtp/.ovpn import',
                ],
                'is_active' => true,
                'is_featured' => false,
            ],
            [
                'slug' => 'pro_monthly',
                'google_play_product_id' => 'com.ramez.tunnelplus.pro_monthly',
                'name' => 'Pro Monthly',
                'description' => 'Full unthrottled gigabit bandwidth, all global VIP nodes, zero logs, priority DNS routing.',
                'price_cents' => 499,
                'currency' => 'USD',
                'duration_days' => 30,
                'features' => [
                    'All global VIP locations unlocked',
                    'Unthrottled 1Gbps+ speed',
                    'Advanced split tunneling & kill-switch',
                    'Ad & malware blocker DNS',
                    'Zero latency gaming & streaming routes',
                ],
                'is_active' => true,
                'is_featured' => false,
            ],
            [
                'slug' => 'pro_annual',
                'google_play_product_id' => 'com.ramez.tunnelplus.pro_annual',
                'name' => 'Pro Annual (Best Value)',
                'description' => 'Save 50% on annual subscription. 12 months of high-speed tunneling.',
                'price_cents' => 2999,
                'currency' => 'USD',
                'duration_days' => 365,
                'features' => [
                    'Everything in Pro Monthly',
                    'Save 50% over monthly billing',
                    'VIP 24/7 priority support',
                    'Custom payload generator',
                ],
                'is_active' => true,
                'is_featured' => true,
            ],
            [
                'slug' => 'vip_lifetime',
                'google_play_product_id' => 'com.ramez.tunnelplus.vip_lifetime',
                'name' => 'VIP Lifetime Access',
                'description' => 'One-time payment for lifetime VIP access on your device.',
                'price_cents' => 7999,
                'currency' => 'USD',
                'duration_days' => 36500,
                'features' => [
                    'Permanent VIP status',
                    'All present & future features',
                    'Dedicated high-bandwidth relay nodes',
                ],
                'is_active' => true,
                'is_featured' => false,
            ],
        ];

        foreach ($plans as $plan) {
            Plan::updateOrCreate(['slug' => $plan['slug']], $plan);
        }
    }
}
