<?php

namespace App\Console\Commands;

use App\Models\Server;
use Database\Seeders\ServerSeeder;
use Illuminate\Console\Command;

class SyncPublicServerPoolCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'servers:sync-pool
                            {--source=default : Community pool source (default, vpngate)}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Synchronizes and refreshes curated public OpenVPN servers pool';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $source = $this->option('source');
        $this->info("Synchronizing curated server pool from source [{$source}]...");

        $seeder = new ServerSeeder();
        $seeder->run();

        $count = Server::where('is_active', true)->count();
        $this->info("Public server pool synchronized successfully. Total active servers: {$count}.");

        return 0;
    }
}
