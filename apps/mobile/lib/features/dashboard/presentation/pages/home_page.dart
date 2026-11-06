import 'package:flutter/material.dart';
import '../../../../core/config/app_environment.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/device_identity_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _deviceUuid = 'Loading...';
  String _deviceModel = 'Loading...';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
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
    setState(() {
      _isConnected = !_isConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = AppConfig.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(config.appName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings will be configured in Phase 2')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Flavor & Environment Badge
              if (!config.isProduction)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: config.isDevelopment
                        ? Colors.amber.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: config.isDevelopment ? Colors.amber : Colors.orange,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.developer_mode,
                        size: 16,
                        color: config.isDevelopment ? Colors.amber[800] : Colors.orange[800],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'FLAVOR: ${config.flavor.name.toUpperCase()} (API: ${config.apiBaseUrl})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: config.isDevelopment ? Colors.amber[900] : Colors.orange[900],
                        ),
                      ),
                    ],
                  ),
                ),

              // Device Identity Info Card (No login required - device acts as user)
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.perm_identity, size: 20, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Device Identity (Guest Session)',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Device: $_deviceModel',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: $_deviceUuid',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: 'monospace',
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Animated Connect Button (One-tap promise)
              Center(
                child: GestureDetector(
                  onTap: _toggleConnection,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isConnected
                          ? const Color(0xFF059669)
                          : theme.colorScheme.primaryContainer,
                      boxShadow: [
                        BoxShadow(
                          color: (_isConnected ? Colors.green : theme.colorScheme.primary)
                              .withValues(alpha: 0.3),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.power_settings_new,
                          size: 64,
                          color: _isConnected
                              ? Colors.white
                              : theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isConnected ? 'CONNECTED' : 'TAP TO CONNECT',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: _isConnected
                                ? Colors.white
                                : theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Status Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Protocol', 'OpenVPN / sing-box', theme),
                    _buildStatItem('Server', 'Ready Server (Auto)', theme),
                    _buildStatItem('Latency', _isConnected ? '35 ms' : '--', theme),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
