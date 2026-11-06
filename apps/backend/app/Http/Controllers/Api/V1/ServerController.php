<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Server;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ServerController extends Controller
{
    /**
     * Returns curated ready-made OpenVPN and proxy servers.
     */
    public function index(Request $request): JsonResponse
    {
        $query = Server::where('is_active', true);

        if ($request->filled('country')) {
            $query->where('country_code', strtoupper($request->query('country')));
        }

        if ($request->filled('protocol')) {
            $query->where('protocol', strtolower($request->query('protocol')));
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
                    'ovpn_config' => $server->ovpn_config,
                ];
            }),
            'meta' => [
                'count' => $servers->count(),
                'timestamp' => now()->toISOString(),
            ],
        ]);
    }
}
