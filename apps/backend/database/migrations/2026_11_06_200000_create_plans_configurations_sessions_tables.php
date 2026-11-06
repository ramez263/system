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
        // 1. Subscription Plans Table
        Schema::create('plans', function (Blueprint $table) {
            $table->id();
            $table->string('slug', 50)->unique();
            $table->string('name', 100);
            $table->text('description')->nullable();
            $table->unsignedInteger('price_cents')->default(0);
            $table->string('currency', 10)->default('USD');
            $table->unsignedInteger('duration_days')->default(30);
            $table->json('features')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index('is_active');
        });

        // 2. Add push token and plan reference to Devices
        Schema::table('devices', function (Blueprint $table) {
            $table->string('push_token', 255)->nullable()->after('app_version');
            $table->boolean('is_premium')->default(false)->after('is_active');
            $table->foreignId('plan_id')->nullable()->after('is_premium')->constrained('plans')->nullOnDelete();
        });

        // 3. Subscriptions / Entitlements Table (Device-centric)
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('device_id')->constrained('devices')->cascadeOnDelete();
            $table->foreignId('plan_id')->constrained('plans')->cascadeOnDelete();
            $table->string('status', 30)->default('active'); // active, expired, cancelled, refunded
            $table->string('store', 30)->default('google_play'); // google_play, promo, trial, manual
            $table->text('purchase_token')->nullable();
            $table->string('order_id', 100)->nullable();
            $table->timestamp('starts_at')->useCurrent();
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();

            $table->index(['device_id', 'status']);
        });

        // 4. Custom & Community Configurations Table
        Schema::create('configurations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('device_id')->nullable()->constrained('devices')->nullOnDelete();
            $table->foreignId('server_id')->nullable()->constrained('servers')->nullOnDelete();
            $table->string('name', 100);
            $table->text('description')->nullable();
            $table->string('protocol', 30)->default('ovpn'); // ovpn, vless, vmess, trojan, ssh, rtp
            $table->longText('config_data');
            $table->string('share_code', 16)->nullable()->unique();
            $table->boolean('is_public')->default(false);
            $table->boolean('is_active')->default(true);
            $table->boolean('export_locked')->default(false);
            $table->unsignedInteger('downloads_count')->default(0);
            $table->timestamps();

            $table->index(['is_public', 'is_active']);
        });

        // 5. Connection Sessions & Telemetry Table
        Schema::create('connection_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('device_id')->constrained('devices')->cascadeOnDelete();
            $table->foreignId('server_id')->nullable()->constrained('servers')->nullOnDelete();
            $table->foreignId('configuration_id')->nullable()->constrained('configurations')->nullOnDelete();
            $table->string('session_uuid', 64)->unique();
            $table->string('protocol', 30)->default('ovpn');
            $table->unsignedBigInteger('bytes_in')->default(0);
            $table->unsignedBigInteger('bytes_out')->default(0);
            $table->unsignedInteger('duration_seconds')->default(0);
            $table->string('client_ip', 45)->nullable();
            $table->string('disconnect_reason', 100)->nullable();
            $table->timestamp('connected_at')->nullable();
            $table->timestamp('disconnected_at')->nullable();
            $table->timestamps();

            $table->index(['device_id', 'connected_at']);
        });

        // 6. Remote App Settings & Feature Flags Table
        Schema::create('app_settings', function (Blueprint $table) {
            $table->id();
            $table->string('key', 64)->unique();
            $table->text('value')->nullable();
            $table->string('type', 20)->default('string'); // string, boolean, integer, json
            $table->string('description', 255)->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('app_settings');
        Schema::dropIfExists('connection_sessions');
        Schema::dropIfExists('configurations');
        Schema::dropIfExists('subscriptions');
        
        Schema::table('devices', function (Blueprint $table) {
            $table->dropForeign(['plan_id']);
            $table->dropColumn(['push_token', 'is_premium', 'plan_id']);
        });

        Schema::dropIfExists('plans');
    }
};
