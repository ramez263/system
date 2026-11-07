<!DOCTYPE html>
<html lang="en" class="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Control Plane') - Ramez Tunnel Plus Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    colors: {
                        brand: {
                            50: '#f0f9ff',
                            100: '#e0f2fe',
                            400: '#38bdf8',
                            500: '#0284c7',
                            600: '#0369a1',
                            700: '#075985',
                            800: '#0c4a6e',
                            900: '#082f49',
                            950: '#031726',
                        }
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-slate-950 text-slate-100 min-h-screen flex font-sans antialiased selection:bg-sky-500 selection:text-white">
    <!-- Sidebar Navigation -->
    <aside class="w-64 bg-slate-900 border-r border-slate-800 flex flex-col fixed inset-y-0 z-40">
        <!-- Logo -->
        <div class="h-16 flex items-center px-6 border-b border-slate-800 space-x-3">
            <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-sky-500 via-indigo-500 to-purple-600 flex items-center justify-center font-black text-white shadow-lg shadow-sky-500/20 text-lg">
                R+
            </div>
            <div>
                <h1 class="text-base font-bold tracking-tight text-white leading-tight">Ramez Tunnel+</h1>
                <span class="text-[10px] uppercase tracking-wider font-semibold text-sky-400 bg-sky-950/60 px-1.5 py-0.5 rounded border border-sky-800/40">Control Plane</span>
            </div>
        </div>

        <!-- Navigation Links -->
        <nav class="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
            <a href="{{ route('admin.dashboard') }}" class="flex items-center px-3 py-2.5 rounded-lg text-sm font-medium transition {{ request()->routeIs('admin.dashboard') ? 'bg-sky-600 text-white shadow-lg shadow-sky-600/30' : 'text-slate-300 hover:bg-slate-800 hover:text-white' }}">
                <i class="fa-solid fa-gauge-high w-5 mr-3 text-center"></i>
                Dashboard
            </a>
            <a href="{{ route('admin.analytics') }}" class="flex items-center px-3 py-2.5 rounded-lg text-sm font-medium transition {{ request()->routeIs('admin.analytics') ? 'bg-sky-600 text-white shadow-lg shadow-sky-600/30' : 'text-slate-300 hover:bg-slate-800 hover:text-white' }}">
                <i class="fa-solid fa-chart-line w-5 mr-3 text-center"></i>
                Analytics
            </a>
            <div class="pt-3 pb-1 px-3 text-[11px] font-semibold uppercase tracking-wider text-slate-500">Infrastructure</div>
            <a href="{{ route('admin.servers.index') }}" class="flex items-center px-3 py-2.5 rounded-lg text-sm font-medium transition {{ request()->routeIs('admin.servers.*') ? 'bg-sky-600 text-white shadow-lg shadow-sky-600/30' : 'text-slate-300 hover:bg-slate-800 hover:text-white' }}">
                <i class="fa-solid fa-server w-5 mr-3 text-center"></i>
                Servers Pool
            </a>
            <a href="{{ route('admin.configurations.index') }}" class="flex items-center px-3 py-2.5 rounded-lg text-sm font-medium transition {{ request()->routeIs('admin.configurations.*') ? 'bg-sky-600 text-white shadow-lg shadow-sky-600/30' : 'text-slate-300 hover:bg-slate-800 hover:text-white' }}">
                <i class="fa-solid fa-network-wired w-5 mr-3 text-center"></i>
                Configurations (.rtp)
            </a>
            <div class="pt-3 pb-1 px-3 text-[11px] font-semibold uppercase tracking-wider text-slate-500">Clients & Monetization</div>
            <a href="{{ route('admin.devices.index') }}" class="flex items-center px-3 py-2.5 rounded-lg text-sm font-medium transition {{ request()->routeIs('admin.devices.*') ? 'bg-sky-600 text-white shadow-lg shadow-sky-600/30' : 'text-slate-300 hover:bg-slate-800 hover:text-white' }}">
                <i class="fa-solid fa-mobile-screen-button w-5 mr-3 text-center"></i>
                Hardware Devices
            </a>
            <a href="{{ route('admin.plans.index') }}" class="flex items-center px-3 py-2.5 rounded-lg text-sm font-medium transition {{ request()->routeIs('admin.plans.*') ? 'bg-sky-600 text-white shadow-lg shadow-sky-600/30' : 'text-slate-300 hover:bg-slate-800 hover:text-white' }}">
                <i class="fa-solid fa-receipt w-5 mr-3 text-center"></i>
                Plans & Promo Vouchers
            </a>
            <a href="{{ route('admin.announcements.index') }}" class="flex items-center px-3 py-2.5 rounded-lg text-sm font-medium transition {{ request()->routeIs('admin.announcements.*') ? 'bg-sky-600 text-white shadow-lg shadow-sky-600/30' : 'text-slate-300 hover:bg-slate-800 hover:text-white' }}">
                <i class="fa-solid fa-bullhorn w-5 mr-3 text-center"></i>
                Announcements
            </a>
            <div class="pt-3 pb-1 px-3 text-[11px] font-semibold uppercase tracking-wider text-slate-500">System & Governance</div>
            <a href="{{ route('admin.remote_config.index') }}" class="flex items-center px-3 py-2.5 rounded-lg text-sm font-medium transition {{ request()->routeIs('admin.remote_config.*') ? 'bg-sky-600 text-white shadow-lg shadow-sky-600/30' : 'text-slate-300 hover:bg-slate-800 hover:text-white' }}">
                <i class="fa-solid fa-sliders w-5 mr-3 text-center"></i>
                Remote Config & Releases
            </a>
            <a href="{{ route('admin.audit_logs.index') }}" class="flex items-center px-3 py-2.5 rounded-lg text-sm font-medium transition {{ request()->routeIs('admin.audit_logs.*') ? 'bg-sky-600 text-white shadow-lg shadow-sky-600/30' : 'text-slate-300 hover:bg-slate-800 hover:text-white' }}">
                <i class="fa-solid fa-shield-halved w-5 mr-3 text-center"></i>
                Audit Trail
            </a>
            <a href="/api/documentation" target="_blank" class="flex items-center px-3 py-2.5 rounded-lg text-sm font-medium text-amber-400 hover:bg-slate-800 transition">
                <i class="fa-solid fa-book-open w-5 mr-3 text-center"></i>
                Swagger API Docs
            </a>
        </nav>

        <!-- Current User Profile & Logout -->
        <div class="p-3 border-t border-slate-800 bg-slate-900/60">
            @auth
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-3 overflow-hidden">
                    <div class="w-9 h-9 rounded-full bg-slate-800 border border-slate-700 flex items-center justify-center font-bold text-sky-400">
                        {{ strtoupper(substr(Auth::user()->name, 0, 1)) }}
                    </div>
                    <div class="truncate">
                        <div class="text-sm font-semibold text-slate-200 truncate">{{ Auth::user()->name }}</div>
                        <div class="text-[11px] text-sky-400 font-mono capitalize">{{ str_replace('_', ' ', Auth::user()->role) }}</div>
                    </div>
                </div>
                <form method="POST" action="{{ route('admin.logout') }}">
                    @csrf
                    <button type="submit" title="Logout" class="p-2 text-slate-400 hover:text-rose-400 hover:bg-slate-800 rounded-lg transition">
                        <i class="fa-solid fa-arrow-right-from-bracket"></i>
                    </button>
                </form>
            </div>
            @endauth
        </div>
    </aside>

    <!-- Main Wrapper -->
    <div class="flex-1 flex flex-col ml-64 min-h-screen">
        <!-- Topbar -->
        <header class="h-16 border-b border-slate-800 bg-slate-900/80 backdrop-blur sticky top-0 z-30 px-6 flex items-center justify-between">
            <div class="flex items-center space-x-3">
                <span class="text-slate-400 text-sm font-medium">Control Plane /</span>
                <span class="text-white text-sm font-semibold">@yield('page_title', 'Overview')</span>
            </div>
            <div class="flex items-center space-x-4">
                <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                    <span class="w-2 h-2 rounded-full bg-emerald-400 mr-1.5 animate-pulse"></span>
                    API Gateway Online
                </span>
                <a href="/api/documentation" target="_blank" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-300 px-3 py-1.5 rounded-lg border border-slate-700 transition">
                    OpenAPI 3.0
                </a>
            </div>
        </header>

        <!-- Content Area -->
        <main class="flex-1 p-6 lg:p-8 max-w-7xl w-full mx-auto">
            @if(session('success'))
                <div class="mb-6 p-4 rounded-xl bg-emerald-950/60 border border-emerald-700/60 text-emerald-300 text-sm flex items-center shadow-lg shadow-emerald-950/40">
                    <i class="fa-solid fa-circle-check text-lg mr-3 text-emerald-400"></i>
                    <span>{{ session('success') }}</span>
                </div>
            @endif

            @if(session('error'))
                <div class="mb-6 p-4 rounded-xl bg-rose-950/60 border border-rose-700/60 text-rose-300 text-sm flex items-center shadow-lg shadow-rose-950/40">
                    <i class="fa-solid fa-circle-exclamation text-lg mr-3 text-rose-400"></i>
                    <span>{{ session('error') }}</span>
                </div>
            @endif

            @if($errors->any())
                <div class="mb-6 p-4 rounded-xl bg-amber-950/60 border border-amber-700/60 text-amber-300 text-sm shadow-lg shadow-amber-950/40">
                    <div class="font-bold flex items-center mb-2">
                        <i class="fa-solid fa-triangle-exclamation mr-2 text-amber-400"></i> Please correct the following errors:
                    </div>
                    <ul class="list-disc list-inside space-y-1 text-xs">
                        @foreach($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            @yield('content')
        </main>

        <!-- Footer -->
        <footer class="border-t border-slate-900 bg-slate-950/80 py-4 px-8 text-center text-xs text-slate-500">
            Ramez Tunnel Plus &copy; {{ date('Y') }} — Monitored via Device UUID Architecture & Curated OpenVPN Nodes.
        </footer>
    </div>
</body>
</html>
