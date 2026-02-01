import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'analytics_service.dart';

/// Service for exporting anonymized clinical data to CSV format.
/// All exports are anonymized - no individual student identities are included.
class ClinicalExportService {
  
  /// Exports daily mood stats and risk distribution to CSV
  Future<bool> exportToCSV({
    List<DailyMoodStats>? dailyStats,
    RiskDistribution? riskDistribution,
    List<WeeklyTrend>? weeklyTrends,
  }) async {
    try {
      final buffer = StringBuffer();
      final dateFormat = DateFormat('yyyy-MM-dd');
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      
      // ===== HEADER =====
      buffer.writeln('SINO School Analytics Export');
      buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
      buffer.writeln('Data Type: Anonymized Aggregate Statistics');
      buffer.writeln('');
      
      // ===== RISK DISTRIBUTION =====
      if (riskDistribution != null) {
        buffer.writeln('=== CURRENT RISK DISTRIBUTION ===');
        buffer.writeln('Category,Count,Percentage');
        buffer.writeln('Positive,${riskDistribution.positive},${riskDistribution.positivePercent.toStringAsFixed(1)}%');
        buffer.writeln('Neutral,${riskDistribution.neutral},${riskDistribution.neutralPercent.toStringAsFixed(1)}%');
        buffer.writeln('Moderate Risk,${riskDistribution.moderateRisk},${riskDistribution.moderateRiskPercent.toStringAsFixed(1)}%');
        buffer.writeln('High Risk,${riskDistribution.highRisk},${riskDistribution.highRiskPercent.toStringAsFixed(1)}%');
        buffer.writeln('Total,${riskDistribution.total},100%');
        buffer.writeln('');
      }
      
      // ===== DAILY MOOD STATS =====
      if (dailyStats != null && dailyStats.isNotEmpty) {
        buffer.writeln('=== DAILY MOOD STATISTICS ===');
        buffer.writeln('Date,Entry Count,Avg Sentiment,Concern Count,Positive Count');
        
        for (final stat in dailyStats) {
          buffer.writeln([
            dateFormat.format(stat.date),
            stat.entryCount,
            stat.avgSentiment.toStringAsFixed(2),
            stat.concernCount,
            stat.positiveCount,
          ].join(','));
        }
        buffer.writeln('');
      }
      
      // ===== WEEKLY TRENDS =====
      if (weeklyTrends != null && weeklyTrends.isNotEmpty) {
        buffer.writeln('=== WEEKLY TRENDS ===');
        buffer.writeln('Week Starting,Active Users,Total Entries,Avg Sentiment,Sentiment Variance');
        
        for (final trend in weeklyTrends) {
          buffer.writeln([
            dateFormat.format(trend.weekStart),
            trend.activeUsers,
            trend.totalEntries,
            trend.avgSentiment.toStringAsFixed(2),
            trend.sentimentVariance.toStringAsFixed(2),
          ].join(','));
        }
        buffer.writeln('');
      }
      
      // ===== FOOTER =====
      buffer.writeln('');
      buffer.writeln('--- END OF REPORT ---');
      buffer.writeln('Note: All data is anonymized. No individual student identities are included.');
      
      // Save to file
      final csvContent = buffer.toString();
      
      if (kIsWeb) {
        // Web: Would trigger download via dart:html
        debugPrint('CSV Export (Web): Would trigger download');
        debugPrint(csvContent);
        return true;
      } else {
        // Mobile/Desktop: Save to documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/sino_report_$timestamp.csv');
        await file.writeAsString(csvContent);
        debugPrint('CSV exported to: ${file.path}');
        return true;
      }
    } catch (e) {
      debugPrint('Error exporting CSV: $e');
      return false;
    }
  }

  /// Generates a summary report string for display or email
  String generateSummaryReport({
    required RiskDistribution riskDistribution,
    required List<WeeklyTrend> weeklyTrends,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('📊 SINO Weekly Wellness Summary');
    buffer.writeln('================================');
    buffer.writeln('');
    
    // Risk Overview
    buffer.writeln('🎯 Student Population: ${riskDistribution.total} active users');
    buffer.writeln('');
    buffer.writeln('Risk Distribution:');
    buffer.writeln('  ✅ Positive: ${riskDistribution.positive} (${riskDistribution.positivePercent.toStringAsFixed(0)}%)');
    buffer.writeln('  🔵 Neutral: ${riskDistribution.neutral} (${riskDistribution.neutralPercent.toStringAsFixed(0)}%)');
    buffer.writeln('  ⚠️ Moderate: ${riskDistribution.moderateRisk} (${riskDistribution.moderateRiskPercent.toStringAsFixed(0)}%)');
    buffer.writeln('  🔴 High Risk: ${riskDistribution.highRisk} (${riskDistribution.highRiskPercent.toStringAsFixed(0)}%)');
    buffer.writeln('');
    
    // Trend
    if (weeklyTrends.length >= 2) {
      final current = weeklyTrends.last;
      final previous = weeklyTrends[weeklyTrends.length - 2];
      final change = current.avgSentiment - previous.avgSentiment;
      final trendEmoji = change > 0.05 ? '📈' : change < -0.05 ? '📉' : '➡️';
      
      buffer.writeln('Weekly Trend: $trendEmoji ${change > 0 ? '+' : ''}${(change * 100).toStringAsFixed(1)}%');
    }
    
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln('This report contains anonymized data only.');
    
    return buffer.toString();
  }
}
