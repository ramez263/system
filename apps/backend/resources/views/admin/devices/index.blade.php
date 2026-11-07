@extends('admin.layout')

@section('title', 'Hardware Devices')
@section('page_title', 'Hardware Devices Explorer')

@section('content')
<div class="space-y-6">
    <!-- Header with Stats -->
    <div class="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Total Devices</span>
            <div class="text-2xl font-bold text-white mt-1">{{ number_format($stats['total']) }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Active Hardware</span>
            <div class="text-2xl font-bold text-emerald-400 mt-1">{{ number_format($stats['active']) }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Suspended</span>
            <div class="text-2xl font-bold text-rose-400 mt-1">{{ number_format($stats['suspended']) }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">VIP Premium</span>
            <div class="text-2xl font-bold text-amber-400 mt-1">{{ number_format($stats['premium']) }}</div>
        </div>
    </div>

    <!-- Filters & Search Form -->
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-4">
        <form method="GET" action="{{ route('admin.devices.index') }}" class="grid grid-cols-1 md:grid-cols-4 gap-3">
            <div class="md:col-span-2">
                <input type="text" name="search" value="{{ request('search') }}" placeholder="Search by Device UUID, Name or Model..."
                    class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-2 text-xs text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-sky-500">
            </div>
            <div>
                <select name="status" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:ring-2 focus:ring-sky-500">
                    <option value="">All Statuses</option>
                    <option value="active" {{ request('status') === 'active' ? 'selected' : '' }}>Active Only</option>
                    <option value="suspended" {{ request('status') === 'suspended' ? 'selected' : '' }}>Suspended Only</option>
                </select>
            </div>
            <div class="flex space-x-2">
                <select name="tier" class="flex-1 bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:ring-2 focus:ring-sky-500">
                    <option value="">All Tiers</option>
                    <option value="premium" {{ request('tier') === 'premium' ? 'selected' : '' }}>Premium VIP</option>
                    <option value="free" {{ request('tier') === 'free' ? 'selected' : '' }}>Free Tier</option>
                </select>
                <button type="submit" class="bg-sky-600 hover:bg-sky-500 text-white px-4 py-2 rounded-xl text-xs font-semibold transition">
                    <i class="fa-solid fa-filter mr-1"></i> Filter
                </button>
            </div>
        </form>
    </div>

    <!-- Devices Table -->
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 text-slate-400 uppercase text-[10px] tracking-wider">
                        <th class="py-3 px-3">Device UUID / Identity</th>
                        <th class="py-3 px-3">Model & Platform</th>
                        <th class="py-3 px-3">Bandwidth (Down/Up)</th>
                        <th class="py-3 px-3">Tier</th>
                        <th class="py-3 px-3">Status</th>
                        <th class="py-3 px-3">Last Active</th>
                        <th class="py-3 px-3 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($devices as $device)
                    <tr class="hover:bg-slate-800/40 transition">
                        <td class="py-3 px-3 font-medium text-white">
                            <a href="{{ route('admin.devices.show', $device->id) }}" class="font-mono text-sky-400 hover:underline font-bold block truncate max-w-[220px]" title="{{ $device->device_uuid }}">
                                {{ $device->device_uuid }}
                            </a>
                            <div class="text-[10px] text-slate-500">{{ $device->device_name ?? 'Unnamed Client' }}</div>
                        </td>
                        <td class="py-3 px-3">
                            <div class="text-slate-200 font-medium">{{ $device->model ?? 'Android Device' }}</div>
                            <div class="text-[10px] text-slate-500 capitalize">{{ $device->platform ?? 'android' }} &bull; OS {{ $device->os_version ?? '14' }}</div>
                        </td>
                        <td class="py-3 px-3 font-mono text-slate-300">
                            <div>{{ round($device->bytes_downloaded / (1024*1024), 2) }} MB &darr;</div>
                            <div class="text-[10px] text-slate-500">{{ round($device->bytes_uploaded / (1024*1024), 2) }} MB &uarr;</div>
                        </td>
                        <td class="py-3 px-3">
                            @if($device->is_premium)
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
                            @if($device->is_active)
                                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                                    ACTIVE
                                </span>
                            @else
                                <span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-rose-500/10 text-rose-400 border border-rose-500/20">
                                    SUSPENDED
                                </span>
                            @endif
                        </td>
                        <td class="py-3 px-3 text-slate-400 text-[10px] font-mono">
                            {{ $device->last_handshake_at ? $device->last_handshake_at->diffForHumans() : 'Never' }}
                        </td>
                        <td class="py-3 px-3 text-right">
                            <div class="flex items-center justify-end space-x-1.5">
                                <a href="{{ route('admin.devices.show', $device->id) }}" class="p-1.5 rounded-lg text-slate-400 hover:text-sky-400 hover:bg-slate-800 transition" title="Inspect Device">
                                    <i class="fa-solid fa-eye"></i>
                                </a>
                                <form method="POST" action="{{ route('admin.devices.toggle', $device->id) }}" class="inline">
                                    @csrf
                                    <button type="submit" class="p-1.5 rounded-lg {{ $device->is_active ? 'text-amber-400 hover:text-amber-300' : 'text-emerald-400 hover:text-emerald-300' }} hover:bg-slate-800 transition" title="{{ $device->is_active ? 'Suspend Device' : 'Reactivate Device' }}">
                                        <i class="fa-solid {{ $device->is_active ? 'fa-ban' : 'fa-circle-check' }}"></i>
                                    </button>
                                </form>
                                <form method="POST" action="{{ route('admin.devices.reset_bandwidth', $device->id) }}" class="inline">
                                    @csrf
                                    <button type="submit" onclick="return confirm('Reset bandwidth quota for this hardware device?')" class="p-1.5 rounded-lg text-slate-400 hover:text-purple-400 hover:bg-slate-800 transition" title="Reset Bandwidth Quota">
                                        <i class="fa-solid fa-rotate-left"></i>
                                    </button>
                                </form>
                                <form method="POST" action="{{ route('admin.devices.destroy', $device->id) }}" class="inline">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" onclick="return confirm('Permanently delete this hardware device identity and all session records?')" class="p-1.5 rounded-lg text-slate-400 hover:text-rose-400 hover:bg-slate-800 transition" title="Delete Device">
                                        <i class="fa-solid fa-trash-can"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="7" class="py-8 text-center text-slate-500">No hardware devices found matching your criteria.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="mt-4">
            {{ $devices->links() }}
        </div>
    </div>
</div>
@endsection
