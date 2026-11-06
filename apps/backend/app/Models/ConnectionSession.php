<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ConnectionSession extends Model
{
    use HasFactory;

    protected $fillable = [
        'device_id',
        'server_id',
        'configuration_id',
        'session_uuid',
        'protocol',
        'bytes_in',
        'bytes_out',
        'duration_seconds',
        'client_ip',
        'disconnect_reason',
        'connected_at',
        'disconnected_at',
    ];

    protected $casts = [
        'bytes_in' => 'integer',
        'bytes_out' => 'integer',
        'duration_seconds' => 'integer',
        'connected_at' => 'datetime',
        'disconnected_at' => 'datetime',
    ];

    public function device(): BelongsTo
    {
        return $this->belongsTo(Device::class);
    }

    public function server(): BelongsTo
    {
        return $this->belongsTo(Server::class);
    }

    public function configuration(): BelongsTo
    {
        return $this->belongsTo(Configuration::class);
    }
}
