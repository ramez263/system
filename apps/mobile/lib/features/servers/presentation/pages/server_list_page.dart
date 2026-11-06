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
  _ServerSort _sort = _ServerSort.ping;

  final List<Map<String, dynamic>> _mockServers = [
    {'id': 1, 'name': 'Frankfurt OpenVPN 01', 'country_code': 'DE', 'country_name': 'Germany', 'city': 'Frankfurt', 'flag': '🇩🇪', 'protocol': 'OpenVPN UDP', 'ping_ms': 28, 'load': 24, 'is_premium': false},
    {'id': 2, 'name': 'Amsterdam Ultra 01', 'country_code': 'NL', 'country_name': 'Netherlands', 'city': 'Amsterdam', 'flag': '🇳🇱', 'protocol': 'OpenVPN TCP', 'ping_ms': 32, 'load': 35, 'is_premium': false},
    {'id': 3, 'name': 'London Express 01', 'country_code': 'GB', 'country_name': 'United Kingdom', 'city': 'London', 'flag': '🇬🇧', 'protocol': 'OpenVPN UDP', 'ping_ms': 42, 'load': 18, 'is_premium': false},
    {'id': 4, 'name': 'New York East 01', 'country_code': 'US', 'country_name': 'United States', 'city': 'New York', 'flag': '🇺🇸', 'protocol': 'OpenVPN UDP', 'ping_ms': 96, 'load': 45, 'is_premium': false},
    {'id': 5, 'name': 'Singapore Hub 01', 'country_code': 'SG', 'country_name': 'Singapore', 'city': 'Singapore', 'flag': '🇸🇬', 'protocol': 'OpenVPN UDP', 'ping_ms': 118, 'load': 28, 'is_premium': false},
  ];

  Map<String, dynamic> get _bestServer {
    return _mockServers.reduce((a, b) => (a['ping_ms'] as int) <= (b['ping_ms'] as int) ? a : b);
  }

  List<Map<String, dynamic>> get _filteredServers {
    final list = _mockServers.where((s) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch = s['name'].toString().toLowerCase().contains(query) ||
          s['country_name'].toString().toLowerCase().contains(query) ||
          s['city'].toString().toLowerCase().contains(query);
      final matchesCountry = _selectedCountry == 'ALL' || s['country_code'] == _selectedCountry;
      return matchesSearch && matchesCountry;
    }).toList();

    list.sort((a, b) {
      switch (_sort) {
        case _ServerSort.ping:
          return (a['ping_ms'] as int).compareTo(b['ping_ms'] as int);
        case _ServerSort.load:
          return (a['load'] as int).compareTo(b['load'] as int);
        case _ServerSort.name:
          return (a['name'] as String).compareTo(b['name'] as String);
      }
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final servers = _filteredServers;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'الخوادم الجاهزة' : 'Ready Servers',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              isArabic ? 'اختر الأقرب والأسرع إليك' : 'Pick the fastest server near you',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Smart Connect hero banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: GestureDetector(
              onTap: () => context.push(AppRouter.serverDetailsPath, extra: _bestServer),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'اتصال ذكي' : 'Smart Connect',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_bestServer['name']} • ${_bestServer['ping_ms']} ms',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                  ],
                ),
              ),
            ),
          ),

          // Search + sort
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: isArabic ? 'بحث بالاسم أو الدولة...' : 'Search servers...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SortMenu(
                  current: _sort,
                  onChanged: (sort) => setState(() => _sort = sort),
                ),
              ],
            ),
          ),

          // Country filter chips
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('ALL', isArabic ? 'الكل' : 'All Servers', null),
                _buildFilterChip('DE', 'Germany', '🇩🇪'),
                _buildFilterChip('NL', 'Netherlands', '🇳🇱'),
                _buildFilterChip('GB', 'UK', '🇬🇧'),
                _buildFilterChip('US', 'USA', '🇺🇸'),
                _buildFilterChip('SG', 'Singapore', '🇸🇬'),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  isArabic ? '${servers.length} خوادم متاحة' : '${servers.length} servers available',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (_selectedCountry != 'ALL' || _searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() {
                      _selectedCountry = 'ALL';
                      _searchQuery = '';
                    }),
                    child: Text(isArabic ? 'مسح الفلاتر' : 'Clear filters'),
                  ),
              ],
            ),
          ),

          Expanded(
            child: servers.isEmpty
                ? RamezEmptyState(
                    title: isArabic ? 'لا توجد نتائج' : 'No Servers Found',
                    description: isArabic
                        ? 'لم نتمكن من إيجاد خوادم مطابقة لمعايير البحث.'
                        : 'No servers match your current search filters.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: servers.length,
                    itemBuilder: (context, index) {
                      final server = servers[index];
                      final ping = server['ping_ms'] as int;
                      final isBest = server['id'] == _bestServer['id'];
                      return _ServerCard(
                        server: server,
                        ping: ping,
                        isBest: isBest,
                        isArabic: isArabic,
                        onTap: () => context.push(AppRouter.serverDetailsPath, extra: server),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String code, String label, String? flag) {
    final isSelected = _selectedCountry == code;
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCountry = code),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : color,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (flag != null) ...[
                Text(flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ServerSort { ping, load, name }

class _SortMenu extends StatelessWidget {
  final _ServerSort current;
  final ValueChanged<_ServerSort> onChanged;

  const _SortMenu({
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<_ServerSort>(
      tooltip: 'Sort servers',
      icon: const Icon(Icons.sort_rounded),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _ServerSort.ping,
          child: Row(
            children: [
              Icon(Icons.signal_cellular_alt, size: 18, color: colorScheme.primary),
              const SizedBox(width: 10),
              const Text('Sort by Ping'),
              if (current == _ServerSort.ping) ...[
                const Spacer(),
                Icon(Icons.check, color: colorScheme.primary, size: 18),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: _ServerSort.load,
          child: Row(
            children: [
              Icon(Icons.speed_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 10),
              const Text('Sort by Load'),
              if (current == _ServerSort.load) ...[
                const Spacer(),
                Icon(Icons.check, color: colorScheme.primary, size: 18),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: _ServerSort.name,
          child: Row(
            children: [
              Icon(Icons.sort_by_alpha_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 10),
              const Text('Sort by Name'),
              if (current == _ServerSort.name) ...[
                const Spacer(),
                Icon(Icons.check, color: colorScheme.primary, size: 18),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ServerCard extends StatelessWidget {
  final Map<String, dynamic> server;
  final int ping;
  final bool isBest;
  final bool isArabic;
  final VoidCallback onTap;

  const _ServerCard({
    required this.server,
    required this.ping,
    required this.isBest,
    required this.isArabic,
    required this.onTap,
  });

  Color _pingColor() {
    if (ping < 60) return Colors.green;
    if (ping < 110) return Colors.orange;
    return Colors.red;
  }

  int _pingLevel() {
    if (ping < 45) return 4;
    if (ping < 70) return 3;
    if (ping < 110) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final load = server['load'] as int;
    final loadColor = load < 40 ? Colors.green : (load < 70 ? Colors.orange : Colors.red);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RamezGlassCard(
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.2),
                        colorScheme.primary.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Text(
                    server['flag'] as String,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                if (isBest)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          server['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isBest)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isArabic ? 'الأفضل' : 'BEST',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.amber,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          '${server['city']}, ${server['country_name']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _MiniTag(
                        icon: Icons.lock_outline_rounded,
                        label: server['protocol'] as String,
                      ),
                      const SizedBox(width: 6),
                      _MiniTag(
                        icon: Icons.shield_outlined,
                        label: 'AES-256',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        isArabic ? 'الحمل' : 'Load',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: load / 100,
                            minHeight: 4,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(loadColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$load%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: loadColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                _SignalBars(level: _pingLevel(), color: _pingColor()),
                const SizedBox(height: 4),
                Text(
                  '$ping',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: _pingColor(),
                    height: 1,
                  ),
                ),
                Text(
                  'ms',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(Icons.chevron_right_rounded, size: 20, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  final int level; // 1..4
  final Color color;

  const _SignalBars({required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        final height = 6.0 + i * 6;
        final active = i < level;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Container(
            width: 4,
            height: height,
            decoration: BoxDecoration(
              color: active ? color : Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
