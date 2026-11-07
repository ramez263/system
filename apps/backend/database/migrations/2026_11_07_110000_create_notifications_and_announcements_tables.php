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
        // 1. Device Notification Preferences
        Schema::create('device_notification_preferences', function (Blueprint $table) {
            $table->id();
            $table->foreignId('device_id')->unique()->constrained('devices')->cascadeOnDelete();
            $table->boolean('notify_connection')->default(true);
            $table->boolean('notify_disconnection')->default(true);
            $table->boolean('notify_server_failure')->default(true);
            $table->boolean('notify_subscription_expiry')->default(true);
            $table->boolean('notify_security_alerts')->default(true);
            $table->boolean('notify_updates')->default(true);
            $table->boolean('notify_promotions')->default(false);
            $table->timestamps();
        });

        // 2. System Announcements and Broadcast Alerts
        Schema::create('announcements', function (Blueprint $table) {
            $table->id();
            $table->string('title', 150);
            $table->text('body');
            $table->string('category', 32)->default('updates'); // updates, server_failure, promotions, security_alerts
            $table->string('icon', 32)->default('notifications');
            $table->string('target_tier', 20)->nullable(); // null for all, or free, pro
            $table->string('action_url', 255)->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();

            $table->index(['is_active', 'category']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('announcements');
        Schema::dropIfExists('device_notification_preferences');
    }
};
