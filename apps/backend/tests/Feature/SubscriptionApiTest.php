<?php

namespace Tests\Feature;

use App\Models\Device;
use App\Models\Plan;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SubscriptionApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_active_subscription_plans(): void
    {
        Plan::create([
            'slug' => 'pro_test',
            'name' => 'Pro Test Plan',
            'price_cents' => 499,
            'currency' => 'USD',
            'duration_days' => 30,
            'is_active' => true,
        ]);

        $response = $this->getJson('/api/v1/plans');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    [
                        'slug' => 'pro_test',
                        'name' => 'Pro Test Plan',
                        'price_cents' => 499,
                    ],
                ],
            ]);
    }

    public function test_can_verify_google_play_purchase_and_activate_pro(): void
    {
        $plan = Plan::create([
            'slug' => 'pro_monthly',
            'name' => 'Pro Monthly',
            'price_cents' => 499,
            'duration_days' => 30,
            'is_active' => true,
        ]);

        $device = Device::create([
            'device_uuid' => 'sub-test-device-uuid',
            'is_active' => true,
            'is_premium' => false,
        ]);

        $payload = [
            'plan_id' => $plan->id,
            'purchase_token' => 'sample_google_play_purchase_token_xyz',
            'order_id' => 'GPA.1234-5678-9012',
            'store' => 'google_play',
        ];

        $response = $this->withHeader('X-Device-UUID', $device->device_uuid)
            ->postJson('/api/v1/subscriptions/verify', $payload);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'is_premium' => true,
                    'tier' => 'pro',
                    'order_id' => 'GPA.1234-5678-9012',
                ],
            ]);

        $device->refresh();
        $this->assertTrue($device->is_premium);
        $this->assertDatabaseHas('subscriptions', [
            'device_id' => $device->id,
            'plan_id' => $plan->id,
            'status' => 'active',
        ]);
    }

    public function test_can_check_subscription_status(): void
    {
        $device = Device::create([
            'device_uuid' => 'status-check-device',
            'is_active' => true,
            'is_premium' => true,
        ]);

        $response = $this->withHeader('X-Device-UUID', $device->device_uuid)
            ->getJson('/api/v1/subscriptions/status');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'device_uuid' => 'status-check-device',
                    'is_premium' => true,
                    'tier' => 'pro',
                ],
            ]);
    }
}
