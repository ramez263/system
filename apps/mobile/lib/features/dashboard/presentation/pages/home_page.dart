import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/device_identity_service.dart';
import '../../../../core/theme/theme_extension.dart';
import '../../../../core/widgets/ramez_glass_card.dart';
import '../../../../core/widgets/ramez_status_chip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _deviceUuid = 'Loading...';
  String _deviceModel = 'Loading...';
  TunnelState _tunnelState = TunnelState.disconnected;
  Timer? _sessionTimer;
  int _secondsConnected = 0;
  String _selectedServerName = 'Frankfurt Fast-01 (Auto)';
  String _selectedServerFlag = '🇩🇪';

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDeviceInfo() async {
    final deviceService = sl<DeviceIdentityService>();
    final uuid = await deviceService.getOrCreateDeviceUuid();
    final meta = await deviceService.getDeviceMetadata();
    if (mounted) {
      setState(() {
        _deviceUuid = uuid;
        _deviceModel = meta['device_name']?.toString() ?? 'Android Device';
      });
    }
  }

  void _toggleConnection() {
    if (_tunnelState == TunnelState.connected) {
      _sessionTimer?.cancel();
      setState(() {
        _tunnelState = TunnelState.disconnected;
        _secondsConnected = 0;
      });
    } else if (_tunnelState == TunnelState.disconnected) {
      setState(() => _tunnelState = TunnelState.connecting);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _tunnelState = TunnelState.connected;
            _secondsConnected = 0;
          });
          _sessionTimer = Timer.periodic(const Duration(seconds: 1), (t) {
            if (mounted) setState(() => _secondsConnected++);
          });
        }
      });
    }
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RamezThemeExtension>();
    final strings = AppStrings.of(context);
    final isArabic = strings.isArabic;
    final isConnected = _tunnelState == TunnelState.connected;
    final isConnecting = _tunnelState == TunnelState.connecting;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: strings.get('notifications_title'),
            onPressed: () => context.push(AppRouter.notificationsPath),
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(context, strings, isArabic),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Guest Device Identity Banner
              RamezGlassCard(
                padding: const EdgeInsets.all(12),
                onTap: () => context.push(AppRouter.deviceAuthPath),
                child: Row(
                  children: [
                    Icon(Icons.fingerprint, size: 28, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_deviceModel • ${strings.guestSession}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            _deviceUuid,
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'monospace',
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Status Chip
              Center(
                child: RamezStatusChip(state: _tunnelState),
              ),

              const SizedBox(height: 20),

              // Center Animated Power Button (One-tap promise)
              Center(
                child: GestureDetector(
                  onTap: isConnecting ? null : _toggleConnection,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected
                          ? (ext?.connectedColor ?? Colors.green)
                          : isConnecting
                              ? (ext?.connectingColor ?? Colors.amber)
                              : theme.colorScheme.surfaceContainerHighest,
                      boxShadow: [
                        BoxShadow(
                          color: (isConnected
                                  ? (ext?.connectedColor ?? Colors.green)
                                  : isConnecting
                                      ? Colors.amber
                                      : theme.colorScheme.primary)
                              .withValues(alpha: isConnected || isConnecting ? 0.4 : 0.15),
                          blurRadius: isConnected ? 32 : 16,
                          spreadRadius: isConnected ? 4 : 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.power_settings_new,
                          size: 68,
                          color: isConnected
                              ? Colors.white
                              : isConnecting
                                  ? Colors.black87
                                  : theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isConnected
                              ? strings.connected
                              : isConnecting
                                  ? strings.connecting
                                  : strings.tapToConnect,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: isConnected
                                ? Colors.white
                                : isConnecting
                                    ? Colors.black87
                                    : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (isConnected) ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatDuration(_secondsConnected),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Server Selection Card
              RamezGlassCard(
                onTap: () async {
                  final result = await context.push(AppRouter.serversPath);
                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      _selectedServerName = result['name'] as String;
                      _selectedServerFlag = result['flag'] as String;
                    });
                  }
                },
                child: Row(
                  children: [
                    Text(_selectedServerFlag, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.server,
                            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                          ),
                          Text(
                            _selectedServerName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Live Real-Time Telemetry Counters
              Row(
                children: [
                  Expanded(
                    child: RamezGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_downward, size: 16, color: Colors.blue),
                              const SizedBox(width: 6),
                              Text(strings.downloadSpeed, style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isConnected ? '24.8 Mbps' : '0.0 Mbps',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RamezGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_upward, size: 16, color: Colors.purple),
                              const SizedBox(width: 6),
                              Text(strings.uploadSpeed, style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isConnected ? '8.4 Mbps' : '0.0 Mbps',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RamezGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.network_ping, size: 16, color: Colors.green),
                              const SizedBox(width: 6),
                              Text(strings.latency, style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isConnected ? '32 ms' : '--',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Quick Action Shortcuts Grid
              Text(
                isArabic ? 'الوصول السريع' : 'Quick Actions',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.vpn_lock,
                      label: strings.configsTitle,
                      onTap: () => context.push(AppRouter.configsPath),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.bar_chart,
                      label: strings.statisticsTitle,
                      onTap: () => context.push(AppRouter.statisticsPath),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.star_outline,
                      label: strings.plansTitle,
                      onTap: () => context.push(AppRouter.plansPath),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return RamezGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context, AppStrings strings, bool isArabic) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.shield, size: 42, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  strings.appName,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${strings.guestSession} • v1.0.0',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text(strings.appName),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: Text(strings.serversTitle),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRouter.serversPath);
            },
          ),
          ListTile(
            leading: const Icon(Icons.tune_outlined),
            title: Text(strings.configsTitle),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRouter.configsPath);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: Text(strings.statisticsTitle),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRouter.statisticsPath);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history_outlined),
            title: Text(strings.historyTitle),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRouter.historyPath);
            },
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: Text(strings.plansTitle),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRouter.plansPath);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(strings.appearanceTitle),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRouter.appearancePath);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(strings.languageTitle),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRouter.languagePath);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_input_component_outlined),
            title: Text(strings.advancedSettingsTitle),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRouter.advancedNetworkPath);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(strings.get('app_settings_title')),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRouter.appSettingsPath);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(strings.supportCenterTitle),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRouter.supportPath);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(strings.aboutTitle),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRouter.aboutPath);
            },
          ),
        ],
      ),
    );
  }
}
