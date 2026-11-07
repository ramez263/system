@extends('admin.layout')

@section('title', 'Servers Pool')
@section('page_title', 'Curated & Dedicated Servers Pool')

@section('content')
<div class="space-y-6">
    <!-- Header with KPI Stats -->
    <div class="grid grid-cols-2 sm:grid-cols-5 gap-4">
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Total Nodes</span>
            <div class="text-2xl font-bold text-white mt-1">{{ $stats['total'] }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Online</span>
            <div class="text-2xl font-bold text-emerald-400 mt-1">{{ $stats['online'] }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Offline</span>
            <div class="text-2xl font-bold text-rose-400 mt-1">{{ $stats['offline'] }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Cluster Latency</span>
            <div class="text-2xl font-bold text-sky-400 mt-1">{{ $stats['avg_ping'] }}ms</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4 col-span-2 sm:col-span-1">
            <span class="text-xs text-slate-400 font-semibold uppercase">Cluster Load</span>
            <div class="text-2xl font-bold text-purple-400 mt-1">{{ $stats['avg_load'] }}%</div>
        </div>
    </div>

    <!-- Add Server Section (Collapsible Accordion / Card) -->
    <details class="bg-slate-900 border border-slate-800 rounded-2xl p-6 group">
        <summary class="flex items-center justify-between cursor-pointer text-white font-bold text-sm">
            <span class="flex items-center">
                <i class="fa-solid fa-server text-sky-400 mr-2.5"></i>
                Deploy / Register New Curated OpenVPN Server Node
            </span>
            <span class="text-xs text-sky-400 group-open:hidden">+ Expand Form</span>
            <span class="text-xs text-slate-500 hidden group-open:inline">&times; Close</span>
        </summary>

        <form method="POST" action="{{ route('admin.servers.store') }}" class="mt-6 pt-6 border-t border-slate-800 grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
            @csrf
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Server Name *</label>
                <input type="text" name="name" required placeholder="e.g. Frankfurt Fast Node #1"
                    class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white focus:outline-none focus:ring-2 focus:ring-sky-500">
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Country Name & Code (2-char) *</label>
                <div class="grid grid-cols-3 gap-2">
                    <input type="text" name="country_name" required placeholder="Germany" class="col-span-2 bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white">
                    <input type="text" name="country_code" required maxlength="2" placeholder="DE" class="uppercase bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white text-center">
                </div>
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">City & Flag Emoji *</label>
                <div class="grid grid-cols-3 gap-2">
                    <input type="text" name="city" required placeholder="Frankfurt" class="col-span-2 bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white">
                    <input type="text" name="flag_emoji" placeholder="🇩🇪" class="bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white text-center">
                </div>
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">IP Address / Domain *</label>
                <input type="text" name="ip_address" required placeholder="185.192.68.10" class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white">
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Port & Protocol *</label>
                <div class="grid grid-cols-2 gap-2">
                    <input type="number" name="port" required value="1194" class="bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white">
                    <select name="protocol" class="bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white">
                        <option value="ovpn">OpenVPN</option>
                        <option value="wireguard">WireGuard</option>
                        <option value="vless">VLESS</option>
                        <option value="vmess">VMess</option>
                        <option value="trojan">Trojan</option>
                        <option value="ssh">SSH</option>
                    </select>
                </div>
            </div>
            <div class="flex items-center space-x-6 pt-5">
                <label class="flex items-center text-slate-300 cursor-pointer">
                    <input type="checkbox" name="is_premium" value="1" class="rounded bg-slate-950 border-slate-700 text-amber-500 focus:ring-amber-500 mr-2">
                    VIP Premium Only
                </label>
                <label class="flex items-center text-slate-300 cursor-pointer">
                    <input type="checkbox" name="is_active" value="1" checked class="rounded bg-slate-950 border-slate-700 text-sky-500 focus:ring-sky-500 mr-2">
                    Immediately Active
                </label>
            </div>
            <div class="md:col-span-3">
                <label class="block text-slate-300 font-semibold mb-1">Raw OpenVPN (.ovpn) Configuration Payload</label>
                <textarea name="ovpn_config" rows="3" placeholder="client&#10;dev tun&#10;proto udp&#10;remote 185.192.68.10 1194&#10;..."
                    class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 font-mono text-xs text-slate-300 focus:outline-none focus:ring-2 focus:ring-sky-500"></textarea>
            </div>
            <div class="md:col-span-3 text-right">
                <button type="submit" class="bg-sky-600 hover:bg-sky-500 text-white font-semibold px-6 py-2.5 rounded-xl transition shadow-lg shadow-sky-600/30">
                    <i class="fa-solid fa-cloud-arrow-up mr-1.5"></i> Deploy Node
                </button>
            </div>
        </form>
    </details>

    <!-- Servers Table -->
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-base font-bold text-white flex items-center">
                <i class="fa-solid fa-globe text-sky-400 mr-2"></i>
                Active Cluster Nodes ({{ $servers->total() }})
            </h3>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 text-slate-400 uppercase text-[10px] tracking-wider">
                        <th class="py-3 px-3">Node Location</th>
                        <th class="py-3 px-3">Protocol</th>
                        <th class="py-3 px-3">IP & Port</th>
                        <th class="py-3 px-3">Ping Latency</th>
                        <th class="py-3 px-3">Capacity Load</th>
                        <th class="py-3 px-3">Tier</th>
                        <th class="py-3 px-3">Status</th>
                        <th class="py-3 px-3 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($servers as $srv)
                    <tr class="hover:bg-slate-800/40 transition">
                        <td class="py-3 px-3 font-medium text-white flex items-center space-x-2.5">
                            <span class="text-xl">{{ $srv->flag_emoji }}</span>
                            <div>
                                <div class="font-bold text-slate-100">{{ $srv->name }}</div>
                                <div class="text-[10px] text-slate-400">{{ $srv->city }}, {{ $srv->country_name }} ({{ $srv->country_code }})</div>
                            </div>
                        </td>
                        <td class="py-3 px-3 uppercase font-mono font-bold text-[10px] text-sky-400">
                            {{ $srv->protocol }}
                        </td>
                        <td class="py-3 px-3 font-mono text-slate-300">
                            {{ $srv->ip_address }}:{{ $srv->port }}
                        </td>
                        <td class="py-3 px-3 font-mono">
                            <span class="px-2 py-0.5 rounded text-[10px] font-semibold {{ $srv->ping_ms < 60 ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-amber-500/10 text-amber-400 border border-amber-500/20' }}">
                                {{ $srv->ping_ms }}ms
                            </span>
                        </td>
                        <td class="py-3 px-3">
                            <div class="w-24 bg-slate-800 rounded-full h-1.5 overflow-hidden">
                                <div class="bg-gradient-to-r from-sky-500 to-indigo-500 h-1.5 rounded-full" style="width: {{ min(100, $srv->current_load) }}%"></div>
                            </div>
                            <span class="text-[10px] text-slate-400 mt-0.5 block">{{ $srv->current_load }}% load</span>
                        </td>
                        <td class="py-3 px-3">
                            @if($srv->is_premium)
                                <span class="px-2 py-0.5 rounded text-[10px] font-semibold bg-amber-500/10 text-amber-400 border border-amber-500/20">
                                    <i class="fa-solid fa-crown text-[9px] mr-1"></i> VIP
                                </span>
                            @else
                                <span class="px-2 py-0.5 rounded text-[10px] font-semibold bg-slate-800 text-slate-400">
                                    FREE
                                </span>
                            @endif
                        </td>
                        <td class="py-3 px-3">
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
                        <td class="py-3 px-3 text-right">
                            <div class="flex items-center justify-end space-x-1.5">
                                <!-- Test Socket Probe Button -->
                                <form method="POST" action="{{ route('admin.servers.probe', $srv->id) }}" class="inline">
                                    @csrf
                                    <button type="submit" class="p-1.5 rounded-lg text-slate-400 hover:text-sky-400 hover:bg-slate-800 transition" title="Probe Socket Latency & Health">
                                        <i class="fa-solid fa-bolt"></i>
                                    </button>
                                </form>
                                <!-- Toggle Active -->
                                <form method="POST" action="{{ route('admin.servers.toggle', $srv->id) }}" class="inline">
                                    @csrf
                                    <button type="submit" class="p-1.5 rounded-lg {{ $srv->is_active ? 'text-amber-400 hover:text-amber-300' : 'text-emerald-400 hover:text-emerald-300' }} hover:bg-slate-800 transition" title="{{ $srv->is_active ? 'Disable Server' : 'Enable Server' }}">
                                        <i class="fa-solid {{ $srv->is_active ? 'fa-pause' : 'fa-play' }}"></i>
                                    </button>
                                </form>
                                <!-- Delete Server -->
                                <form method="POST" action="{{ route('admin.servers.destroy', $srv->id) }}" class="inline">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" onclick="return confirm('Decommission and remove server node {{ $srv->name }}?')" class="p-1.5 rounded-lg text-slate-400 hover:text-rose-400 hover:bg-slate-800 transition" title="Delete Server">
                                        <i class="fa-solid fa-trash-can"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="8" class="py-8 text-center text-slate-500">No servers registered in the pool.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="mt-4">
            {{ $servers->links() }}
        </div>
    </div>
</div>
@endsection
