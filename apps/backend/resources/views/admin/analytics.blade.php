@extends('admin.layout')

@section('title', 'Network & Telemetry Analytics')
@section('page_title', 'Analytics & Usage Telemetry')

@section('content')
<div class="space-y-8">
    <!-- Header -->
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6">
        <h2 class="text-xl font-bold text-white flex items-center">
            <i class="fa-solid fa-chart-line text-sky-400 mr-3"></i>
            Network Usage & Device Analytics
        </h2>
        <p class="text-sm text-slate-400 mt-1">Real-time aggregate telemetry across curated nodes and device clients.</p>
    </div>

    <!-- Analytics Breakdown Cards -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- 1. Country Node Distribution -->
        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
            <h3 class="text-base font-bold text-white mb-4 flex items-center">
                <i class="fa-solid fa-earth-americas text-emerald-400 mr-2"></i>
                Country Node Distribution
            </h3>
            <div class="space-y-3">
                @foreach($serverCountryStats as $country)
                <div class="bg-slate-950/60 border border-slate-800 p-3 rounded-xl flex items-center justify-between text-xs">
                    <div>
                        <span class="font-bold text-white">{{ $country->country_name }}</span>
                        <div class="text-[10px] text-slate-500 font-mono">Code: {{ $country->country_code }} &bull; Ping: {{ round($country->avg_ping) }}ms</div>
                    </div>
                    <div class="text-right">
                        <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-sky-500/10 text-sky-400 border border-sky-500/20">
                            {{ $country->count }} node{{ $country->count > 1 ? 's' : '' }}
                        </span>
                        <div class="text-[10px] text-slate-400 mt-0.5">Load: {{ round($country->avg_load) }}%</div>
                    </div>
                </div>
                @endforeach
            </div>
        </div>

        <!-- 2. Device Platforms -->
        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
            <h3 class="text-base font-bold text-white mb-4 flex items-center">
                <i class="fa-brands fa-android text-sky-400 mr-2"></i>
                Client Platforms
            </h3>
            <div class="space-y-4">
                @forelse($osBreakdown as $platform => $count)
                <div>
                    <div class="flex justify-between text-xs font-semibold mb-1">
                        <span class="capitalize text-slate-200">{{ $platform ?? 'Android' }}</span>
                        <span class="text-sky-400 font-mono">{{ $count }} devices</span>
                    </div>
                    <div class="w-full bg-slate-800 rounded-full h-2 overflow-hidden">
                        <div class="bg-sky-500 h-2 rounded-full" style="width: 100%"></div>
                    </div>
                </div>
                @empty
                <p class="text-xs text-slate-500 py-6 text-center">No platform data captured yet.</p>
                @endforelse
            </div>
        </div>

        <!-- 3. Free vs VIP Subscriptions -->
        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
            <h3 class="text-base font-bold text-white mb-4 flex items-center">
                <i class="fa-solid fa-crown text-amber-400 mr-2"></i>
                Monetization Tier Split
            </h3>
            <div class="space-y-4">
                @foreach($tierBreakdown as $tierName => $count)
                <div class="bg-slate-950/60 border border-slate-800 p-4 rounded-xl flex items-center justify-between">
                    <div>
                        <div class="text-sm font-bold text-white">{{ $tierName }}</div>
                        <div class="text-xs text-slate-400 mt-0.5">Device hardware accounts</div>
                    </div>
                    <div class="text-2xl font-black {{ str_contains($tierName, 'VIP') ? 'text-amber-400' : 'text-slate-300' }}">
                        {{ $count }}
                    </div>
                </div>
                @endforeach
            </div>
        </div>
    </div>

    <!-- Full Sessions Telemetry Log -->
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
        <h3 class="text-base font-bold text-white mb-4 flex items-center">
            <i class="fa-solid fa-list-check text-purple-400 mr-2"></i>
            Live Connection Sessions Telemetry Log
        </h3>
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 text-slate-400 uppercase text-[10px] tracking-wider">
                        <th class="py-3 px-3">Device HWID</th>
                        <th class="py-3 px-3">Server Node</th>
                        <th class="py-3 px-3">Protocol</th>
                        <th class="py-3 px-3">Duration</th>
                        <th class="py-3 px-3">Bandwidth (Down / Up)</th>
                        <th class="py-3 px-3">Status</th>
                        <th class="py-3 px-3 text-right">Time</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($recentSessions as $session)
                    <tr class="hover:bg-slate-800/40 transition">
                        <td class="py-3 px-3 font-mono font-medium text-sky-400">
                            {{ substr($session->device?->device_uuid ?? 'N/A', 0, 18) }}...
                        </td>
                        <td class="py-3 px-3 text-slate-200">
                            {{ $session->server?->name ?? 'Curated OpenVPN' }}
                        </td>
                        <td class="py-3 px-3 uppercase font-mono font-bold text-[10px] text-indigo-400">
                            {{ $session->protocol }}
                        </td>
                        <td class="py-3 px-3 font-mono text-slate-300">
                            {{ gmdate("H:i:s", $session->duration_seconds ?? 0) }}
                        </td>
                        <td class="py-3 px-3 font-mono text-slate-300">
                            {{ round(($session->bytes_downloaded ?? 0)/(1024*1024), 2) }} MB &bull; {{ round(($session->bytes_uploaded ?? 0)/(1024*1024), 2) }} MB
                        </td>
                        <td class="py-3 px-3">
                            <span class="px-2 py-0.5 rounded text-[10px] font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                                {{ strtoupper($session->status ?? 'COMPLETED') }}
                            </span>
                        </td>
                        <td class="py-3 px-3 text-right text-slate-500 font-mono text-[10px]">
                            {{ $session->created_at?->diffForHumans() }}
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="7" class="py-8 text-center text-slate-500">No session telemetry recorded yet.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="mt-4">
            {{ $recentSessions->links() }}
        </div>
    </div>
</div>
@endsection
