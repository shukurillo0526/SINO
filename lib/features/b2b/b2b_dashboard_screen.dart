import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/analytics_service.dart';
import '../../services/clinical_export_service.dart';

class B2BDashboardScreen extends StatefulWidget {
  const B2BDashboardScreen({super.key});

  @override
  State<B2BDashboardScreen> createState() => _B2BDashboardScreenState();
}

class _B2BDashboardScreenState extends State<B2BDashboardScreen> {
  final AnalyticsService _analytics = AnalyticsService();
  final ClinicalExportService _exportService = ClinicalExportService();
  
  bool _isLoading = true;
  RiskDistribution? _riskDistribution;
  List<WeeklyTrend> _weeklyTrends = [];
  List<DailyMoodStats> _dailyStats = [];
  List<SourceBreakdown> _sourceBreakdown = [];
  List<WorkloadMoodCorrelation> _workloadCorrelation = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final results = await Future.wait([
      _analytics.fetchRiskDistribution(),
      _analytics.fetchWeeklyTrends(),
      _analytics.fetchDailyMoodStats(),
      _analytics.fetchSourceBreakdown(),
      _analytics.fetchAcademicStressCorrelation(),
    ]);
    
    setState(() {
      _riskDistribution = results[0] as RiskDistribution;
      _weeklyTrends = results[1] as List<WeeklyTrend>;
      _dailyStats = results[2] as List<DailyMoodStats>;
      _sourceBreakdown = results[3] as List<SourceBreakdown>;
      _workloadCorrelation = results[4] as List<WorkloadMoodCorrelation>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SINO School Admin Dashboard'),
        backgroundColor: const Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildKeyMetrics(),
                  const SizedBox(height: 32),
                  _buildRiskDistributionChart(),
                  const SizedBox(height: 32),
                  _buildWeeklyTrendChart(),
                  const SizedBox(height: 32),
                  _buildAcademicStressChart(),
                  const SizedBox(height: 32),
                  _buildSourceBreakdown(),
                  const SizedBox(height: 32),
                  _buildExportSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2E5077)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.school, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gangnam District High School',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Student Wellness Overview • ${_riskDistribution?.total ?? 0} Active Users',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ANONYMIZED',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    final risk = _riskDistribution;
    final avgSentiment = _weeklyTrends.isNotEmpty 
        ? _weeklyTrends.last.avgSentiment 
        : 0.0;
    final wellnessScore = ((avgSentiment + 1) / 2 * 100).toInt().clamp(0, 100);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Wellness Score',
            value: '$wellnessScore',
            subtitle: '/100',
            color: wellnessScore > 60 ? Colors.green : Colors.orange,
            icon: Icons.health_and_safety,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'High Risk',
            value: '${risk?.highRisk ?? 0}',
            subtitle: 'Students',
            color: Colors.red,
            icon: Icons.warning_amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Moderate',
            value: '${risk?.moderateRisk ?? 0}',
            subtitle: 'Students',
            color: Colors.orange,
            icon: Icons.remove_circle_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskDistributionChart() {
    final risk = _riskDistribution;
    if (risk == null) return const SizedBox.shrink();

    return _ChartCard(
      title: 'Risk Distribution',
      subtitle: 'Anonymized student wellness tiers',
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: risk.positive.toDouble(),
                      color: const Color(0xFF4CAF50),
                      title: '${risk.positivePercent.toStringAsFixed(0)}%',
                      radius: 55,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    PieChartSectionData(
                      value: risk.neutral.toDouble(),
                      color: const Color(0xFF2196F3),
                      title: '${risk.neutralPercent.toStringAsFixed(0)}%',
                      radius: 55,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    PieChartSectionData(
                      value: risk.moderateRisk.toDouble(),
                      color: const Color(0xFFFF9800),
                      title: '${risk.moderateRiskPercent.toStringAsFixed(0)}%',
                      radius: 55,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    PieChartSectionData(
                      value: risk.highRisk.toDouble(),
                      color: const Color(0xFFE53935),
                      title: '${risk.highRiskPercent.toStringAsFixed(0)}%',
                      radius: 55,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 35,
                ),
              ),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendItem(color: Color(0xFF4CAF50), label: 'Positive'),
                  _LegendItem(color: Color(0xFF2196F3), label: 'Neutral'),
                  _LegendItem(color: Color(0xFFFF9800), label: 'Moderate Risk'),
                  _LegendItem(color: Color(0xFFE53935), label: 'High Risk'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTrendChart() {
    if (_weeklyTrends.isEmpty) return const SizedBox.shrink();

    final spots = _weeklyTrends.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value.avgSentiment + 1) / 2);
    }).toList();

    return _ChartCard(
      title: 'Wellness Trend',
      subtitle: 'Week-over-week sentiment average',
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 0.25,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final percent = (value * 100).toInt();
                    return Text('$percent%', style: TextStyle(color: Colors.grey[600], fontSize: 10));
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx >= 0 && idx < _weeklyTrends.length) {
                      return Text(
                        'W${idx + 1}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 10),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: const Color(0xFF1E3A5F),
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFF1E3A5F).withOpacity(0.1),
                ),
              ),
            ],
            minY: 0,
            maxY: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildAcademicStressChart() {
    if (_workloadCorrelation.isEmpty) return const SizedBox.shrink();

    return _ChartCard(
      title: 'Academic Stress vs Mood',
      subtitle: 'Correlation between workload and wellness',
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 1,
            minY: -1,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const Text('0', style: TextStyle(fontSize: 10));
                    if (value == 0.5) return const Text('+', style: TextStyle(fontSize: 10, color: Colors.green));
                    if (value == -0.5) return const Text('-', style: TextStyle(fontSize: 10, color: Colors.red));
                    return const Text('');
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx >= 0 && idx < _workloadCorrelation.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _workloadCorrelation[idx].displayName,
                          style: const TextStyle(fontSize: 9),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 0.5,
            ),
            barGroups: _workloadCorrelation.asMap().entries.map((e) {
              final sentiment = e.value.avgSentiment;
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: sentiment,
                    color: sentiment > 0 ? Colors.green : Colors.red,
                    width: 30,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSourceBreakdown() {
    if (_sourceBreakdown.isEmpty) return const SizedBox.shrink();

    return _ChartCard(
      title: 'Data Sources',
      subtitle: 'Where mood data comes from',
      child: Column(
        children: _sourceBreakdown.map((source) {
          final maxCount = _sourceBreakdown.map((s) => s.entryCount).reduce((a, b) => a > b ? a : b);
          final percent = maxCount > 0 ? source.entryCount / maxCount : 0.0;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(source.displayName, style: const TextStyle(fontSize: 12)),
                ),
                Expanded(
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: source.avgSentiment > 0 ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${source.entryCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExportSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Reports',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Download anonymized data for policy planning',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final success = await _exportService.exportToCSV(
                      dailyStats: _dailyStats,
                      riskDistribution: _riskDistribution,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success 
                            ? 'Report exported successfully!' 
                            : 'Export failed. Please try again.'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Export CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Weekly report sent to admin email.')),
                    );
                  },
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Email Report'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== HELPER WIDGETS =====

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 2),
                child: Text(
                  subtitle,
                  style: TextStyle(color: color.withOpacity(0.7), fontSize: 12),
                ),
              ),
            ],
          ),
          Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
