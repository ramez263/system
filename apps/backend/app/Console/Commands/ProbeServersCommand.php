<?php

namespace App\Console\Commands;

use App\Models\Server;
use App\Services\ServerProbeService;
use Illuminate\Console\Command;

class ProbeServersCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'servers:probe
                            {--dry-run : Test probes without saving changes to database}
                            {--id= : Probe single server by ID}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Probes all active curated OpenVPN servers and updates latency and load metrics';

    /**
     * Execute the console command.
     */
    public function handle(ServerProbeService $probeService): int
    {
        $dryRun = (bool) $this->option('dry-run');
        $serverId = $this->option('id');

        $this->info($dryRun ? 'Running server latency probes (DRY RUN)...' : 'Probing and updating server metrics...');

        if ($serverId) {
            $server = Server::find($serverId);
            if (!$server) {
                $this->error("Server ID {$serverId} not found.");
                return 1;
            }
            $results = collect([$probeService->probeServer($server, $dryRun)]);
        } else {
            $results = $probeService->probeAllServers($dryRun);
        }

        $headers = ['ID', 'Server Name', 'IP:Port', 'Country', 'Status', 'Ping (ms)', 'Load (%)'];
        $rows = $results->map(function ($r) {
            return [
                $r['id'],
                $r['name'],
                "{$r['ip']}:{$r['port']}",
                $r['country'],
                $r['status'],
                "{$r['ping_ms']} ms",
                "{$r['load']}%",
            ];
        })->toArray();

        $this->table($headers, $rows);
        $this->info("Successfully probed {$results->count()} servers.");

        return 0;
    }
}
