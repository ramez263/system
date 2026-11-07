@extends('admin.layout')

@section('title', 'Security Audit Trail')
@section('page_title', 'Administrative Security Audit Trail')

@section('content')
<div class="space-y-6">
    <!-- Stats Cards & Purge Controls -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 flex-1">
            <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
                <span class="text-xs text-slate-400 font-semibold uppercase">Total Audit Events</span>
                <div class="text-2xl font-bold text-white mt-1">{{ number_format($stats['total_events']) }}</div>
            </div>
            <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
                <span class="text-xs text-slate-400 font-semibold uppercase">Events Today</span>
                <div class="text-2xl font-bold text-emerald-400 mt-1">{{ number_format($stats['today_events']) }}</div>
            </div>
            <div class="bg-slate-900 border border-slate-800 rounded-xl p-4">
                <span class="text-xs text-slate-400 font-semibold uppercase">Admin Operators</span>
                <div class="text-2xl font-bold text-sky-400 mt-1">{{ number_format($stats['unique_admins']) }}</div>
            </div>
        </div>

        <div>
            <form method="POST" action="{{ route('admin.audit_logs.purge') }}">
                @csrf
                <button type="submit" onclick="return confirm('Archive and delete audit logs older than 90 days?')"
                    class="px-4 py-2.5 rounded-xl text-xs font-semibold bg-slate-900 hover:bg-slate-800 text-slate-400 hover:text-white border border-slate-800 transition">
                    <i class="fa-solid fa-broom mr-1.5 text-amber-400"></i> Archive Logs > 90 Days
                </button>
            </form>
        </div>
    </div>

    <!-- Filters -->
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-4">
        <form method="GET" action="{{ route('admin.audit_logs.index') }}" class="grid grid-cols-1 sm:grid-cols-4 gap-3 text-xs">
            <div>
                <input type="text" name="action" value="{{ request('action') }}" placeholder="Filter by action (e.g. server, device)..."
                    class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-sky-500">
            </div>
            <div>
                <input type="text" name="admin" value="{{ request('admin') }}" placeholder="Filter by admin email..."
                    class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-sky-500">
            </div>
            <div>
                <select name="resource" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-white focus:outline-none focus:ring-2 focus:ring-sky-500">
                    <option value="">All Resource Types</option>
                    @foreach($resourceTypes as $res)
                        <option value="{{ $res }}" {{ request('resource') === $res ? 'selected' : '' }}>{{ $res }}</option>
                    @endforeach
                </select>
            </div>
            <div class="flex space-x-2">
                <button type="submit" class="flex-1 bg-sky-600 hover:bg-sky-500 text-white font-semibold py-2 rounded-xl transition">
                    <i class="fa-solid fa-filter mr-1"></i> Apply Filter
                </button>
                <a href="{{ route('admin.audit_logs.index') }}" class="bg-slate-800 hover:bg-slate-700 text-slate-300 font-semibold px-4 py-2 rounded-xl transition flex items-center justify-center">
                    Reset
                </a>
            </div>
        </form>
    </div>

    <!-- Audit Logs Table -->
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-lg shadow-slate-950/40">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 text-slate-400 uppercase text-[10px] tracking-wider">
                        <th class="py-3 px-3">Action</th>
                        <th class="py-3 px-3">Admin Operator</th>
                        <th class="py-3 px-3">Target Entity</th>
                        <th class="py-3 px-3">Operation Details</th>
                        <th class="py-3 px-3">IP Address</th>
                        <th class="py-3 px-3 text-right">Timestamp</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    @forelse($logs as $log)
                    <tr class="hover:bg-slate-800/40 transition">
                        <td class="py-3 px-3 font-mono">
                            <span class="px-2 py-1 rounded text-[10px] font-bold uppercase tracking-wider bg-slate-950 text-sky-400 border border-slate-800">
                                {{ $log->action }}
                            </span>
                        </td>
                        <td class="py-3 px-3 font-medium text-white">
                            <div class="flex items-center space-x-2">
                                <div class="w-6 h-6 rounded-full bg-slate-800 text-sky-400 font-bold flex items-center justify-center text-[10px]">
                                    {{ strtoupper(substr($log->admin_email ?? 'S', 0, 1)) }}
                                </div>
                                <span class="font-mono text-xs">{{ $log->admin_email ?? 'system' }}</span>
                            </div>
                        </td>
                        <td class="py-3 px-3">
                            @if($log->resource_type)
                                <span class="text-slate-300 font-semibold">{{ $log->resource_type }}</span>
                                @if($log->resource_id)
                                    <span class="text-slate-500 font-mono text-[10px]">#{{ $log->resource_id }}</span>
                                @endif
                            @else
                                <span class="text-slate-500">-</span>
                            @endif
                        </td>
                        <td class="py-3 px-3 font-mono text-[11px] text-slate-400 max-w-xs truncate">
                            @if($log->details)
                                <code class="bg-slate-950 px-1.5 py-0.5 rounded text-[10px] text-indigo-300 border border-slate-800">
                                    {{ json_encode($log->details) }}
                                </code>
                            @else
                                <span class="text-slate-600">None</span>
                            @endif
                        </td>
                        <td class="py-3 px-3 font-mono text-[10px] text-slate-400">
                            {{ $log->ip_address }}
                        </td>
                        <td class="py-3 px-3 text-right font-mono text-[10px] text-slate-400">
                            <div>{{ $log->created_at->toDayDateTimeString() }}</div>
                            <div class="text-[9px] text-slate-500">{{ $log->created_at->diffForHumans() }}</div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="6" class="py-8 text-center text-slate-500">No audit events match your filter query.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="mt-4">
            {{ $logs->links() }}
        </div>
    </div>
</div>
@endsection
