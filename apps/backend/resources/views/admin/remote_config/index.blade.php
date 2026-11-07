@extends('admin.layout')

@section('title', 'Remote Config & Releases')
@section('page_title', 'Remote Configuration & Feature Flags')

@section('content')
<div class="space-y-8">
    <!-- Emergency Maintenance Mode Banner -->
    <div class="p-6 rounded-2xl {{ $settings['maintenance_mode'] ? 'bg-rose-950/80 border-2 border-rose-600 shadow-xl shadow-rose-950/50' : 'bg-slate-900 border border-slate-800' }} flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
            <div class="flex items-center space-x-2">
                <span class="w-3 h-3 rounded-full {{ $settings['maintenance_mode'] ? 'bg-rose-500 animate-ping' : 'bg-emerald-500' }}"></span>
                <h3 class="text-base font-bold {{ $settings['maintenance_mode'] ? 'text-rose-200' : 'text-white' }}">
                    Global Maintenance Mode: {{ $settings['maintenance_mode'] ? 'ENABLED (Service Offline)' : 'DISABLED (Operational)' }}
                </h3>
            </div>
            <p class="text-xs text-slate-400 mt-1">
                {{ $settings['maintenance_mode'] ? 'All mobile clients receive HTTP 503 Maintenance and lock tunnel connections.' : 'Mobile clients connect normally to cataloged proxy nodes.' }}
            </p>
        </div>
        <form method="POST" action="{{ route('admin.remote_config.maintenance') }}">
            @csrf
            <button type="submit" onclick="return confirm('Toggle global infrastructure maintenance mode?')"
                class="px-5 py-2.5 rounded-xl text-xs font-bold transition shadow-lg {{ $settings['maintenance_mode'] ? 'bg-emerald-600 hover:bg-emerald-500 text-white shadow-emerald-600/30' : 'bg-rose-600 hover:bg-rose-500 text-white shadow-rose-600/30' }}">
                <i class="fa-solid fa-power-off mr-1.5"></i>
                {{ $settings['maintenance_mode'] ? 'Deactivate Maintenance (Go Live)' : 'Activate Maintenance Mode' }}
            </button>
        </form>
    </div>

    <!-- Remote Config & Feature Flags Form -->
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
        <div class="mb-6">
            <h3 class="text-base font-bold text-white flex items-center">
                <i class="fa-solid fa-sliders text-sky-400 mr-2"></i>
                Runtime Parameters & Feature Flags
            </h3>
            <p class="text-xs text-slate-400 mt-0.5">Mobile applications poll these parameters at start up (`/api/v1/app/config`). Changes apply immediately without app recompile.</p>
        </div>

        <form method="POST" action="{{ route('admin.remote_config.update') }}" class="space-y-6 text-xs">
            @csrf
            <!-- Versions & Force Update -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                    <label class="block text-slate-300 font-semibold mb-1">Minimum Supported Version</label>
                    <input type="text" name="min_app_version" value="{{ old('min_app_version', $settings['min_app_version']) }}" required
                        class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white font-mono focus:outline-none focus:ring-2 focus:ring-sky-500">
                    <p class="text-[10px] text-slate-500 mt-1">Clients below this version will be prompted to update.</p>
                </div>
                <div>
                    <label class="block text-slate-300 font-semibold mb-1">Latest Release Version</label>
                    <input type="text" name="latest_app_version" value="{{ old('latest_app_version', $settings['latest_app_version']) }}" required
                        class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white font-mono focus:outline-none focus:ring-2 focus:ring-sky-500">
                </div>
                <div class="flex items-center space-x-6 pt-5">
                    <label class="flex items-center text-slate-300 cursor-pointer">
                        <input type="checkbox" name="force_update" value="1" {{ $settings['force_update'] ? 'checked' : '' }} class="rounded bg-slate-950 border-slate-700 text-rose-500 focus:ring-rose-500 mr-2">
                        <span class="font-bold text-rose-400">Force Update Modal</span>
                    </label>
                    <label class="flex items-center text-slate-300 cursor-pointer">
                        <input type="checkbox" name="maintenance_mode" value="1" {{ $settings['maintenance_mode'] ? 'checked' : '' }} class="rounded bg-slate-950 border-slate-700 text-amber-500 focus:ring-amber-500 mr-2">
                        Maintenance Flag
                    </label>
                </div>
            </div>

            <!-- Maintenance & Bilingual Messages -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                    <label class="block text-slate-300 font-semibold mb-1">Maintenance Advisory Message</label>
                    <input type="text" name="maintenance_message" value="{{ old('maintenance_message', $settings['maintenance_message']) }}"
                        class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white">
                </div>
                <div>
                    <label class="block text-slate-300 font-semibold mb-1">Arabic Feed Headline (AR)</label>
                    <input type="text" name="announcement_ar" value="{{ old('announcement_ar', $settings['announcement_ar']) }}" dir="rtl"
                        class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white">
                </div>
                <div>
                    <label class="block text-slate-300 font-semibold mb-1">English Feed Headline (EN)</label>
                    <input type="text" name="announcement_en" value="{{ old('announcement_en', $settings['announcement_en']) }}"
                        class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white">
                </div>
            </div>

            <!-- DNS & Security Defaults -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-slate-300 font-semibold mb-1">Default Fallback DNS Resolvers (Comma Separated)</label>
                    <input type="text" name="default_dns_servers" value="{{ old('default_dns_servers', $settings['default_dns_servers']) }}" required
                        class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white font-mono">
                    <p class="text-[10px] text-slate-500 mt-1">e.g. 1.1.1.1, 1.0.0.1, 8.8.8.8 (Cloudflare & Google)</p>
                </div>
                <div class="pt-5 space-y-2">
                    <label class="flex items-center text-slate-300 cursor-pointer">
                        <input type="checkbox" name="kill_switch_default" value="1" {{ $settings['kill_switch_default'] ? 'checked' : '' }} class="rounded bg-slate-950 border-slate-700 text-sky-500 focus:ring-sky-500 mr-2">
                        Kill Switch Guidance Active by Default
                    </label>
                    <label class="flex items-center text-slate-300 cursor-pointer">
                        <input type="checkbox" name="enable_custom_config_import" value="1" {{ $settings['enable_custom_config_import'] ? 'checked' : '' }} class="rounded bg-slate-950 border-slate-700 text-sky-500 focus:ring-sky-500 mr-2">
                        Enable Custom Configuration Import (.rtp, .ovpn)
                    </label>
                    <label class="flex items-center text-slate-300 cursor-pointer">
                        <input type="checkbox" name="enable_split_tunneling" value="1" {{ $settings['enable_split_tunneling'] ? 'checked' : '' }} class="rounded bg-slate-950 border-slate-700 text-sky-500 focus:ring-sky-500 mr-2">
                        Enable Split Tunneling Feature
                    </label>
                </div>
            </div>

            <div class="text-right pt-4 border-t border-slate-800">
                <button type="submit" class="bg-sky-600 hover:bg-sky-500 text-white font-semibold px-6 py-2.5 rounded-xl transition shadow-lg shadow-sky-600/30">
                    <i class="fa-solid fa-floppy-disk mr-1.5"></i> Save Runtime Settings
                </button>
            </div>
        </form>
    </div>

    <!-- App Releases Manager -->
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
        <div class="flex items-center justify-between mb-6">
            <div>
                <h3 class="text-base font-bold text-white flex items-center">
                    <i class="fa-brands fa-google-play text-emerald-400 mr-2"></i>
                    App Releases & Production Builds
                </h3>
                <p class="text-xs text-slate-400 mt-0.5">Manage deployed client APKs, versions, and release changelogs.</p>
            </div>
        </div>

        <!-- Add Release Form -->
        <form method="POST" action="{{ route('admin.remote_config.release') }}" class="mb-6 p-4 rounded-xl bg-slate-950/70 border border-slate-800 grid grid-cols-1 sm:grid-cols-4 gap-3 text-xs">
            @csrf
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Version String *</label>
                <input type="text" name="version" required placeholder="1.2.0" class="w-full bg-slate-900 border border-slate-700 rounded-xl p-2 text-white font-mono">
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Build Number *</label>
                <input type="number" name="build_number" required value="2" min="1" class="w-full bg-slate-900 border border-slate-700 rounded-xl p-2 text-white font-mono">
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Min Supported Version *</label>
                <input type="text" name="min_supported_version" required value="1.0.0" class="w-full bg-slate-900 border border-slate-700 rounded-xl p-2 text-white font-mono">
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Platform *</label>
                <select name="platform" class="w-full bg-slate-900 border border-slate-700 rounded-xl p-2 text-white">
                    <option value="android">Android (APK / AAB)</option>
                    <option value="ios">iOS (IPA)</option>
                </select>
            </div>
            <div class="sm:col-span-2">
                <label class="block text-slate-300 font-semibold mb-1">Download / Store URL</label>
                <input type="url" name="download_url" placeholder="https://play.google.com/store/apps/details?id=com.rameztunnel.plus" class="w-full bg-slate-900 border border-slate-700 rounded-xl p-2 text-white">
            </div>
            <div class="sm:col-span-2">
                <label class="block text-slate-300 font-semibold mb-1">Release Notes / Changelog</label>
                <input type="text" name="release_notes" placeholder="Performance improvements and Arabic translation updates." class="w-full bg-slate-900 border border-slate-700 rounded-xl p-2 text-white">
            </div>
            <div class="sm:col-span-4 flex items-center justify-between pt-2">
                <label class="flex items-center text-slate-300 cursor-pointer">
                    <input type="checkbox" name="force_update" value="1" class="rounded bg-slate-950 border-slate-700 text-rose-500 focus:ring-rose-500 mr-2">
                    <span class="font-bold text-rose-400">Mark as Mandatory Force Update</span>
                </label>
                <button type="submit" class="bg-emerald-600 hover:bg-emerald-500 text-white font-semibold py-2 px-5 rounded-xl transition shadow-lg shadow-emerald-600/30">
                    <i class="fa-solid fa-plus mr-1"></i> Publish Release
                </button>
            </div>
        </form>

        <!-- Releases List -->
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 text-slate-400 uppercase text-[10px] tracking-wider">
                        <th class="py-3 px-3">Version & Build</th>
                        <th class="py-3 px-3">Platform</th>
                        <th class="py-3 px-3">Min Supported</th>
                        <th class="py-3 px-3">Mandatory</th>
                        <th class="py-3 px-3">Changelog</th>
                        <th class="py-3 px-3 text-right">Published</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($releases as $rel)
                    <tr class="hover:bg-slate-800/40 transition">
                        <td class="py-3 px-3 font-mono font-bold text-white">
                            v{{ $rel->version }} (Build {{ $rel->build_number }})
                        </td>
                        <td class="py-3 px-3 uppercase text-[10px] font-mono text-sky-400">
                            {{ $rel->platform }}
                        </td>
                        <td class="py-3 px-3 font-mono text-slate-300">
                            v{{ $rel->min_supported_version }}
                        </td>
                        <td class="py-3 px-3">
                            @if($rel->force_update)
                                <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-rose-500/10 text-rose-400 border border-rose-500/20">
                                    FORCE
                                </span>
                            @else
                                <span class="px-2 py-0.5 rounded text-[10px] font-semibold bg-slate-800 text-slate-400">
                                    OPTIONAL
                                </span>
                            @endif
                        </td>
                        <td class="py-3 px-3 text-slate-300">
                            {{ $rel->release_notes ?? '-' }}
                        </td>
                        <td class="py-3 px-3 text-right text-slate-500 font-mono text-[10px]">
                            {{ $rel->created_at->diffForHumans() }}
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="6" class="py-6 text-center text-slate-500">No app releases cataloged yet. Defaulting to v1.0.0.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection
