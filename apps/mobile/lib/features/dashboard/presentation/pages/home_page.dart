import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/device_identity_service.dart';
import '../../../../core/theme/app_colors.dart';
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
  Map<String, dynamic>? _selectedConfig;

  final List<Map<String, dynamic>> _providerConfigs = const [
    {
      'id': 'vod-router',
      'name': 'Vodafone for Router',
      'provider': 'Vodafone',
      'device': 'Router',
      'protocol': 'OpenVPN UDP',
      'port': 1194,
      'speed': '45 Mbps',
      'asset': 'assets/images/providers/vodafone.png'
    },
    {
      'id': 'vod-flex',
      'name': 'Vodafone for Flex',
      'provider': 'Vodafone',
      'device': 'Flex',
      'protocol': 'OpenVPN UDP',
      'port': 1194,
      'speed': '60 Mbps',
      'asset': 'assets/images/providers/vodafone.png'
    },
    {
      'id': 'orange-router',
      'name': 'Orange for Router',
      'provider': 'Orange',
      'device': 'Router',
      'protocol': 'OpenVPN TCP',
      'port': 443,
      'speed': '38 Mbps',
      'asset': 'assets/images/providers/orange.png'
    },
    {
      'id': 'orange-flex',
      'name': 'Orange for Flex',
      'provider': 'Orange',
      'device': 'Flex',
      'protocol': 'OpenVPN UDP',
      'port': 1194,
      'speed': '55 Mbps',
      'asset': 'assets/images/providers/orange.png'
    },
    {
      'id': 'etis-router',
      'name': 'Etisalat for Router',
      'provider': 'Etisalat',
      'device': 'Router',
      'protocol': 'OpenVPN UDP',
      'port': 1194,
      'speed': '40 Mbps',
      'asset': 'assets/images/providers/etisalat.png'
    },
    {
      'id': 'we-mobile',
      'name': 'WE for Mobile',
      'provider': 'WE',
      'device': 'Mobile',
      'protocol': 'OpenVPN UDP',
      'port': 1194,
      'speed': '30 Mbps',
      'asset': 'assets/images/providers/we.png'
    },
  ];

  final List<Map<String, dynamic>> _serverOptions = const [
    {
      'name': 'Frankfurt Fast-01 (Auto)',
      'flag': '🇩🇪',
      'city': 'Frankfurt',
      'country_name': 'Germany',
      'ping_ms': 28,
      'load': 24
    },
    {
      'name': 'Amsterdam Ultra 01',
      'flag': '🇳🇱',
      'city': 'Amsterdam',
      'country_name': 'Netherlands',
      'ping_ms': 32,
      'load': 35
    },
    {
      'name': 'London Express 01',
      'flag': '🇬🇧',
      'city': 'London',
      'country_name': 'United Kingdom',
      'ping_ms': 42,
      'load': 18
    },
    {
      'name': 'New York East 01',
      'flag': '🇺🇸',
      'city': 'New York',
      'country_name': 'United States',
      'ping_ms': 96,
      'load': 45
    },
    {
      'name': 'Singapore Hub 01',
      'flag': '🇸🇬',
      'city': 'Singapore',
      'country_name': 'Singapore',
      'ping_ms': 118,
      'load': 28
    },
  ];

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
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    if (h != '00') return '$h:$m:$s';
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 28, width: 28),
            const SizedBox(width: 10),
            Text(
              strings.appName,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
          ],
        ),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Guest Device Identity Banner
              RamezGlassCard(
                padding: const EdgeInsets.all(14),
                onTap: () => context.push(AppRouter.deviceAuthPath),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.fingerprint,
                          size: 26, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_deviceModel • ${strings.guestSession}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
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
                    const Icon(Icons.chevron_right,
                        size: 18, color: Colors.grey),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Center Animated Power Button
              Center(
                child: _PowerButton(
                  state: _tunnelState,
                  durationText: _formatDuration(_secondsConnected),
                  label: isConnected
                      ? strings.connected
                      : isConnecting
                          ? strings.connecting
                          : strings.tapToConnect,
                  accentColor: theme.colorScheme.primary,
                  connectedColor: ext?.connectedColor ?? AppColors.success,
                  connectingColor: ext?.connectingColor ?? AppColors.warning,
                  onTap: isConnecting ? null : _toggleConnection,
                ),
              ),

              const SizedBox(height: 28),

              // Status Chip
              Center(
                child: RamezStatusChip(state: _tunnelState),
              ),

              const SizedBox(height: 20),

              // Choose Server & Configuration (full-width rows)
              _buildConnectionChooser(context, strings, isArabic),

              const SizedBox(height: 18),

              // Live Telemetry Row
              Row(
                children: [
                  Expanded(
                    child: _TelemetryTile(
                      icon: Icons.arrow_downward_rounded,
                      label: strings.downloadSpeed,
                      value: isConnected ? '24.8' : '0.0',
                      unit: 'Mbps',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TelemetryTile(
                      icon: Icons.arrow_upward_rounded,
                      label: strings.uploadSpeed,
                      value: isConnected ? '8.4' : '0.0',
                      unit: 'Mbps',
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TelemetryTile(
                      icon: Icons.network_ping_rounded,
                      label: strings.latency,
                      value: isConnected ? '32' : '--',
                      unit: 'ms',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Action Shortcuts Grid
              Text(
                isArabic ? 'الوصول السريع' : 'Quick Actions',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.vpn_lock_rounded,
                      label: strings.configsTitle,
                      color: Colors.deepPurple,
                      onTap: () => context.push(AppRouter.configsPath),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.bar_chart_rounded,
                      label: strings.statisticsTitle,
                      color: Colors.teal,
                      onTap: () => context.push(AppRouter.statisticsPath),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.workspace_premium_rounded,
                      label: strings.plansTitle,
                      color: Colors.orange,
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

  Widget _buildConnectionChooser(
      BuildContext context, AppStrings strings, bool isArabic) {
    final colorScheme = Theme.of(context).colorScheme;
    final cfg = _selectedConfig;

    return Column(
      children: [
        _chooserTile(
          context: context,
          onTap: () => _showServerSheet(context, strings, isArabic),
          leading: Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(_selectedServerFlag, style: const TextStyle(fontSize: 26)),
          ),
          title: isArabic ? 'خادم' : 'CHOOSE SERVER',
          subtitle: _selectedServerName,
          accentColor: colorScheme.primary,
        ),
        const SizedBox(height: 12),
        _chooserTile(
          context: context,
          onTap: () => _showConfigSheet(context, isArabic),
          leading: cfg != null
              ? Container(
                  width: 54,
                  height: 54,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Image.asset(cfg['asset'] as String, fit: BoxFit.contain),
                )
              : Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white, size: 26),
                ),
          title: isArabic ? 'التكوين' : 'CHOOSE CONFIG',
          subtitle: cfg != null
              ? cfg['name'] as String
              : (isArabic ? 'اختر تكويناً' : 'Select config'),
          accentColor: const Color(0xFF1E293B),
        ),
      ],
    );
  }

  Widget _chooserTile({
    required BuildContext context,
    required VoidCallback onTap,
    required Widget leading,
    required String title,
    required String subtitle,
    required Color accentColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 78,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
  void _showConfigSheet(BuildContext context, bool isArabic) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'اختر التكوين' : 'Choose Configuration',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isArabic
                              ? 'تكوينات جاهزة لمختلف الشبكات'
                              : 'Ready configs for your provider & device',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _providerConfigs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final cfg = _providerConfigs[index];
                    final selected = _selectedConfig?['id'] == cfg['id'];
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() => _selectedConfig = cfg);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${cfg['name']} selected')),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selected
                              ? colorScheme.primary.withValues(alpha: 0.12)
                              : colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? colorScheme.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: colorScheme.outlineVariant
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Image.asset(cfg['asset'] as String,
                                  fit: BoxFit.contain),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          cfg['name'] as String,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (cfg['device'] == 'Router')
                                        _tag('Router', colorScheme)
                                      else if (cfg['device'] == 'Flex')
                                        _tag('Flex', colorScheme)
                                      else
                                        _tag('Mobile', colorScheme),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${cfg['protocol']} • Port ${cfg['port']}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cfg['speed'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: colorScheme.primary,
                                size: 26,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String label, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: colorScheme.primary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  void _showServerSheet(
      BuildContext context, AppStrings strings, bool isArabic) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'اختر الخادم' : 'Choose Server',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isArabic
                              ? 'الأسرع والأقل زمن استجابة'
                              : 'Fastest and lowest latency',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _serverOptions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final s = _serverOptions[index];
                    final ping = s['ping_ms'] as int;
                    final selected = _selectedServerName == s['name'];
                    final isAuto = s['name'].toString().contains('(Auto)');

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(() {
                          _selectedServerName = s['name'] as String;
                          _selectedServerFlag = s['flag'] as String;
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${s['name']} selected')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected
                              ? colorScheme.primary.withValues(alpha: 0.12)
                              : colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? colorScheme.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(s['flag'] as String,
                                style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          s['name'] as String,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isAuto)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.amber
                                                .withValues(alpha: 0.18),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'AUTO',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.amber,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${s['city']}, ${s['country_name']}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$ping',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: ping < 60
                                        ? Colors.green
                                        : Colors.orange,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  'ms',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            if (selected)
                              Icon(Icons.check_circle_rounded,
                                  color: colorScheme.primary, size: 22),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer(
      BuildContext context, AppStrings strings, bool isArabic) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Drawer(
      width: MediaQuery.of(context).size.width.clamp(0.0, 340.0),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Column(
          children: [
            // Header: hero gradient with logo and identity
            _drawerHeader(context, strings, isArabic, primary),
            // Menu sections
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                children: [
                  _sectionLabel(isArabic ? 'القائمة الرئيسية' : 'MAIN MENU'),
                  _drawerItem(
                    context,
                    Icons.home_rounded,
                    strings.appName,
                    () => Navigator.pop(context),
                    selected: true,
                    iconColor: primary,
                  ),
                  _drawerItem(context, Icons.dns_outlined, strings.serversTitle,
                      () {
                    Navigator.pop(context);
                    context.push(AppRouter.serversPath);
                  }, iconColor: Colors.indigo),
                  _drawerItem(
                      context, Icons.tune_outlined, strings.configsTitle, () {
                    Navigator.pop(context);
                    context.push(AppRouter.configsPath);
                  }, iconColor: Colors.deepPurple),
                  _drawerItem(context, Icons.bar_chart_outlined,
                      strings.statisticsTitle, () {
                    Navigator.pop(context);
                    context.push(AppRouter.statisticsPath);
                  }, iconColor: Colors.teal),
                  _drawerItem(
                      context, Icons.history_outlined, strings.historyTitle,
                      () {
                    Navigator.pop(context);
                    context.push(AppRouter.historyPath);
                  }, iconColor: Colors.orange),
                  _drawerItem(context, Icons.workspace_premium_outlined,
                      strings.plansTitle, () {
                    Navigator.pop(context);
                    context.push(AppRouter.plansPath);
                  }, iconColor: Colors.amber),
                  const SizedBox(height: 8),
                  _sectionLabel(isArabic ? 'التخصيص' : 'CUSTOMIZE'),
                  _drawerItem(
                      context, Icons.palette_outlined, strings.appearanceTitle,
                      () {
                    Navigator.pop(context);
                    context.push(AppRouter.appearancePath);
                  }, iconColor: Colors.pink),
                  _drawerItem(
                      context, Icons.language_outlined, strings.languageTitle,
                      () {
                    Navigator.pop(context);
                    context.push(AppRouter.languagePath);
                  }, iconColor: Colors.cyan),
                  _drawerItem(context, Icons.settings_input_component_outlined,
                      strings.advancedSettingsTitle, () {
                    Navigator.pop(context);
                    context.push(AppRouter.advancedNetworkPath);
                  }, iconColor: Colors.green),
                  _drawerItem(context, Icons.settings_outlined,
                      strings.get('app_settings_title'), () {
                    Navigator.pop(context);
                    context.push(AppRouter.appSettingsPath);
                  }, iconColor: Colors.blueGrey),
                  const SizedBox(height: 8),
                  _sectionLabel(
                      isArabic ? 'الدعم والمعلومات' : 'SUPPORT & ABOUT'),
                  _drawerItem(
                      context, Icons.help_outline, strings.supportCenterTitle,
                      () {
                    Navigator.pop(context);
                    context.push(AppRouter.supportPath);
                  }, iconColor: Colors.amber),
                  _drawerItem(context, Icons.info_outline, strings.aboutTitle,
                      () {
                    Navigator.pop(context);
                    context.push(AppRouter.aboutPath);
                  }, iconColor: Colors.blue),
                  const SizedBox(height: 16),
                  _upgradeCard(context, strings, isArabic),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            // Footer: version + status
            _drawerFooter(context, strings, isArabic),
          ],
        ),
      ),
    );
  }

  Widget _drawerHeader(
      BuildContext context, AppStrings strings, bool isArabic, Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary,
            primary.withValues(alpha: 0.75),
            primary.withValues(alpha: 0.45),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative translucent circles
          Positioned(
            right: -40,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Logo in glass circle
                  Container(
                    width: 52,
                    height: 52,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset('assets/images/logo.png',
                        fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.appName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Guest session chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            strings.guestSession,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _statusPill(Icons.verified_user_rounded,
                      isArabic ? 'متصل آمن' : 'Secure'),
                  const SizedBox(width: 8),
                  _statusPill(Icons.wifi_protected_setup_rounded,
                      isArabic ? 'تشفير قوي' : 'AES-256'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.6,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color iconColor = Colors.blueGrey,
    bool selected = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? iconColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: selected
                ? Border.all(color: iconColor.withValues(alpha: 0.3))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 19, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? iconColor : colorScheme.onSurface,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.chevron_right_rounded, size: 18, color: iconColor)
              else
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _upgradeCard(BuildContext context, AppStrings strings, bool isArabic) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.pop(context);
        context.push(AppRouter.plansPath);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.75)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'ترقية إلى البرو' : 'Upgrade to Pro',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isArabic
                        ? 'خوادم أسرع بلا حدود'
                        : 'Unlimited faster servers',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _drawerFooter(
      BuildContext context, AppStrings strings, bool isArabic) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.4))),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isArabic ? 'جميع الأنظمة تعمل' : 'All systems operational',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            'v1.0.0',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PowerButton extends StatelessWidget {
  final TunnelState state;
  final String label;
  final String durationText;
  final Color accentColor;
  final Color connectedColor;
  final Color connectingColor;
  final VoidCallback? onTap;

  const _PowerButton({
    required this.state,
    required this.label,
    required this.durationText,
    required this.accentColor,
    required this.connectedColor,
    required this.connectingColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = state == TunnelState.connected;
    final isConnecting = state == TunnelState.connecting;

    final activeColor = isConnected
        ? connectedColor
        : isConnecting
            ? connectingColor
            : accentColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 210,
        height: 210,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              activeColor,
              activeColor.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: activeColor.withValues(
                  alpha: isConnected || isConnecting ? 0.45 : 0.2),
              blurRadius: isConnected ? 40 : 20,
              spreadRadius: isConnected ? 6 : 2,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.power_settings_new_rounded,
              size: 74,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: Colors.white,
              ),
            ),
            if (isConnected) ...[
              const SizedBox(height: 4),
              Text(
                durationText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TelemetryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _TelemetryTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
