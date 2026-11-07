<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Referral extends Model
{
    use HasFactory;

    protected $fillable = [
        'referrer_device_id',
        'referred_device_id',
        'reward_days',
        'status',
    ];

    protected $casts = [
        'reward_days' => 'integer',
    ];

    public function referrerDevice(): BelongsTo
    {
        return $this->belongsTo(Device::class, 'referrer_device_id');
    }

    public function referredDevice(): BelongsTo
    {
        return $this->belongsTo(Device::class, 'referred_device_id');
    }
}
