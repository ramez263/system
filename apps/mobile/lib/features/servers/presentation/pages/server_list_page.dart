import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/ramez_empty_state.dart';
import '../../../../core/widgets/ramez_glass_card.dart';
import '../../domain/entities/server_entity.dart';
import '../cubit/server_list_cubit.dart';

class ServerListPage extends StatefulWidget {
  const ServerListPage({super.key});

  @override
  State<ServerListPage> createState() => _ServerListPageState();
}

class _ServerListPageState extends State<ServerListPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _mockServers = [
    {'id': 1, 'name': 'Frankfurt OpenVPN 01', 'country_code': 'DE', 'country_name': 'Germany', 'city': 'Frankfurt', 'flag': '🇩🇪', 'protocol': 'OpenVPN UDP', 'ping_ms': 24, 'load': 22, 'is_premium': false, 'ip_address': '185.120.40.12', 'port': 1194},
    {'id': 2, 'name': 'Amsterdam Ultra 01', 'country_code': 'NL', 'country_name': 'Netherlands', 'city': 'Amsterdam', 'flag': '🇳🇱', 'protocol': 'OpenVPN UDP', 'ping_ms': 28, 'load': 31, 'is_premium': false, 'ip_address': '194.36.144.50', 'port': 1194},
    {'id': 3, 'name': 'London Express 01', 'country_code': 'GB', 'country_name': 'United Kingdom', 'city': 'London', 'flag': '🇬🇧', 'protocol': 'OpenVPN UDP', 'ping_ms': 36, 'load': 18, 'is_premium': false, 'ip_address': '89.238.150.10', 'port': 1194},
    {'id': 4, 'name': 'Paris Secure 01', 'country_code': 'FR', 'country_name': 'France', 'city': 'Paris', 'flag': '🇫🇷', 'protocol': 'OpenVPN UDP', 'ping_ms': 34, 'load': 27, 'is_premium': false, 'ip_address': '51.159.22.44', 'port': 1194},
    {'id': 5, 'name': 'Zurich Alpine 01', 'country_code': 'CH', 'country_name': 'Switzerland', 'city': 'Zurich', 'flag': '🇨🇭', 'protocol': 'OpenVPN UDP', 'ping_ms': 32, 'load': 15, 'is_premium': true, 'ip_address': '179.43.140.10', 'port': 1194},
    {'id': 6, 'name': 'New York East 01', 'country_code': 'US', 'country_name': 'United States', 'city': 'New York', 'flag': '🇺🇸', 'protocol': 'OpenVPN UDP', 'ping_ms': 88, 'load': 45, 'is_premium': false, 'ip_address': '198.51.100.88', 'port': 1194},
    {'id': 7, 'name': 'Singapore Hub 01', 'country_code': 'SG', 'country_name': 'Singapore', 'city': 'Singapore', 'flag': '🇸🇬', 'protocol': 'OpenVPN UDP', 'ping_ms': 115, 'load': 26, 'is_premium': false, 'ip_address': '103.253.14.9', 'port': 1194},
    {'id': 8, 'name': 'Tokyo Sakura 01', 'country_code': 'JP', 'country_name': 'Japan', 'city': 'Tokyo', 'flag': '🇯🇵', 'protocol': 'OpenVPN UDP', 'ping_ms': 135, 'load': 33, 'is_premium': false, 'ip_address': '133.242.18.77', 'port': 1194},
    {'id': 9, 'name': 'Dubai Gulf 01', 'country_code': 'AE', 'country_name': 'United Arab Emirates', 'city': 'Dubai', 'flag': '🇦🇪', 'protocol': 'OpenVPN UDP', 'ping_ms': 65, 'load': 29, 'is_premium': true, 'ip_address': '185.193.64.18', 'port': 1194},
    {'id': 10, 'name': 'Stockholm Nordic 01', 'country_code': 'SE', 'country_name': 'Sweden', 'city': 'Stockholm', 'flag': '🇸🇪', 'protocol': 'OpenVPN UDP', 'ping_ms': 42, 'load': 16, 'is_premium': false, 'ip_address': '193.180.118.4', 'port': 1194},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasCubit = context.findAncestorWidgetOfExactType<BlocProvider<ServerListCubit>>() != null;
      if (hasCubit) {
        context.read<ServerListCubit>().loadServers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _serverToMap(ServerEntity s) {
    return {
      'id': s.id,
      'name': s.name,
      'country_code': s.countryCode,
      'country_name': s.countryName,
      'city': s.city ?? '',
      'flag': s.flagEmoji,
      'protocol': s.protocol.toUpperCase(),
      'ping_ms': s.pingMs,
      'load': s.currentLoad,
      'is_premium': s.isPremium,
      'ip_address': s.ipAddress,
      'port': s.port,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final hasCubit = context.findAncestorWidgetOfExactType<BlocProvider<ServerListCubit>>() != null;

    if (!hasCubit) {
      return _buildStaticScaffold(context, theme, isArabic, _mockServers);
    }

    return BlocBuilder<ServerListCubit, ServerListState>(
      builder: (context, state) {
        if (state is ServerListLoading) {
          return Scaffold(
            appBar: _buildAppBar(theme, colorScheme, isArabic),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ServerListError) {
          return Scaffold(
            appBar: _buildAppBar(theme, colorScheme, isArabic),
            body: Center(
              child: RamezEmptyState(
                title: isArabic ? 'حدث خطأ في تحميل الخوادم' : 'Failed to Load Servers',
                description: state.message,
                actionLabel: isArabic ? 'إعادة المحاولة' : 'Try Again',
                onAction: () => context.read<ServerListCubit>().loadServers(forceRefresh: true),
              ),
            ),
          );
        }

        if (state is ServerListLoaded) {
          final servers = state.filteredServers.map(_serverToMap).toList();
          final bestServer = state.selectedServer != null
              ? _serverToMap(state.selectedServer!)
              : (servers.isNotEmpty ? servers.first : _mockServers.first);
          final countries = state.availableCountries;
          final selectedCountry = state.selectedCountry ?? 'ALL';
          final sortOption = state.sortOption;

          return Scaffold(
            appBar: _buildAppBar(theme, colorScheme, isArabic),
            body: RefreshIndicator(
              onRefresh: () => context.read<ServerListCubit>().loadServers(forceRefresh: true),
              child: Column(
                children: [
                  // Smart Connect hero banner
                  _buildSmartConnectBanner(context, colorScheme, isArabic, bestServer),

                  // Search + sort row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => context.read<ServerListCubit>().search(val),
                            style: theme.textTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: isArabic ? 'بحث بالاسم أو الدولة...' : 'Search servers...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        context.read<ServerListCubit>().search('');
                                      },
                                    )
                                  : null,
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
                          current: sortOption,
                          onChanged: (sort) => context.read<ServerListCubit>().changeSort(sort),
                        ),
                      ],
                    ),
                  ),

                  // Country filter chips carousel
                  SizedBox(
                    height: 46,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: countries.length,
                      itemBuilder: (context, i) {
                        final code = countries[i];
                        final flag = _getCountryFlag(code);
                        final label = _getCountryName(code, isArabic);
                        return _buildFilterChip(
                          code: code,
                          label: label,
                          flag: flag,
                          isSelected: selectedCountry == code,
                          onTap: () => context.read<ServerListCubit>().filterByCountry(code),
                        );
                      },
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
                        if (selectedCountry != 'ALL' || _searchController.text.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              context.read<ServerListCubit>().filterByCountry('ALL');
                              context.read<ServerListCubit>().search('');
                            },
                            child: Text(isArabic ? 'مسح الفلاتر' : 'Clear filters'),
                          ),
                      ],
                    ),
                  ),

                  // Servers List
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
                              final isBest = server['id'] == bestServer['id'];
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
            ),
          );
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, ColorScheme colorScheme, bool isArabic) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'الخوادم الجاهزة' : 'Ready Servers',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          Text(
            isArabic ? 'خوادم OpenVPN عامة جاهزة للاتصال الفوري' : 'Curated public OpenVPN servers ready to connect',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      centerTitle: false,
    );
  }

  Widget _buildSmartConnectBanner(BuildContext context, ColorScheme colorScheme, bool isArabic, Map<String, dynamic> bestServer) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: GestureDetector(
        onTap: () => context.push(AppRouter.serverDetailsPath, extra: bestServer),
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
                      isArabic ? 'اتصال ذكي (الأسرع)' : 'Smart Connect (Fastest)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${bestServer['name']} • ${bestServer['ping_ms']} ms',
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
    );
  }

  Widget _buildStaticScaffold(BuildContext context, ThemeData theme, bool isArabic, List<Map<String, dynamic>> servers) {
    final colorScheme = theme.colorScheme;
    final bestServer = servers.first;

    return Scaffold(
      appBar: _buildAppBar(theme, colorScheme, isArabic),
      body: Column(
        children: [
          _buildSmartConnectBanner(context, colorScheme, isArabic, bestServer),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: servers.length,
              itemBuilder: (context, index) {
                final server = servers[index];
                final ping = server['ping_ms'] as int;
                return _ServerCard(
                  server: server,
                  ping: ping,
                  isBest: index == 0,
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

  Widget _buildFilterChip({
    required String code,
    required String label,
    required String? flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: GestureDetector(
        onTap: onTap,
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

  String? _getCountryFlag(String code) {
    switch (code.toUpperCase()) {
      case 'DE': return '🇩🇪';
      case 'NL': return '🇳🇱';
      case 'GB': return '🇬🇧';
      case 'FR': return '🇫🇷';
      case 'CH': return '🇨🇭';
      case 'US': return '🇺🇸';
      case 'CA': return '🇨🇦';
      case 'SG': return '🇸🇬';
      case 'JP': return '🇯🇵';
      case 'AE': return '🇦🇪';
      case 'SE': return '🇸🇪';
      default: return null;
    }
  }

  String _getCountryName(String code, bool isArabic) {
    switch (code.toUpperCase()) {
      case 'ALL': return isArabic ? 'الكل' : 'All Servers';
      case 'DE': return isArabic ? 'ألمانيا' : 'Germany';
      case 'NL': return isArabic ? 'هولندا' : 'Netherlands';
      case 'GB': return isArabic ? 'بريطانيا' : 'UK';
      case 'FR': return isArabic ? 'فرنسا' : 'France';
      case 'CH': return isArabic ? 'سويسرا' : 'Switzerland';
      case 'US': return isArabic ? 'أمريكا' : 'USA';
      case 'CA': return isArabic ? 'كندا' : 'Canada';
      case 'SG': return isArabic ? 'سنغافورة' : 'Singapore';
      case 'JP': return isArabic ? 'اليابان' : 'Japan';
      case 'AE': return isArabic ? 'الإمارات' : 'UAE';
      case 'SE': return isArabic ? 'السويد' : 'Sweden';
      default: return code;
    }
  }
}

class _SortMenu extends StatelessWidget {
  final ServerSortOption current;
  final ValueChanged<ServerSortOption> onChanged;

  const _SortMenu({
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<ServerSortOption>(
      tooltip: 'Sort servers',
      icon: const Icon(Icons.sort_rounded),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ServerSortOption.ping,
          child: Row(
            children: [
              Icon(Icons.signal_cellular_alt, size: 18, color: colorScheme.primary),
              const SizedBox(width: 10),
              const Text('Lowest Ping'),
              if (current == ServerSortOption.ping) ...[
                const Spacer(),
                Icon(Icons.check, color: colorScheme.primary, size: 18),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: ServerSortOption.load,
          child: Row(
            children: [
              Icon(Icons.speed_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 10),
              const Text('Lowest Load'),
              if (current == ServerSortOption.load) ...[
                const Spacer(),
                Icon(Icons.check, color: colorScheme.primary, size: 18),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: ServerSortOption.name,
          child: Row(
            children: [
              Icon(Icons.sort_by_alpha_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 10),
              const Text('Alphabetical'),
              if (current == ServerSortOption.name) ...[
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
    if (ping < 50) return Colors.green;
    if (ping < 100) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final load = (server['load'] as num?)?.toInt() ?? 20;
    final loadColor = load < 40 ? Colors.green : (load < 75 ? Colors.orange : Colors.red);
    final isPremium = server['is_premium'] == true;

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
                    server['flag']?.toString() ?? '🌐',
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                if (isBest)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber,
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
                          server['name']?.toString() ?? 'OpenVPN Server',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${server['city']}, ${server['country_name']} • ${server['protocol']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Ping badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _pingColor().withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _pingColor(),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$ping ms',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _pingColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Load indicator
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: load / 100.0,
                                  backgroundColor: colorScheme.surfaceContainerHighest,
                                  color: loadColor,
                                  minHeight: 5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$load%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
