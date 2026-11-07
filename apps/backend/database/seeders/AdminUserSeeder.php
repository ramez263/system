<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $admins = [
            [
                'name' => 'Ramez Super Admin',
                'email' => 'admin@rameztunnel.com',
                'password' => Hash::make('password123'),
                'role' => User::ROLE_SUPER_ADMIN,
                'is_active' => true,
            ],
            [
                'name' => 'Support Desk Lead',
                'email' => 'support@rameztunnel.com',
                'password' => Hash::make('password123'),
                'role' => User::ROLE_SUPPORT,
                'is_active' => true,
            ],
            [
                'name' => 'Finance Specialist',
                'email' => 'finance@rameztunnel.com',
                'password' => Hash::make('password123'),
                'role' => User::ROLE_FINANCE,
                'is_active' => true,
            ],
            [
                'name' => 'System Auditor / Viewer',
                'email' => 'viewer@rameztunnel.com',
                'password' => Hash::make('password123'),
                'role' => User::ROLE_READ_ONLY,
                'is_active' => true,
            ],
        ];

        foreach ($admins as $admin) {
            User::updateOrCreate(
                ['email' => $admin['email']],
                $admin
            );
        }
    }
}
