<!DOCTYPE html>
<html lang="en" class="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Ramez Tunnel Plus</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="bg-slate-950 text-slate-100 min-h-screen flex items-center justify-center p-4 antialiased">
    <div class="max-w-md w-full">
        <!-- Logo and Title -->
        <div class="text-center mb-8">
            <div class="inline-flex w-16 h-16 rounded-2xl bg-gradient-to-tr from-sky-500 via-indigo-500 to-purple-600 items-center justify-center font-black text-white shadow-2xl shadow-sky-500/30 text-2xl mb-4">
                R+
            </div>
            <h1 class="text-2xl font-bold tracking-tight text-white">Ramez Tunnel Plus</h1>
            <p class="text-xs text-sky-400 font-mono mt-1">Control Plane Administration</p>
        </div>

        <!-- Flash alerts -->
        @if(session('error'))
            <div class="mb-4 p-3 rounded-xl bg-rose-950/70 border border-rose-800 text-rose-300 text-sm flex items-center">
                <i class="fa-solid fa-circle-exclamation mr-2 text-rose-400"></i>
                {{ session('error') }}
            </div>
        @endif
        @if(session('success'))
            <div class="mb-4 p-3 rounded-xl bg-emerald-950/70 border border-emerald-800 text-emerald-300 text-sm flex items-center">
                <i class="fa-solid fa-circle-check mr-2 text-emerald-400"></i>
                {{ session('success') }}
            </div>
        @endif

        <!-- Login Card -->
        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 sm:p-8 shadow-2xl shadow-slate-950">
            <h2 class="text-lg font-semibold text-white mb-6 flex items-center">
                <i class="fa-solid fa-lock text-sky-400 mr-2 text-sm"></i>
                Administrative Authentication
            </h2>

            <form method="POST" action="{{ route('admin.login.submit') }}" class="space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5" for="email">Admin Email</label>
                    <div class="relative">
                        <span class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-slate-500">
                            <i class="fa-solid fa-envelope"></i>
                        </span>
                        <input type="email" id="email" name="email" value="{{ old('email', 'admin@rameztunnel.com') }}" required autofocus
                            class="w-full bg-slate-950 border border-slate-700 rounded-xl py-2.5 pl-10 pr-4 text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-sky-500 focus:border-transparent">
                    </div>
                    @error('email')
                        <p class="mt-1 text-xs text-rose-400">{{ $message }}</p>
                    @enderror
                </div>

                <div>
                    <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5" for="password">Password</label>
                    <div class="relative">
                        <span class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-slate-500">
                            <i class="fa-solid fa-key"></i>
                        </span>
                        <input type="password" id="password" name="password" value="password123" required
                            class="w-full bg-slate-950 border border-slate-700 rounded-xl py-2.5 pl-10 pr-4 text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-sky-500 focus:border-transparent">
                    </div>
                    @error('password')
                        <p class="mt-1 text-xs text-rose-400">{{ $message }}</p>
                    @enderror
                </div>

                <div class="flex items-center justify-between text-xs pt-1">
                    <label class="flex items-center text-slate-400 hover:text-slate-300 cursor-pointer">
                        <input type="checkbox" name="remember" class="rounded bg-slate-950 border-slate-700 text-sky-500 focus:ring-sky-500 mr-2">
                        Remember session
                    </label>
                    <span class="text-slate-500 text-[11px]">Hardware ID Security Enabled</span>
                </div>

                <button type="submit"
                    class="w-full mt-4 bg-gradient-to-r from-sky-500 to-indigo-600 hover:from-sky-600 hover:to-indigo-700 text-white font-medium py-2.5 px-4 rounded-xl text-sm transition shadow-lg shadow-sky-500/25 flex items-center justify-center space-x-2">
                    <i class="fa-solid fa-right-to-bracket"></i>
                    <span>Sign In to Control Plane</span>
                </button>
            </form>

            <!-- Quick Demo Credentials Selector -->
            <div class="mt-6 pt-6 border-t border-slate-800">
                <p class="text-[11px] text-slate-400 mb-2 font-semibold uppercase tracking-wider">Quick Fill Demo Roles:</p>
                <div class="grid grid-cols-2 gap-2 text-xs">
                    <button type="button" onclick="setCreds('admin@rameztunnel.com')" class="text-left bg-slate-950 hover:bg-slate-800 p-2 rounded-lg border border-slate-800 hover:border-slate-700 transition">
                        <div class="font-medium text-sky-400">Super Admin</div>
                        <div class="text-[10px] text-slate-500 truncate">admin@rameztunnel.com</div>
                    </button>
                    <button type="button" onclick="setCreds('support@rameztunnel.com')" class="text-left bg-slate-950 hover:bg-slate-800 p-2 rounded-lg border border-slate-800 hover:border-slate-700 transition">
                        <div class="font-medium text-emerald-400">Support Desk</div>
                        <div class="text-[10px] text-slate-500 truncate">support@rameztunnel.com</div>
                    </button>
                    <button type="button" onclick="setCreds('finance@rameztunnel.com')" class="text-left bg-slate-950 hover:bg-slate-800 p-2 rounded-lg border border-slate-800 hover:border-slate-700 transition">
                        <div class="font-medium text-purple-400">Finance Lead</div>
                        <div class="text-[10px] text-slate-500 truncate">finance@rameztunnel.com</div>
                    </button>
                    <button type="button" onclick="setCreds('viewer@rameztunnel.com')" class="text-left bg-slate-950 hover:bg-slate-800 p-2 rounded-lg border border-slate-800 hover:border-slate-700 transition">
                        <div class="font-medium text-amber-400">Auditor</div>
                        <div class="text-[10px] text-slate-500 truncate">viewer@rameztunnel.com</div>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        function setCreds(email) {
            document.getElementById('email').value = email;
            document.getElementById('password').value = 'password123';
        }
    </script>
</body>
</html>
