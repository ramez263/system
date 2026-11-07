<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Server;
use App\Services\ServerProbeService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdminServerController extends Controller
{
    /**
     * Curated and dedicated server pool list.
     */
    public function index(Request $request): View
    {
        $query = Server::query();

        if ($request->filled('country')) {
            $query->where('country_code', strtoupper($request->query('country')));
        }

        if ($request->filled('protocol')) {
            $query->where('protocol', $request->query('protocol'));
        }

        if ($request->query('tier') === 'premium') {
            $query->where('is_premium', true);
        } elseif ($request->query('tier') === 'free') {
            $query->where('is_premium', false);
        }

        $servers = $query->orderBy('is_active', 'desc')->orderBy('ping_ms', 'asc')->paginate(20)->withQueryString();

        $stats = [
            'total' => Server::count(),
            'online' => Server::where('is_active', true)->count(),
            'offline' => Server::where('is_active', false)->count(),
            'avg_ping' => (int) Server::avg('ping_ms'),
            'avg_load' => (int) Server::avg('current_load'),
        ];

        return view('admin.servers.index', compact('servers', 'stats'));
    }

    /**
     * Add new server node to the pool.
     */
    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'country_code' => ['required', 'string', 'size:2'],
            'country_name' => ['required', 'string', 'max:100'],
            'city' => ['required', 'string', 'max:100'],
            'flag_emoji' => ['nullable', 'string', 'max:10'],
            'protocol' => ['required', 'string', 'in:ovpn,wireguard,vless,vmess,trojan,ssh'],
            'ip_address' => ['required', 'string'],
            'port' => ['required', 'integer', 'between:1,65535'],
            'is_premium' => ['boolean'],
            'is_active' => ['boolean'],
            'ovpn_config' => ['nullable', 'string'],
        ]);

        $validated['country_code'] = strtoupper($validated['country_code']);
        $validated['flag_emoji'] = $validated['flag_emoji'] ?? '🌐';
        $validated['ping_ms'] = 45;
        $validated['current_load'] = 15;
        $validated['is_premium'] = $request->boolean('is_premium');
        $validated['is_active'] = $request->has('is_active') ? $request->boolean('is_active') : true;

        $server = Server::create($validated);

        AuditLog::record(
            action: 'server.created',
            resourceType: 'Server',
            resourceId: $server->id,
            details: [
                'name' => $server->name,
                'ip' => $server->ip_address,
                'country' => $server->country_code,
                'protocol' => $server->protocol,
            ]
        );

        return redirect()->route('admin.servers.index')->with('success', "Server '{$server->name}' successfully deployed to cluster.");
    }

    /**
     * Update an existing server node.
     */
    public function update(Request $request, int $id): RedirectResponse
    {
        $server = Server::findOrFail($id);

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'country_code' => ['required', 'string', 'size:2'],
            'country_name' => ['required', 'string', 'max:100'],
            'city' => ['required', 'string', 'max:100'],
            'flag_emoji' => ['nullable', 'string', 'max:10'],
            'protocol' => ['required', 'string', 'in:ovpn,wireguard,vless,vmess,trojan,ssh'],
            'ip_address' => ['required', 'string'],
            'port' => ['required', 'integer', 'between:1,65535'],
            'is_premium' => ['boolean'],
            'is_active' => ['boolean'],
            'ovpn_config' => ['nullable', 'string'],
        ]);

        $validated['country_code'] = strtoupper($validated['country_code']);
        $validated['is_premium'] = $request->boolean('is_premium');
        $validated['is_active'] = $request->boolean('is_active');

        $server->update($validated);

        AuditLog::record(
            action: 'server.updated',
            resourceType: 'Server',
            resourceId: $server->id,
            details: ['name' => $server->name, 'ip' => $server->ip_address]
        );

        return redirect()->route('admin.servers.index')->with('success', "Server '{$server->name}' configuration updated.");
    }

    /**
     * Toggle server active state.
     */
    public function toggle(int $id): RedirectResponse
    {
        $server = Server::findOrFail($id);
        $server->is_active = !$server->is_active;
        $server->save();

        AuditLog::record(
            action: 'server.toggled',
            resourceType: 'Server',
            resourceId: $server->id,
            details: [
                'name' => $server->name,
                'is_active' => $server->is_active,
            ]
        );

        $state = $server->is_active ? 'ENABLED' : 'DISABLED';
        return redirect()->back()->with('success', "Server '{$server->name}' is now {$state}.");
    }

    /**
     * Trigger live health probe on an individual server.
     */
    public function probe(int $id, ServerProbeService $probeService): RedirectResponse
    {
        $server = Server::findOrFail($id);
        $result = $probeService->probeServer($server);

        AuditLog::record(
            action: 'server.probed',
            resourceType: 'Server',
            resourceId: $server->id,
            details: $result
        );

        return redirect()->back()->with('success', "Probe completed for '{$server->name}': {$result['status']} ({$result['ping_ms']}ms, load {$result['load']}%).");
    }

    /**
     * Remove server from pool.
     */
    public function destroy(int $id): RedirectResponse
    {
        $server = Server::findOrFail($id);
        $name = $server->name;

        AuditLog::record(
            action: 'server.deleted',
            resourceType: 'Server',
            resourceId: $server->id,
            details: ['name' => $name, 'ip' => $server->ip_address]
        );

        $server->delete();

        return redirect()->route('admin.servers.index')->with('success', "Server '{$name}' decommissioned and removed.");
    }
}
