<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Configuration;
use App\Models\ConnectionSession;
use App\Models\Device;
use App\Models\Plan;
use App\Models\Server;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdminDashboardController extends Controller
{
    /**
     * Admin dashboard summary.
     */
    public function index(): View
    {
        $stats = [
            'total_devices' => Device::count(),
            'active_devices' => Device::where('is_active', true)->count(),
            'total_servers' => Server::count(),
            'active_servers' => Server::where('is_active', true)->count(),
            'total_configs' => Configuration::count(),
            'total_plans' => Plan::count(),
            'total_sessions' => ConnectionSession::count(),
            'total_download_bytes' => Device::sum('bytes_downloaded'),
            'total_upload_bytes' => Device::sum('bytes_uploaded'),
        ];

        $recentDevices = Device::latest('last_handshake_at')->take(8)->get();
        $servers = Server::orderBy('current_load', 'asc')->get();
        $recentSessions = ConnectionSession::with(['device', 'server'])->latest()->take(8)->get();

        return view('admin.dashboard', compact('stats', 'recentDevices', 'servers', 'recentSessions'));
    }

    /**
     * Curated server management list.
     */
    public function servers(): View
    {
        $servers = Server::orderBy('is_active', 'desc')->orderBy('ping_ms', 'asc')->get();
        return view('admin.servers', compact('servers'));
    }

    /**
     * Devices explorer.
     */
    public function devices(Request $request): View
    {
        $query = Device::query();
        if ($request->filled('search')) {
            $term = '%' . $request->query('search') . '%';
            $query->where('device_uuid', 'like', $term)
                  ->orWhere('device_name', 'like', $term);
        }

        $devices = $query->latest('last_handshake_at')->paginate(25);
        return view('admin.devices', compact('devices'));
    }

    /**
     * Toggle server active state.
     */
    public function toggleServer(int $id)
    {
        $server = Server::findOrFail($id);
        $server->update(['is_active' => !$server->is_active]);

        return redirect()->back()->with('success', "Server '{$server->name}' active status toggled.");
    }
}
