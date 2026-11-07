import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/device_identity_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_extension.dart';
import '../../../../core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_glass_card.dart';
import '../../../../core/widgets/ramez_status_chip.dart';
import '../../../configurations/domain/entities/configuration_entity.dart';
import '../../../servers/domain/entities/server_entity.dart';
import '../../../vpn_connection/presentation/cubit/vpn_connection_cubit.dart';
import '../../../vpn_connection/presentation/cubit/vpn_connection_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _deviceUuid = 'Loading...';
  String _deviceModel = 'Loading...';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RamezThemeExtension>();
    final strings = AppStrings.of(context);
    final isArabic = strings.isArabic;

    return BlocConsumer<VpnConnectionCubit, VpnConnectionState>(
      listener: (context, vpnState) {
        if (vpnState.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vpnState.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, vpnState) {
        final tunnelState = vpnState.status;
        final isConnected = vpnState.isConnected;
        final isConnecting = vpnState.isConnecting;
        final durationText = vpnState.formattedDuration;
        final downloadSpeed = isConnected ? vpnState.downloadSpeedMbps : '0.0';
        final uploadSpeed = isConnected ? vpnState.uploadSpeedMbps : '0.0';

        return Scaffold(
          key: _scaffoldKey,
          appBar: ModernAppBar(
            title: strings.appName,
            showBack: false,
            leadingWidget: IconButton(
              icon: const Icon(Icons.menu_rounded),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
                  // 1. Sleek Identity & Security Status Bar
                  _buildIdentityBar(context, theme, strings, isArabic, isConnected, isConnecting),

                  const SizedBox(height: 22),

                  // 2. Hero Tunnel Power Center with Ambient Aura
                  Center(
                    child: _PowerButton(
                      state: tunnelState,
                      durationText: durationText,
                      label: isConnected
                          ? strings.connected
                          : isConnecting
                              ? strings.connecting
                              : strings.tapToConnect,
                      accentColor: theme.colorScheme.primary,
                      connectedColor: ext?.connectedColor ?? AppColors.success,
                      connectingColor: ext?.connectingColor ?? AppColors.warning,
                      onTap: isConnecting
                          ? null
                          : () => context
                              .read<VpnConnectionCubit>()
                              .toggleConnection(),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 3. Dynamic Status Pill
                  Center(
                    child: RamezStatusChip(state: tunnelState),
                  ),

                  const SizedBox(height: 20),

                  // 4. Unified Cockpit Connection Chooser (Server & Profile)
                  _buildConnectionChooser(context, strings, isArabic, vpnState),

                  const SizedBox(height: 18),

                  // 5. Real-Time Telemetry Matrix (Download, Upload, Ping)
                  Row(
                    children: [
                      Expanded(
                        child: _TelemetryTile(
                          icon: Icons.arrow_downward_rounded,
                          label: isArabic ? 'تحميل' : 'Download',
                          value: downloadSpeed,
                          unit: 'Mbps',
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TelemetryTile(
                          icon: Icons.arrow_upward_rounded,
                          label: isArabic ? 'رفع' : 'Upload',
                          value: uploadSpeed,
                          unit: 'Mbps',
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TelemetryTile(
                          icon: Icons.network_ping_rounded,
                          label: isArabic ? 'استجابة' : 'Ping',
                          value: isConnected ? '${vpnState.selectedServer?.pingMs ?? 28}' : '--',
                          unit: 'ms',
                          color: isConnected ? const Color(0xFF10B981) : theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // 6. Modern Quick Action Dock (Servers, Configs, Stats, Plans)
                  Text(
                    isArabic ? 'الوصول السريع' : 'Quick Shortcuts',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.dns_rounded,
                          label: strings.serversTitle,
                          color: Colors.indigo,
                          onTap: () => context.push(AppRouter.serversPath),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.tune_rounded,
                          label: strings.configsTitle,
                          color: Colors.deepPurple,
                          onTap: () => context.push(AppRouter.configsPath),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.insights_rounded,
                          label: strings.statisticsTitle,
                          color: Colors.teal,
                          onTap: () => context.push(AppRouter.statisticsPath),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.workspace_premium_rounded,
                          label: strings.plansTitle,
                          color: Colors.amber.shade700,
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
      },
    );
  }

  Widget _buildIdentityBar(
    BuildContext context,
    ThemeData theme,
    AppStrings strings,
    bool isArabic,
    bool isConnected,
    bool isConnecting,
  ) {
    final colorScheme = theme.colorScheme;
    final shortUuid = _deviceUuid.length > 10
        ? '${_deviceUuid.substring(0, 4)}...${_deviceUuid.substring(_deviceUuid.length - 4)}'
        : _deviceUuid;

    final statusColor = isConnected
        ? AppColors.success
        : isConnecting
            ? AppColors.warning
            : colorScheme.outline;

    final statusText = isConnected
        ? (isArabic ? 'محمي ومشفّر' : 'Protected')
        : isConnecting
            ? (isArabic ? 'جارٍ التأمين...' : 'Securing...')
            : (isArabic ? 'غير محمي' : 'Unprotected');

    final statusIcon = isConnected
        ? Icons.shield_rounded
        : isConnecting
            ? Icons.sync_rounded
            : Icons.shield_outlined;

    return RamezGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 18,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.phonelink_setup_rounded,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _deviceModel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: $shortUuid',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 10.5,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.28),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 12, color: statusColor),
                const SizedBox(width: 5),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionChooser(
      BuildContext context, AppStrings strings, bool isArabic, VpnConnectionState vpnState) {
    final colorScheme = Theme.of(context).colorScheme;
    final cfg = _selectedConfig;
    final displayServerName =
        vpnState.selectedServer?.name ?? _selectedServerName;
    final displayServerFlag =
        vpnState.selectedServer?.flagEmoji ?? _selectedServerFlag;
    final displayServerPing = vpnState.selectedServer?.pingMs ?? 28;
    final displayConfigName = vpnState.selectedConfig?.name ??
        (cfg != null
            ? cfg['name'] as String
            : (isArabic ? 'اختر تكويناً' : 'Select config'));
    final displayConfigProto = cfg != null
        ? (cfg['protocol'] as String? ?? 'OpenVPN')
        : (isArabic ? 'تلقائي' : 'Auto');

    return RamezGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      borderRadius: 20,
      child: Column(
        children: [
          // Server Selection Row
          InkWell(
            onTap: () => _showServerSheet(context, strings, isArabic),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      displayServerFlag,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'خادم الاتصال' : 'SERVER NODE',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayServerName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$displayServerPing ms',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Divider(
              height: 1,
              thickness: 0.8,
              color: colorScheme.outlineVariant.withValues(alpha: 0.25),
            ),
          ),

          // Config Profile Selection Row
          InkWell(
            onTap: () => _showConfigSheet(context, isArabic),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(7),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cfg != null
                          ? Colors.white
                          : colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: cfg != null
                        ? Image.asset(cfg['asset'] as String, fit: BoxFit.contain)
                        : Icon(Icons.tune_rounded,
                            color: colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'ملف التكوين' : 'CONNECTION PROFILE',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayConfigName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      displayConfigProto,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
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
                        final configEntity = ConfigurationEntity(
                          id: index + 1,
                          name: cfg['name'] as String,
                          protocol: 'ovpn',
                          serverAddress: '185.220.101.5',
                          serverPort: cfg['port'] as int,
                          rawConfig:
                              'client\ndev tun\nproto udp\nremote 185.220.101.5 ${cfg['port']}\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\nverb 3\n',
                          createdAt: DateTime.now(),
                        );
                        context
                            .read<VpnConnectionCubit>()
                            .selectConfig(configEntity);
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
                        final server = ServerEntity(
                          id: index + 1,
                          name: s['name'] as String,
                          countryCode: s['flag'] == '🇩🇪'
                              ? 'DE'
                              : s['flag'] == '🇳🇱'
                                  ? 'NL'
                                  : 'US',
                          countryName: s['country_name'] as String,
                          city: s['city'] as String,
                          flagEmoji: s['flag'] as String,
                          protocol: 'ovpn',
                          ipAddress: '185.220.101.${index + 10}',
                          port: 1194,
                          pingMs: ping,
                          currentLoad: s['load'] as int,
                          isPremium: false,
                          hasOvpn: true,
                        );
                        context.read<VpnConnectionCubit>().selectServer(server);
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
        gradient: AppColors.getSplashGradient(primary),
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
          gradient: (colorScheme.primary == AppColors.primaryBlue || colorScheme.primary == const Color(0xFF1864ab))
              ? AppColors.appBarGradient
              : AppColors.getThemeGradient(colorScheme.primary),
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
    final isConnecting =
        state == TunnelState.connecting || state == TunnelState.reconnecting;

    final activeColor = isConnected
        ? connectedColor
        : isConnecting
            ? connectingColor
            : accentColor;

    final Gradient buttonGradient;
    if (isConnected) {
      buttonGradient = LinearGradient(
        colors: [connectedColor, const Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (isConnecting) {
      buttonGradient = LinearGradient(
        colors: [connectingColor, const Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      buttonGradient = (accentColor == AppColors.primaryBlue || accentColor == const Color(0xFF1864ab))
          ? AppColors.appBarGradient
          : AppColors.getThemeGradient(accentColor);
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 236,
        height: 236,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient Breathing Halo Aura
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: isConnected ? 236 : 220,
              height: isConnected ? 236 : 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withValues(
                      alpha: isConnected ? 0.38 : (isConnecting ? 0.32 : 0.22),
                    ),
                    blurRadius: isConnected ? 42 : 28,
                    spreadRadius: isConnected ? 8 : 2,
                  ),
                ],
              ),
            ),

            // Outer Frosted Track Ring
            Container(
              width: 216,
              height: 216,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: activeColor.withValues(alpha: isConnected ? 0.45 : 0.22),
                  width: 2,
                ),
                color: activeColor.withValues(alpha: 0.05),
              ),
            ),

            // Tactile Core Power Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 188,
              height: 188,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: buttonGradient,
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.power_settings_new_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: Colors.white,
                    ),
                  ),
                  if (isConnected) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 12, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            durationText,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: color),
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
