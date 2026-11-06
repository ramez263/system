@extends('admin.layout')

@section('title', 'Dashboard')

@section('content')
<div class="space-y-8">
    <!-- Top KPI Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div class="p-5 rounded-2xl bg-slate-900/60 border border-slate-800 shadow-sm backdrop-blur">
            <span class="text-xs uppercase font-semibold text-slate-400">Total Devices</span>
            <div class="mt-2 flex items-baseline justify-between">
                <span class="text-3xl font-extrabold text-white">{{ number_format($stats['total_devices']) }}</span>
                <span class="text-xs font-medium text-emerald-400">{{ $stats['active_devices'] }} active</span>
            </div>
        </div>

        <div class="p-5 rounded-2xl bg-slate-900/60 border border-slate-800 shadow-sm backdrop-blur">
            <span class="text-xs uppercase font-semibold text-slate-400">Curated Servers</span>
            <div class="mt-2 flex items-baseline justify-between">
                <span class="text-3xl font-extrabold text-white">{{ number_format($stats['total_servers']) }}</span>
                <span class="text-xs font-medium text-sky-400">{{ $stats['active_servers'] }} online</span>
            </div>
        </div>

        <div class="p-5 rounded-2xl bg-slate-900/60 border border-slate-800 shadow-sm backdrop-blur">
            <span class="text-xs uppercase font-semibold text-slate-400">Total Data Downloaded</span>
            <div class="mt-2 flex items-baseline justify-between">
                <span class="text-3xl font-extrabold text-indigo-400">
                    {{ round($stats['total_download_bytes'] / (1024 * 1024), 2) }} <span class="text-sm font-normal text-slate-400">MB</span>
                </span>
                <span class="text-xs font-medium text-slate-400">{{ number_format($stats['total_sessions']) }} sessions</span>
            </div>
        </div>

        <div class="p-5 rounded-2xl bg-slate-900/60 border border-slate-800 shadow-sm backdrop-blur">
            <span class="text-xs uppercase font-semibold text-slate-400">Community Configs</span>
            <div class="mt-2 flex items-baseline justify-between">
                <span class="text-3xl font-extrabold text-amber-400">{{ number_format($stats['total_configs']) }}</span>
                <span class="text-xs font-medium text-purple-400">{{ $stats['total_plans'] }} plans</span>
            </div>
        </div>
    </div>

    <!-- Live Curated Servers Table -->
    <div class="p-6 rounded-2xl bg-slate-900/60 border border-slate-800 shadow-sm">
        <div class="flex items-center justify-between mb-4">
            <div>
                <h2 class="text-lg font-bold text-white">Active Curated OpenVPN Nodes</h2>
                <p class="text-xs text-slate-400">Production ready-made endpoints available for client connections</p>
            </div>
            <a href="/admin/servers" class="text-xs font-medium text-sky-400 hover:text-sky-300">View All &rarr;</a>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-left text-sm text-slate-300">
                <thead class="text-xs uppercase bg-slate-800/50 text-slate-400">
                    <tr>
                        <th class="py-3 px-4">Server</th>
                        <th class="py-3 px-4">Country</th>
                        <th class="py-3 px-4">Protocol</th>
                        <th class="py-3 px-4">Host / Port</th>
                        <th class="py-3 px-4">Ping</th>
                        <th class="py-3 px-4">Load</th>
                        <th class="py-3 px-4">Tier</th>
                        <th class="py-3 px-4">Status</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800">
                    @forelse($servers as $server)
                    <tr class="hover:bg-slate-800/30 transition">
                        <td class="py-3 px-4 font-semibold text-white flex items-center space-x-2">
                            <span>{{ $server->flag_emoji }}</span>
                            <span>{{ $server->name }}</span>
                        </td>
                        <td class="py-3 px-4">{{ $server->country_name }} ({{ $server->country_code }})</td>
                        <td class="py-3 px-4"><span class="px-2 py-0.5 rounded text-xs bg-slate-800 font-mono">{{ strtoupper($server->protocol) }}</span></td>
                        <td class="py-3 px-4 font-mono text-xs text-slate-400">{{ $server->ip_address }}:{{ $server->port }}</td>
                        <td class="py-3 px-4 text-emerald-400 font-mono">{{ $server->ping_ms }}ms</td>
                        <td class="py-3 px-4">
                            <div class="flex items-center space-x-2">
                                <div class="w-16 bg-slate-800 rounded-full h-1.5 overflow-hidden">
                                    <div class="bg-sky-500 h-1.5 rounded-full" style="width: {{ $server->current_load }}%"></div>
                                </div>
                                <span class="text-xs font-mono text-slate-400">{{ $server->current_load }}%</span>
                            </div>
                        </td>
                        <td class="py-3 px-4">
                            @if($server->is_premium)
                                <span class="px-2 py-0.5 rounded-full text-xs bg-amber-950 text-amber-300 border border-amber-800">VIP</span>
                            @else
                                <span class="px-2 py-0.5 rounded-full text-xs bg-emerald-950 text-emerald-300 border border-emerald-800">Free</span>
                            @endif
                        </td>
                        <td class="py-3 px-4">
                            @if($server->is_active)
                                <span class="inline-flex items-center text-xs text-emerald-400">
                                    <span class="w-2 h-2 rounded-full bg-emerald-500 mr-1.5 animate-pulse"></span>
                                    Online
                                </span>
                            @else
                                <span class="inline-flex items-center text-xs text-slate-500">
                                    <span class="w-2 h-2 rounded-full bg-slate-600 mr-1.5"></span>
                                    Disabled
                                </span>
                            @endif
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="8" class="py-6 text-center text-slate-500">No servers found.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Recent Devices Handshake Table -->
    <div class="p-6 rounded-2xl bg-slate-900/60 border border-slate-800 shadow-sm">
        <div class="flex items-center justify-between mb-4">
            <div>
                <h2 class="text-lg font-bold text-white">Recent Hardware Handshakes</h2>
                <p class="text-xs text-slate-400">Frictionless device-first client registrations</p>
            </div>
            <a href="/admin/devices" class="text-xs font-medium text-sky-400 hover:text-sky-300">Explore Devices &rarr;</a>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-left text-sm text-slate-300">
                <thead class="text-xs uppercase bg-slate-800/50 text-slate-400">
                    <tr>
                        <th class="py-3 px-4">Device UUID</th>
                        <th class="py-3 px-4">Name / Model</th>
                        <th class="py-3 px-4">OS / Platform</th>
                        <th class="py-3 px-4">App Version</th>
                        <th class="py-3 px-4">Tier</th>
                        <th class="py-3 px-4">Data Usage</th>
                        <th class="py-3 px-4">Last Handshake</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800">
                    @forelse($recentDevices as $device)
                    <tr class="hover:bg-slate-800/30 transition">
                        <td class="py-3 px-4 font-mono text-xs text-sky-300">{{ $device->device_uuid }}</td>
                        <td class="py-3 px-4">{{ $device->device_name }} <span class="text-xs text-slate-500">{{ $device->model }}</span></td>
                        <td class="py-3 px-4 text-xs">{{ $device->platform }} {{ $device->os_version }}</td>
                        <td class="py-3 px-4 font-mono text-xs">{{ $device->app_version ?? 'v1.0.0' }}</td>
                        <td class="py-3 px-4">
                            @if($device->is_premium)
                                <span class="px-2 py-0.5 rounded-full text-xs bg-amber-950 text-amber-300 border border-amber-800">VIP Pro</span>
                            @else
                                <span class="px-2 py-0.5 rounded-full text-xs bg-slate-800 text-slate-300">Free Tier</span>
                            @endif
                        </td>
                        <td class="py-3 px-4 text-xs font-mono">
                            &darr; {{ round($device->bytes_downloaded / (1024 * 1024), 1) }}MB / &uarr; {{ round($device->bytes_uploaded / (1024 * 1024), 1) }}MB
                        </td>
                        <td class="py-3 px-4 text-xs text-slate-400">{{ $device->last_handshake_at?->diffForHumans() ?? 'Just now' }}</td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="7" class="py-6 text-center text-slate-500">No devices registered yet. Run the mobile app or API tests to register.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection
