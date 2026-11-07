import 'package:equatable/equatable.dart';

class AdvancedNetworkSettings extends Equatable {
  final bool killSwitch;
  final bool ipv6Protection;
  final String dnsProvider;
  final String customDns;
  final int mtu;
  final bool splitTunnelingEnabled;
  final String splitTunnelingMode; // 'exclude' (bypass VPN) or 'include' (only VPN)
  final List<String> selectedApps;

  const AdvancedNetworkSettings({
    this.killSwitch = true,
    this.ipv6Protection = true,
    this.dnsProvider = 'Cloudflare (1.1.1.1)',
    this.customDns = '1.1.1.1',
    this.mtu = 1420,
    this.splitTunnelingEnabled = false,
    this.splitTunnelingMode = 'exclude',
    this.selectedApps = const [],
  });

  AdvancedNetworkSettings copyWith({
    bool? killSwitch,
    bool? ipv6Protection,
    String? dnsProvider,
    String? customDns,
    int? mtu,
    bool? splitTunnelingEnabled,
    String? splitTunnelingMode,
    List<String>? selectedApps,
  }) {
    return AdvancedNetworkSettings(
      killSwitch: killSwitch ?? this.killSwitch,
      ipv6Protection: ipv6Protection ?? this.ipv6Protection,
      dnsProvider: dnsProvider ?? this.dnsProvider,
      customDns: customDns ?? this.customDns,
      mtu: mtu ?? this.mtu,
      splitTunnelingEnabled: splitTunnelingEnabled ?? this.splitTunnelingEnabled,
      splitTunnelingMode: splitTunnelingMode ?? this.splitTunnelingMode,
      selectedApps: selectedApps ?? this.selectedApps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kill_switch': killSwitch,
      'ipv6_protection': ipv6Protection,
      'dns_provider': dnsProvider,
      'custom_dns': customDns,
      'mtu': mtu,
      'split_tunneling_enabled': splitTunnelingEnabled,
      'split_tunneling_mode': splitTunnelingMode,
      'selected_apps': selectedApps,
    };
  }

  factory AdvancedNetworkSettings.fromJson(Map<String, dynamic> json) {
    return AdvancedNetworkSettings(
      killSwitch: json['kill_switch'] != false,
      ipv6Protection: json['ipv6_protection'] != false,
      dnsProvider: json['dns_provider'] as String? ?? 'Cloudflare (1.1.1.1)',
      customDns: json['custom_dns'] as String? ?? '1.1.1.1',
      mtu: (json['mtu'] as num?)?.toInt() ?? 1420,
      splitTunnelingEnabled: json['split_tunneling_enabled'] == true,
      splitTunnelingMode: json['split_tunneling_mode'] as String? ?? 'exclude',
      selectedApps: (json['selected_apps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [
        killSwitch,
        ipv6Protection,
        dnsProvider,
        customDns,
        mtu,
        splitTunnelingEnabled,
        splitTunnelingMode,
        selectedApps,
      ];
}
