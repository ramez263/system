<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

class AdminAuthController extends Controller
{
    /**
     * Show admin login form.
     */
    public function showLogin(): View|RedirectResponse
    {
        if (Auth::guard('web')->check()) {
            return redirect()->route('admin.dashboard');
        }

        return view('admin.auth.login');
    }

    /**
     * Authenticate administrative user.
     */
    public function login(Request $request): RedirectResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $remember = $request->boolean('remember');

        if (!Auth::guard('web')->attempt($credentials, $remember)) {
            throw ValidationException::withMessages([
                'email' => __('auth.failed'),
            ]);
        }

        $user = Auth::guard('web')->user();

        if (!$user->is_active) {
            Auth::guard('web')->logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            return redirect()->route('admin.login')->with('error', 'Your administrative account has been suspended.');
        }

        $request->session()->regenerate();

        AuditLog::record(
            action: 'admin.login',
            resourceType: 'User',
            resourceId: $user->id,
            details: ['email' => $user->email, 'role' => $user->role]
        );

        return redirect()->intended(route('admin.dashboard'))->with('success', "Welcome back, {$user->name}!");
    }

    /**
     * Log out of administrative session.
     */
    public function logout(Request $request): RedirectResponse
    {
        $user = Auth::guard('web')->user();

        if ($user) {
            AuditLog::record(
                action: 'admin.logout',
                resourceType: 'User',
                resourceId: $user->id,
                details: ['email' => $user->email]
            );
        }

        Auth::guard('web')->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.login')->with('success', 'Logged out successfully.');
    }
}
