<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\VerifySubscriptionRequest;
use App\Models\Device;
use App\Models\Plan;
use App\Models\Subscription;
use App\Services\Billing\BillingManager;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SubscriptionController extends Controller
{
    protected BillingManager $billingManager;

    public function __construct(BillingManager $billingManager)
    {
        $this->billingManager = $billingManager;
    }

    /**
     * List all active database-driven subscription plans.
     */
    public function plans(): JsonResponse
    {
        $plans = Plan::where('is_active', true)->orderBy('price_cents', 'asc')->get();

        return response()->json([
            'status' => 'success',
            'message' => 'Subscription plans retrieved.',
            'data' => $plans->map(function (Plan $plan) {
                return [
                    'id' => $plan->id,
                    'slug' => $plan->slug,
                    'google_play_product_id' => $plan->google_play_product_id ?? $plan->slug,
                    'name' => $plan->name,
                    'description' => $plan->description,
                    'price_cents' => $plan->price_cents,
                    'currency' => $plan->currency ?? 'USD',
                    'formatted_price' => $plan->price_cents == 0 ? 'Free' : ('$' . number_format($plan->price_cents / 100, 2)),
                    'duration_days' => $plan->duration_days,
                    'features' => $plan->features ?? [],
                    'is_featured' => (bool) $plan->is_featured,
                ];
            }),
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * Verifies purchase receipt (Google Play / sandbox) and grants entitlement to device.
     */
    public function verify(VerifySubscriptionRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $deviceUuid = $request->header('X-Device-UUID') ?? $request->input('device_uuid');
        if (!$deviceUuid) {
            return response()->json([
                'status' => 'error',
                'message' => 'Missing X-Device-UUID header.',
                'data' => null,
                'errors' => ['device_uuid' => ['Header X-Device-UUID is required.']],
            ], 400);
        }

        $device = Device::firstOrCreate(
            ['device_uuid' => $deviceUuid],
            ['device_name' => 'Android Device', 'is_active' => true]
        );

        $plan = isset($validated['plan_id'])
            ? Plan::findOrFail($validated['plan_id'])
            : Plan::where('slug', $validated['plan_slug'])->firstOrFail();

        $store = $validated['store'] ?? 'google_play';
        $purchaseToken = $validated['purchase_token'];
        $clientOrderId = $validated['order_id'] ?? null;

        $activationResult = $this->billingManager->verifyAndActivate(
            $device,
            $plan,
            $purchaseToken,
            $store,
            $clientOrderId
        );

        if (!$activationResult['success']) {
            return response()->json([
                'status' => 'error',
                'message' => $activationResult['message'],
                'data' => null,
            ], 422);
        }

        /** @var Subscription $subscription */
        $subscription = $activationResult['subscription'];

        return response()->json([
            'status' => 'success',
            'message' => 'Subscription verified and activated.',
            'data' => [
                'device_uuid' => $device->device_uuid,
                'is_premium' => true,
                'tier' => 'pro',
                'plan_name' => $plan->name,
                'order_id' => $subscription->order_id,
                'store' => $subscription->store,
                'starts_at' => $subscription->starts_at->toIso8601String(),
                'expires_at' => $subscription->expires_at?->toIso8601String(),
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * Redeems a promo code/voucher for the device.
     */
    public function redeemPromoCode(Request $request): JsonResponse
    {
        $request->validate([
            'code' => ['required', 'string', 'max:32'],
        ]);

        $deviceUuid = $request->header('X-Device-UUID') ?? $request->input('device_uuid');
        if (!$deviceUuid) {
            return response()->json([
                'status' => 'error',
                'message' => 'Missing X-Device-UUID header.',
                'data' => null,
            ], 400);
        }

        $device = Device::firstOrCreate(
            ['device_uuid' => $deviceUuid],
            ['device_name' => 'Android Device', 'is_active' => true]
        );

        $result = $this->billingManager->redeemPromoCode($device, $request->input('code'));

        if (!$result['success']) {
            return response()->json([
                'status' => 'error',
                'message' => $result['message'],
                'data' => null,
            ], 422);
        }

        /** @var Subscription $subscription */
        $subscription = $result['subscription'];

        return response()->json([
            'status' => 'success',
            'message' => $result['message'],
            'data' => [
                'device_uuid' => $device->device_uuid,
                'is_premium' => true,
                'tier' => 'pro',
                'plan_name' => $subscription->plan?->name,
                'order_id' => $subscription->order_id,
                'expires_at' => $subscription->expires_at?->toIso8601String(),
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * Checks subscription, entitlements, and quota usage for the device.
     */
    public function status(Request $request): JsonResponse
    {
        $deviceUuid = $request->header('X-Device-UUID') ?? $request->query('device_uuid');
        if (!$deviceUuid) {
            return response()->json([
                'status' => 'error',
                'message' => 'Missing X-Device-UUID header.',
                'data' => null,
            ], 400);
        }

        $device = Device::where('device_uuid', $deviceUuid)->first();
        if (!$device) {
            return response()->json([
                'status' => 'error',
                'message' => 'Device not found.',
                'data' => null,
            ], 404);
        }

        $activeSub = $device->activeSubscription;
        $isPremium = $device->is_premium || ($activeSub !== null && $activeSub->isValid());

        // Calculate usage limits
        $totalBytesUsed = ($device->bytes_uploaded ?? 0) + ($device->bytes_downloaded ?? 0);
        $dailyBandwidthCap = $isPremium ? null : (2 * 1024 * 1024 * 1024); // Free tier has 2GB/day soft limit

        return response()->json([
            'status' => 'success',
            'message' => 'Subscription status retrieved.',
            'data' => [
                'device_uuid' => $device->device_uuid,
                'is_premium' => $isPremium,
                'tier' => $isPremium ? 'pro' : 'free',
                'entitlements' => [
                    'all_servers_unlocked' => $isPremium,
                    'high_speed_bandwidth' => $isPremium,
                    'ad_blocker_dns' => $isPremium,
                    'custom_rtp_generation' => $isPremium,
                    'priority_support' => $isPremium,
                    'max_devices' => $isPremium ? 5 : 1,
                ],
                'usage' => [
                    'bytes_uploaded' => $device->bytes_uploaded ?? 0,
                    'bytes_downloaded' => $device->bytes_downloaded ?? 0,
                    'total_bytes' => $totalBytesUsed,
                    'bandwidth_cap_bytes' => $dailyBandwidthCap,
                    'cap_exceeded' => $dailyBandwidthCap !== null && $totalBytesUsed > $dailyBandwidthCap,
                ],
                'active_subscription' => $activeSub ? [
                    'id' => $activeSub->id,
                    'plan_id' => $activeSub->plan_id,
                    'plan_name' => $activeSub->plan?->name,
                    'status' => $activeSub->status,
                    'store' => $activeSub->store,
                    'order_id' => $activeSub->order_id,
                    'is_auto_renewing' => $activeSub->is_auto_renewing,
                    'starts_at' => $activeSub->starts_at?->toIso8601String(),
                    'expires_at' => $activeSub->expires_at?->toIso8601String(),
                ] : null,
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * Lists payment and subscription transaction history for the device.
     */
    public function history(Request $request): JsonResponse
    {
        $deviceUuid = $request->header('X-Device-UUID') ?? $request->query('device_uuid');
        if (!$deviceUuid) {
            return response()->json([
                'status' => 'error',
                'message' => 'Missing X-Device-UUID header.',
                'data' => null,
            ], 400);
        }

        $device = Device::where('device_uuid', $deviceUuid)->first();
        if (!$device) {
            return response()->json([
                'status' => 'success',
                'message' => 'No payment history found for new device.',
                'data' => [],
                'meta' => ['timestamp' => now()->toIso8601String()],
            ]);
        }

        $subscriptions = $device->subscriptions()
            ->with('plan')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'Payment history retrieved.',
            'data' => $subscriptions->map(function (Subscription $sub) {
                return [
                    'id' => $sub->id,
                    'order_id' => $sub->order_id ?? ('SUB-' . $sub->id),
                    'plan_name' => $sub->plan?->name ?? 'Custom Plan',
                    'amount_cents' => $sub->amount_paid_cents,
                    'formatted_amount' => $sub->amount_paid_cents > 0 ? ('$' . number_format($sub->amount_paid_cents / 100, 2)) : 'Free',
                    'currency' => $sub->currency ?? 'USD',
                    'store' => match ($sub->store) {
                        'google_play' => 'Google Play Billing',
                        'promo' => 'Promo Voucher Code',
                        'trial' => 'Free Trial',
                        default => ucfirst($sub->store),
                    },
                    'status' => ucfirst($sub->status),
                    'is_auto_renewing' => (bool) $sub->is_auto_renewing,
                    'date' => $sub->created_at->format('Y-m-d'),
                    'created_at' => $sub->created_at->toIso8601String(),
                    'expires_at' => $sub->expires_at?->toIso8601String(),
                ];
            }),
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }
}
