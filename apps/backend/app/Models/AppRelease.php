<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AppRelease extends Model
{
    use HasFactory;

    protected $fillable = [
        'version',
        'build_number',
        'platform',
        'min_supported_version',
        'force_update',
        'download_url',
        'release_notes',
        'is_active',
    ];

    protected $casts = [
        'build_number' => 'integer',
        'force_update' => 'boolean',
        'is_active' => 'boolean',
    ];
}
