import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/ramez_glass_card.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'إحصائيات استهلاك البيانات' : 'Data Usage & Statistics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: RamezGlassCard(
                  child: Column(
                    children: [
                      const Icon(Icons.data_usage, color: Colors.blue),
                      const SizedBox(height: 4),
                      Text(isArabic ? 'إجمالي الاستهلاك' : 'Total Bandwidth', style: const TextStyle(fontSize: 12)),
                      const Text('4.82 GB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RamezGlassCard(
                  child: Column(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.purple),
                      const SizedBox(height: 4),
                      Text(isArabic ? 'إجمالي الساعات' : 'Total Uptime', style: const TextStyle(fontSize: 12)),
                      const Text('28h 45m', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RamezGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'الاستهلاك الأسبوعي (GB)' : 'Weekly Bandwidth (GB)',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              const days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                              if (val.toInt() >= 0 && val.toInt() < days.length) {
                                return Text(days[val.toInt()], style: const TextStyle(fontSize: 11));
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        _makeBarGroup(0, 0.6, theme.colorScheme.primary),
                        _makeBarGroup(1, 1.2, theme.colorScheme.primary),
                        _makeBarGroup(2, 0.4, theme.colorScheme.primary),
                        _makeBarGroup(3, 1.8, theme.colorScheme.primary),
                        _makeBarGroup(4, 0.9, theme.colorScheme.primary),
                        _makeBarGroup(5, 2.1, theme.colorScheme.primary),
                        _makeBarGroup(6, 1.4, theme.colorScheme.primary),
                      ],
                    ),
                  ),
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
                  isArabic ? 'الخوادم الأكثر استخداماً' : 'Most Used Server Locations',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20),
                _buildServerUsageRow('🇩🇪 Frankfurt Fast-01', '3.1 GB (64%)'),
                _buildServerUsageRow('🇳🇱 Amsterdam Ultra-01', '1.2 GB (25%)'),
                _buildServerUsageRow('🇬🇧 London Express-01', '0.5 GB (11%)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildServerUsageRow(String server, String usage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(server, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(usage, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}
