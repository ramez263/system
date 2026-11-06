<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreConfigurationRequest;
use App\Models\Configuration;
use App\Models\Device;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class ConfigController extends Controller
{
    /**
     * List public and community configurations.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Configuration::where('is_public', true)->where('is_active', true);

        if ($request->filled('protocol')) {
            $query->where('protocol', strtolower($request->query('protocol')));
        }

        if ($request->filled('search')) {
            $term = '%' . $request->query('search') . '%';
            $query->where(function ($q) use ($term) {
                $q->where('name', 'like', $term)
                  ->orWhere('description', 'like', $term)
                  ->orWhere('share_code', 'like', $term);
            });
        }

        $configs = $query->orderBy('downloads_count', 'desc')->paginate(20);

        return response()->json([
            'status' => 'success',
            'message' => 'Configurations retrieved.',
            'data' => collect($configs->items())->map(function (Configuration $cfg) {
                return [
                    'id' => $cfg->id,
                    'name' => $cfg->name,
                    'description' => $cfg->description,
                    'protocol' => $cfg->protocol,
                    'share_code' => $cfg->share_code,
                    'export_locked' => $cfg->export_locked,
                    'downloads_count' => $cfg->downloads_count,
                    'created_at' => $cfg->created_at->toIso8601String(),
                ];
            }),
            'meta' => [
                'current_page' => $configs->currentPage(),
                'last_page' => $configs->lastPage(),
                'total' => $configs->total(),
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * Publish or upload a configuration.
     */
    public function store(StoreConfigurationRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $deviceId = null;
        $deviceUuid = $request->header('X-Device-UUID');
        if ($deviceUuid) {
            $device = Device::where('device_uuid', $deviceUuid)->first();
            $deviceId = $device?->id;
        }

        $config = Configuration::create([
            'device_id' => $deviceId,
            'server_id' => $validated['server_id'] ?? null,
            'name' => $validated['name'],
            'description' => $validated['description'] ?? null,
            'protocol' => $validated['protocol'],
            'config_data' => $validated['config_data'],
            'is_public' => $validated['is_public'] ?? false,
            'is_active' => true,
            'export_locked' => $validated['export_locked'] ?? false,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Configuration saved successfully.',
            'data' => [
                'id' => $config->id,
                'name' => $config->name,
                'protocol' => $config->protocol,
                'share_code' => $config->share_code,
                'is_public' => $config->is_public,
                'export_locked' => $config->export_locked,
                'created_at' => $config->created_at->toIso8601String(),
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ], 201);
    }

    /**
     * Show single configuration details.
     */
    public function show(int $id): JsonResponse
    {
        $config = Configuration::where('is_active', true)->find($id);
        if (!$config) {
            return response()->json([
                'status' => 'error',
                'message' => 'Configuration not found.',
                'data' => null,
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Configuration retrieved.',
            'data' => [
                'id' => $config->id,
                'name' => $config->name,
                'description' => $config->description,
                'protocol' => $config->protocol,
                'share_code' => $config->share_code,
                'config_data' => $config->export_locked ? null : $config->config_data,
                'export_locked' => $config->export_locked,
                'downloads_count' => $config->downloads_count,
                'created_at' => $config->created_at->toIso8601String(),
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * Download raw configuration text payload.
     */
    public function download(int $id): Response|JsonResponse
    {
        $config = Configuration::where('is_active', true)->find($id);
        if (!$config) {
            return response()->json([
                'status' => 'error',
                'message' => 'Configuration not found.',
                'data' => null,
            ], 404);
        }

        $config->increment('downloads_count');

        $ext = $config->protocol === 'ovpn' ? 'ovpn' : ($config->protocol === 'rtp' ? 'rtp' : 'txt');
        $filename = preg_replace('/[^a-zA-Z0-9_-]/', '_', $config->name) . '.' . $ext;

        return response($config->config_data, 200, [
            'Content-Type' => 'text/plain; charset=UTF-8',
            'Content-Disposition' => "attachment; filename=\"{$filename}\"",
        ]);
    }

    /**
     * Import configuration by share code (e.g. FAST-DE1).
     */
    public function byShareCode(string $code): JsonResponse
    {
        $config = Configuration::where('share_code', strtoupper($code))
            ->where('is_active', true)
            ->first();

        if (!$config) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid or expired configuration share code.',
                'data' => null,
            ], 404);
        }

        $config->increment('downloads_count');

        return response()->json([
            'status' => 'success',
            'message' => 'Configuration imported via share code.',
            'data' => [
                'id' => $config->id,
                'name' => $config->name,
                'description' => $config->description,
                'protocol' => $config->protocol,
                'share_code' => $config->share_code,
                'config_data' => $config->config_data,
                'export_locked' => $config->export_locked,
                'downloads_count' => $config->downloads_count,
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }
}
