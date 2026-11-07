<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Announcement;
use App\Models\AuditLog;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdminAnnouncementController extends Controller
{
    /**
     * Broadcast announcements and notifications manager.
     */
    public function index(): View
    {
        $announcements = Announcement::latest()->paginate(15);

        $stats = [
            'total' => Announcement::count(),
            'active' => Announcement::where('is_active', true)->count(),
            'expired' => Announcement::where('expires_at', '<', now())->count(),
        ];

        return view('admin.announcements.index', compact('announcements', 'stats'));
    }

    /**
     * Publish new broadcast announcement.
     */
    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:150'],
            'body' => ['required', 'string'],
            'category' => ['required', 'string', 'in:security,system,promotional,maintenance,server_health'],
            'icon' => ['nullable', 'string', 'max:50'],
            'target_tier' => ['required', 'string', 'in:all,free,pro'],
            'action_url' => ['nullable', 'url', 'max:255'],
            'expires_at' => ['nullable', 'date'],
            'is_active' => ['boolean'],
        ]);

        $validated['icon'] = $validated['icon'] ?? 'bullhorn';
        $validated['is_active'] = $request->has('is_active') ? $request->boolean('is_active') : true;

        $announcement = Announcement::create($validated);

        AuditLog::record(
            action: 'announcement.created',
            resourceType: 'Announcement',
            resourceId: $announcement->id,
            details: [
                'title' => $announcement->title,
                'target_tier' => $announcement->target_tier,
                'category' => $announcement->category,
            ]
        );

        return redirect()->route('admin.announcements.index')->with('success', "Announcement '{$announcement->title}' published.");
    }

    /**
     * Toggle announcement active state.
     */
    public function toggle(int $id): RedirectResponse
    {
        $announcement = Announcement::findOrFail($id);
        $announcement->is_active = !$announcement->is_active;
        $announcement->save();

        AuditLog::record(
            action: 'announcement.toggled',
            resourceType: 'Announcement',
            resourceId: $announcement->id,
            details: ['title' => $announcement->title, 'is_active' => $announcement->is_active]
        );

        $status = $announcement->is_active ? 'ACTIVATED' : 'DEACTIVATED';
        return redirect()->back()->with('success', "Announcement '{$announcement->title}' is now {$status}.");
    }

    /**
     * Remove announcement.
     */
    public function destroy(int $id): RedirectResponse
    {
        $announcement = Announcement::findOrFail($id);
        $title = $announcement->title;

        AuditLog::record(
            action: 'announcement.deleted',
            resourceType: 'Announcement',
            resourceId: $announcement->id,
            details: ['title' => $title]
        );

        $announcement->delete();

        return redirect()->route('admin.announcements.index')->with('success', "Announcement '{$title}' removed.");
    }
}
