import 'package:flutter/material.dart';
import '../../../../core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_button.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class ConfigEditorPage extends StatefulWidget {
  const ConfigEditorPage({super.key});

  @override
  State<ConfigEditorPage> createState() => _ConfigEditorPageState();
}

class _ConfigEditorPageState extends State<ConfigEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Custom Tunnel 01');
  final _serverController = TextEditingController(text: '185.120.40.12');
  final _portController = TextEditingController(text: '1194');
  final _sniController = TextEditingController(text: 'vpn.example.com');
  final _dnsController = TextEditingController(text: '1.1.1.1, 8.8.8.8');
  String _protocol = 'OpenVPN';

  @override
  void dispose() {
    _nameController.dispose();
    _serverController.dispose();
    _portController.dispose();
    _sniController.dispose();
    _dnsController.dispose();
    super.dispose();
  }

  void _saveConfig() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'تم حفظ الإعداد بنجاح'
                : 'Configuration saved successfully',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: const ModernAppBar(title: 'Configuration Editor', subtitle: 'Create or edit tunnel profiles'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            // 1. Basic Parameters
            _sectionHeader(context, isArabic ? 'البيانات الأساسية' : 'Basic Parameters'),
            const SizedBox(height: 12),
            RamezGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'اسم الملف' : 'Profile Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.label),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _protocol,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'نوع البروتوكول' : 'Protocol Family',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.vpn_key),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'OpenVPN', child: Text('OpenVPN (OVPN)')),
                      DropdownMenuItem(value: 'VLESS', child: Text('VLESS Reality')),
                      DropdownMenuItem(value: 'VMess', child: Text('VMess WebSocket')),
                      DropdownMenuItem(value: 'Trojan', child: Text('Trojan TLS')),
                      DropdownMenuItem(value: 'Hysteria2', child: Text('Hysteria 2 (QUIC)')),
                    ],
                    onChanged: (val) => setState(() => _protocol = val ?? 'OpenVPN'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Server & Network Details
            _sectionHeader(context, isArabic ? 'عنوان الخادم والشبكة' : 'Server & Network Details'),
            const SizedBox(height: 12),
            RamezGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _serverController,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'عنوان الخادم / Host' : 'Server Host / IP',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.public),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _portController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'المنفذ' : 'Port',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.numbers),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Port' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _sniController,
                    decoration: InputDecoration(
                      labelText: 'SNI (Server Name Indication)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.security),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _dnsController,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'خوادم DNS' : 'Custom DNS',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.dns),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 3. Save action
            SizedBox(
              width: double.infinity,
              height: 54,
              child: RamezButton(
                label: isArabic ? 'حفظ وتطبيق الإعداد' : 'Save Configuration',
                icon: Icons.save,
                onPressed: _saveConfig,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
    );
  }
}
