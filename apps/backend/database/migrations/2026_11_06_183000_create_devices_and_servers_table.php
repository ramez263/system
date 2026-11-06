<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('devices', function (Blueprint $table) {
            $table->id();
            $table->string('device_uuid', 64)->unique();
            $table->string('device_name', 100)->nullable();
            $table->string('model', 100)->nullable();
            $table->string('os_version', 50)->nullable();
            $table->string('app_version', 50)->nullable();
            $table->string('platform', 30)->default('android');
            $table->boolean('is_active')->default(true);
            $table->unsignedBigInteger('bytes_uploaded')->default(0);
            $table->unsignedBigInteger('bytes_downloaded')->default(0);
            $table->timestamp('last_handshake_at')->nullable();
            $table->timestamps();

            $table->index('device_uuid');
        });

        Schema::create('servers', function (Blueprint $table) {
            $table->id();
            $table->string('name', 100);
            $table->char('country_code', 2);
            $table->string('country_name', 80);
            $table->string('city', 80)->nullable();
            $table->string('flag_emoji', 10);
            $table->string('protocol', 30)->default('ovpn'); // ovpn, vless, trojan
            $table->string('ip_address', 45);
            $table->unsignedInteger('port')->default(1194);
            $table->unsignedInteger('ping_ms')->default(35);
            $table->unsignedTinyInteger('current_load')->default(15);
            $table->boolean('is_active')->default(true);
            $table->boolean('is_premium')->default(false);
            $table->longText('ovpn_config')->nullable();
            $table->timestamps();

            $table->index(['is_active', 'is_premium']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('servers');
        Schema::dropIfExists('devices');
    }
};
