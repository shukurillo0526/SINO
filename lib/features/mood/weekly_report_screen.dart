import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/mood_controller.dart';
import '../../models/mood_models.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    final moodController = context.watch<MoodController>();
    final theme = Theme.of(context);
    final report = moodController.getWeeklyReport();

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.isEnglish ? 'Weekly Report' : '주간 보고서'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            '${DateFormat('MMM d').format(report.weekStart)} - ${DateFormat('MMM d, yyyy').format(report.weekEnd)}',
            style: TextStyle(fontSize: 16, color: theme.disabledColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Summary Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryItem(
                        label: lang.isEnglish ? 'Average Mood' : '평균 기분',
                        value: report.averageSentiment >= 0 ? '😊 Positive' : '😔 Negative',
                        color: report.averageSentiment >= 0
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFF9800),
                      ),
                      Container(width: 1, height: 40, color: theme.dividerColor),
                      _SummaryItem(
                        label: lang.isEnglish ? 'Trend' : '추세',
                        value: '${report.trend.emoji} ${report.trend.label}',
                        color: report.trend.color,
                      ),
                    ],
                  ),
                  if (report.concernCount > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              lang.isEnglish
                                  ? '${report.concernCount} concerning moments this week'
                                  : '이번 주 ${report.concernCount}개의 우려스러운 순간',
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Daily Mood Chart
          Text(
            lang.isEnglish ? 'Daily Mood Trend' : '일일 기분 추세',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: _DailyMoodChart(
                  weekStart: report.weekStart,
                  moodController: moodController,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Source Breakdown
          if (report.sourceBreakdown.isNotEmpty) ...[
            Text(
              lang.isEnglish ? 'Activity Breakdown' : '활동 분석',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: report.sourceBreakdown.entries.map((entry) {
                    final total = report.sourceBreakdown.values.reduce((a, b) => a + b);
                    final percentage = (entry.value / total * 100).round();
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(entry.key.icon, size: 16, color: theme.disabledColor),
                              const SizedBox(width: 8),
                              Text(entry.key.label),
                              const Spacer(),
                              Text('$percentage%', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: entry.value / total,
                            backgroundColor: theme.dividerColor,
                            color: theme.primaryColor,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Insights
          Text(
            lang.isEnglish ? 'Insights' : '인사이트',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...report.insights.map((insight) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(Icons.lightbulb_outline, color: theme.primaryColor),
                  title: Text(insight),
                ),
              )),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.disabledColor,
          ),
        ),
      ],
    );
  }
}

class _DailyMoodChart extends StatelessWidget {
  final DateTime weekStart;
  final MoodController moodController;

  const _DailyMoodChart({
    required this.weekStart,
    required this.moodController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get daily averages for the week
    final spots = <FlSpot>[];
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final avg = moodController.getAverageSentimentForDay(day);
      spots.add(FlSpot(i.toDouble(), avg));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.dividerColor,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == -1) return const Text('-1', style: TextStyle(fontSize: 10));
                if (value == 0) return const Text('0', style: TextStyle(fontSize: 10));
                if (value == 1) return const Text('+1', style: TextStyle(fontSize: 10));
                return const Text('');
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() >= 0 && value.toInt() < 7) {
                  return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: -1,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.primaryColor,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final color = spot.y >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);
                return FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: theme.primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
