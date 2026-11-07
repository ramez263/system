<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Configuration;
use App\Models\ConnectionSession;
use App\Models\Device;
use App\Models\Plan;
use App\Models\PromoCode;
use App\Models\Server;
use App\Models\Subscription;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class AdminDashboardController extends Controller
{
    /**
     * Admin dashboard executive summary.
     */
    public function index(): View
    {
        $totalBytesDown = Device::sum('bytes_downloaded');
        $totalBytesUp = Device::sum('bytes_uploaded');
        $totalBandwidthGb = round(($totalBytesDown + $totalBytesUp) / (1024 * 1024 * 1024), 2);

        $activeSubsCount = Subscription::whereIn('status', ['active', 'in_grace_period'])->count();
        $monthlyRevenueCents = DB::table('subscriptions')
            ->join('plans', 'subscriptions.plan_id', '=', 'plans.id')
            ->whereIn('subscriptions.status', ['active', 'in_grace_period'])
            ->sum('plans.price_cents');

        $stats = [
            'total_devices' => Device::count(),
            'active_devices' => Device::where('is_active', true)->count(),
            'premium_devices' => Device::where('is_premium', true)->count(),
            'total_servers' => Server::count(),
            'active_servers' => Server::where('is_active', true)->count(),
            'avg_server_load' => round(Server::avg('current_load') ?? 0, 1),
            'avg_server_ping' => round(Server::avg('ping_ms') ?? 0, 0),
            'total_configs' => Configuration::count(),
            'total_plans' => Plan::count(),
            'active_subscriptions' => $activeSubsCount,
            'estimated_revenue' => round($monthlyRevenueCents / 100, 2),
            'total_promo_codes' => PromoCode::count(),
            'total_sessions' => ConnectionSession::count(),
            'bandwidth_gb' => $totalBandwidthGb,
            'download_gb' => round($totalBytesDown / (1024 * 1024 * 1024), 2),
            'upload_gb' => round($totalBytesUp / (1024 * 1024 * 1024), 2),
        ];

        $recentDevices = Device::latest('last_handshake_at')->take(6)->get();
        $servers = Server::orderBy('is_active', 'desc')->orderBy('ping_ms', 'asc')->take(8)->get();
        $recentSessions = ConnectionSession::with(['device', 'server'])->latest()->take(6)->get();
        $recentAudits = AuditLog::latest('created_at')->take(8)->get();

        // Protocol breakdown
        $protocolStats = Configuration::select('protocol', DB::raw('count(*) as count'))
            ->groupBy('protocol')
            ->pluck('count', 'protocol')
            ->toArray();

        return view('admin.dashboard', compact(
            'stats',
            'recentDevices',
            'servers',
            'recentSessions',
            'recentAudits',
            'protocolStats'
        ));
    }

    /**
     * Deep-dive analytics and telemetry view.
     */
    public function analytics(): View
    {
        $serverCountryStats = Server::select('country_code', 'country_name', DB::raw('count(*) as count'), DB::raw('avg(ping_ms) as avg_ping'), DB::raw('avg(current_load) as avg_load'))
            ->groupBy('country_code', 'country_name')
            ->orderBy('count', 'desc')
            ->get();

        $osBreakdown = Device::select('platform', DB::raw('count(*) as count'))
            ->groupBy('platform')
            ->pluck('count', 'platform')
            ->toArray();

        $tierBreakdown = [
            'Free Users' => Device::where('is_premium', false)->count(),
            'Premium VIP' => Device::where('is_premium', true)->count(),
        ];

        $recentSessions = ConnectionSession::with(['device', 'server'])
            ->latest()
            ->paginate(15);

        return view('admin.analytics', compact(
            'serverCountryStats',
            'osBreakdown',
            'tierBreakdown',
            'recentSessions'
        ));
    }
}
