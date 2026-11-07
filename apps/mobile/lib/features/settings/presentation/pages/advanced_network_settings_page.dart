import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.security, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    isArabic ? 'حماية قفل النظام (Always-on VPN)' : 'Native Android Lockdown',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                isArabic
                    ? 'للحصول على أعلى درجات الأمان المطلق وحظر تسرب أي حزم:\n'
                      '1. توجه إلى إعدادات Android -> الشبكة والإنترنت -> VPN.\n'
                      '2. اضغط على أيقونة الترس بجانب Ramez Tunnel Plus.\n'
                      '3. فعّل خيار "VPN قيد التشغيل دائمًا" وخيار "حظر الاتصالات بدون VPN".'
                    : 'To achieve 100% native hardware-level traffic interception:\n'
                      '1. Open Android Settings -> Network & Internet -> VPN.\n'
                      '2. Tap the Gear icon beside Ramez Tunnel Plus.\n'
                      '3. Turn ON "Always-on VPN" and "Block connections without VPN".',
                style: const TextStyle(fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isArabic
                              ? 'يرجى ضبط الإعداد من إعدادات VPN في نظام Android'
                              : 'Open Android System Settings > VPN to configure Lockdown.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: Text(isArabic ? 'فهمت، شكراً' : 'Understood'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSplitTunnelingAppSelector(BuildContext context, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state is! SettingsLoaded) return const SizedBox.shrink();
            final selected = state.advancedSettings.selectedApps;
            final isExclude = state.advancedSettings.splitTunnelingMode == 'exclude';

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'تحديد التطبيقات (Split Tunneling)' : 'Select Apps for Split Tunneling',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isExclude
                            ? (isArabic
                                ? 'التطبيقات المحددة ستتجاوز VPN وتتصل بالإنترنت مباشرة.'
                                : 'Selected apps will bypass the VPN tunnel and connect directly.')
                            : (isArabic
                                ? 'فقط التطبيقات المحددة سيتم توجيهها عبر VPN.'
                                : 'Only selected apps will be routed through the VPN tunnel.'),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Divider(height: 24),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: _popularApps.length,
                          itemBuilder: (context, index) {
                            final app = _popularApps[index];
                            final pkg = app['package']!;
                            final isChecked = selected.contains(pkg);

                            return CheckboxListTile(
                              value: isChecked,
                              title: Text(app['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text(pkg, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              secondary: const Icon(Icons.apps),
                              onChanged: (_) {
                                context.read<SettingsCubit>().toggleAppForSplitTunnel(pkg);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final hasCubit = context.findAncestorWidgetOfExactType<BlocProvider<SettingsCubit>>() != null;

    if (!hasCubit) {
      return _buildStaticFallback(context, theme, isArabic);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إعدادات الشبكة المتقدمة' : 'Advanced Network'),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsLoaded) {
            final adv = state.advancedSettings;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Kill Switch & System Lockdown Card
                RamezGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        value: adv.killSwitch,
                        title: Text(
                          isArabic ? 'مفتاح الإيقاف التلقائي (Kill Switch)' : 'Kill Switch Protection',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          isArabic
                              ? 'حظر جميع حزم البيانات تلقائياً في حال انقطاع نفق VPN فجأة.'
                              : 'Blocks unencrypted traffic if the VPN tunnel drops unexpectedly.',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onChanged: (v) => context.read<SettingsCubit>().updateAdvancedSettings(killSwitch: v),
                      ),
                      const Divider(height: 16),
                      ListTile(
                        leading: const Icon(Icons.lock_outline, color: Colors.amber),
                        title: Text(
                          isArabic ? 'دليل قفل نظام Android (Lockdown)' : 'Always-on VPN & Lockdown Guide',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showKillSwitchLockdownGuide(context, isArabic),
                      ),
                      const Divider(height: 16),
                      SwitchListTile(
                        value: adv.ipv6Protection,
                        title: Text(
                          isArabic ? 'منع تسرب IPv6' : 'Block IPv6 Traffic Leaks',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          isArabic
                              ? 'توجيه كافة حزم IPv6 بأمان داخل النفق أو إسقاطها.'
                              : 'Forces IPv6 traffic through the tunnel or blocks it to prevent leaks.',
                          style: const TextStyle(fontSize: 12),
                        ),
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
                      Text(
                        isArabic ? 'خوادم DNS المشفرة' : 'Encrypted DNS Resolvers',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: adv.dnsProvider,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Cloudflare (1.1.1.1)', child: Text('Cloudflare 1.1.1.1 (Fast & Private)')),
                          DropdownMenuItem(value: 'Google (8.8.8.8)', child: Text('Google Public DNS (8.8.8.8)')),
                          DropdownMenuItem(value: 'AdGuard Ad-Blocking', child: Text('AdGuard (Blocks Ads & Trackers)')),
                          DropdownMenuItem(value: 'Quad9 (9.9.9.9)', child: Text('Quad9 (Malware Protection)')),
                          DropdownMenuItem(value: 'Custom DNS', child: Text('Custom DNS')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            context.read<SettingsCubit>().updateAdvancedSettings(dnsProvider: v);
                          }
                        },
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
                      SwitchListTile(
                        value: adv.splitTunnelingEnabled,
                        title: Text(
                          isArabic ? 'تقسيم النفق (Split Tunneling)' : 'Split Tunneling',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          isArabic
                              ? 'اختر التطبيقات التي تتصل عبر VPN وتلك التي تتجاوزه.'
                              : 'Choose which apps use the VPN tunnel and which connect directly.',
                          style: const TextStyle(fontSize: 12),
                        ),
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
                          title: Text(
                            isArabic
                                ? 'التطبيقات المحددة (${adv.selectedApps.length})'
                                : 'Selected Applications (${adv.selectedApps.length})',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
                            isArabic ? 'حجم حزمة MTU للأنفاق' : 'Tunnel MTU Size',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${adv.mtu} bytes',
                            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
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
                            ? 'القيمة الافتراضية 1420 مثالية لشبكات الهاتف 4G/5G لتفادي تقطيع الحزم.'
                            : 'Default 1420 is optimal for cellular networks to prevent packet fragmentation.',
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

  Widget _buildStaticFallback(BuildContext context, ThemeData theme, bool isArabic) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إعدادات الشبكة المتقدمة' : 'Advanced Network'),
      ),
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
