<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

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

    public function connectionSessions(): HasMany
    {
        return $this->hasMany(ConnectionSession::class);
    }

    public function configurations(): HasMany
    {
        return $this->hasMany(Configuration::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeFree($query)
    {
        return $query->where('is_premium', false);
    }

    public function scopePremium($query)
    {
        return $query->where('is_premium', true);
    }

    public function scopeCountry($query, ?string $countryCode)
    {
        if (!empty($countryCode)) {
            return $query->where('country_code', strtoupper($countryCode));
        }
        return $query;
    }
}
