<?php

namespace App\Services\Billing\DTOs;

use Carbon\Carbon;

class PurchaseVerificationResult
{
    public function __construct(
        public readonly bool $isValid,
        public readonly string $orderId,
        public readonly string $productId,
        public readonly ?Carbon $expiresAt = null,
        public readonly string $status = 'active',
        public readonly ?array $rawPayload = null,
        public readonly ?string $errorMessage = null,
        public readonly bool $isAutoRenewing = true,
    ) {}

    public static function success(
        string $orderId,
        string $productId,
        ?Carbon $expiresAt,
        array $rawPayload = [],
        bool $isAutoRenewing = true,
    ): self {
        return new self(
            isValid: true,
            orderId: $orderId,
            productId: $productId,
            expiresAt: $expiresAt,
            status: 'active',
            rawPayload: $rawPayload,
            errorMessage: null,
            isAutoRenewing: $isAutoRenewing,
        );
    }

    public static function failure(string $errorMessage, ?array $rawPayload = null): self
    {
        return new self(
            isValid: false,
            orderId: '',
            productId: '',
            expiresAt: null,
            status: 'failed',
            rawPayload: $rawPayload,
            errorMessage: $errorMessage,
            isAutoRenewing: false,
        );
    }
}
