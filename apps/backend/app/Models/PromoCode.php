<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class PromoCode extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'plan_id',
        'description',
        'duration_days',
        'max_uses',
        'uses_count',
        'is_active',
        'expires_at',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'duration_days' => 'integer',
        'max_uses' => 'integer',
        'uses_count' => 'integer',
        'expires_at' => 'datetime',
    ];

    public function plan(): BelongsTo
    {
        return $this->belongsTo(Plan::class);
    }

    public function redeemedDevices(): BelongsToMany
    {
        return $this->belongsToMany(Device::class, 'promo_code_redemptions')
            ->withPivot('redeemed_at');
    }

    public function isValid(): bool
    {
        if (!$this->is_active) {
            return false;
        }

        if ($this->max_uses > 0 && $this->uses_count >= $this->max_uses) {
            return false;
        }

        if ($this->expires_at !== null && $this->expires_at->isPast()) {
            return false;
        }

        return true;
    }

    public function isRedeemedBy(Device $device): bool
    {
        return $this->redeemedDevices()->where('devices.id', $device->id)->exists();
    }
}
