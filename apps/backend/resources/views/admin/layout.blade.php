<!DOCTYPE html>
<html lang="en" class="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Control Plane') - Ramez Tunnel Plus Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    colors: {
                        brand: {
                            50: '#eff6ff',
                            500: '#0284c7',
                            600: '#0369a1',
                            700: '#075985',
                            900: '#0c4a6e',
                        }
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-slate-950 text-slate-100 min-h-screen flex flex-col font-sans antialiased">
    <!-- Navbar -->
    <header class="border-b border-slate-800 bg-slate-900/80 backdrop-blur sticky top-0 z-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
            <div class="flex items-center space-x-3">
                <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-sky-600 to-indigo-600 flex items-center justify-center font-bold text-white shadow-lg shadow-sky-500/20">
                    R+
                </div>
                <div>
                    <h1 class="text-lg font-bold tracking-tight text-white">Ramez Tunnel Plus</h1>
                    <p class="text-xs text-sky-400 font-mono">Control Plane Admin MVP</p>
                </div>
            </div>
            <nav class="flex items-center space-x-1 sm:space-x-4">
                <a href="/admin" class="px-3 py-2 rounded-lg text-sm font-medium hover:bg-slate-800 transition">Dashboard</a>
                <a href="/admin/servers" class="px-3 py-2 rounded-lg text-sm font-medium hover:bg-slate-800 transition">Servers</a>
                <a href="/admin/devices" class="px-3 py-2 rounded-lg text-sm font-medium hover:bg-slate-800 transition">Devices</a>
                <a href="/api/documentation" class="px-3 py-2 rounded-lg text-sm font-medium text-amber-400 hover:bg-slate-800 transition">API Docs</a>
            </nav>
        </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 max-w-7xl mx-auto w-full px-4 sm:px-6 lg:px-8 py-8">
        @if(session('success'))
            <div class="mb-6 p-4 rounded-xl bg-emerald-950/60 border border-emerald-800 text-emerald-300 text-sm flex items-center">
                <svg class="w-5 h-5 mr-2 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                {{ session('success') }}
            </div>
        @endif

        @yield('content')
    </main>

    <!-- Footer -->
    <footer class="border-t border-slate-900 bg-slate-950/60 py-6 text-center text-xs text-slate-500">
        <p>Ramez Tunnel Plus &copy; {{ date('Y') }} — OpenVPN & WireGuard High-Performance Control Plane</p>
    </footer>
</body>
</html>
