import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_glass_card.dart';
import '../cubit/vpn_connection_cubit.dart';
import '../cubit/vpn_connection_state.dart';

class ConnectionDetailsPage extends StatelessWidget {
  const ConnectionDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final hasCubit = context.findAncestorWidgetOfExactType<BlocProvider<VpnConnectionCubit>>() != null;

    if (hasCubit) {
      return BlocBuilder<VpnConnectionCubit, VpnConnectionState>(
        builder: (context, state) => _buildScaffold(context, theme, isArabic, state, hasCubit: true),
      );
    }

    return _buildScaffold(context, theme, isArabic, const VpnConnectionState(), hasCubit: false);
  }

  Widget _buildScaffold(
    BuildContext context,
    ThemeData theme,
    bool isArabic,
    VpnConnectionState state, {
    required bool hasCubit,
  }) {
    final downloadedMb = (state.bytesIn / (1024 * 1024)).toStringAsFixed(1);
    final uploadedMb = (state.bytesOut / (1024 * 1024)).toStringAsFixed(1);
    final serverName = state.connectedServerName ??
        state.selectedServer?.name ??
        'Frankfurt OpenVPN 01';
    final gateway = state.selectedServer?.ipAddress ?? '185.220.101.5';
    final port = state.selectedServer?.port ?? 1194;
    final protocol = (state.selectedServer?.protocol ??
            state.selectedConfig?.protocol ??
            'OpenVPN')
        .toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic
            ? 'تفاصيل الجلسة النشطة'
            : 'Active Connection Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: state.isConnected
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.orange.withValues(alpha: 0.15),
              ),
              child: Icon(
                Icons.shield,
                size: 54,
                color: state.isConnected ? Colors.green : Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.isConnected
                ? (isArabic
                    ? 'الاتصال محمي ومشفر بالكامل'
                    : 'Connection Fully Encrypted')
                : (isArabic ? 'جاري تأمين النفق' : 'Securing Tunnel...'),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '$serverName ($gateway)',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: RamezGlassCard(
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_downward, color: Colors.blue),
                      const SizedBox(height: 4),
                      Text(isArabic ? 'تم تنزيله' : 'Downloaded',
                          style: const TextStyle(fontSize: 12)),
                      Text('$downloadedMb MB',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RamezGlassCard(
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.purple),
                      const SizedBox(height: 4),
                      Text(isArabic ? 'تم رفعه' : 'Uploaded',
                          style: const TextStyle(fontSize: 12)),
                      Text('$uploadedMb MB',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RamezGlassCard(
            child: Column(
              children: [
                _buildRow(
                    isArabic ? 'مدة الاتصال' : 'Session Duration',
                    state.formattedDuration),
                _buildRow(
                    isArabic ? 'عنوان IP المعين' : 'Assigned Virtual IP',
                    '10.8.0.14'),
                _buildRow(isArabic ? 'الخادم البعيد' : 'Gateway Node',
                    '$gateway:$port'),
                _buildRow(isArabic ? 'نوع البروتوكول' : 'Protocol',
                    '$protocol (tun0)'),
                _buildRow(isArabic ? 'خوارزمية التشفير' : 'Encryption',
                    'AES-256-GCM / SHA256'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          RamezButton(
            label: isArabic ? 'قطع الاتصال الآن' : 'Disconnect Tunnel',
            variant: RamezButtonVariant.danger,
            icon: Icons.power_settings_new,
            onPressed: () {
              if (hasCubit) {
                context.read<VpnConnectionCubit>().disconnect();
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(isArabic
                        ? 'تم قطع الاتصال'
                        : 'Tunnel Disconnected')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
