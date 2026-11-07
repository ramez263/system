import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_empty_state.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class ChangelogPage extends StatefulWidget {
  const ChangelogPage({super.key});

  @override
  State<ChangelogPage> createState() => _ChangelogPageState();
}

class _ChangelogPageState extends State<ChangelogPage> {
  int _selectedTab = 0; // 0: Logs, 1: Changelog
  String _selectedSeverityFilter = 'ALL';

  final List<Map<String, dynamic>> _logs = [
    {
      'id': '1',
      'timestamp': '13:40:12',
      'tag': 'INFO',
      'color': const Color(0xFF0284C7),
      'icon': Icons.info_outline_rounded,
      'message': 'Core VPN Engine initialized (OpenVPN 2.6.4 / WireGuard GO)',
    },
    {
      'id': '2',
      'timestamp': '13:40:14',
      'tag': 'SECURITY',
      'color': const Color(0xFF8B5CF6),
      'icon': Icons.security_rounded,
      'message': 'Hardware UUID authenticated with zero-PII telemetry',
    },
    {
      'id': '3',
      'timestamp': '13:40:15',
      'tag': 'NETWORK',
      'color': const Color(0xFF3B82F6),
      'icon': Icons.dns_rounded,
      'message': 'Encrypted handshake initiated with Frankfurt Fast-01 (185.220.101.5:1194)',
    },
    {
      'id': '4',
      'timestamp': '13:40:17',
      'tag': 'SUCCESS',
      'color': const Color(0xFF10B981),
      'icon': Icons.check_circle_outline_rounded,
      'message': 'Tunnel interface tun0 established (Assigned IP: 10.8.0.4, MTU: 1420)',
    },
    {
      'id': '5',
      'timestamp': '13:40:18',
      'tag': 'NETWORK',
      'color': const Color(0xFF3B82F6),
      'icon': Icons.alt_route_rounded,
      'message': 'Routing table configured: 0.0.0.0/0 via 10.8.0.1 (DNS: 1.1.1.1, 1.0.0.1)',
    },
    {
      'id': '6',
      'timestamp': '13:40:22',
      'tag': 'SUCCESS',
      'color': const Color(0xFF10B981),
      'icon': Icons.speed_rounded,
      'message': 'Telemetry active: RX 42.5 Mbps / TX 12.8 Mbps, Latency: 28ms',
    },
    {
      'id': '7',
      'timestamp': '13:40:25',
      'tag': 'SYSTEM',
      'color': const Color(0xFF64748B),
      'icon': Icons.battery_charging_full_rounded,
      'message': 'Battery optimization exemption verified; Foreground keepalive active',
    },
  ];

  final List<Map<String, dynamic>> _changelogReleases = const [
    {
      'version': 'v1.2.0',
      'date': 'November 2026',
      'isLatest': true,
      'badge': 'Current Release',
      'badgeAr': 'الإصدار الحالي',
      'highlights': [
        '🚀 Modern Cockpit UI: Breathing halo aura, frosted track ring & tactile core button.',
        '🛡️ Real-Time IP Shield: Integrated public & virtual IP display with one-tap copy.',
        '⚡ Unified Chooser: Consolidated server location and operator profile into a glass card.',
        '📜 Changelog & Connection Logs: Live diagnostic logs viewer with instant log clearing.',
      ],
      'highlightsAr': [
        '🚀 واجهة تحكم عصرية: هالة مضيئة تفاعلية، حلقة مسار زجاجية وزر تشغيل تكتيكي متطور.',
        '🛡️ درع عنوان IP المباشر: عرض فوري لعنوان IP الحقيقي والمشفر مع ميزة النسخ السريع.',
        '⚡ موحّد الإعدادات: دمج اختيار الخادم وملف الشبكة في بطاقة قمرة قيادة واحدة.',
        '📜 سجل التغييرات وسجلات الاتصال: متصفح سجلات تشخيصية مباشر مع إمكانية مسح السجلات.',
      ],
    },
    {
      'version': 'v1.1.0',
      'date': 'November 2026',
      'isLatest': false,
      'badge': 'Feature Update',
      'badgeAr': 'تحديث ميزات',
      'highlights': [
        '🔔 Redesigned Notification Center with frosted dual-tab switchers and channel filters.',
        '✨ LoadingAnimationWidget four rotating dots on splash launch screen.',
        '🎨 Dynamic brand-based splash background gradients matching theme presets.',
      ],
      'highlightsAr': [
        '🔔 تصميم عصري لمركز الإشعارات مع مبدل تبويبات زجاجي وفلاتر قنوات مخصصة.',
        '✨ دمج أنيميشن النقاط الأربعة الدوارة في شاشة البداية.',
        '🎨 تدرجات لونية ديناميكية لشاشة البداية مستوحاة من ثيم التطبيق.',
      ],
    },
    {
      'version': 'v1.0.0',
      'date': 'October 2026',
      'isLatest': false,
      'badge': 'Initial Launch',
      'badgeAr': 'الإطلاق الأولي',
      'highlights': [
        '🔒 Zero-login guest authentication with encrypted hardware UUID architecture.',
        '🌐 Multi-protocol engines: OpenVPN (UDP/TCP), WireGuard, SSH Tunnel, V2Ray.',
        '🌍 Full native Arabic (RTL) & English (LTR) localization.',
        '🛡️ Kill Switch, Custom DNS resolvers, and Per-App Split Tunneling.',
      ],
      'highlightsAr': [
        '🔒 جلسات ضيف بدون تسجيل دخول مع بنية UUID مشفرة للهاردوير.',
        '🌐 دعم 4 بروتوكولات: OpenVPN (UDP/TCP)، WireGuard، SSH، و V2Ray.',
        '🌍 دعم كامل وأصيل للغة العربية (RTL) والإنجليزية (LTR).',
        '🛡️ ميزة Kill Switch، خوادم DNS مخصصة، وتقسيم الأنفاق لكل تطبيق.',
      ],
    },
  ];

  void _clearLogs(bool isArabic) {
    if (_logs.isEmpty) return;

    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.delete_sweep_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isArabic ? 'مسح كافة السجلات؟' : 'Clear all logs?',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من مسح جميع سجلات الاتصال الحالية؟ لا يمكن التراجع عن هذا الإجراء.'
              : 'Are you sure you want to clear all current connection logs? This action cannot be undone.',
          style: const TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isArabic ? 'تأكيد المسح' : 'Clear Logs'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        setState(() {
          _logs.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(isArabic ? 'تم مسح السجلات بنجاح' : 'Logs cleared successfully'),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });
  }

  void _restoreSampleLogs(bool isArabic) {
    setState(() {
      _logs.addAll([
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'timestamp': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}',
          'tag': 'INFO',
          'color': const Color(0xFF0284C7),
          'icon': Icons.info_outline_rounded,
          'message': 'Core VPN Engine initialized (Diagnostic session started)',
        },
        {
          'id': (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          'timestamp': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${(DateTime.now().second + 1).toString().padLeft(2, '0')}',
          'tag': 'SUCCESS',
          'color': const Color(0xFF10B981),
          'icon': Icons.check_circle_outline_rounded,
          'message': 'Diagnostic event logged: System healthy & ready to connect',
        },
      ]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isArabic ? 'تمت إضافة سجلات تشخيصية جديدة' : 'Generated sample diagnostic logs'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _copyLogsToClipboard(bool isArabic) {
    if (_logs.isEmpty) return;
    final logText = _logs.map((e) => '[${e['tag']}] ${e['timestamp']} - ${e['message']}').join('\n');
    Clipboard.setData(ClipboardData(text: logText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isArabic ? 'تم نسخ كافة السجلات إلى الحافظة' : 'Copied logs to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppStrings.of(context);
    final isArabic = strings.isArabic;

    final filteredLogs = _selectedSeverityFilter == 'ALL'
        ? _logs
        : _logs.where((l) => l['tag'] == _selectedSeverityFilter).toList();

    return Scaffold(
      appBar: ModernAppBar(
        title: isArabic ? 'سجل التغييرات والسجلات' : 'Changelog & Logs',
        subtitle: isArabic ? 'سجلات الاتصال وتحديثات النظام' : 'Engine logs & release history',
        actions: [
          if (_selectedTab == 0 && _logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: isArabic ? 'مسح السجلات' : 'Clear Logs',
              onPressed: () => _clearLogs(isArabic),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Top Segmented Tab Switcher (Connection Logs vs App Changelog)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        label: isArabic ? 'سجلات الاتصال' : 'Connection Logs',
                        badge: '${_logs.length}',
                        isSelected: _selectedTab == 0,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _TabButton(
                        label: isArabic ? 'سجل التحديثات' : 'App Changelog',
                        badge: 'v1.2.0',
                        isSelected: _selectedTab == 1,
                        onTap: () => setState(() => _selectedTab = 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Body content based on selected tab
            Expanded(
              child: _selectedTab == 0
                  ? _buildLogsView(context, colorScheme, strings, isArabic, filteredLogs)
                  : _buildChangelogView(context, colorScheme, strings, isArabic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsView(
    BuildContext context,
    ColorScheme colorScheme,
    AppStrings strings,
    bool isArabic,
    List<Map<String, dynamic>> filteredLogs,
  ) {
    if (_logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RamezEmptyState(
                icon: Icons.cleaning_services_rounded,
                title: isArabic ? 'سجل الأحداث فارغ' : 'All logs cleared',
                description: isArabic
                    ? 'تم مسح كافة سجلات الاتصال بنجاح. ستظهر السجلات الجديدة تلقائياً عند بدء أي اتصال جديد.'
                    : 'All connection logs have been purged. Fresh event logs will be recorded on next connection.',
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.add_task_rounded, size: 18),
                label: Text(isArabic ? 'إضافة سجلات تجريبية' : 'Generate Test Logs'),
                onPressed: () => _restoreSampleLogs(isArabic),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Filter toolbar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterPill(
                        label: isArabic ? 'الكل' : 'All',
                        isSelected: _selectedSeverityFilter == 'ALL',
                        onTap: () => setState(() => _selectedSeverityFilter = 'ALL'),
                      ),
                      const SizedBox(width: 6),
                      _FilterPill(
                        label: 'INFO',
                        isSelected: _selectedSeverityFilter == 'INFO',
                        color: const Color(0xFF0284C7),
                        onTap: () => setState(() => _selectedSeverityFilter = 'INFO'),
                      ),
                      const SizedBox(width: 6),
                      _FilterPill(
                        label: 'SUCCESS',
                        isSelected: _selectedSeverityFilter == 'SUCCESS',
                        color: const Color(0xFF10B981),
                        onTap: () => setState(() => _selectedSeverityFilter = 'SUCCESS'),
                      ),
                      const SizedBox(width: 6),
                      _FilterPill(
                        label: 'SECURITY',
                        isSelected: _selectedSeverityFilter == 'SECURITY',
                        color: const Color(0xFF8B5CF6),
                        onTap: () => setState(() => _selectedSeverityFilter = 'SECURITY'),
                      ),
                      const SizedBox(width: 6),
                      _FilterPill(
                        label: 'NETWORK',
                        isSelected: _selectedSeverityFilter == 'NETWORK',
                        color: const Color(0xFF3B82F6),
                        onTap: () => setState(() => _selectedSeverityFilter = 'NETWORK'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Copy All Logs icon button
              IconButton.filledTonal(
                icon: const Icon(Icons.copy_rounded, size: 16),
                tooltip: isArabic ? 'نسخ السجلات' : 'Copy All',
                visualDensity: VisualDensity.compact,
                onPressed: () => _copyLogsToClipboard(isArabic),
              ),
              const SizedBox(width: 4),
              // Clear Logs icon button
              IconButton.filledTonal(
                style: IconButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  backgroundColor: colorScheme.error.withValues(alpha: 0.12),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                tooltip: isArabic ? 'مسح السجلات' : 'Clear Logs',
                visualDensity: VisualDensity.compact,
                onPressed: () => _clearLogs(isArabic),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Logs list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            itemCount: filteredLogs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final log = filteredLogs[index];
              final Color tagColor = log['color'] as Color? ?? colorScheme.primary;
              final IconData icon = log['icon'] as IconData? ?? Icons.info_outline_rounded;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: tagColor.withValues(alpha: 0.22),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 16, color: tagColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: tagColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  log['tag'] as String,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: tagColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                log['timestamp'] as String,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            log['message'] as String,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChangelogView(
    BuildContext context,
    ColorScheme colorScheme,
    AppStrings strings,
    bool isArabic,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _changelogReleases.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final rel = _changelogReleases[index];
        final isLatest = rel['isLatest'] == true;
        final highlights = (isArabic ? rel['highlightsAr'] : rel['highlights']) as List<String>;
        final badgeText = (isArabic ? rel['badgeAr'] : rel['badge']) as String;

        return RamezGlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isLatest
                          ? colorScheme.primary.withValues(alpha: 0.15)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isLatest ? Icons.rocket_launch_rounded : Icons.auto_awesome_rounded,
                      size: 20,
                      color: isLatest ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rel['version'] as String,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          rel['date'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLatest
                          ? AppColors.success.withValues(alpha: 0.14)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isLatest
                            ? AppColors.success.withValues(alpha: 0.3)
                            : colorScheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isLatest ? AppColors.success : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, thickness: 0.7),
              const SizedBox(height: 12),
              ...highlights.map(
                (h) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isLatest ? colorScheme.primary : colorScheme.onSurfaceVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          h,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final String badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.22)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = color ?? colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.16)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? activeColor : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
