<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Device;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdminDeviceController extends Controller
{
    /**
     * Devices explorer with search and status filters.
     */
    public function index(Request $request): View
    {
        $query = Device::query()->with(['plan', 'activeSubscription']);

        if ($request->filled('search')) {
            $term = '%' . $request->query('search') . '%';
            $query->where(function ($q) use ($term) {
                $q->where('device_uuid', 'like', $term)
                  ->orWhere('device_name', 'like', $term)
                  ->orWhere('model', 'like', $term);
            });
        }

        if ($request->query('status') === 'suspended') {
            $query->where('is_active', false);
        } elseif ($request->query('status') === 'active') {
            $query->where('is_active', true);
        }

        if ($request->query('tier') === 'premium') {
            $query->where('is_premium', true);
        } elseif ($request->query('tier') === 'free') {
            $query->where('is_premium', false);
        }

        $devices = $query->latest('last_handshake_at')->paginate(20)->withQueryString();

        $stats = [
            'total' => Device::count(),
            'active' => Device::where('is_active', true)->count(),
            'suspended' => Device::where('is_active', false)->count(),
            'premium' => Device::where('is_premium', true)->count(),
        ];

        return view('admin.devices.index', compact('devices', 'stats'));
    }

    /**
     * Inspect individual hardware device identity.
     */
    public function show(int $id): View
    {
        $device = Device::with([
            'plan',
            'subscriptions.plan',
            'notificationPreference',
            'redeemedPromoCodes',
            'connectionSessions.server',
            'configurations'
        ])->findOrFail($id);

        $sessions = $device->connectionSessions()->latest()->paginate(10);

        return view('admin.devices.show', compact('device', 'sessions'));
    }

    /**
     * Suspend or reactivate hardware device.
     */
    public function toggleStatus(int $id): RedirectResponse
    {
        $device = Device::findOrFail($id);
        $device->is_active = !$device->is_active;
        $device->save();

        $action = $device->is_active ? 'device.activated' : 'device.suspended';

        AuditLog::record(
            action: $action,
            resourceType: 'Device',
            resourceId: $device->id,
            details: [
                'device_uuid' => $device->device_uuid,
                'new_status' => $device->is_active ? 'ACTIVE' : 'SUSPENDED',
            ]
        );

        $statusText = $device->is_active ? 'activated' : 'suspended';
        return redirect()->back()->with('success', "Device [{$device->device_uuid}] has been {$statusText}.");
    }

    /**
     * Reset bandwidth counter for device.
     */
    public function resetBandwidth(int $id): RedirectResponse
    {
        $device = Device::findOrFail($id);
        $previousDown = $device->bytes_downloaded;
        $previousUp = $device->bytes_uploaded;

        $device->bytes_downloaded = 0;
        $device->bytes_uploaded = 0;
        $device->save();

        AuditLog::record(
            action: 'device.bandwidth_reset',
            resourceType: 'Device',
            resourceId: $device->id,
            details: [
                'device_uuid' => $device->device_uuid,
                'cleared_download_bytes' => $previousDown,
                'cleared_upload_bytes' => $previousUp,
            ]
        );

        return redirect()->back()->with('success', "Bandwidth quota counters reset for device [{$device->device_uuid}].");
    }

    /**
     * Hard-delete device identity and associated records (GDPR compliant).
     */
    public function destroy(int $id): RedirectResponse
    {
        $device = Device::findOrFail($id);
        $uuid = $device->device_uuid;

        AuditLog::record(
            action: 'device.deleted',
            resourceType: 'Device',
            resourceId: $device->id,
            details: ['device_uuid' => $uuid]
        );

        $device->connectionSessions()->delete();
        $device->delete();

        return redirect()->route('admin.devices.index')->with('success', "Device [{$uuid}] and session logs permanently removed.");
    }
}
