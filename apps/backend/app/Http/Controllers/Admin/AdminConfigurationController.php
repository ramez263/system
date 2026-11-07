<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Configuration;
use App\Models\Server;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\View\View;

class AdminConfigurationController extends Controller
{
    /**
     * List configurations with search and protocol filters.
     */
    public function index(Request $request): View
    {
        $query = Configuration::with(['server', 'device']);

        if ($request->filled('protocol')) {
            $query->where('protocol', $request->query('protocol'));
        }

        if ($request->filled('search')) {
            $term = '%' . $request->query('search') . '%';
            $query->where(function ($q) use ($term) {
                $q->where('name', 'like', $term)
                  ->orWhere('share_code', 'like', $term)
                  ->orWhere('description', 'like', $term);
            });
        }

        $configurations = $query->latest()->paginate(20)->withQueryString();
        $servers = Server::where('is_active', true)->get();

        $stats = [
            'total' => Configuration::count(),
            'active' => Configuration::where('is_active', true)->count(),
            'locked' => Configuration::where('export_locked', true)->count(),
            'downloads' => Configuration::sum('downloads_count'),
        ];

        return view('admin.configurations.index', compact('configurations', 'servers', 'stats'));
    }

    /**
     * Store new system configuration.
     */
    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'description' => ['nullable', 'string', 'max:500'],
            'protocol' => ['required', 'string', 'in:ovpn,wireguard,vless,vmess,trojan,rtp,ssh'],
            'config_data' => ['required', 'string'],
            'server_id' => ['nullable', 'exists:servers,id'],
            'export_locked' => ['boolean'],
            'is_public' => ['boolean'],
            'is_active' => ['boolean'],
        ]);

        $validated['export_locked'] = $request->boolean('export_locked');
        $validated['is_public'] = $request->has('is_public') ? $request->boolean('is_public') : true;
        $validated['is_active'] = $request->has('is_active') ? $request->boolean('is_active') : true;
        $validated['share_code'] = strtoupper(Str::random(8));

        $config = Configuration::create($validated);

        AuditLog::record(
            action: 'configuration.created',
            resourceType: 'Configuration',
            resourceId: $config->id,
            details: [
                'name' => $config->name,
                'protocol' => $config->protocol,
                'share_code' => $config->share_code,
                'export_locked' => $config->export_locked,
            ]
        );

        return redirect()->route('admin.configurations.index')->with('success', "Configuration '{$config->name}' created with share code {$config->share_code}.");
    }

    /**
     * Update an existing configuration.
     */
    public function update(Request $request, int $id): RedirectResponse
    {
        $config = Configuration::findOrFail($id);

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:120'],
            'description' => ['nullable', 'string', 'max:500'],
            'protocol' => ['required', 'string', 'in:ovpn,wireguard,vless,vmess,trojan,rtp,ssh'],
            'config_data' => ['required', 'string'],
            'server_id' => ['nullable', 'exists:servers,id'],
            'export_locked' => ['boolean'],
            'is_public' => ['boolean'],
            'is_active' => ['boolean'],
        ]);

        $validated['export_locked'] = $request->boolean('export_locked');
        $validated['is_public'] = $request->boolean('is_public');
        $validated['is_active'] = $request->boolean('is_active');

        $config->update($validated);

        AuditLog::record(
            action: 'configuration.updated',
            resourceType: 'Configuration',
            resourceId: $config->id,
            details: ['name' => $config->name, 'protocol' => $config->protocol]
        );

        return redirect()->route('admin.configurations.index')->with('success', "Configuration '{$config->name}' updated.");
    }

    /**
     * Toggle active state.
     */
    public function toggle(int $id): RedirectResponse
    {
        $config = Configuration::findOrFail($id);
        $config->is_active = !$config->is_active;
        $config->save();

        AuditLog::record(
            action: 'configuration.toggled',
            resourceType: 'Configuration',
            resourceId: $config->id,
            details: ['name' => $config->name, 'is_active' => $config->is_active]
        );

        $status = $config->is_active ? 'ENABLED' : 'DISABLED';
        return redirect()->back()->with('success', "Configuration '{$config->name}' is now {$status}.");
    }

    /**
     * Remove configuration.
     */
    public function destroy(int $id): RedirectResponse
    {
        $config = Configuration::findOrFail($id);
        $name = $config->name;

        AuditLog::record(
            action: 'configuration.deleted',
            resourceType: 'Configuration',
            resourceId: $config->id,
            details: ['name' => $name, 'share_code' => $config->share_code]
        );

        $config->delete();

        return redirect()->route('admin.configurations.index')->with('success', "Configuration '{$name}' deleted.");
    }
}
