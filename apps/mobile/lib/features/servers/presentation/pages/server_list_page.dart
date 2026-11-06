import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/ramez_empty_state.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class ServerListPage extends StatefulWidget {
  const ServerListPage({super.key});

  @override
  State<ServerListPage> createState() => _ServerListPageState();
}

class _ServerListPageState extends State<ServerListPage> {
  String _searchQuery = '';
  String _selectedCountry = 'ALL';

  final List<Map<String, dynamic>> _mockServers = [
    {
      'id': 1,
      'name': 'Frankfurt OpenVPN 01',
      'country_code': 'DE',
      'country_name': 'Germany',
      'city': 'Frankfurt',
      'flag': '🇩🇪',
      'protocol': 'OpenVPN UDP',
      'ping_ms': 28,
      'load': 24,
      'is_premium': false,
    },
    {
      'id': 2,
      'name': 'Amsterdam Ultra 01',
      'country_code': 'NL',
      'country_name': 'Netherlands',
      'city': 'Amsterdam',
      'flag': '🇳🇱',
      'protocol': 'OpenVPN TCP',
      'ping_ms': 32,
      'load': 35,
      'is_premium': false,
    },
    {
      'id': 3,
      'name': 'London Express 01',
      'country_code': 'GB',
      'country_name': 'United Kingdom',
      'city': 'London',
      'flag': '🇬🇧',
      'protocol': 'OpenVPN UDP',
      'ping_ms': 42,
      'load': 18,
      'is_premium': false,
    },
    {
      'id': 4,
      'name': 'New York East 01',
      'country_code': 'US',
      'country_name': 'United States',
      'city': 'New York',
      'flag': '🇺🇸',
      'protocol': 'OpenVPN UDP',
      'ping_ms': 96,
      'load': 45,
      'is_premium': false,
    },
    {
      'id': 5,
      'name': 'Singapore Hub 01',
      'country_code': 'SG',
      'country_name': 'Singapore',
      'city': 'Singapore',
      'flag': '🇸🇬',
      'protocol': 'OpenVPN UDP',
      'ping_ms': 118,
      'load': 28,
      'is_premium': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final filteredServers = _mockServers.where((s) {
      final matchesSearch = s['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s['country_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCountry = _selectedCountry == 'ALL' || s['country_code'] == _selectedCountry;
      return matchesSearch && matchesCountry;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'خوادم OpenVPN الجاهزة' : 'Ready OpenVPN Servers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: isArabic ? 'بحث بالاسم أو الدولة...' : 'Search servers...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip('ALL', isArabic ? 'الكل' : 'All'),
                _buildFilterChip('DE', '🇩🇪 Germany'),
                _buildFilterChip('NL', '🇳🇱 Netherlands'),
                _buildFilterChip('GB', '🇬🇧 UK'),
                _buildFilterChip('US', '🇺🇸 USA'),
                _buildFilterChip('SG', '🇸🇬 Singapore'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredServers.isEmpty
                ? RamezEmptyState(
                    title: isArabic ? 'لا توجد نتائج' : 'No Servers Found',
                    description: isArabic
                        ? 'لم نتمكن من إيجاد خوادم مطابقة لمعايير البحث.'
                        : 'No servers match your current search filters.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredServers.length,
                    itemBuilder: (context, index) {
                      final server = filteredServers[index];
                      return RamezGlassCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        onTap: () {
                          context.push(
                            AppRouter.serverDetailsPath,
                            extra: server,
                          );
                        },
                        child: Row(
                          children: [
                            Text(server['flag'] as String, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    server['name'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${server['city']}, ${server['country_name']} • ${server['protocol']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.network_ping,
                                      size: 16,
                                      color: server['ping_ms'] < 60 ? Colors.green : Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${server['ping_ms']} ms',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: server['ping_ms'] < 60 ? Colors.green : Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Load: ${server['load']}%',
                                  style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String code, String label) {
    final isSelected = _selectedCountry == code;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (val) => setState(() => _selectedCountry = code),
      ),
    );
  }
}
