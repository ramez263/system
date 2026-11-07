<?php

namespace App\Services\Billing;

use App\Models\Device;
use App\Models\Plan;
use App\Models\PromoCode;
use App\Models\Subscription;
use App\Services\Billing\Contracts\PaymentProvider;
use App\Services\Billing\DTOs\PurchaseVerificationResult;
use App\Services\Billing\Providers\GooglePlayBillingProvider;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class BillingManager
{
    protected array $providers = [];

    public function __construct()
    {
        $this->registerProvider(new GooglePlayBillingProvider());
    }

    public function registerProvider(PaymentProvider $provider): self
    {
        $this->providers[$provider->getProviderName()] = $provider;
        return $this;
    }

    public function getProvider(string $store = 'google_play'): PaymentProvider
    {
        return $this->providers[$store] ?? $this->providers['google_play'];
    }

    /**
     * Verifies and activates a subscription for a device from an app store purchase.
     */
    public function verifyAndActivate(
        Device $device,
        Plan $plan,
        string $purchaseToken,
        string $store = 'google_play',
        ?string $clientOrderId = null,
    ): array {
        $provider = $this->getProvider($store);
        $productId = $plan->google_play_product_id ?? $plan->slug;

        $result = $provider->verifySubscription($productId, $purchaseToken);

        if (!$result->isValid) {
            return [
                'success' => false,
                'message' => $result->errorMessage ?? 'Purchase verification failed.',
                'subscription' => null,
            ];
        }

        // Acknowledge store receipt
        $provider->acknowledgePurchase($productId, $purchaseToken);

        $orderId = !empty($clientOrderId) 
            ? $clientOrderId 
            : (!empty($result->orderId) ? $result->orderId : ('GPA.' . mt_rand(1000, 9999) . '-' . mt_rand(1000, 9999)));

        $subscription = DB::transaction(function () use ($device, $plan, $result, $store, $purchaseToken, $orderId) {
            $sub = Subscription::create([
                'device_id' => $device->id,
                'plan_id' => $plan->id,
                'status' => 'active',
                'store' => $store,
                'amount_paid_cents' => $plan->price_cents,
                'currency' => $plan->currency ?? 'USD',
                'purchase_token' => $purchaseToken,
                'order_id' => $orderId,
                'is_auto_renewing' => $result->isAutoRenewing,
                'raw_verification_payload' => $result->rawPayload,
                'starts_at' => now(),
                'expires_at' => $result->expiresAt,
            ]);

            $device->update([
                'is_premium' => true,
                'plan_id' => $plan->id,
            ]);

            return $sub;
        });

        Log::info("Activated subscription #{$subscription->id} for device {$device->device_uuid} on plan {$plan->name}");

        return [
            'success' => true,
            'message' => 'Subscription verified and activated.',
            'subscription' => $subscription,
        ];
    }

    /**
     * Redeems a promo code or voucher for a device.
     */
    public function redeemPromoCode(Device $device, string $code): array
    {
        $code = strtoupper(trim($code));
        $promo = PromoCode::where('code', $code)->first();

        if (!$promo) {
            return [
                'success' => false,
                'message' => 'Invalid or unrecognized promo code.',
            ];
        }

        if (!$promo->isValid()) {
            return [
                'success' => false,
                'message' => 'This promo code is expired or has reached maximum usage limit.',
            ];
        }

        if ($promo->isRedeemedBy($device)) {
            return [
                'success' => false,
                'message' => 'This promo code has already been redeemed on this device.',
            ];
        }

        $plan = $promo->plan ?? Plan::where('slug', 'pro_monthly')->first() ?? Plan::first();
        $durationDays = $promo->duration_days > 0 ? $promo->duration_days : 30;

        $subscription = DB::transaction(function () use ($device, $promo, $plan, $durationDays) {
            // Determine start date (extend if currently active)
            $activeSub = $device->activeSubscription;
            $startsAt = now();
            $expiresAt = ($activeSub && $activeSub->expires_at && $activeSub->expires_at->isFuture())
                ? $activeSub->expires_at->addDays($durationDays)
                : now()->addDays($durationDays);

            $sub = Subscription::create([
                'device_id' => $device->id,
                'plan_id' => $plan->id,
                'status' => 'active',
                'store' => 'promo',
                'amount_paid_cents' => 0,
                'currency' => 'USD',
                'purchase_token' => 'PROMO_' . $promo->code . '_' . $device->id,
                'order_id' => 'PRM-' . strtoupper(bin2hex(random_bytes(4))),
                'is_auto_renewing' => false,
                'starts_at' => $startsAt,
                'expires_at' => $expiresAt,
            ]);

            $promo->increment('uses_count');
            $promo->redeemedDevices()->attach($device->id, ['redeemed_at' => now()]);

            $device->update([
                'is_premium' => true,
                'plan_id' => $plan->id,
            ]);

            return $sub;
        });

        Log::info("Promo code {$code} redeemed by device {$device->device_uuid}. Valid until {$subscription->expires_at}");

        return [
            'success' => true,
            'message' => "Promo code activated successfully! Enjoy VIP access until {$subscription->expires_at->format('Y-m-d')}.",
            'subscription' => $subscription,
        ];
    }

    /**
     * Handles Google Play Real-Time Developer Notifications (RTDN).
     *
     * Notification types:
     * 1: SUBSCRIPTION_RECOVERED
     * 2: SUBSCRIPTION_RENEWED
     * 3: SUBSCRIPTION_CANCELED
     * 4: SUBSCRIPTION_PURCHASED
     * 5: SUBSCRIPTION_ON_HOLD
     * 6: SUBSCRIPTION_IN_GRACE_PERIOD
     * 7: SUBSCRIPTION_RESTARTED
     * 12: SUBSCRIPTION_REVOKED
     * 13: SUBSCRIPTION_EXPIRED
     */
    public function handleGooglePlayNotification(int $notificationType, string $purchaseToken, string $subscriptionId): array
    {
        $subscription = Subscription::where('purchase_token', $purchaseToken)->first();

        if (!$subscription) {
            Log::warning("RTDN received for unknown purchase token: {$purchaseToken}");
            return ['status' => 'ignored', 'reason' => 'subscription_not_found'];
        }

        $device = $subscription->device;

        switch ($notificationType) {
            case 1: // SUBSCRIPTION_RECOVERED
            case 2: // SUBSCRIPTION_RENEWED
            case 4: // SUBSCRIPTION_PURCHASED
            case 7: // SUBSCRIPTION_RESTARTED
                $subscription->update([
                    'status' => 'active',
                    'expires_at' => now()->addDays($subscription->plan?->duration_days ?? 30),
                ]);
                $device?->update(['is_premium' => true]);
                break;

            case 3: // SUBSCRIPTION_CANCELED (will not renew, but remains active until expiry)
                $subscription->update(['is_auto_renewing' => false]);
                break;

            case 6: // SUBSCRIPTION_IN_GRACE_PERIOD
                $subscription->update(['status' => 'in_grace_period']);
                $device?->update(['is_premium' => true]);
                break;

            case 5: // SUBSCRIPTION_ON_HOLD
                $subscription->update(['status' => 'on_hold']);
                $device?->update(['is_premium' => false]);
                break;

            case 12: // SUBSCRIPTION_REVOKED
                $subscription->update(['status' => 'revoked']);
                $device?->update(['is_premium' => false]);
                break;

            case 13: // SUBSCRIPTION_EXPIRED
                $subscription->update(['status' => 'expired']);
                $device?->update(['is_premium' => false]);
                break;
        }

        Log::info("RTDN event {$notificationType} handled for subscription #{$subscription->id}, new status: {$subscription->status}");

        return [
            'status' => 'processed',
            'subscription_id' => $subscription->id,
            'new_status' => $subscription->status,
        ];
    }
}
