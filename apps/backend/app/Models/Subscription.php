<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Subscription extends Model
{
    use HasFactory;

    protected $fillable = [
        'device_id',
        'plan_id',
        'status',
        'store',
        'amount_paid_cents',
        'currency',
        'purchase_token',
        'order_id',
        'is_auto_renewing',
        'raw_verification_payload',
        'starts_at',
        'expires_at',
    ];

    protected $casts = [
        'amount_paid_cents' => 'integer',
        'is_auto_renewing' => 'boolean',
        'raw_verification_payload' => 'array',
        'starts_at' => 'datetime',
        'expires_at' => 'datetime',
    ];

    public function device(): BelongsTo
    {
        return $this->belongsTo(Device::class);
    }

    public function plan(): BelongsTo
    {
        return $this->belongsTo(Plan::class);
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active')
            ->where(function ($q) {
                $q->whereNull('expires_at')
                  ->orWhere('expires_at', '>', now());
            });
    }

    public function isValid(): bool
    {
        if (!in_array($this->status, ['active', 'in_grace_period'])) {
            return false;
        }
        return $this->expires_at === null || $this->expires_at->isFuture();
    }
}
