<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdminAuditLogController extends Controller
{
    /**
     * Complete administrative audit trail.
     */
    public function index(Request $request): View
    {
        $query = AuditLog::query()->with('user');

        if ($request->filled('action')) {
            $query->where('action', 'like', '%' . $request->query('action') . '%');
        }

        if ($request->filled('admin')) {
            $query->where('admin_email', 'like', '%' . $request->query('admin') . '%');
        }

        if ($request->filled('resource')) {
            $query->where('resource_type', $request->query('resource'));
        }

        $logs = $query->latest('created_at')->paginate(25)->withQueryString();

        $actionTypes = AuditLog::distinct()->pluck('action')->filter()->values();
        $resourceTypes = AuditLog::distinct()->pluck('resource_type')->filter()->values();

        $stats = [
            'total_events' => AuditLog::count(),
            'today_events' => AuditLog::whereDate('created_at', today())->count(),
            'unique_admins' => AuditLog::distinct('admin_email')->count(),
        ];

        return view('admin.audit_logs.index', compact('logs', 'actionTypes', 'resourceTypes', 'stats'));
    }

    /**
     * Purge older audit logs (Super Admin only).
     */
    public function purge(): RedirectResponse
    {
        $deleted = AuditLog::where('created_at', '<', now()->subDays(90))->delete();

        AuditLog::record(
            action: 'audit_log.purged',
            details: ['deleted_rows' => $deleted, 'retention_days' => 90]
        );

        return redirect()->route('admin.audit_logs.index')->with('success', "Archived {$deleted} log entries older than 90 days.");
    }
}
