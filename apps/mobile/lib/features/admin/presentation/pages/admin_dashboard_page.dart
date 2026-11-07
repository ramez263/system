import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/storage/database/app_database.dart';
import '../../../../core/storage/hive_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_empty_state.dart';
import '../../../../core/widgets/ramez_glass_card.dart';
import '../../../../core/widgets/ramez_status_chip.dart';
import '../../../configurations/domain/entities/configuration_entity.dart';
import '../../../servers/domain/entities/server_entity.dart';

class AdminDashboardPage extends StatefulWidget {
  final bool initialAuthenticated;

  const AdminDashboardPage({
    super.key,
    this.initialAuthenticated = false,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isAuthenticated = false;
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _passwordError;

  int _selectedTab = 0; // 0: Servers, 1: Configs, 2: System

  // In-memory + persisted servers list
  List<Map<String, dynamic>> _servers = [];

  // In-memory + persisted configs list
  List<Map<String, dynamic>> _configs = [];

  final List<Map<String, dynamic>> _initialDefaultServers = [
    {
      'id': 1,
      'name': 'Frankfurt Fast-01 (Auto)',
      'country_name': 'Germany',
      'country_code': 'DE',
      'city': 'Frankfurt',
      'flag': '🇩🇪',
      'ip': '185.220.101.5',
      'port': 1194,
      'protocol': 'OpenVPN UDP',
      'ping_ms': 28,
      'load': 24,
      'is_premium': false,
    },
    {
      'id': 2,
      'name': 'Amsterdam Ultra 01',
      'country_name': 'Netherlands',
      'country_code': 'NL',
      'city': 'Amsterdam',
      'flag': '🇳🇱',
      'ip': '194.165.16.12',
      'port': 443,
      'protocol': 'OpenVPN TCP',
      'ping_ms': 32,
      'load': 35,
      'is_premium': false,
    },
    {
      'id': 3,
      'name': 'London Express 01',
      'country_name': 'United Kingdom',
      'country_code': 'GB',
      'city': 'London',
      'flag': '🇬🇧',
      'ip': '51.89.145.20',
      'port': 51820,
      'protocol': 'WireGuard',
      'ping_ms': 42,
      'load': 18,
      'is_premium': false,
    },
    {
      'id': 4,
      'name': 'New York East VIP',
      'country_name': 'United States',
      'country_code': 'US',
      'city': 'New York',
      'flag': '🇺🇸',
      'ip': '198.51.100.44',
      'port': 1194,
      'protocol': 'OpenVPN UDP',
      'ping_ms': 96,
      'load': 45,
      'is_premium': true,
    },
  ];

  final List<Map<String, dynamic>> _initialDefaultConfigs = [
    {
      'id': 'vod-router',
      'name': 'Vodafone for Router',
      'provider': 'Vodafone',
      'device': 'Router',
      'protocol': 'OpenVPN UDP',
      'host': '185.220.101.5',
      'port': 1194,
      'asset': 'assets/images/providers/vodafone.png',
      'raw': 'client\ndev tun\nproto udp\nremote 185.220.101.5 1194\nresolv-retry infinite\nnobind',
    },
    {
      'id': 'ora-mobile',
      'name': 'Orange for Mobile',
      'provider': 'Orange',
      'device': 'Mobile',
      'protocol': 'OpenVPN TCP',
      'host': '194.165.16.12',
      'port': 443,
      'asset': 'assets/images/providers/orange.png',
      'raw': 'client\ndev tun\nproto tcp\nremote 194.165.16.12 443\nresolv-retry infinite\nnobind',
    },
    {
      'id': 'eti-stream',
      'name': 'Etisalat for Router',
      'provider': 'Etisalat',
      'device': 'Router',
      'protocol': 'OpenVPN UDP',
      'host': '51.89.145.20',
      'port': 1194,
      'asset': 'assets/images/providers/etisalat.png',
      'raw': 'client\ndev tun\nproto udp\nremote 51.89.145.20 1194\nresolv-retry infinite\nnobind',
    },
    {
      'id': 'we-mobile',
      'name': 'WE for Mobile',
      'provider': 'WE',
      'device': 'Mobile',
      'protocol': 'OpenVPN UDP',
      'host': '185.220.101.5',
      'port': 1194,
      'asset': 'assets/images/providers/we.png',
      'raw': 'client\ndev tun\nproto udp\nremote 185.220.101.5 1194\nresolv-retry infinite\nnobind',
    },
  ];

  @override
  void initState() {
    super.initState();
    _isAuthenticated = widget.initialAuthenticated;
    _loadCatalog();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    final hive = sl<IHiveStorageService>();
    final cachedServers = hive.get<String>(HiveStorageService.boxCache, 'admin_custom_servers');
    if (cachedServers != null) {
      try {
        final decoded = jsonDecode(cachedServers) as List;
        _servers = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {
        _servers = List.from(_initialDefaultServers);
      }
    } else {
      _servers = List.from(_initialDefaultServers);
    }

    final cachedConfigs = hive.get<String>(HiveStorageService.boxCache, 'admin_custom_configs');
    if (cachedConfigs != null) {
      try {
        final decoded = jsonDecode(cachedConfigs) as List;
        _configs = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {
        _configs = List.from(_initialDefaultConfigs);
      }
    } else {
      _configs = List.from(_initialDefaultConfigs);
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveCatalog() async {
    final hive = sl<IHiveStorageService>();
    await hive.put(HiveStorageService.boxCache, 'admin_custom_servers', jsonEncode(_servers));
    await hive.put(HiveStorageService.boxCache, 'admin_custom_configs', jsonEncode(_configs));
  }

  void _verifyPassword(bool isArabic) {
    final pass = _passwordController.text.trim();
    if (pass == 'admin' || pass == 'admin123' || pass == '123456') {
      setState(() {
        _isAuthenticated = true;
        _passwordError = null;
      });
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(isArabic ? 'تم تأكيد صلاحيات المسؤول بنجاح' : 'Admin authorization granted'),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      setState(() {
        _passwordError = isArabic ? 'كلمة المرور غير صحيحة' : 'Incorrect admin password';
      });
      HapticFeedback.heavyImpact();
    }
  }

  // Add / Upload Server Dialog
  void _showUploadServerSheet(BuildContext context, bool isArabic) {
    final nameCtrl = TextEditingController();
    final countryCtrl = TextEditingController(text: isArabic ? 'ألمانيا' : 'Germany');
    final codeCtrl = TextEditingController(text: 'DE');
    final flagCtrl = TextEditingController(text: '🇩🇪');
    final ipCtrl = TextEditingController();
    final portCtrl = TextEditingController(text: '1194');
    final pingCtrl = TextEditingController(text: '28');
    final loadCtrl = TextEditingController(text: '20');
    final rawCtrl = TextEditingController();
    String selectedProtocol = 'OpenVPN UDP';
    bool isPremium = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final colorScheme = Theme.of(context).colorScheme;
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
              top: 16,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.cloud_upload_rounded, color: colorScheme.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'رفع خادم جديد' : 'Upload New Server',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              isArabic ? 'إضافة خادم إلى قائمة الخوادم المتاحة' : 'Deploy node to active server pool',
                              style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
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
                  const SizedBox(height: 18),

                  // Name
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'اسم الخادم' : 'Server Name',
                      hintText: 'e.g. Frankfurt Fast 02',
                      prefixIcon: const Icon(Icons.dns_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Country & Flag Row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: countryCtrl,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'الدولة' : 'Country',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: codeCtrl,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'الرمز' : 'Code',
                            hintText: 'DE',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: flagCtrl,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'العلم' : 'Flag',
                            hintText: '🇩🇪',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // IP & Port Row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: ipCtrl,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'عنوان IP' : 'IP Address',
                            hintText: '185.220.101.9',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: portCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'المنفذ' : 'Port',
                            hintText: '1194',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Protocol Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedProtocol,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'البروتوكول' : 'Protocol',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      prefixIcon: const Icon(Icons.tune_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'OpenVPN UDP', child: Text('OpenVPN UDP')),
                      DropdownMenuItem(value: 'OpenVPN TCP', child: Text('OpenVPN TCP')),
                      DropdownMenuItem(value: 'WireGuard', child: Text('WireGuard')),
                      DropdownMenuItem(value: 'SSH', child: Text('SSH Tunnel')),
                      DropdownMenuItem(value: 'V2Ray', child: Text('V2Ray VMess')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedProtocol = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Premium Switch
                  SwitchListTile(
                    title: Text(isArabic ? 'خادم مميز (VIP Premium)' : 'VIP Premium Server'),
                    subtitle: Text(isArabic ? 'يتطلب اشتراك مفعل' : 'Requires active subscription'),
                    value: isPremium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    onChanged: (val) => setModalState(() => isPremium = val),
                  ),
                  const SizedBox(height: 14),

                  // Raw Config String
                  TextField(
                    controller: rawCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'محتوى ملف .ovpn / الإعداد الخام (اختياري)' : 'Raw .ovpn payload (Optional)',
                      hintText: 'client\ndev tun\nproto udp...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.paste_rounded),
                        tooltip: isArabic ? 'لصق من الحافظة' : 'Paste from clipboard',
                        onPressed: () async {
                          final data = await Clipboard.getData(Clipboard.kTextPlain);
                          if (data?.text != null) {
                            rawCtrl.text = data!.text!;
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  RamezButton(
                    label: isArabic ? 'حفظ ونشر الخادم' : 'Deploy Server',
                    icon: Icons.check_circle_rounded,
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty || ipCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isArabic ? 'يرجى إدخال اسم الخادم وعنوان IP' : 'Please provide server name and IP')),
                        );
                        return;
                      }

                      final newServer = {
                        'id': DateTime.now().millisecondsSinceEpoch,
                        'name': nameCtrl.text.trim(),
                        'country_name': countryCtrl.text.trim(),
                        'country_code': codeCtrl.text.trim().toUpperCase(),
                        'city': countryCtrl.text.trim(),
                        'flag': flagCtrl.text.trim().isNotEmpty ? flagCtrl.text.trim() : '🌐',
                        'ip': ipCtrl.text.trim(),
                        'port': int.tryParse(portCtrl.text.trim()) ?? 1194,
                        'protocol': selectedProtocol,
                        'ping_ms': int.tryParse(pingCtrl.text.trim()) ?? 28,
                        'load': int.tryParse(loadCtrl.text.trim()) ?? 20,
                        'is_premium': isPremium,
                        'raw': rawCtrl.text.trim(),
                      };

                      setState(() {
                        _servers.insert(0, newServer);
                      });
                      await _saveCatalog();
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isArabic ? 'تم حفظ ونشر الخادم بنجاح' : 'Server deployed successfully'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Add / Upload Configuration Dialog
  void _showUploadConfigSheet(BuildContext context, bool isArabic) {
    final nameCtrl = TextEditingController();
    final hostCtrl = TextEditingController(text: '185.220.101.5');
    final portCtrl = TextEditingController(text: '1194');
    final rawCtrl = TextEditingController();
    String selectedProvider = 'Vodafone';
    String selectedDevice = 'Mobile';
    String selectedProtocol = 'OpenVPN UDP';

    final Map<String, String> providerAssets = {
      'Vodafone': 'assets/images/providers/vodafone.png',
      'Orange': 'assets/images/providers/orange.png',
      'Etisalat': 'assets/images/providers/etisalat.png',
      'WE': 'assets/images/providers/we.png',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final colorScheme = Theme.of(context).colorScheme;

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
              top: 16,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.post_add_rounded, color: colorScheme.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'رفع تكوين جديد' : 'Upload New Configuration',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              isArabic ? 'إضافة ملف تكوين لمشغلي الشبكات' : 'Deploy profile for mobile & router networks',
                              style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
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
                  const SizedBox(height: 18),

                  // Config Name
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'اسم التكوين' : 'Configuration Name',
                      hintText: 'e.g. Vodafone Gaming Fast 2026',
                      prefixIcon: const Icon(Icons.tune_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Provider Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedProvider,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'مزود الشبكة' : 'Network Provider',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      prefixIcon: const Icon(Icons.cell_tower_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Vodafone', child: Text('Vodafone Egypt')),
                      DropdownMenuItem(value: 'Orange', child: Text('Orange Egypt')),
                      DropdownMenuItem(value: 'Etisalat', child: Text('Etisalat Egypt')),
                      DropdownMenuItem(value: 'WE', child: Text('WE (Telecom Egypt)')),
                      DropdownMenuItem(value: 'Custom', child: Text('Custom Provider')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedProvider = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Device Target & Protocol Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedDevice,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'نوع الجهاز' : 'Device',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Mobile', child: Text('Mobile')),
                            DropdownMenuItem(value: 'Router', child: Text('Router')),
                            DropdownMenuItem(value: 'PC', child: Text('PC / Mac')),
                          ],
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedDevice = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: selectedProtocol,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'البروتوكول' : 'Protocol',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'OpenVPN UDP', child: Text('OpenVPN UDP')),
                            DropdownMenuItem(value: 'OpenVPN TCP', child: Text('OpenVPN TCP')),
                            DropdownMenuItem(value: 'WireGuard', child: Text('WireGuard')),
                            DropdownMenuItem(value: 'SSH', child: Text('SSH Tunnel')),
                          ],
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedProtocol = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Host & Port Row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: hostCtrl,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'عنوان السيرفر' : 'Server Host',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: portCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'المنفذ' : 'Port',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Raw Payload
                  TextField(
                    controller: rawCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'محتوى ملف التكوين .ovpn / Payload' : 'Configuration Payload',
                      hintText: 'client\ndev tun\nproto udp\nremote 185.220.101.5 1194...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.paste_rounded),
                        tooltip: isArabic ? 'لصق من الحافظة' : 'Paste from clipboard',
                        onPressed: () async {
                          final data = await Clipboard.getData(Clipboard.kTextPlain);
                          if (data?.text != null) {
                            rawCtrl.text = data!.text!;
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  RamezButton(
                    label: isArabic ? 'حفظ ونشر التكوين' : 'Deploy Configuration',
                    icon: Icons.check_circle_rounded,
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isArabic ? 'يرجى إدخال اسم التكوين' : 'Please provide configuration name')),
                        );
                        return;
                      }

                      final newConfig = {
                        'id': 'cfg-${DateTime.now().millisecondsSinceEpoch}',
                        'name': nameCtrl.text.trim(),
                        'provider': selectedProvider,
                        'device': selectedDevice,
                        'protocol': selectedProtocol,
                        'host': hostCtrl.text.trim(),
                        'port': int.tryParse(portCtrl.text.trim()) ?? 1194,
                        'asset': providerAssets[selectedProvider] ?? 'assets/images/providers/vodafone.png',
                        'raw': rawCtrl.text.trim().isNotEmpty
                            ? rawCtrl.text.trim()
                            : 'client\ndev tun\nproto udp\nremote ${hostCtrl.text.trim()} ${portCtrl.text.trim()}\nresolv-retry infinite\nnobind',
                      };

                      setState(() {
                        _configs.insert(0, newConfig);
                      });
                      await _saveCatalog();
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isArabic ? 'تم حفظ ونشر التكوين بنجاح' : 'Configuration deployed successfully'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppStrings.of(context);
    final isArabic = strings.isArabic;

    // 1. Password Lock View if unauthenticated
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: ModernAppBar(
          title: isArabic ? 'بوابة المشرفين' : 'Admin Security Gate',
          subtitle: isArabic ? 'منطقة محمية بكلمة مرور' : 'Password protected zone',
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: RamezGlassCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.35),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 38,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isArabic ? 'تسجيل دخول المسؤول' : 'Admin Authorization',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isArabic
                          ? 'أدخل كلمة مرور الإدارة لرفع وإدارة الخوادم والتكوينات'
                          : 'Enter admin passcode to upload and manage network nodes and profiles.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofocus: true,
                      onSubmitted: (_) => _verifyPassword(isArabic),
                      decoration: InputDecoration(
                        labelText: isArabic ? 'كلمة مرور المشرف' : 'Admin Password',
                        hintText: isArabic ? 'أدخل كلمة المرور (افتراضي: admin123)' : 'Enter passcode (Default: admin123)',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        errorText: _passwordError,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    RamezButton(
                      label: isArabic ? 'تحقق ودخول' : 'Unlock & Access',
                      icon: Icons.key_rounded,
                      onPressed: () => _verifyPassword(isArabic),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 2. Full Admin Dashboard Cockpit
    return Scaffold(
      appBar: ModernAppBar(
        title: isArabic ? 'لوحة تحكم المسؤول' : 'Admin Dashboard',
        subtitle: isArabic ? 'رفع وإدارة الخوادم والتكوينات' : 'Server & profile deployment center',
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_rounded),
            tooltip: isArabic ? 'قفل لوحة التحكم' : 'Lock Session',
            onPressed: () {
              setState(() {
                _isAuthenticated = false;
                _passwordController.clear();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Top Segmented Switcher
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
                      child: _AdminTabButton(
                        label: isArabic ? 'الخوادم' : 'Servers',
                        count: '${_servers.length}',
                        isSelected: _selectedTab == 0,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _AdminTabButton(
                        label: isArabic ? 'التكوينات' : 'Configs',
                        count: '${_configs.length}',
                        isSelected: _selectedTab == 1,
                        onTap: () => setState(() => _selectedTab = 1),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _AdminTabButton(
                        label: isArabic ? 'العمليات' : 'Operations',
                        count: '⚡',
                        isSelected: _selectedTab == 2,
                        onTap: () => setState(() => _selectedTab = 2),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tab Content
            Expanded(
              child: _selectedTab == 0
                  ? _buildServersTab(context, colorScheme, strings, isArabic)
                  : _selectedTab == 1
                      ? _buildConfigsTab(context, colorScheme, strings, isArabic)
                      : _buildOperationsTab(context, colorScheme, strings, isArabic),
            ),
          ],
        ),
      ),
    );
  }

  // Servers Tab
  Widget _buildServersTab(
    BuildContext context,
    ColorScheme colorScheme,
    AppStrings strings,
    bool isArabic,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                isArabic ? 'قائمة الخوادم المنشورة' : 'Active Server Nodes',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(isArabic ? 'رفع خادم' : 'Upload Server'),
                onPressed: () => _showUploadServerSheet(context, isArabic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _servers.isEmpty
              ? Center(
                  child: RamezEmptyState(
                    icon: Icons.dns_outlined,
                    title: isArabic ? 'لا توجد خوادم حالياً' : 'No servers available',
                    description: isArabic ? 'قم برفع أول خادم عبر زر الإضافة بالأعلى.' : 'Upload your first node using the button above.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: _servers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final s = _servers[index];
                    final isPremium = s['is_premium'] == true;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: (isPremium ? Colors.amber : colorScheme.primary).withValues(alpha: 0.25),
                        ),
                      ),
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
                              s['flag'] as String? ?? '🌐',
                              style: const TextStyle(fontSize: 22),
                            ),
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
                                        s['name'] as String,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isPremium) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: 0.18),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'VIP',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${s['ip']}:${s['port']} • ${s['protocol']}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            tooltip: isArabic ? 'حذف الخادم' : 'Delete Server',
                            onPressed: () {
                              setState(() {
                                _servers.removeAt(index);
                              });
                              _saveCatalog();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isArabic ? 'تم حذف الخادم' : 'Server removed'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
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

  // Configs Tab
  Widget _buildConfigsTab(
    BuildContext context,
    ColorScheme colorScheme,
    AppStrings strings,
    bool isArabic,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                isArabic ? 'ملفات التكوين المرفوعة' : 'Deployed Configurations',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.post_add_rounded, size: 18),
                label: Text(isArabic ? 'رفع تكوين' : 'Upload Config'),
                onPressed: () => _showUploadConfigSheet(context, isArabic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _configs.isEmpty
              ? Center(
                  child: RamezEmptyState(
                    icon: Icons.tune_rounded,
                    title: isArabic ? 'لا توجد تكوينات حالياً' : 'No configurations available',
                    description: isArabic ? 'قم برفع أول تكوين عبر زر الإضافة بالأعلى.' : 'Upload your first profile using the button above.',
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: _configs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final cfg = _configs[index];
                    final asset = cfg['asset'] as String?;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            child: asset != null
                                ? Image.asset(asset, fit: BoxFit.contain)
                                : Icon(Icons.tune_rounded, color: colorScheme.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cfg['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${cfg['provider']} • ${cfg['device']} • ${cfg['protocol']}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            tooltip: isArabic ? 'حذف التكوين' : 'Delete Configuration',
                            onPressed: () {
                              setState(() {
                                _configs.removeAt(index);
                              });
                              _saveCatalog();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isArabic ? 'تم حذف التكوين' : 'Configuration removed'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
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

  // Operations Tab
  Widget _buildOperationsTab(
    BuildContext context,
    ColorScheme colorScheme,
    AppStrings strings,
    bool isArabic,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        RamezGlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.sync_rounded, color: colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isArabic ? 'مزامنة لوحة التحكم' : 'Control Plane Synchronization',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restore_page_rounded),
                title: Text(isArabic ? 'استعادة الخوادم الافتراضية' : 'Restore Default Servers'),
                subtitle: Text(isArabic ? 'إعادة ضبط كتالوج الخوادم إلى القائمة الأولية' : 'Reset server pool to factory presets'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  setState(() {
                    _servers = List.from(_initialDefaultServers);
                  });
                  await _saveCatalog();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isArabic ? 'تم استعادة الخوادم الافتراضية' : 'Default servers restored')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.settings_backup_restore_rounded),
                title: Text(isArabic ? 'استعادة التكوينات الافتراضية' : 'Restore Default Configs'),
                subtitle: Text(isArabic ? 'إعادة تكوينات فودافون وأورنج واتصالات وWE' : 'Reset operator configs for Vodafone, Orange, WE'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  setState(() {
                    _configs = List.from(_initialDefaultConfigs);
                  });
                  await _saveCatalog();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isArabic ? 'تم استعادة التكوينات الافتراضية' : 'Default configs restored')),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cleaning_services_rounded),
                title: Text(isArabic ? 'مسح ذاكرة التخزين المؤقت' : 'Flush App Cache'),
                subtitle: Text(isArabic ? 'تفريغ الكاش المخزن للشبكة' : 'Clear temporary network cache'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final hive = sl<IHiveStorageService>();
                  await hive.clearBox(HiveStorageService.boxCache);
                  await _saveCatalog();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isArabic ? 'تم مسح الكاش بنجاح' : 'Cache flushed successfully')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminTabButton extends StatelessWidget {
  final String label;
  final String count;
  final bool isSelected;
  final VoidCallback onTap;

  const _AdminTabButton({
    required this.label,
    required this.count,
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
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
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
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.22) : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count,
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
