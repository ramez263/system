<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class AdminAuth
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        if (!Auth::guard('web')->check()) {
            if ($request->expectsJson()) {
                return response()->json(['message' => 'Unauthenticated.'], 401);
            }
            return redirect()->guest(route('admin.login'))->with('error', 'Please authenticate to access the Control Plane.');
        }

        $user = Auth::guard('web')->user();

        if (!$user->is_active) {
            Auth::guard('web')->logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            return redirect()->route('admin.login')->with('error', 'Your administrative account has been suspended.');
        }

        if (!empty($roles)) {
            if (!$user->hasRole($roles)) {
                if ($request->expectsJson()) {
                    return response()->json(['message' => 'Forbidden. Insufficient administrative privileges.'], 403);
                }
                abort(403, 'Forbidden: Your role (' . $user->role . ') does not permit this operation.');
            }
        }

        return $next($request);
    }
}
