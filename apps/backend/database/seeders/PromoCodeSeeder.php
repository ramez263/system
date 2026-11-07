<?php

namespace Database\Seeders;

use App\Models\Plan;
use App\Models\PromoCode;
use Illuminate\Database\Seeder;

class PromoCodeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $proPlan = Plan::where('slug', 'pro_monthly')->first() ?? Plan::first();
        $annualPlan = Plan::where('slug', 'pro_annual')->first() ?? $proPlan;

        $codes = [
            [
                'code' => 'RAMEZVIP',
                'plan_id' => $proPlan->id,
                'description' => 'VIP 30-Day Pro Access Gift',
                'duration_days' => 30,
                'max_uses' => 1000,
                'uses_count' => 0,
                'is_active' => true,
                'expires_at' => now()->addYear(),
            ],
            [
                'code' => 'TUNNEL2026',
                'plan_id' => $annualPlan->id,
                'description' => 'Community Launch 60-Day Access',
                'duration_days' => 60,
                'max_uses' => 500,
                'uses_count' => 0,
                'is_active' => true,
                'expires_at' => now()->addMonths(6),
            ],
            [
                'code' => 'WELCOME7',
                'plan_id' => $proPlan->id,
                'description' => 'New User 7-Day Trial Voucher',
                'duration_days' => 7,
                'max_uses' => 10000,
                'uses_count' => 0,
                'is_active' => true,
                'expires_at' => now()->addYears(2),
            ],
            [
                'code' => 'EXPIREDTEST',
                'plan_id' => $proPlan->id,
                'description' => 'Expired Promo Code for Testing',
                'duration_days' => 30,
                'max_uses' => 10,
                'uses_count' => 0,
                'is_active' => true,
                'expires_at' => now()->subDay(),
            ],
        ];

        foreach ($codes as $item) {
            PromoCode::updateOrCreate(['code' => $item['code']], $item);
        }
    }
}
