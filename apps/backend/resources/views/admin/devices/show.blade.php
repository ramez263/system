@extends('admin.layout')

@section('title', 'Device ' . $device->device_uuid)
@section('page_title', 'Hardware Device Inspector')

@section('content')
<div class="space-y-6">
    <!-- Back & Header -->
    <div class="flex items-center justify-between">
        <a href="{{ route('admin.devices.index') }}" class="text-xs text-sky-400 hover:text-sky-300 font-medium flex items-center">
            <i class="fa-solid fa-arrow-left mr-1.5"></i> Back to Devices
        </a>
        <div class="flex items-center space-x-2">
            <form method="POST" action="{{ route('admin.devices.toggle', $device->id) }}">
                @csrf
                <button type="submit" class="px-3.5 py-1.5 rounded-xl text-xs font-semibold {{ $device->is_active ? 'bg-amber-600 hover:bg-amber-500' : 'bg-emerald-600 hover:bg-emerald-500' }} text-white transition">
                    <i class="fa-solid {{ $device->is_active ? 'fa-ban' : 'fa-circle-check' }} mr-1"></i>
                    {{ $device->is_active ? 'Suspend Device' : 'Reactivate Device' }}
                </button>
            </form>
            <form method="POST" action="{{ route('admin.devices.reset_bandwidth', $device->id) }}">
                @csrf
                <button type="submit" onclick="return confirm('Reset bandwidth counters for this device?')" class="px-3.5 py-1.5 rounded-xl text-xs font-semibold bg-slate-800 hover:bg-slate-700 text-purple-400 border border-slate-700 transition">
                    <i class="fa-solid fa-rotate-left mr-1"></i> Reset Quota
                </button>
            </form>
            <form method="POST" action="{{ route('admin.devices.destroy', $device->id) }}">
                @csrf
                @method('DELETE')
                <button type="submit" onclick="return confirm('Permanently delete this hardware device?')" class="px-3.5 py-1.5 rounded-xl text-xs font-semibold bg-rose-600 hover:bg-rose-500 text-white transition">
                    <i class="fa-solid fa-trash-can mr-1"></i> Delete
                </button>
            </form>
        </div>
    </div>

    <!-- Main Device Card -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- HWID Identity Info (2 cols) -->
        <div class="lg:col-span-2 bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
            <div class="flex items-center space-x-3 mb-6">
                <div class="w-12 h-12 rounded-xl bg-sky-500/10 border border-sky-500/20 flex items-center justify-center text-sky-400 text-2xl">
                    <i class="fa-solid fa-microchip"></i>
                </div>
                <div>
                    <h3 class="text-lg font-bold text-white">{{ $device->device_name ?? 'Client Android Hardware' }}</h3>
                    <p class="font-mono text-xs text-sky-400">{{ $device->device_uuid }}</p>
                </div>
            </div>

            <div class="grid grid-cols-2 sm:grid-cols-3 gap-4 text-xs">
                <div class="bg-slate-950/60 p-3 rounded-xl border border-slate-800">
                    <span class="text-slate-400 block text-[10px] uppercase">Device Model</span>
                    <strong class="text-white mt-1 block">{{ $device->model ?? 'Android Device' }}</strong>
                </div>
                <div class="bg-slate-950/60 p-3 rounded-xl border border-slate-800">
                    <span class="text-slate-400 block text-[10px] uppercase">OS Platform</span>
                    <strong class="text-white mt-1 block capitalize">{{ $device->platform }} {{ $device->os_version }}</strong>
                </div>
                <div class="bg-slate-950/60 p-3 rounded-xl border border-slate-800">
                    <span class="text-slate-400 block text-[10px] uppercase">App Build</span>
                    <strong class="text-white mt-1 block font-mono">v{{ $device->app_version ?? '1.0.0' }}</strong>
                </div>
                <div class="bg-slate-950/60 p-3 rounded-xl border border-slate-800">
                    <span class="text-slate-400 block text-[10px] uppercase">Download Volume</span>
                    <strong class="text-sky-400 mt-1 block font-mono">{{ round($device->bytes_downloaded / (1024*1024), 2) }} MB</strong>
                </div>
                <div class="bg-slate-950/60 p-3 rounded-xl border border-slate-800">
                    <span class="text-slate-400 block text-[10px] uppercase">Upload Volume</span>
                    <strong class="text-indigo-400 mt-1 block font-mono">{{ round($device->bytes_uploaded / (1024*1024), 2) }} MB</strong>
                </div>
                <div class="bg-slate-950/60 p-3 rounded-xl border border-slate-800">
                    <span class="text-slate-400 block text-[10px] uppercase">Last Handshake</span>
                    <strong class="text-slate-300 mt-1 block font-mono">{{ $device->last_handshake_at ? $device->last_handshake_at->diffForHumans() : 'Never' }}</strong>
                </div>
            </div>

            <!-- FCM Push Token -->
            <div class="mt-4 bg-slate-950/60 p-3 rounded-xl border border-slate-800 text-xs">
                <span class="text-slate-400 block text-[10px] uppercase mb-1">FCM Push Notification Token</span>
                <span class="font-mono text-slate-400 text-[11px] break-all">{{ $device->push_token ?? 'No push token registered yet' }}</span>
            </div>
        </div>

        <!-- Subscription & Entitlement (1 col) -->
        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
            <h4 class="text-sm font-bold text-white mb-4 flex items-center">
                <i class="fa-solid fa-crown text-amber-400 mr-2"></i>
                Subscription Status
            </h4>

            <div class="p-4 rounded-xl {{ $device->is_premium ? 'bg-amber-950/30 border border-amber-800/40' : 'bg-slate-950 border border-slate-800' }} mb-4">
                <div class="flex items-center justify-between">
                    <span class="text-xs uppercase font-bold tracking-wider {{ $device->is_premium ? 'text-amber-400' : 'text-slate-400' }}">
                        {{ $device->is_premium ? 'VIP Premium Active' : 'Free Tier Account' }}
                    </span>
                    <span class="w-2.5 h-2.5 rounded-full {{ $device->is_premium ? 'bg-amber-400' : 'bg-slate-600' }}"></span>
                </div>
                @if($device->plan)
                    <div class="text-base font-bold text-white mt-2">{{ $device->plan->name }}</div>
                    <div class="text-xs text-slate-400 mt-0.5">${{ number_format($device->plan->price_cents / 100, 2) }} / {{ $device->plan->duration_days }} days</div>
                @endif
            </div>

            <!-- Phase 8 Notification Category Preferences -->
            <div class="mt-4 pt-4 border-t border-slate-800">
                <h5 class="text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">Notification Categories</h5>
                @if($device->notificationPreference)
                    <div class="grid grid-cols-2 gap-1.5 text-[11px]">
                        <span class="{{ $device->notificationPreference->security_alerts ? 'text-emerald-400' : 'text-slate-500' }}">
                            <i class="fa-solid fa-check mr-1"></i> Security Alerts
                        </span>
                        <span class="{{ $device->notificationPreference->server_health ? 'text-emerald-400' : 'text-slate-500' }}">
                            <i class="fa-solid fa-check mr-1"></i> Server Health
                        </span>
                        <span class="{{ $device->notificationPreference->connection_state ? 'text-emerald-400' : 'text-slate-500' }}">
                            <i class="fa-solid fa-check mr-1"></i> Connection
                        </span>
                        <span class="{{ $device->notificationPreference->account_billing ? 'text-emerald-400' : 'text-slate-500' }}">
                            <i class="fa-solid fa-check mr-1"></i> Billing
                        </span>
                        <span class="{{ $device->notificationPreference->promotional_offers ? 'text-emerald-400' : 'text-slate-500' }}">
                            <i class="fa-solid fa-check mr-1"></i> Offers
                        </span>
                        <span class="{{ $device->notificationPreference->data_cap_warnings ? 'text-emerald-400' : 'text-slate-500' }}">
                            <i class="fa-solid fa-check mr-1"></i> Data Caps
                        </span>
                    </div>
                @else
                    <p class="text-xs text-slate-500">Default category preferences enabled.</p>
                @endif
            </div>
        </div>
    </div>

    <!-- Device Connection Sessions History -->
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
        <h4 class="text-base font-bold text-white mb-4 flex items-center">
            <i class="fa-solid fa-timeline text-sky-400 mr-2"></i>
            Hardware Telemetry Sessions History
        </h4>
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 text-slate-400 uppercase text-[10px] tracking-wider">
                        <th class="py-2.5 px-3">Session ID</th>
                        <th class="py-2.5 px-3">Server Node</th>
                        <th class="py-2.5 px-3">Protocol</th>
                        <th class="py-2.5 px-3">Duration</th>
                        <th class="py-2.5 px-3">Downloaded</th>
                        <th class="py-2.5 px-3">Uploaded</th>
                        <th class="py-2.5 px-3 text-right">Date</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($sessions as $s)
                    <tr class="hover:bg-slate-800/40 transition">
                        <td class="py-2.5 px-3 font-mono text-slate-400">#{{ $s->id }}</td>
                        <td class="py-2.5 px-3 font-medium text-white">{{ $s->server?->name ?? 'Curated OpenVPN' }}</td>
                        <td class="py-2.5 px-3 font-mono font-bold uppercase text-[10px] text-sky-400">{{ $s->protocol }}</td>
                        <td class="py-2.5 px-3 font-mono text-slate-300">{{ gmdate("H:i:s", $s->duration_seconds ?? 0) }}</td>
                        <td class="py-2.5 px-3 font-mono text-slate-300">{{ round(($s->bytes_downloaded ?? 0)/(1024*1024), 2) }} MB</td>
                        <td class="py-2.5 px-3 font-mono text-slate-300">{{ round(($s->bytes_uploaded ?? 0)/(1024*1024), 2) }} MB</td>
                        <td class="py-2.5 px-3 text-right text-slate-500 font-mono text-[10px]">{{ $s->created_at?->toDayDateTimeString() }}</td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="7" class="py-6 text-center text-slate-500">No session telemetry recorded for this device.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="mt-4">
            {{ $sessions->links() }}
        </div>
    </div>
</div>
@endsection
