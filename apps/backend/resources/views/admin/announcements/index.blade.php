@extends('admin.layout')

@section('title', 'Broadcast Announcements')
@section('page_title', 'Broadcast Announcements & In-App Alerts')

@section('content')
<div class="space-y-6">
    <!-- Header with Stats -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Total Broadcasts</span>
            <div class="text-2xl font-bold text-white mt-1">{{ $stats['total'] }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Active Feeds</span>
            <div class="text-2xl font-bold text-emerald-400 mt-1">{{ $stats['active'] }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Expired</span>
            <div class="text-2xl font-bold text-slate-500 mt-1">{{ $stats['expired'] }}</div>
        </div>
    </div>

    <!-- Create Announcement Form -->
    <details class="bg-slate-900 border border-slate-800 rounded-2xl p-6 group">
        <summary class="flex items-center justify-between cursor-pointer text-white font-bold text-sm">
            <span class="flex items-center">
                <i class="fa-solid fa-bullhorn text-sky-400 mr-2.5"></i>
                Compose New System Broadcast Announcement
            </span>
            <span class="text-xs text-sky-400 group-open:hidden">+ Compose Broadcast</span>
            <span class="text-xs text-slate-500 hidden group-open:inline">&times; Close</span>
        </summary>

        <form method="POST" action="{{ route('admin.announcements.store') }}" class="mt-6 pt-6 border-t border-slate-800 grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
            @csrf
            <div class="md:col-span-2">
                <label class="block text-slate-300 font-semibold mb-1">Announcement Title *</label>
                <input type="text" name="title" required placeholder="e.g. Scheduled Network Upgrade & New Frankfurt Nodes"
                    class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white focus:outline-none focus:ring-2 focus:ring-sky-500">
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Target Audience / Tier *</label>
                <select name="target_tier" class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white">
                    <option value="all">All Devices (Free & VIP)</option>
                    <option value="free">Free Tier Only</option>
                    <option value="pro">VIP Premium Only</option>
                </select>
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Category *</label>
                <select name="category" class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white">
                    <option value="system">System Notification</option>
                    <option value="security">Security Alert</option>
                    <option value="promotional">Promotional Offer</option>
                    <option value="maintenance">Maintenance Advisory</option>
                    <option value="server_health">Server Health</option>
                </select>
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Optional Action URL</label>
                <input type="url" name="action_url" placeholder="https://t.me/rameztunnel" class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white">
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Expiration Date (Optional)</label>
                <input type="date" name="expires_at" class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white">
            </div>
            <div class="md:col-span-3">
                <label class="block text-slate-300 font-semibold mb-1">Broadcast Message Body *</label>
                <textarea name="body" rows="3" required placeholder="Write the announcement message shown in the client's feed..."
                    class="w-full bg-slate-950 border border-slate-800 rounded-xl p-2.5 text-white focus:outline-none focus:ring-2 focus:ring-sky-500"></textarea>
            </div>
            <div class="md:col-span-3 text-right">
                <button type="submit" class="bg-sky-600 hover:bg-sky-500 text-white font-semibold px-6 py-2.5 rounded-xl transition shadow-lg shadow-sky-600/30">
                    <i class="fa-solid fa-paper-plane mr-1.5"></i> Broadcast Now
                </button>
            </div>
        </form>
    </details>

    <!-- Announcements List -->
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
        <div class="divide-y divide-slate-800/60">
            @forelse($announcements as $ann)
            <div class="py-4 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div class="space-y-1">
                    <div class="flex items-center space-x-2">
                        <span class="px-2 py-0.5 rounded text-[10px] font-bold uppercase tracking-wider bg-slate-950 border border-slate-800 text-sky-400">
                            {{ $ann->category }}
                        </span>
                        <span class="px-2 py-0.5 rounded text-[10px] font-semibold {{ $ann->target_tier === 'pro' ? 'bg-amber-500/10 text-amber-400 border border-amber-500/20' : 'bg-slate-800 text-slate-300' }}">
                            {{ strtoupper($ann->target_tier) }} AUDIENCE
                        </span>
                        @if($ann->is_active)
                            <span class="text-[10px] text-emerald-400 font-semibold flex items-center">
                                <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 mr-1 animate-pulse"></span> ACTIVE
                            </span>
                        @else
                            <span class="text-[10px] text-slate-500 font-semibold">PAUSED</span>
                        @endif
                    </div>
                    <h4 class="text-base font-bold text-white">{{ $ann->title }}</h4>
                    <p class="text-xs text-slate-400 max-w-3xl">{{ $ann->body }}</p>
                    @if($ann->action_url)
                        <a href="{{ $ann->action_url }}" target="_blank" class="text-[11px] text-sky-400 hover:underline inline-flex items-center">
                            <i class="fa-solid fa-arrow-up-right-from-square mr-1 text-[10px]"></i> {{ $ann->action_url }}
                        </a>
                    @endif
                </div>

                <div class="flex items-center space-x-2 flex-shrink-0">
                    <form method="POST" action="{{ route('admin.announcements.toggle', $ann->id) }}">
                        @csrf
                        <button type="submit" class="px-3 py-1.5 rounded-lg text-xs font-semibold {{ $ann->is_active ? 'bg-amber-500/10 text-amber-400 border border-amber-500/20' : 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' }}">
                            {{ $ann->is_active ? 'Pause' : 'Activate' }}
                        </button>
                    </form>
                    <form method="POST" action="{{ route('admin.announcements.destroy', $ann->id) }}">
                        @csrf
                        @method('DELETE')
                        <button type="submit" onclick="return confirm('Delete announcement {{ $ann->title }}?')" class="p-1.5 text-slate-500 hover:text-rose-400 rounded-lg hover:bg-slate-800 transition">
                            <i class="fa-solid fa-trash-can"></i>
                        </button>
                    </form>
                </div>
            </div>
            @empty
            <p class="py-8 text-center text-slate-500 text-xs">No announcements broadcasted yet.</p>
            @endforelse
        </div>
        <div class="mt-4">
            {{ $announcements->links() }}
        </div>
    </div>
</div>
@endsection
