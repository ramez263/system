<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DeviceNotificationPreference extends Model
{
    use HasFactory;

    protected $fillable = [
        'device_id',
        'notify_connection',
        'notify_disconnection',
        'notify_server_failure',
        'notify_subscription_expiry',
        'notify_security_alerts',
        'notify_updates',
        'notify_promotions',
    ];

    protected $casts = [
        'notify_connection' => 'boolean',
        'notify_disconnection' => 'boolean',
        'notify_server_failure' => 'boolean',
        'notify_subscription_expiry' => 'boolean',
        'notify_security_alerts' => 'boolean',
        'notify_updates' => 'boolean',
        'notify_promotions' => 'boolean',
    ];

    public function device(): BelongsTo
    {
        return $this->belongsTo(Device::class);
    }
}
