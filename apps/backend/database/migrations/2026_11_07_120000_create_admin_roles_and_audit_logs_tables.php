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
        // 1. Add role & is_active to users table
        Schema::table('users', function (Blueprint $table) {
            $table->string('role', 30)->default('read_only')->after('email');
            $table->boolean('is_active')->default(true)->after('role');
        });

        // 2. Audit logs table for full admin operation tracking
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable()->index();
            $table->string('admin_email')->nullable();
            $table->string('action', 80)->index();
            $table->string('resource_type', 80)->nullable();
            $table->string('resource_id', 100)->nullable();
            $table->json('details')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->timestamp('created_at')->useCurrent()->index();

            $table->foreign('user_id')->references('id')->on('users')->nullOnDelete();
        });

        // 3. App Releases & Remote Version Management
        Schema::create('app_releases', function (Blueprint $table) {
            $table->id();
            $table->string('version', 20)->index();
            $table->unsignedInteger('build_number');
            $table->string('platform', 20)->default('android');
            $table->string('min_supported_version', 20)->default('1.0.0');
            $table->boolean('force_update')->default(false);
            $table->string('download_url', 500)->nullable();
            $table->text('release_notes')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('app_releases');
        Schema::dropIfExists('audit_logs');

        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['role', 'is_active']);
        });
    }
};
