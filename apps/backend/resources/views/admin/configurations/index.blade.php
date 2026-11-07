@extends('admin.layout')

@section('title', 'Configurations (.rtp)')
@section('page_title', 'Configurations & Export Locking Manager')

@section('content')
<div class="space-y-6">
    <!-- Stats Cards -->
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Total Configs</span>
            <div class="text-2xl font-bold text-white mt-1">{{ $stats['total'] }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Active / Published</span>
            <div class="text-2xl font-bold text-emerald-400 mt-1">{{ $stats['active'] }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Export Locked</span>
            <div class="text-2xl font-bold text-amber-400 mt-1">{{ $stats['locked'] }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Total Downloads</span>
            <div class="text-2xl font-bold text-sky-400 mt-1">{{ number_format($stats['downloads']) }}</div>
        </div>
    </div>

    <!-- Create Configuration Form -->
    <details class="bg-slate-900 border border-slate-800 rounded-2xl p-6 group">
        <summary class="flex items-center justify-between cursor-pointer text-white font-bold text-sm">
            <span class="flex items-center">
                <i class="fa-solid fa-file-code text-sky-400 mr-2.5"></i>
                Create & Publish New VPN Configuration (.rtp v1.0)
            </span>
            <span class="text-xs text-sky-400 group-open:hidden">+ New Configuration</span>
            <span class="text-xs text-slate-500 hidden group-open:inline">&times; Close</span>
        </summary>

        <form method="POST" action="{{ route('admin.configurations.store') }}" class="mt-6 pt-6 border-t border-slate-800 grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
            @csrf
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Config Name *</label>
                <input type="text" name="name" required placeholder="e.g. Egypt Orange Fast UDP"
                    class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white focus:outline-none focus:ring-2 focus:ring-sky-500">
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Protocol *</label>
                <select name="protocol" class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white">
                    <option value="ovpn">OpenVPN (.ovpn)</option>
                    <option value="wireguard">WireGuard (.conf)</option>
                    <option value="vless">VLESS</option>
                    <option value="vmess">VMess</option>
                    <option value="trojan">Trojan</option>
                    <option value="rtp">RTP Native Package</option>
                    <option value="ssh">SSH Tunnel</option>
                </select>
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Target Curated Server</label>
                <select name="server_id" class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white">
                    <option value="">No server bound (Standalone Payload)</option>
                    @foreach($servers as $s)
                        <option value="{{ $s->id }}">{{ $s->name }} ({{ $s->country_code }}) - {{ $s->ip_address }}</option>
                    @endforeach
                </select>
            </div>
            <div class="md:col-span-2">
                <label class="block text-slate-300 font-semibold mb-1">Short Description</label>
                <input type="text" name="description" placeholder="High-speed gaming and browsing profile optimized for Egyptian ISPs."
                    class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white">
            </div>
            <div class="flex items-center space-x-6 pt-5">
                <label class="flex items-center text-slate-300 cursor-pointer">
                    <input type="checkbox" name="export_locked" value="1" checked class="rounded bg-slate-950 border-slate-700 text-amber-500 focus:ring-amber-500 mr-2">
                    <span class="font-bold text-amber-400">Lock Export</span> (Prevent extraction)
                </label>
                <label class="flex items-center text-slate-300 cursor-pointer">
                    <input type="checkbox" name="is_public" value="1" checked class="rounded bg-slate-950 border-slate-700 text-sky-500 focus:ring-sky-500 mr-2">
                    Public Share
                </label>
            </div>
            <div class="md:col-span-3">
                <label class="block text-slate-300 font-semibold mb-1">Configuration Payload / Data *</label>
                <textarea name="config_data" rows="4" required placeholder="Raw OpenVPN, sing-box JSON, or WireGuard configuration content..."
                    class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 font-mono text-xs text-slate-300 focus:outline-none focus:ring-2 focus:ring-sky-500"></textarea>
            </div>
            <div class="md:col-span-3 text-right">
                <button type="submit" class="bg-sky-600 hover:bg-sky-500 text-white font-semibold px-6 py-2.5 rounded-xl transition shadow-lg shadow-sky-600/30">
                    <i class="fa-solid fa-cloud-arrow-up mr-1.5"></i> Publish Config
                </button>
            </div>
        </form>
    </details>

    <!-- Configurations Table -->
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 text-slate-400 uppercase text-[10px] tracking-wider">
                        <th class="py-3 px-3">Share Code</th>
                        <th class="py-3 px-3">Configuration Name</th>
                        <th class="py-3 px-3">Protocol</th>
                        <th class="py-3 px-3">Bound Node</th>
                        <th class="py-3 px-3">Security</th>
                        <th class="py-3 px-3">Downloads</th>
                        <th class="py-3 px-3">Status</th>
                        <th class="py-3 px-3 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($configurations as $cfg)
                    <tr class="hover:bg-slate-800/40 transition">
                        <td class="py-3 px-3 font-mono font-bold text-sky-400">
                            <span class="bg-slate-950 px-2 py-1 rounded border border-slate-800 select-all">
                                {{ $cfg->share_code }}
                            </span>
                        </td>
                        <td class="py-3 px-3">
                            <div class="font-bold text-white">{{ $cfg->name }}</div>
                            <div class="text-[10px] text-slate-400">{{ Str::limit($cfg->description, 45) }}</div>
                        </td>
                        <td class="py-3 px-3 uppercase font-mono font-bold text-[10px] text-indigo-400">
                            {{ $cfg->protocol }}
                        </td>
                        <td class="py-3 px-3 text-slate-300">
                            {{ $cfg->server?->name ?? 'Standalone' }}
                        </td>
                        <td class="py-3 px-3">
                            @if($cfg->export_locked)
                                <span class="px-2 py-0.5 rounded text-[10px] font-semibold bg-amber-500/10 text-amber-400 border border-amber-500/20">
                                    <i class="fa-solid fa-lock text-[9px] mr-1"></i> LOCKED
                                </span>
                            @else
                                <span class="px-2 py-0.5 rounded text-[10px] font-semibold bg-slate-800 text-slate-400">
                                    OPEN
                                </span>
                            @endif
                        </td>
                        <td class="py-3 px-3 font-mono text-slate-300">
                            {{ $cfg->downloads_count }}
                        </td>
                        <td class="py-3 px-3">
                            @if($cfg->is_active)
                                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                                    ACTIVE
                                </span>
                            @else
                                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-rose-500/10 text-rose-400 border border-rose-500/20">
                                    DISABLED
                                </span>
                            @endif
                        </td>
                        <td class="py-3 px-3 text-right">
                            <div class="flex items-center justify-end space-x-1.5">
                                <form method="POST" action="{{ route('admin.configurations.toggle', $cfg->id) }}" class="inline">
                                    @csrf
                                    <button type="submit" class="p-1.5 rounded-lg {{ $cfg->is_active ? 'text-amber-400 hover:text-amber-300' : 'text-emerald-400 hover:text-emerald-300' }} hover:bg-slate-800 transition" title="{{ $cfg->is_active ? 'Disable' : 'Enable' }}">
                                        <i class="fa-solid {{ $cfg->is_active ? 'fa-pause' : 'fa-play' }}"></i>
                                    </button>
                                </form>
                                <form method="POST" action="{{ route('admin.configurations.destroy', $cfg->id) }}" class="inline">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" onclick="return confirm('Delete configuration {{ $cfg->name }}?')" class="p-1.5 rounded-lg text-slate-400 hover:text-rose-400 hover:bg-slate-800 transition" title="Delete">
                                        <i class="fa-solid fa-trash-can"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="8" class="py-8 text-center text-slate-500">No configurations cataloged yet.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="mt-4">
            {{ $configurations->links() }}
        </div>
    </div>
</div>
@endsection
