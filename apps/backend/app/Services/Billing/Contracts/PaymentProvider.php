<?php

namespace App\Services\Billing\Contracts;

use App\Services\Billing\DTOs\PurchaseVerificationResult;

interface PaymentProvider
{
    /**
     * Get the unique provider identifier (e.g. google_play, promo, stripe).
     */
    public function getProviderName(): string;

    /**
     * Verifies the given purchase token and returns a standardized verification result.
     */
    public function verifySubscription(string $productId, string $purchaseToken): PurchaseVerificationResult;

    /**
     * Acknowledges the purchase with the store if required by the payment rail.
     */
    public function acknowledgePurchase(string $productId, string $purchaseToken): bool;
}
