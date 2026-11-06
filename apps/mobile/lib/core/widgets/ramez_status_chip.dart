import 'package:flutter/material.dart';
import '../theme/theme_extension.dart';

enum TunnelState { connected, connecting, disconnected, failed }

class RamezStatusChip extends StatelessWidget {
  final TunnelState state;
  final String? customLabel;

  const RamezStatusChip({
    super.key,
    required this.state,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<RamezThemeExtension>();

    Color color;
    String defaultLabel;
    IconData icon;

    switch (state) {
      case TunnelState.connected:
        color = ext?.connectedColor ?? Colors.green;
        defaultLabel = 'Connected';
        icon = Icons.check_circle_outline;
        break;
      case TunnelState.connecting:
        color = ext?.connectingColor ?? Colors.amber;
        defaultLabel = 'Connecting';
        icon = Icons.sync;
        break;
      case TunnelState.disconnected:
        color = ext?.disconnectedColor ?? Colors.grey;
        defaultLabel = 'Disconnected';
        icon = Icons.power_settings_new;
        break;
      case TunnelState.failed:
        color = Theme.of(context).colorScheme.error;
        defaultLabel = 'Failed';
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            customLabel ?? defaultLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
