<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

class Configuration extends Model
{
    use HasFactory;

    protected $fillable = [
        'device_id',
        'server_id',
        'name',
        'description',
        'protocol',
        'config_data',
        'share_code',
        'is_public',
        'is_active',
        'export_locked',
        'downloads_count',
    ];

    protected $casts = [
        'is_public' => 'boolean',
        'is_active' => 'boolean',
        'export_locked' => 'boolean',
        'downloads_count' => 'integer',
    ];

    protected static function booted()
    {
        static::creating(function ($config) {
            if (empty($config->share_code)) {
                $config->share_code = strtoupper(Str::random(8));
            }
        });
    }

    public function device(): BelongsTo
    {
        return $this->belongsTo(Device::class);
    }

    public function server(): BelongsTo
    {
        return $this->belongsTo(Server::class);
    }

    public function scopePublic($query)
    {
        return $query->where('is_public', true);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}
