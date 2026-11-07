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
        // 1. Promo codes / Vouchers table
        Schema::create('promo_codes', function (Blueprint $table) {
            $table->id();
            $table->string('code', 32)->unique();
            $table->foreignId('plan_id')->constrained('plans')->cascadeOnDelete();
            $table->string('description', 255)->nullable();
            $table->unsignedInteger('duration_days')->default(30);
            $table->unsignedInteger('max_uses')->default(100);
            $table->unsignedInteger('uses_count')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();

            $table->index(['code', 'is_active']);
        });

        // 2. Track which device redeemed which promo code
        Schema::create('promo_code_redemptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('promo_code_id')->constrained('promo_codes')->cascadeOnDelete();
            $table->foreignId('device_id')->constrained('devices')->cascadeOnDelete();
            $table->timestamp('redeemed_at')->useCurrent();

            $table->unique(['promo_code_id', 'device_id']);
        });

        // 3. Referral rewards table (device invites another device)
        Schema::create('referrals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('referrer_device_id')->constrained('devices')->cascadeOnDelete();
            $table->foreignId('referred_device_id')->constrained('devices')->cascadeOnDelete();
            $table->unsignedInteger('reward_days')->default(7);
            $table->string('status', 30)->default('rewarded'); // pending, rewarded
            $table->timestamps();

            $table->unique(['referred_device_id']);
        });

        // 4. Add google_play_product_id to plans
        Schema::table('plans', function (Blueprint $table) {
            $table->string('google_play_product_id', 100)->nullable()->after('slug');
            $table->boolean('is_featured')->default(false)->after('is_active');
        });

        // 5. Add payment tracking details to subscriptions
        Schema::table('subscriptions', function (Blueprint $table) {
            $table->unsignedInteger('amount_paid_cents')->default(0)->after('store');
            $table->string('currency', 10)->default('USD')->after('amount_paid_cents');
            $table->boolean('is_auto_renewing')->default(true)->after('order_id');
            $table->json('raw_verification_payload')->nullable()->after('is_auto_renewing');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subscriptions', function (Blueprint $table) {
            $table->dropColumn(['amount_paid_cents', 'currency', 'is_auto_renewing', 'raw_verification_payload']);
        });

        Schema::table('plans', function (Blueprint $table) {
            $table->dropColumn(['google_play_product_id', 'is_featured']);
        });

        Schema::dropIfExists('referrals');
        Schema::dropIfExists('promo_code_redemptions');
        Schema::dropIfExists('promo_codes');
    }
};
