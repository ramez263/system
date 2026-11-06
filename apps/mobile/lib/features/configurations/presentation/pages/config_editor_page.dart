import 'package:flutter/material.dart';
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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'محرر الإعدادات' : 'Configuration Editor'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            RamezGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'البيانات الأساسية' : 'Basic Parameters',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'اسم الملف' : 'Profile Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _protocol,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'نوع البروتوكول' : 'Protocol Family',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
            RamezGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'عنوان الخادم والشبكة' : 'Server & Network Details',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _serverController,
                          decoration: InputDecoration(
                            labelText: isArabic ? 'عنوان الخادم / Host' : 'Server Host / IP',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _dnsController,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'خوادم DNS' : 'Custom DNS',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            RamezButton(
              label: isArabic ? 'حفظ وتطبيق الإعداد' : 'Save Configuration',
              onPressed: _saveConfig,
              icon: Icons.save,
            ),
          ],
        ),
      ),
    );
  }
}
