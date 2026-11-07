@extends('admin.layout')

@section('title', 'Plans & Promo Vouchers')
@section('page_title', 'Subscription Plans & Promotional Codes')

@section('content')
<div class="space-y-8">
    <!-- Stats Cards -->
    <div class="grid grid-cols-2 sm:grid-cols-6 gap-4">
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Plans</span>
            <div class="text-2xl font-bold text-white mt-1">{{ $stats['total_plans'] }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Active Tiers</span>
            <div class="text-2xl font-bold text-emerald-400 mt-1">{{ $stats['active_plans'] }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Subscribers</span>
            <div class="text-2xl font-bold text-purple-400 mt-1">{{ $stats['active_subscribers'] }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Promo Codes</span>
            <div class="text-2xl font-bold text-sky-400 mt-1">{{ $stats['total_promos'] }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Active Vouchers</span>
            <div class="text-2xl font-bold text-amber-400 mt-1">{{ $stats['active_promos'] }}</div>
        </div>
        <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
            <span class="text-xs text-slate-400 font-semibold uppercase">Redemptions</span>
            <div class="text-2xl font-bold text-emerald-400 mt-1">{{ $stats['total_redemptions'] }}</div>
        </div>
    </div>

    <!-- Section 1: Subscription Plans Grid -->
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
        <div class="flex items-center justify-between mb-6">
            <div>
                <h3 class="text-base font-bold text-white flex items-center">
                    <i class="fa-solid fa-receipt text-amber-400 mr-2"></i>
                    Subscription Tiers & Google Play Billing
                </h3>
                <p class="text-xs text-slate-400 mt-0.5">Configured pricing tiers synchronized with Google Play Console products.</p>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            @foreach($plans as $plan)
            <div class="bg-slate-950/70 border {{ $plan->is_featured ? 'border-amber-500/50 shadow-lg shadow-amber-500/10' : 'border-slate-800' }} rounded-2xl p-5 flex flex-col justify-between relative">
                @if($plan->is_featured)
                    <div class="absolute -top-3 right-4 bg-gradient-to-r from-amber-500 to-orange-500 text-slate-950 font-black text-[10px] uppercase tracking-wider px-2 py-0.5 rounded-full shadow">
                        Popular Choice
                    </div>
                @endif
                <div>
                    <div class="flex items-center justify-between">
                        <h4 class="text-lg font-bold text-white">{{ $plan->name }}</h4>
                        <form method="POST" action="{{ route('admin.plans.toggle', $plan->id) }}">
                            @csrf
                            <button type="submit" class="text-xs px-2 py-0.5 rounded {{ $plan->is_active ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-slate-800 text-slate-500' }}">
                                {{ $plan->is_active ? 'Active' : 'Disabled' }}
                            </button>
                        </form>
                    </div>
                    <div class="mt-2 flex items-baseline space-x-1">
                        <span class="text-3xl font-black text-white">${{ number_format($plan->price_cents / 100, 2) }}</span>
                        <span class="text-xs text-slate-400">/ {{ $plan->duration_days }} days</span>
                    </div>
                    <div class="text-[11px] font-mono text-slate-400 mt-1">Play ID: {{ $plan->google_play_product_id }}</div>

                    <ul class="mt-4 space-y-1.5 text-xs text-slate-300">
                        @foreach((array) $plan->features as $feat)
                        <li class="flex items-center">
                            <i class="fa-solid fa-check text-emerald-400 text-[10px] mr-2"></i>
                            {{ $feat }}
                        </li>
                        @endforeach
                    </ul>
                </div>

                <div class="mt-6 pt-4 border-t border-slate-800 flex items-center justify-between text-xs text-slate-400">
                    <span>Subscribers: <strong class="text-white">{{ $plan->subscriptions_count }}</strong></span>
                    <span class="font-mono text-[10px] text-slate-500">Slug: {{ $plan->slug }}</span>
                </div>
            </div>
            @endforeach
        </div>
    </div>

    <!-- Section 2: Promo Codes & Vouchers -->
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
            <div>
                <h3 class="text-base font-bold text-white flex items-center">
                    <i class="fa-solid fa-ticket text-emerald-400 mr-2"></i>
                    Promotional Vouchers & Instant VIP Unlock
                </h3>
                <p class="text-xs text-slate-400 mt-0.5">Voucher codes redeemable by hardware devices without credit card.</p>
            </div>
        </div>

        <!-- Add Promo Code Form -->
        <form method="POST" action="{{ route('admin.promo_codes.store') }}" class="mb-6 p-4 rounded-xl bg-slate-950/70 border border-slate-800 grid grid-cols-1 sm:grid-cols-5 gap-3 text-xs">
            @csrf
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Promo Code *</label>
                <input type="text" name="code" required placeholder="e.g. VIP2026"
                    class="w-full uppercase font-mono bg-slate-900 border border-slate-700 rounded-xl p-2 text-white focus:outline-none focus:ring-2 focus:ring-sky-500">
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">VIP Duration (Days) *</label>
                <input type="number" name="duration_days" required value="30" min="1"
                    class="w-full bg-slate-900 border border-slate-700 rounded-xl p-2 text-white">
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Max Redemptions (0 = Unltd) *</label>
                <input type="number" name="max_uses" required value="100" min="0"
                    class="w-full bg-slate-900 border border-slate-700 rounded-xl p-2 text-white">
            </div>
            <div>
                <label class="block text-slate-300 font-semibold mb-1">Expiration Date</label>
                <input type="date" name="expires_at"
                    class="w-full bg-slate-900 border border-slate-700 rounded-xl p-2 text-white">
            </div>
            <div class="flex items-end">
                <button type="submit" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-semibold py-2 px-3 rounded-xl transition shadow-lg shadow-emerald-600/30">
                    <i class="fa-solid fa-plus mr-1"></i> Create Voucher
                </button>
            </div>
        </form>

        <!-- Promo Codes Table -->
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 text-slate-400 uppercase text-[10px] tracking-wider">
                        <th class="py-3 px-3">Voucher Code</th>
                        <th class="py-3 px-3">VIP Duration</th>
                        <th class="py-3 px-3">Redemption Quota</th>
                        <th class="py-3 px-3">Expires At</th>
                        <th class="py-3 px-3">Status</th>
                        <th class="py-3 px-3 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($promoCodes as $code)
                    <tr class="hover:bg-slate-800/40 transition">
                        <td class="py-3 px-3 font-mono font-bold text-sky-400">
                            <span class="bg-slate-950 px-2.5 py-1 rounded border border-slate-800 select-all tracking-wider">
                                {{ $code->code }}
                            </span>
                        </td>
                        <td class="py-3 px-3 font-semibold text-white">
                            {{ $code->duration_days }} Days VIP
                        </td>
                        <td class="py-3 px-3 font-mono">
                            <span class="text-emerald-400 font-bold">{{ $code->uses_count }}</span> / {{ $code->max_uses > 0 ? $code->max_uses : 'Unlimited' }}
                        </td>
                        <td class="py-3 px-3 text-slate-400 font-mono text-[10px]">
                            {{ $code->expires_at ? $code->expires_at->toFormattedDateString() : 'Never' }}
                        </td>
                        <td class="py-3 px-3">
                            @if($code->isValid())
                                <span class="px-2 py-0.5 rounded text-[10px] font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                                    ACTIVE
                                </span>
                            @else
                                <span class="px-2 py-0.5 rounded text-[10px] font-semibold bg-rose-500/10 text-rose-400 border border-rose-500/20">
                                    EXPIRED
                                </span>
                            @endif
                        </td>
                        <td class="py-3 px-3 text-right">
                            <div class="flex items-center justify-end space-x-1.5">
                                <form method="POST" action="{{ route('admin.promo_codes.toggle', $code->id) }}" class="inline">
                                    @csrf
                                    <button type="submit" class="p-1.5 rounded-lg {{ $code->is_active ? 'text-amber-400 hover:text-amber-300' : 'text-emerald-400 hover:text-emerald-300' }} hover:bg-slate-800 transition" title="Toggle Active">
                                        <i class="fa-solid {{ $code->is_active ? 'fa-pause' : 'fa-play' }}"></i>
                                    </button>
                                </form>
                                <form method="POST" action="{{ route('admin.promo_codes.destroy', $code->id) }}" class="inline">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" onclick="return confirm('Delete voucher {{ $code->code }}?')" class="p-1.5 rounded-lg text-slate-400 hover:text-rose-400 hover:bg-slate-800 transition" title="Delete">
                                        <i class="fa-solid fa-trash-can"></i>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="6" class="py-6 text-center text-slate-500">No promo codes created yet.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="mt-4">
            {{ $promoCodes->links() }}
        </div>
    </div>
</div>
@endsection
