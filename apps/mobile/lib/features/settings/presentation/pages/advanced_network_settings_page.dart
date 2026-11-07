import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunnel_plus/core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_glass_card.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class AdvancedNetworkSettingsPage extends StatelessWidget {
  const AdvancedNetworkSettingsPage({super.key});

  static const List<Map<String, String>> _popularApps = [
    {'name': 'WhatsApp Messenger', 'package': 'com.whatsapp', 'icon': 'chat'},
    {'name': 'YouTube & Music', 'package': 'com.google.android.youtube', 'icon': 'play_circle'},
    {'name': 'Telegram Messenger', 'package': 'org.telegram.messenger', 'icon': 'send'},
    {'name': 'Google Chrome', 'package': 'com.android.chrome', 'icon': 'web'},
    {'name': 'Netflix Streaming', 'package': 'com.netflix.mediaclient', 'icon': 'movie'},
    {'name': 'Spotify Music', 'package': 'com.spotify.music', 'icon': 'music_note'},
    {'name': 'Gmail & Outlook', 'package': 'com.google.android.gm', 'icon': 'email'},
  ];

  void _showKillSwitchLockdownGuide(BuildContext context, bool isArabic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.security, color: Colors.amber, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isArabic ? 'حماية قفل النظام (Always-on VPN)' : 'Native Android Lockdown',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  isArabic
                      ? 'للحصول على أعلى درجات الأمان المطلق وحظر تسرب أي حزم:\n'
                        '1. توجه إلى إعدادات Android -> الشبكة والإنترنت -> VPN.\n'
                        '2. اضغط على أيقونة الترس beside Ramez Tunnel Plus.\n'
                        '3. فعّل خيار "VPN قيد التشغيل دائمًا" وحظر الاتصالات بدون VPN.'
                      : 'To achieve native hardware-level traffic interception:\n'
                        '1. Open Android Settings > Network & Internet > VPN.\n'
                        '2. Tap the Gear icon beside Ramez Tunnel Plus.\n'
                        '3. Turn ON "Always-on VPN" and "Block connections without VPN".',
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 20),
                RamezButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isArabic
                              ? 'يرجى ضبط الإعداد من إعدادات VPN في نظام Android'
                              : 'Open Android System Settings > VPN to configure Lockdown.',
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  icon: Icons.open_in_new_rounded,
                  label: isArabic ? 'فهمت، شكراً' : 'Understood',
                  height: 48,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSplitTunnelingAppSelector(BuildContext context, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state is! SettingsLoaded) return const SizedBox.shrink();
            final selected = state.advancedSettings.selectedApps;
            final isExclude = state.advancedSettings.splitTunnelingMode == 'exclude';

            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? 'تحديد التطبيقات' : 'Select Apps',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.pop(ctx),
                          child: const Icon(Icons.close, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isExclude
                          ? (isArabic
                              ? 'تطبيقات سيتم تجاوز VPN لها'
                              : 'Selected apps will bypass the VPN tunnel.')
                          : (isArabic
                              ? 'تطبيقات سيتم توجيهها عبر VPN فقط'
                              : 'Only selected apps will route through VPN.'),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Divider(height: 24),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _popularApps.length,
                        itemBuilder: (context, index) {
                          final app = _popularApps[index];
                          final pkg = app['package']!;
                          final isChecked = selected.contains(pkg);

                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              context.read<SettingsCubit>().toggleAppForSplitTunnel(pkg);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isChecked
                                          ? colorScheme.primary.withValues(alpha: 0.15)
                                          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.apps,
                                        color: isChecked ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          app['name']!,
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          pkg,
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Checkbox(
                                    value: isChecked,
                                    activeColor: colorScheme.primary,
                                    onChanged: (_) {
                                      context.read<SettingsCubit>().toggleAppForSplitTunnel(pkg);
                                    },
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final hasCubit = context.findAncestorWidgetOfExactType<BlocProvider<SettingsCubit>>() != null;

    if (!hasCubit) {
      return _buildStaticFallback(context, theme, isArabic);
    }

    return Scaffold(
      appBar: const ModernAppBar(title: 'Advanced Network', subtitle: 'Kill switch, DNS & split tunneling'),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsLoaded) {
            final adv = state.advancedSettings;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                // 1. Kill Switch & System Lockdown Card
                RamezGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _modernSwitchTile(
                        context: context,
                        isArabic: isArabic,
                        value: adv.killSwitch,
                        leading: const Icon(Icons.lock_outline, color: Colors.amber),
                        title: 'مفتاح الإيقاف التلقائي',
                        subtitle: 'Kill Switch Protection',
                        arSubtitle: 'حظر جميع حزم البيانات عند انقطاع نفق VPN فجأة.',
                        enSubtitle: 'Blocks unencrypted traffic if the VPN tunnel drops unexpectedly.',
                        onChanged: (v) => context.read<SettingsCubit>().updateAdvancedSettings(killSwitch: v),
                      ),
                      const Divider(height: 16),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.vpn_lock, color: Colors.amber, size: 20),
                        ),
                        title: Text(
                          isArabic ? 'دليل قفل نظام Android' : 'Always-on VPN & Lockdown',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          isArabic ? 'تأمين حركة المرور على مستوى النظام' : 'Force all traffic through VPN',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showKillSwitchLockdownGuide(context, isArabic),
                      ),
                      const Divider(height: 16),
                      _modernSwitchTile(
                        context: context,
                        isArabic: isArabic,
                        value: adv.ipv6Protection,
                        leading: const Icon(Icons.security, color: Colors.green),
                        title: 'منع تسرب IPv6',
                        subtitle: 'Block IPv6 Traffic Leaks',
                        arSubtitle: 'توجيه كافة حزم IPv6 بأمان داخل النفق',
                        enSubtitle: 'Force IPv6 traffic through the tunnel or block it.',
                        onChanged: (v) => context.read<SettingsCubit>().updateAdvancedSettings(ipv6Protection: v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Encrypted DNS Resolvers Card
                RamezGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isArabic ? 'خوادم DNS المشفرة' : 'Encrypted DNS Resolvers',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            adv.dnsProvider.split(' ').first,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: DropdownButtonFormField<String>(
                          initialValue: adv.dnsProvider,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Cloudflare (1.1.1.1)', child: Text('Cloudflare 1.1.1.1')),
                            DropdownMenuItem(value: 'Google (8.8.8.8)', child: Text('Google Public DNS')),
                            DropdownMenuItem(value: 'AdGuard Ad-Blocking', child: Text('AdGuard (Blocks Ads)')),
                            DropdownMenuItem(value: 'Quad9 (9.9.9.9)', child: Text('Quad9 (Malware Protection)')),
                            DropdownMenuItem(value: 'Custom DNS', child: Text('Custom DNS')),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              context.read<SettingsCubit>().updateAdvancedSettings(dnsProvider: v);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Split Tunneling Card
                RamezGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _modernSwitchTile(
                        context: context,
                        isArabic: isArabic,
                        value: adv.splitTunnelingEnabled,
                        leading: const Icon(Icons.call_split, color: Colors.purple),
                        title: 'تقسيم النفق',
                        subtitle: 'Split Tunneling',
                        arSubtitle: 'اختر التطبيقات التي تستخدم نفق VPN.',
                        enSubtitle: 'Choose which apps use the VPN tunnel.',
                        onChanged: (v) => context.read<SettingsCubit>().updateAdvancedSettings(splitTunnelingEnabled: v),
                      ),
                      if (adv.splitTunnelingEnabled) ...[
                        const Divider(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SegmentedButton<String>(
                                segments: [
                                  ButtonSegment(
                                    value: 'exclude',
                                    label: Text(isArabic ? 'تجاوز VPN' : 'Bypass VPN'),
                                    icon: const Icon(Icons.call_split),
                                  ),
                                  ButtonSegment(
                                    value: 'include',
                                    label: Text(isArabic ? 'عبر VPN فقط' : 'Only via VPN'),
                                    icon: const Icon(Icons.vpn_lock),
                                  ),
                                ],
                                selected: {adv.splitTunnelingMode},
                                onSelectionChanged: (set) {
                                  context.read<SettingsCubit>().updateAdvancedSettings(splitTunnelingMode: set.first);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.apps, color: colorScheme.primary, size: 20),
                          ),
                          title: Text(
                            isArabic
                                ? 'التطبيقات المحددة (${adv.selectedApps.length})'
                                : 'Selected Applications (${adv.selectedApps.length})',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            adv.selectedApps.isEmpty
                                ? (isArabic ? 'انقر لتحديد التطبيقات' : 'Tap to select apps')
                                : adv.selectedApps.join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showSplitTunnelingAppSelector(context, isArabic),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. MTU Packet Size Slider Card
                RamezGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isArabic ? 'حجم حزمة MTU' : 'Tunnel MTU Size',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${adv.mtu} bytes',
                            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      Slider(
                        value: adv.mtu.toDouble(),
                        min: 1280,
                        max: 1500,
                        divisions: 22,
                        label: '${adv.mtu}',
                        onChanged: (v) => context.read<SettingsCubit>().updateAdvancedSettings(mtu: v.toInt()),
                      ),
                      Text(
                        isArabic
                            ? 'القيمة الافتراضية 1420 مثالية لشبكات الهاتف 4G/5G.'
                            : 'Default 1420 is optimal for cellular networks.',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _modernSwitchTile({
    required BuildContext context,
    required bool isArabic,
    required bool value,
    required Widget leading,
    required String title,
    required String subtitle,
    required String arSubtitle,
    required String enSubtitle,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SwitchListTile(
      value: value,
      title: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        isArabic ? arSubtitle : enSubtitle,
        style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
      ),
      secondary: leading,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildStaticFallback(BuildContext context, ThemeData theme, bool isArabic) {
    return Scaffold(
      appBar: const ModernAppBar(title: 'Advanced Network', subtitle: 'Kill switch, DNS & split tunneling'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RamezGlassCard(
            child: SwitchListTile(
              value: true,
              title: Text(isArabic ? 'مفتاح الإيقاف التلقائي' : 'Kill Switch'),
              onChanged: (_) {},
            ),
          ),
        ],
      ),
    );
  }
}
