@extends('admin.layout')

@section('title', 'Registered Devices')

@section('content')
<div class="space-y-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
            <h2 class="text-xl font-bold text-white">Registered Client Devices</h2>
            <p class="text-xs text-slate-400">Zero-friction hardware identities registered via X-Device-UUID</p>
        </div>
        <form method="GET" action="/admin/devices" class="flex gap-2">
            <input type="text" name="search" value="{{ request('search') }}" placeholder="Search UUID or Model..." class="px-3 py-1.5 rounded-lg bg-slate-900 border border-slate-700 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-sky-500">
            <button type="submit" class="px-3 py-1.5 rounded-lg bg-sky-600 hover:bg-sky-500 text-white text-sm font-medium">Search</button>
        </form>
    </div>

    <div class="p-6 rounded-2xl bg-slate-900/60 border border-slate-800 shadow-sm overflow-x-auto">
        <table class="w-full text-left text-sm text-slate-300">
            <thead class="text-xs uppercase bg-slate-800/50 text-slate-400">
                <tr>
                    <th class="py-3 px-4">UUID</th>
                    <th class="py-3 px-4">Device Name</th>
                    <th class="py-3 px-4">Model / OS</th>
                    <th class="py-3 px-4">App Version</th>
                    <th class="py-3 px-4">Tier</th>
                    <th class="py-3 px-4">Downloaded</th>
                    <th class="py-3 px-4">Uploaded</th>
                    <th class="py-3 px-4">Last Handshake</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-800">
                @forelse($devices as $device)
                <tr class="hover:bg-slate-800/30 transition">
                    <td class="py-3 px-4 font-mono text-xs text-sky-400">{{ $device->device_uuid }}</td>
                    <td class="py-3 px-4 font-medium text-white">{{ $device->device_name }}</td>
                    <td class="py-3 px-4 text-xs text-slate-400">{{ $device->model }} ({{ $device->os_version }})</td>
                    <td class="py-3 px-4 font-mono text-xs">{{ $device->app_version ?? 'v1.0.0' }}</td>
                    <td class="py-3 px-4">
                        @if($device->is_premium)
                            <span class="px-2 py-0.5 rounded-full text-xs bg-amber-950 text-amber-300 border border-amber-800">VIP Pro</span>
                        @else
                            <span class="px-2 py-0.5 rounded-full text-xs bg-slate-800 text-slate-300">Free Tier</span>
                        @endif
                    </td>
                    <td class="py-3 px-4 text-xs font-mono text-indigo-400">{{ round($device->bytes_downloaded / (1024 * 1024), 2) }} MB</td>
                    <td class="py-3 px-4 text-xs font-mono text-sky-400">{{ round($device->bytes_uploaded / (1024 * 1024), 2) }} MB</td>
                    <td class="py-3 px-4 text-xs text-slate-400">{{ $device->last_handshake_at?->toDateTimeString() ?? 'N/A' }}</td>
                </tr>
                @empty
                <tr>
                    <td colspan="8" class="py-8 text-center text-slate-500">No devices found.</td>
                </tr>
                @endforelse
            </tbody>
        </table>

        @if($devices->hasPages())
        <div class="mt-4 pt-4 border-t border-slate-800">
            {{ $devices->links() }}
        </div>
        @endif
    </div>
</div>
@endsection
