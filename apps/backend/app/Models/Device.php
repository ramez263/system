<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Device extends Model
{
    use HasFactory;

    protected $fillable = [
        'device_uuid',
        'device_name',
        'model',
        'os_version',
        'app_version',
        'platform',
        'push_token',
        'is_active',
        'is_premium',
        'plan_id',
        'bytes_uploaded',
        'bytes_downloaded',
        'last_handshake_at',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'is_premium' => 'boolean',
        'last_handshake_at' => 'datetime',
        'bytes_uploaded' => 'integer',
        'bytes_downloaded' => 'integer',
    ];

    public function plan(): BelongsTo
    {
        return $this->belongsTo(Plan::class);
    }

    public function subscriptions(): HasMany
    {
        return $this->hasMany(Subscription::class);
    }

    public function activeSubscription(): HasOne
    {
        return $this->hasOne(Subscription::class)
            ->where('status', 'active')
            ->where(function ($q) {
                $q->whereNull('expires_at')
                  ->orWhere('expires_at', '>', now());
            })
            ->latestOfMany();
    }

    public function configurations(): HasMany
    {
        return $this->hasMany(Configuration::class);
    }

    public function connectionSessions(): HasMany
    {
        return $this->hasMany(ConnectionSession::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopePremium($query)
    {
        return $query->where('is_premium', true);
    }
}
