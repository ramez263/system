import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tunnel_plus/core/widgets/modern_app_bar.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: ModernAppBar(
        title: 'Data Statistics',
        subtitle: 'Total bandwidth & session overview',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // ---- Summary Cards -----------------------------------------------
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: isArabic ? 'إجمالي الاستهلاك' : 'Total Bandwidth',
                  value: '4.82 GB',
                  icon: Icons.data_usage,
                  color: colorScheme.primary,
                  subtitle: '▲ 12% this week',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: isArabic ? 'إجمالي المدة' : 'Total Uptime',
                  value: '28h 45m',
                  icon: Icons.timer_outlined,
                  color: Colors.purple,
                  subtitle: '▲ 8% this week',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: _SummaryCard(
              label: isArabic ? 'متوسط السرعة' : 'Avg. Speed',
              value: '24.8 Mbps',
              icon: Icons.speed,
              color: Colors.teal,
              subtitle: 'Peak: 68 Mbps',
            ),
          ),

          const SizedBox(height: 24),

          // ---- Weekly Chart -----------------------------------------------
          Text(
            isArabic ? 'الاستهلاك الأسبوعي' : 'Weekly Usage',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          RamezGlassCard(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => const FlLine(
                      color: Color(0xFFE5E7EB),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (val, meta) {
                          return Text(
                            '${val.toInt()} GB',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (val, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (val.toInt() >= 0 && val.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[val.toInt()],
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 0.6),
                        const FlSpot(1, 1.2),
                        const FlSpot(2, 0.4),
                        const FlSpot(3, 1.8),
                        const FlSpot(4, 0.9),
                        const FlSpot(5, 2.1),
                        const FlSpot(6, 1.4),
                      ],
                      isCurved: true,
                      curveSmoothness: 0.4,
                      color: colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorScheme.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ---- Server Usage -----------------------------------------------
          Text(
            isArabic ? 'أكثر الخوادم استخداماً' : 'Most Used Servers',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          _ServerUsageRow(
            flag: '🇩🇪',
            name: 'Frankfurt Fast-01',
            country: 'Germany',
            usage: '3.1 GB',
            share: '64%',
            color: colorScheme.primary,
            isArabic: isArabic,
          ),
          const SizedBox(height: 10),
          _ServerUsageRow(
            flag: '🇳🇱',
            name: 'Amsterdam Ultra-01',
            country: 'Netherlands',
            usage: '1.2 GB',
            share: '25%',
            color: Colors.purple,
            isArabic: isArabic,
          ),
          const SizedBox(height: 10),
          _ServerUsageRow(
            flag: '🇬🇧',
            name: 'London Express-01',
            country: 'United Kingdom',
            usage: '0.5 GB',
            share: '11%',
            color: Colors.teal,
            isArabic: isArabic,
          ),
        ],
      ),
    ),
  );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RamezGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(icon, size: 20, color: color),
                ),
              ),
              const Spacer(),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServerUsageRow extends StatelessWidget {
  final String flag;
  final String name;
  final String country;
  final String usage;
  final String share;
  final Color color;
  final bool isArabic;

  const _ServerUsageRow({
    required this.flag,
    required this.name,
    required this.country,
    required this.usage,
    required this.share,
    required this.color,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(flag, style: const TextStyle(fontSize: 26)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    country,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    usage,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      share,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
