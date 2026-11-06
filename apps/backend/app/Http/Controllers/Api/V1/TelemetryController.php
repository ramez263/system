<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreTelemetryRequest;
use App\Models\ConnectionSession;
use App\Models\Device;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TelemetryController extends Controller
{
    /**
     * Reports VPN connection session telemetry and records traffic accounting.
     */
    public function storeSession(StoreTelemetryRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $deviceUuid = $request->header('X-Device-UUID') ?? $request->input('device_uuid');
        if (!$deviceUuid) {
            return response()->json([
                'status' => 'error',
                'message' => 'Missing X-Device-UUID header.',
                'data' => null,
                'errors' => ['device_uuid' => ['Header X-Device-UUID is required.']],
            ], 400);
        }

        $device = Device::firstOrCreate(
            ['device_uuid' => $deviceUuid],
            ['device_name' => 'Android Device', 'is_active' => true]
        );

        $session = ConnectionSession::create([
            'device_id' => $device->id,
            'server_id' => $validated['server_id'] ?? null,
            'configuration_id' => $validated['configuration_id'] ?? null,
            'session_uuid' => $validated['session_uuid'],
            'protocol' => $validated['protocol'] ?? 'ovpn',
            'bytes_in' => $validated['bytes_in'],
            'bytes_out' => $validated['bytes_out'],
            'duration_seconds' => $validated['duration_seconds'],
            'client_ip' => $request->ip(),
            'disconnect_reason' => $validated['disconnect_reason'] ?? 'user_disconnect',
            'connected_at' => $validated['connected_at'] ?? now()->subSeconds($validated['duration_seconds']),
            'disconnected_at' => $validated['disconnected_at'] ?? now(),
        ]);

        // Accumulate device overall bandwidth
        $device->increment('bytes_downloaded', $validated['bytes_in']);
        $device->increment('bytes_uploaded', $validated['bytes_out']);

        return response()->json([
            'status' => 'success',
            'message' => 'Session telemetry logged.',
            'data' => [
                'session_uuid' => $session->session_uuid,
                'bytes_in' => $session->bytes_in,
                'bytes_out' => $session->bytes_out,
                'device_total_downloaded' => $device->bytes_downloaded,
                'device_total_uploaded' => $device->bytes_uploaded,
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ], 201);
    }

    /**
     * Aggregated bandwidth & telemetry summary for a device.
     */
    public function summary(Request $request): JsonResponse
    {
        $deviceUuid = $request->header('X-Device-UUID') ?? $request->query('device_uuid');
        if (!$deviceUuid) {
            return response()->json([
                'status' => 'error',
                'message' => 'Missing X-Device-UUID header.',
                'data' => null,
            ], 400);
        }

        $device = Device::where('device_uuid', $deviceUuid)->first();
        if (!$device) {
            return response()->json([
                'status' => 'error',
                'message' => 'Device not found.',
                'data' => null,
            ], 404);
        }

        $sessionStats = ConnectionSession::where('device_id', $device->id)
            ->selectRaw('COUNT(*) as total_sessions, COALESCE(SUM(duration_seconds), 0) as total_duration_seconds')
            ->first();

        return response()->json([
            'status' => 'success',
            'message' => 'Usage telemetry summary retrieved.',
            'data' => [
                'device_uuid' => $device->device_uuid,
                'total_sessions' => (int) ($sessionStats->total_sessions ?? 0),
                'total_duration_seconds' => (int) ($sessionStats->total_duration_seconds ?? 0),
                'bytes_downloaded' => $device->bytes_downloaded,
                'bytes_uploaded' => $device->bytes_uploaded,
                'total_bytes_transferred' => $device->bytes_downloaded + $device->bytes_uploaded,
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }
}
