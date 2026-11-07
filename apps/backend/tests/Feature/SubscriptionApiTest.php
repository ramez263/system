<?php

namespace Tests\Feature;

use App\Models\Device;
use App\Models\Plan;
use App\Models\PromoCode;
use App\Models\Subscription;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SubscriptionApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_active_subscription_plans(): void
    {
        Plan::create([
            'slug' => 'pro_test',
            'google_play_product_id' => 'com.ramez.tunnelplus.pro_test',
            'name' => 'Pro Test Plan',
            'price_cents' => 499,
            'currency' => 'USD',
            'duration_days' => 30,
            'is_active' => true,
            'is_featured' => true,
        ]);

        $response = $this->getJson('/api/v1/plans');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    [
                        'slug' => 'pro_test',
                        'google_play_product_id' => 'com.ramez.tunnelplus.pro_test',
                        'name' => 'Pro Test Plan',
                        'price_cents' => 499,
                        'is_featured' => true,
                    ],
                ],
            ]);
    }

    public function test_can_verify_google_play_purchase_and_activate_pro(): void
    {
        $plan = Plan::create([
            'slug' => 'pro_monthly',
            'google_play_product_id' => 'com.ramez.tunnelplus.pro_monthly',
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
            'purchase_token' => 'sandbox_purchase_token_xyz_valid',
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

    public function test_rejects_invalid_or_expired_purchase_token(): void
    {
        $plan = Plan::create([
            'slug' => 'pro_monthly',
            'name' => 'Pro Monthly',
            'price_cents' => 499,
            'duration_days' => 30,
            'is_active' => true,
        ]);

        $device = Device::create([
            'device_uuid' => 'invalid-token-device',
            'is_active' => true,
            'is_premium' => false,
        ]);

        $payload = [
            'plan_id' => $plan->id,
            'purchase_token' => 'test_invalid_token_sample',
            'store' => 'google_play',
        ];

        $response = $this->withHeader('X-Device-UUID', $device->device_uuid)
            ->postJson('/api/v1/subscriptions/verify', $payload);

        $response->assertStatus(422)
            ->assertJson([
                'status' => 'error',
            ]);

        $device->refresh();
        $this->assertFalse($device->is_premium);
    }

    public function test_can_redeem_valid_promo_code(): void
    {
        $plan = Plan::create([
            'slug' => 'pro_monthly',
            'name' => 'Pro Monthly',
            'price_cents' => 499,
            'duration_days' => 30,
            'is_active' => true,
        ]);

        $promo = PromoCode::create([
            'code' => 'RAMEZVIP',
            'plan_id' => $plan->id,
            'duration_days' => 30,
            'max_uses' => 10,
            'uses_count' => 0,
            'is_active' => true,
            'expires_at' => now()->addMonth(),
        ]);

        $device = Device::create([
            'device_uuid' => 'promo-redeem-device',
            'is_active' => true,
            'is_premium' => false,
        ]);

        $response = $this->withHeader('X-Device-UUID', $device->device_uuid)
            ->postJson('/api/v1/subscriptions/redeem-code', ['code' => 'RAMEZVIP']);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    'is_premium' => true,
                    'tier' => 'pro',
                ],
            ]);

        $device->refresh();
        $this->assertTrue($device->is_premium);
        $promo->refresh();
        $this->assertEquals(1, $promo->uses_count);
    }

    public function test_rejects_re_redeeming_promo_code_on_same_device(): void
    {
        $plan = Plan::create([
            'slug' => 'pro_monthly',
            'name' => 'Pro Monthly',
            'price_cents' => 499,
            'duration_days' => 30,
            'is_active' => true,
        ]);

        $promo = PromoCode::create([
            'code' => 'SINGLEREUSE',
            'plan_id' => $plan->id,
            'duration_days' => 14,
            'max_uses' => 100,
            'uses_count' => 0,
            'is_active' => true,
        ]);

        $device = Device::create([
            'device_uuid' => 'double-dip-device',
            'is_active' => true,
            'is_premium' => false,
        ]);

        // First redemption succeeds
        $first = $this->withHeader('X-Device-UUID', $device->device_uuid)
            ->postJson('/api/v1/subscriptions/redeem-code', ['code' => 'SINGLEREUSE']);
        $first->assertStatus(200);

        // Second redemption fails
        $second = $this->withHeader('X-Device-UUID', $device->device_uuid)
            ->postJson('/api/v1/subscriptions/redeem-code', ['code' => 'SINGLEREUSE']);
        $second->assertStatus(422)
            ->assertJson([
                'status' => 'error',
                'message' => 'This promo code has already been redeemed on this device.',
            ]);
    }

    public function test_can_retrieve_subscription_status_and_entitlements(): void
    {
        $device = Device::create([
            'device_uuid' => 'status-check-device',
            'is_active' => true,
            'is_premium' => true,
            'bytes_uploaded' => 1048576,
            'bytes_downloaded' => 2097152,
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
                    'entitlements' => [
                        'all_servers_unlocked' => true,
                        'high_speed_bandwidth' => true,
                    ],
                    'usage' => [
                        'total_bytes' => 3145728,
                    ],
                ],
            ]);
    }

    public function test_can_retrieve_payment_history(): void
    {
        $plan = Plan::create([
            'slug' => 'pro_annual',
            'name' => 'Pro Annual',
            'price_cents' => 2999,
            'duration_days' => 365,
            'is_active' => true,
        ]);

        $device = Device::create([
            'device_uuid' => 'history-device-uuid',
            'is_active' => true,
            'is_premium' => true,
        ]);

        Subscription::create([
            'device_id' => $device->id,
            'plan_id' => $plan->id,
            'status' => 'active',
            'store' => 'google_play',
            'amount_paid_cents' => 2999,
            'currency' => 'USD',
            'purchase_token' => 'token_history_test',
            'order_id' => 'GPA.9999-8888-7777',
            'starts_at' => now(),
            'expires_at' => now()->addDays(365),
        ]);

        $response = $this->withHeader('X-Device-UUID', $device->device_uuid)
            ->getJson('/api/v1/subscriptions/history');

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'data' => [
                    [
                        'order_id' => 'GPA.9999-8888-7777',
                        'plan_name' => 'Pro Annual',
                        'formatted_amount' => '$29.99',
                        'store' => 'Google Play Billing',
                        'status' => 'Active',
                    ],
                ],
            ]);
    }

    public function test_handles_google_play_rtdn_webhook_cancellation_and_expiration(): void
    {
        $plan = Plan::create([
            'slug' => 'pro_monthly',
            'name' => 'Pro Monthly',
            'price_cents' => 499,
            'duration_days' => 30,
            'is_active' => true,
        ]);

        $device = Device::create([
            'device_uuid' => 'rtdn-test-device',
            'is_active' => true,
            'is_premium' => true,
        ]);

        $sub = Subscription::create([
            'device_id' => $device->id,
            'plan_id' => $plan->id,
            'status' => 'active',
            'store' => 'google_play',
            'purchase_token' => 'rtdn_token_12345',
            'order_id' => 'GPA.0000-1111-2222',
            'is_auto_renewing' => true,
            'starts_at' => now()->subDays(10),
            'expires_at' => now()->addDays(20),
        ]);

        // RTDN Type 3: SUBSCRIPTION_CANCELED
        $responseCancel = $this->postJson('/api/v1/subscriptions/google-play/webhook', [
            'notificationType' => 3,
            'purchaseToken' => 'rtdn_token_12345',
            'subscriptionId' => 'pro_monthly',
        ]);
        $responseCancel->assertStatus(200);

        $sub->refresh();
        $this->assertFalse($sub->is_auto_renewing);
        $this->assertTrue($device->fresh()->is_premium); // still active until expiry

        // RTDN Type 13: SUBSCRIPTION_EXPIRED
        $responseExpire = $this->postJson('/api/v1/subscriptions/google-play/webhook', [
            'notificationType' => 13,
            'purchaseToken' => 'rtdn_token_12345',
            'subscriptionId' => 'pro_monthly',
        ]);
        $responseExpire->assertStatus(200);

        $sub->refresh();
        $this->assertEquals('expired', $sub->status);
        $this->assertFalse($device->fresh()->is_premium);
    }
}
