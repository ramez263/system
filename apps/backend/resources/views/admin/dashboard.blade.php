@extends('admin.layout')

@section('title', 'Executive Dashboard')
@section('page_title', 'Dashboard Overview')

@section('content')
<div class="space-y-8">
    <!-- Header Summary & Quick Controls -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4 bg-slate-900 border border-slate-800 rounded-2xl p-6">
        <div>
            <h2 class="text-xl font-bold text-white tracking-tight flex items-center">
                <i class="fa-solid fa-satellite-dish text-sky-400 mr-3"></i>
                Control Plane Live Telemetry
            </h2>
            <p class="text-sm text-slate-400 mt-1">Zero-login device authentication & curated high-performance OpenVPN pool.</p>
        </div>
        <div class="flex items-center flex-wrap gap-2">
            <a href="{{ route('admin.servers.index') }}" class="inline-flex items-center px-3.5 py-2 rounded-xl text-xs font-semibold bg-sky-600 hover:bg-sky-500 text-white shadow-lg shadow-sky-600/20 transition">
                <i class="fa-solid fa-plus mr-1.5"></i> Add Server
            </a>
            <a href="{{ route('admin.plans.index') }}" class="inline-flex items-center px-3.5 py-2 rounded-xl text-xs font-semibold bg-emerald-600 hover:bg-emerald-500 text-white shadow-lg shadow-emerald-600/20 transition">
                <i class="fa-solid fa-ticket mr-1.5"></i> New Promo
            </a>
            <form method="POST" action="{{ route('admin.remote_config.maintenance') }}" class="inline">
                @csrf
                <button type="submit" class="inline-flex items-center px-3.5 py-2 rounded-xl text-xs font-semibold bg-slate-800 hover:bg-slate-700 text-amber-400 border border-slate-700 transition">
                    <i class="fa-solid fa-power-off mr-1.5"></i> Maintenance Mode
                </button>
            </form>
        </div>
    </div>

    <!-- 4 Primary KPI Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        <!-- 1. Devices -->
        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-lg shadow-slate-950/40 relative overflow-hidden">
            <div class="flex items-center justify-between">
                <div>
                    <span class="text-xs font-semibold uppercase tracking-wider text-slate-400">Hardware Devices</span>
                    <h3 class="text-3xl font-extrabold text-white mt-2">{{ number_format($stats['total_devices']) }}</h3>
                </div>
                <div class="w-12 h-12 rounded-xl bg-sky-500/10 border border-sky-500/20 flex items-center justify-center text-sky-400 text-xl">
                    <i class="fa-solid fa-mobile-screen"></i>
                </div>
            </div>
            <div class="mt-4 pt-3 border-t border-slate-800/80 flex items-center justify-between text-xs text-slate-400">
                <span>Active: <strong class="text-emerald-400">{{ $stats['active_devices'] }}</strong></span>
                <span>Premium: <strong class="text-amber-400">{{ $stats['premium_devices'] }}</strong></span>
            </div>
        </div>

        <!-- 2. Servers Pool -->
        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-lg shadow-slate-950/40 relative overflow-hidden">
            <div class="flex items-center justify-between">
                <div>
                    <span class="text-xs font-semibold uppercase tracking-wider text-slate-400">Curated Nodes</span>
                    <h3 class="text-3xl font-extrabold text-white mt-2">{{ $stats['active_servers'] }}/{{ $stats['total_servers'] }}</h3>
                </div>
                <div class="w-12 h-12 rounded-xl bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center text-emerald-400 text-xl">
                    <i class="fa-solid fa-server"></i>
                </div>
            </div>
            <div class="mt-4 pt-3 border-t border-slate-800/80 flex items-center justify-between text-xs text-slate-400">
                <span>Avg Latency: <strong class="text-sky-400">{{ $stats['avg_server_ping'] }}ms</strong></span>
                <span>Avg Load: <strong class="text-emerald-400">{{ $stats['avg_server_load'] }}%</strong></span>
            </div>
        </div>

        <!-- 3. Subscriptions & Revenue -->
        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-lg shadow-slate-950/40 relative overflow-hidden">
            <div class="flex items-center justify-between">
                <div>
                    <span class="text-xs font-semibold uppercase tracking-wider text-slate-400">Active VIP Subs</span>
                    <h3 class="text-3xl font-extrabold text-white mt-2">{{ number_format($stats['active_subscriptions']) }}</h3>
                </div>
                <div class="w-12 h-12 rounded-xl bg-purple-500/10 border border-purple-500/20 flex items-center justify-center text-purple-400 text-xl">
                    <i class="fa-solid fa-gem"></i>
                </div>
            </div>
            <div class="mt-4 pt-3 border-t border-slate-800/80 flex items-center justify-between text-xs text-slate-400">
                <span>Est. MRR: <strong class="text-emerald-400">${{ number_format($stats['estimated_revenue'], 2) }}</strong></span>
                <span>Vouchers: <strong class="text-slate-300">{{ $stats['total_promo_codes'] }}</strong></span>
            </div>
        </div>

        <!-- 4. Bandwidth Volume -->
        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-lg shadow-slate-950/40 relative overflow-hidden">
            <div class="flex items-center justify-between">
                <div>
                    <span class="text-xs font-semibold uppercase tracking-wider text-slate-400">Total Bandwidth</span>
                    <h3 class="text-3xl font-extrabold text-white mt-2">{{ $stats['bandwidth_gb'] }} <span class="text-lg font-normal text-slate-400">GB</span></h3>
                </div>
                <div class="w-12 h-12 rounded-xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center text-amber-400 text-xl">
                    <i class="fa-solid fa-arrow-right-arrow-left"></i>
                </div>
            </div>
            <div class="mt-4 pt-3 border-t border-slate-800/80 flex items-center justify-between text-xs text-slate-400">
                <span>Down: <strong class="text-sky-400">{{ $stats['download_gb'] }} GB</strong></span>
                <span>Up: <strong class="text-indigo-400">{{ $stats['upload_gb'] }} GB</strong></span>
            </div>
        </div>
    </div>

    <!-- Middle Section: Server Health Glance & Protocols -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Servers Cluster Live Monitor (2 cols) -->
        <div class="lg:col-span-2 bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-base font-bold text-white flex items-center">
                    <i class="fa-solid fa-network-wired text-sky-400 mr-2"></i>
                    Curated Server Nodes Status
                </h3>
                <a href="{{ route('admin.servers.index') }}" class="text-xs text-sky-400 hover:text-sky-300 font-medium">Manage All &rarr;</a>
            </div>
            <div class="overflow-x-auto">
                <table class="w-full text-left text-xs">
                    <thead>
                        <tr class="border-b border-slate-800 text-slate-400 uppercase text-[10px] tracking-wider">
                            <th class="py-2.5 px-3">Location / Name</th>
                            <th class="py-2.5 px-3">Protocol</th>
                            <th class="py-2.5 px-3">Ping</th>
                            <th class="py-2.5 px-3">Load</th>
                            <th class="py-2.5 px-3">Tier</th>
                            <th class="py-2.5 px-3 text-right">State</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-800/60">
                        @foreach($servers as $srv)
                        <tr class="hover:bg-slate-800/40 transition">
                            <td class="py-2.5 px-3 font-medium text-white flex items-center space-x-2">
                                <span class="text-base">{{ $srv->flag_emoji }}</span>
                                <div>
                                    <div class="font-semibold">{{ $srv->name }}</div>
                                    <div class="text-[10px] text-slate-500 font-mono">{{ $srv->city }}, {{ $srv->country_code }} &bull; {{ $srv->ip_address }}:{{ $srv->port }}</div>
                                </div>
                            </td>
                            <td class="py-2.5 px-3 uppercase font-mono font-bold text-[10px] text-sky-400">{{ $srv->protocol }}</td>
                            <td class="py-2.5 px-3 font-mono">
                                <span class="px-2 py-0.5 rounded text-[10px] font-semibold {{ $srv->ping_ms < 60 ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-amber-500/10 text-amber-400 border border-amber-500/20' }}">
                                    {{ $srv->ping_ms }}ms
                                </span>
                            </td>
                            <td class="py-2.5 px-3">
                                <div class="w-20 bg-slate-800 rounded-full h-1.5 overflow-hidden">
                                    <div class="bg-sky-500 h-1.5 rounded-full" style="width: {{ min(100, $srv->current_load) }}%"></div>
                                </div>
                                <span class="text-[10px] text-slate-400 mt-0.5 block">{{ $srv->current_load }}%</span>
                            </td>
                            <td class="py-2.5 px-3">
                                @if($srv->is_premium)
                                    <span class="px-2 py-0.5 rounded text-[10px] font-semibold bg-amber-500/10 text-amber-400 border border-amber-500/20">VIP</span>
                                @else
                                    <span class="px-2 py-0.5 rounded text-[10px] font-semibold bg-slate-800 text-slate-300">FREE</span>
                                @endif
                            </td>
                            <td class="py-2.5 px-3 text-right">
                                @if($srv->is_active)
                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 mr-1 animate-pulse"></span> ONLINE
                                    </span>
                                @else
                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-rose-500/10 text-rose-400 border border-rose-500/20">
                                        OFFLINE
                                    </span>
                                @endif
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Protocol & Config Stats (1 col) -->
        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40 flex flex-col justify-between">
            <div>
                <h3 class="text-base font-bold text-white flex items-center mb-4">
                    <i class="fa-solid fa-layer-group text-purple-400 mr-2"></i>
                    Tunnel Protocols Pool
                </h3>
                <div class="space-y-3">
                    @forelse($protocolStats as $protocol => $count)
                    <div class="bg-slate-950/60 border border-slate-800 p-3 rounded-xl flex items-center justify-between">
                        <div class="flex items-center space-x-2">
                            <span class="w-2.5 h-2.5 rounded-full bg-sky-400"></span>
                            <span class="font-bold uppercase text-xs tracking-wider text-slate-200">{{ $protocol }}</span>
                        </div>
                        <span class="text-xs font-mono font-semibold text-slate-400 bg-slate-900 px-2 py-0.5 rounded border border-slate-800">{{ $count }} configs</span>
                    </div>
                    @empty
                    <div class="text-xs text-slate-500 py-4 text-center">OpenVPN Ready Pool Initialized</div>
                    @endforelse
                </div>
            </div>

            <div class="mt-6 pt-4 border-t border-slate-800">
                <div class="text-xs text-slate-400 mb-2">Remote Configuration Status:</div>
                <div class="flex items-center justify-between text-xs bg-slate-950 p-2.5 rounded-xl border border-slate-800">
                    <span class="text-slate-300">Min Client Version:</span>
                    <span class="font-mono text-sky-400 font-bold">1.0.0</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Bottom Section: Recent Connection Sessions & Security Audit Logs -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Recent Sessions -->
        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-base font-bold text-white flex items-center">
                    <i class="fa-solid fa-clock-rotate-left text-emerald-400 mr-2"></i>
                    Recent Connection Sessions
                </h3>
                <a href="{{ route('admin.analytics') }}" class="text-xs text-sky-400 hover:text-sky-300">View Analytics &rarr;</a>
            </div>
            <div class="divide-y divide-slate-800/60">
                @forelse($recentSessions as $session)
                <div class="py-3 flex items-center justify-between text-xs">
                    <div>
                        <div class="font-mono text-slate-200 font-semibold">{{ substr($session->device?->device_uuid ?? 'Anonymous', 0, 16) }}...</div>
                        <div class="text-[10px] text-slate-500">Node: {{ $session->server?->name ?? 'Curated OpenVPN' }} &bull; {{ $session->protocol }}</div>
                    </div>
                    <div class="text-right">
                        <div class="font-mono text-sky-400">{{ round(($session->bytes_downloaded + $session->bytes_uploaded) / (1024*1024), 2) }} MB</div>
                        <div class="text-[10px] text-slate-500">{{ $session->created_at?->diffForHumans() }}</div>
                    </div>
                </div>
                @empty
                <p class="text-xs text-slate-500 py-6 text-center">No telemetry sessions recorded yet.</p>
                @endforelse
            </div>
        </div>

        <!-- Recent Audit Trail -->
        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-base font-bold text-white flex items-center">
                    <i class="fa-solid fa-shield-halved text-amber-400 mr-2"></i>
                    Administrative Audit Trail
                </h3>
                <a href="{{ route('admin.audit_logs.index') }}" class="text-xs text-sky-400 hover:text-sky-300">All Logs &rarr;</a>
            </div>
            <div class="divide-y divide-slate-800/60">
                @forelse($recentAudits as $audit)
                <div class="py-3 flex items-center justify-between text-xs">
                    <div>
                        <div class="font-medium text-slate-200">
                            <span class="font-mono text-sky-400 uppercase text-[10px] bg-slate-950 px-1.5 py-0.5 rounded border border-slate-800 mr-1.5">{{ $audit->action }}</span>
                            {{ $audit->admin_email }}
                        </div>
                        <div class="text-[10px] text-slate-500 mt-0.5">Target: {{ $audit->resource_type }} #{{ $audit->resource_id ?? '-' }} &bull; IP: {{ $audit->ip_address }}</div>
                    </div>
                    <div class="text-right text-[10px] text-slate-500 font-mono">
                        {{ $audit->created_at->diffForHumans() }}
                    </div>
                </div>
                @empty
                <p class="text-xs text-slate-500 py-6 text-center">Audit trail clean and operational.</p>
                @endforelse
            </div>
        </div>
    </div>
</div>
@endsection
