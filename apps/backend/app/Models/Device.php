<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

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
        'is_active',
        'bytes_uploaded',
        'bytes_downloaded',
        'last_handshake_at',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'last_handshake_at' => 'datetime',
        'bytes_uploaded' => 'integer',
        'bytes_downloaded' => 'integer',
    ];
}
