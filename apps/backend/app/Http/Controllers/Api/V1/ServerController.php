<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\ServerQueryRequest;
use App\Models\Server;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;

class ServerController extends Controller
{
    /**
     * Returns curated ready-made OpenVPN and proxy servers.
     */
    public function index(ServerQueryRequest $request): JsonResponse
    {
        $query = Server::where('is_active', true);

        if ($request->filled('country')) {
            $query->where('country_code', strtoupper($request->query('country')));
        }

        if ($request->filled('protocol')) {
            $query->where('protocol', strtolower($request->query('protocol')));
        }

        if ($request->has('is_premium')) {
            $query->where('is_premium', filter_var($request->query('is_premium'), FILTER_VALIDATE_BOOLEAN));
        }

        if ($request->filled('search')) {
            $term = '%' . $request->query('search') . '%';
            $query->where(function ($q) use ($term) {
                $q->where('name', 'like', $term)
                  ->orWhere('city', 'like', $term)
                  ->orWhere('country_name', 'like', $term);
            });
        }

        $servers = $query->orderBy('ping_ms', 'asc')->get();

        return response()->json([
            'status' => 'success',
            'message' => 'Servers retrieved successfully.',
            'data' => $servers->map(function (Server $server) {
                return [
                    'id' => $server->id,
                    'name' => $server->name,
                    'country_code' => $server->country_code,
                    'country_name' => $server->country_name,
                    'city' => $server->city,
                    'flag_emoji' => $server->flag_emoji,
                    'protocol' => $server->protocol,
                    'ip_address' => $server->ip_address,
                    'port' => $server->port,
                    'ping_ms' => $server->ping_ms,
                    'current_load' => $server->current_load,
                    'is_premium' => $server->is_premium,
                    'has_ovpn' => !empty($server->ovpn_config),
                ];
            }),
            'meta' => [
                'count' => $servers->count(),
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * Server details including OpenVPN configuration string.
     */
    public function show(int $id): JsonResponse
    {
        $server = Server::where('is_active', true)->find($id);
        if (!$server) {
            return response()->json([
                'status' => 'error',
                'message' => 'Server not found.',
                'data' => null,
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Server retrieved.',
            'data' => [
                'id' => $server->id,
                'name' => $server->name,
                'country_code' => $server->country_code,
                'country_name' => $server->country_name,
                'city' => $server->city,
                'flag_emoji' => $server->flag_emoji,
                'protocol' => $server->protocol,
                'ip_address' => $server->ip_address,
                'port' => $server->port,
                'ping_ms' => $server->ping_ms,
                'current_load' => $server->current_load,
                'is_premium' => $server->is_premium,
                'ovpn_config' => $server->ovpn_config,
            ],
            'meta' => [
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }

    /**
     * Download raw OpenVPN configuration file.
     */
    public function downloadOvpn(int $id): Response|JsonResponse
    {
        $server = Server::where('is_active', true)->find($id);
        if (!$server || empty($server->ovpn_config)) {
            return response()->json([
                'status' => 'error',
                'message' => 'OpenVPN configuration not available for this server.',
                'data' => null,
            ], 404);
        }

        $filename = preg_replace('/[^a-zA-Z0-9_-]/', '_', $server->name) . '.ovpn';

        return response($server->ovpn_config, 200, [
            'Content-Type' => 'text/plain; charset=UTF-8',
            'Content-Disposition' => "attachment; filename=\"{$filename}\"",
        ]);
    }

    /**
     * Returns unique countries with available active servers.
     */
    public function countries(): JsonResponse
    {
        $countries = Server::where('is_active', true)
            ->selectRaw('country_code, country_name, flag_emoji, COUNT(*) as server_count')
            ->groupBy('country_code', 'country_name', 'flag_emoji')
            ->orderBy('country_name', 'asc')
            ->get();

        return response()->json([
            'status' => 'success',
            'message' => 'Countries retrieved.',
            'data' => $countries,
            'meta' => [
                'total_countries' => $countries->count(),
                'timestamp' => now()->toIso8601String(),
            ],
        ]);
    }
}
