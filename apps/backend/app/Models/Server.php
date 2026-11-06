<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Server extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'country_code',
        'country_name',
        'city',
        'flag_emoji',
        'protocol',
        'ip_address',
        'port',
        'ping_ms',
        'current_load',
        'is_active',
        'is_premium',
        'ovpn_config',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'is_premium' => 'boolean',
        'port' => 'integer',
        'ping_ms' => 'integer',
        'current_load' => 'integer',
    ];
}
