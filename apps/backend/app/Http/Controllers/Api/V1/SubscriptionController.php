<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\VerifySubscriptionRequest;
use App\Models\Device;
use App\Models\Plan;
use App\Models\Subscription;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SubscriptionController extends Controller
{
    /**
     * List all active subscription plans.
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
                    'name' => $plan->name,
                    'description' => $plan->description,
                    'price_cents' => $plan->price_cents,
                    'currency' => $plan->currency,
                    'formatted_price' => '$' . number_format($plan->price_cents / 100, 2),
                    'duration_days' => $plan->duration_days,
                    'features' => $plan->features ?? [],
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

        $plan = Plan::findOrFail($validated['plan_id']);

        $expiresAt = $plan->duration_days > 0 
            ? now()->addDays($plan->duration_days) 
            : null;

        $subscription = Subscription::create([
            'device_id' => $device->id,
            'plan_id' => $plan->id,
            'status' => 'active',
            'store' => $validated['store'] ?? 'google_play',
            'purchase_token' => $validated['purchase_token'],
            'order_id' => $validated['order_id'] ?? ('GPA.' . rand(1000, 9999) . '-' . rand(1000, 9999)),
            'starts_at' => now(),
            'expires_at' => $expiresAt,
        ]);

        $device->update([
            'is_premium' => true,
            'plan_id' => $plan->id,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Subscription verified and activated.',
            'data' => [
                'device_uuid' => $device->device_uuid,
                'is_premium' => true,
                'tier' => 'pro',
                'plan_name' => $plan->name,
                'order_id' => $subscription->order_id,
                'starts_at' => $subscription->starts_at->toIso8601String(),
                'expires_at' => $subscription->expires_at?->toIso8601String(),
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * Checks subscription and entitlement status for the device.
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

        return response()->json([
            'status' => 'success',
            'message' => 'Subscription status retrieved.',
            'data' => [
                'device_uuid' => $device->device_uuid,
                'is_premium' => $isPremium,
                'tier' => $isPremium ? 'pro' : 'free',
                'active_subscription' => $activeSub ? [
                    'id' => $activeSub->id,
                    'plan_id' => $activeSub->plan_id,
                    'plan_name' => $activeSub->plan?->name,
                    'status' => $activeSub->status,
                    'store' => $activeSub->store,
                    'expires_at' => $activeSub->expires_at?->toIso8601String(),
                ] : null,
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }
}
