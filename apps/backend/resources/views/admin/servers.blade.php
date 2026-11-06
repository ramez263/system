@extends('admin.layout')

@section('title', 'Curated Servers')

@section('content')
<div class="space-y-6">
    <div class="flex items-center justify-between">
        <div>
            <h2 class="text-xl font-bold text-white">Curated OpenVPN Nodes</h2>
            <p class="text-xs text-slate-400">Manage ready-made server endpoints available in the client catalog</p>
        </div>
    </div>

    <div class="p-6 rounded-2xl bg-slate-900/60 border border-slate-800 shadow-sm overflow-x-auto">
        <table class="w-full text-left text-sm text-slate-300">
            <thead class="text-xs uppercase bg-slate-800/50 text-slate-400">
                <tr>
                    <th class="py-3 px-4">Node Name</th>
                    <th class="py-3 px-4">Location</th>
                    <th class="py-3 px-4">Protocol</th>
                    <th class="py-3 px-4">Endpoint</th>
                    <th class="py-3 px-4">Ping</th>
                    <th class="py-3 px-4">Load</th>
                    <th class="py-3 px-4">Tier</th>
                    <th class="py-3 px-4">Status</th>
                    <th class="py-3 px-4 text-right">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-800">
                @forelse($servers as $server)
                <tr class="hover:bg-slate-800/30 transition">
                    <td class="py-3 px-4 font-semibold text-white flex items-center space-x-2">
                        <span>{{ $server->flag_emoji }}</span>
                        <span>{{ $server->name }}</span>
                    </td>
                    <td class="py-3 px-4">{{ $server->city ?? $server->country_name }}, {{ $server->country_code }}</td>
                    <td class="py-3 px-4"><span class="px-2 py-0.5 rounded text-xs bg-slate-800 font-mono">{{ strtoupper($server->protocol) }}</span></td>
                    <td class="py-3 px-4 font-mono text-xs text-slate-400">{{ $server->ip_address }}:{{ $server->port }}</td>
                    <td class="py-3 px-4 text-emerald-400 font-mono">{{ $server->ping_ms }}ms</td>
                    <td class="py-3 px-4 text-xs font-mono">{{ $server->current_load }}%</td>
                    <td class="py-3 px-4">
                        @if($server->is_premium)
                            <span class="px-2 py-0.5 rounded-full text-xs bg-amber-950 text-amber-300 border border-amber-800">VIP</span>
                        @else
                            <span class="px-2 py-0.5 rounded-full text-xs bg-emerald-950 text-emerald-300 border border-emerald-800">Free</span>
                        @endif
                    </td>
                    <td class="py-3 px-4">
                        @if($server->is_active)
                            <span class="text-xs text-emerald-400 font-medium">Active</span>
                        @else
                            <span class="text-xs text-rose-400 font-medium">Disabled</span>
                        @endif
                    </td>
                    <td class="py-3 px-4 text-right space-x-2">
                        <a href="/api/v1/servers/{{ $server->id }}/ovpn" target="_blank" class="px-2.5 py-1 rounded text-xs bg-slate-800 hover:bg-slate-700 text-sky-400 font-mono">
                            .ovpn
                        </a>
                        <form method="POST" action="/admin/servers/{{ $server->id }}/toggle" class="inline">
                            @csrf
                            <button type="submit" class="px-2.5 py-1 rounded text-xs {{ $server->is_active ? 'bg-rose-950 text-rose-300 border border-rose-800' : 'bg-emerald-950 text-emerald-300 border border-emerald-800' }}">
                                {{ $server->is_active ? 'Disable' : 'Enable' }}
                            </button>
                        </form>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="9" class="py-6 text-center text-slate-500">No servers configured.</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection
