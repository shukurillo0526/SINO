import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/mood_controller.dart';
import '../../controllers/consent_controller.dart';
import '../../models/mood_models.dart';
import '../../services/crisis_service.dart';
// fl_chart import removed
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
// AcademicsService import removed (unused)
import '../../services/clinical_export_service.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  bool _isAuthorized = false;
  final _pinController = TextEditingController();
  String? _error;

  void _verifyPin() {
    // For prototype, PIN is hardcoded to 1234
    if (_pinController.text == '1234') {
      setState(() {
        _isAuthorized = true;
        _error = null;
      });
    } else {
      setState(() {
        _error = 'Incorrect PIN. Try 1234 for demo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    
    if (!_isAuthorized) {
      return _buildPinEntry(lang);
    }

    return _buildDashboard(context, lang);
  }

  Widget _buildPinEntry(LanguageController lang) {
    return Scaffold(
      appBar: AppBar(title: Text(lang.isEnglish ? 'Parent Access' : '보호자 접속')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              lang.isEnglish ? 'Enter Parent PIN' : '보호자 비밀번호를 입력하세요',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              lang.isEnglish 
                ? 'Your student\'s specific messages are hidden for privacy.' 
                : '학생의 구체적인 메시지는 개인정보 보호를 위해 숨겨집니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                hintText: 'PIN',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              onSubmitted: (_) => _verifyPin(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifyPin,
                child: Text(lang.isEnglish ? 'Unlock Dashboard' : '대시보드 열기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, LanguageController lang) {
    final moodController = context.watch<MoodController>();
    // Unused variables removed

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.isEnglish ? 'Parent Dashboard' : '보호자 대시보드'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => setState(() => _isAuthorized = false),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Research Data',
            onPressed: () => _showExportDialog(context, lang),
          ),
        ],
      ),
      body: _buildDashboardBody(context, lang),
    );
  }

  Widget _buildDashboardBody(BuildContext context, LanguageController lang) {
    final moodController = context.watch<MoodController>();
    final consent = context.watch<ConsentController>();
    final theme = Theme.of(context);
    final report = moodController.getWeeklyReport();

    if (!consent.shareMood) {
      return _buildPrivacyBlocked(lang, Icons.mood_bad, 
        lang.isEnglish ? 'Mood Sharing Disabled' : '기분 공유 비활성화됨',
        lang.isEnglish 
          ? 'The student has chosen not to share their emotional trends.' 
          : '학생이 감정 변화를 공유하지 않기로 선택했습니다.');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Crisis Alerts (Persistent & Visible - Safety override)
        if (moodController.crisisAlerts.isNotEmpty) ...[
          _CrisisAlertBanner(alerts: moodController.crisisAlerts, lang: lang),
          const SizedBox(height: 16),
        ],

          // Risk Indicator
          _RiskIndicatorCard(report: report, lang: lang),
          
          const SizedBox(height: 24),

          // Aggregated Trend
          Text(
            lang.isEnglish ? 'Weekly Overview' : '주간 개요',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
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
                      _StatBox(
                        label: lang.isEnglish ? 'Average' : '평균',
                        value: '${(report.averageSentiment * 100).round()}%',
                        color: report.averageSentiment >= 0 ? Colors.green : Colors.orange,
                      ),
                      _StatBox(
                        label: lang.isEnglish ? 'Trend' : '추세',
                        value: report.trend.label,
                        color: report.trend.color,
                      ),
                       _StatBox(
                        label: lang.isEnglish ? 'Flagged' : '감지됨',
                        value: '${report.concernCount}',
                        color: report.concernCount > 0 ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Activity Summary (No details)
          Text(
            lang.isEnglish ? 'Activity Support' : '활동 지원',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...MoodSource.values.map((source) {
            final avgBySource = moodController.getAverageBySource();
            final score = avgBySource[source];
            if (score == null) return const SizedBox.shrink();

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(source.icon, color: theme.primaryColor),
                title: Text(source.label),
                subtitle: Text(
                  score > 0.3 
                    ? (lang.isEnglish ? 'Doing well here!' : '잘하고 있어요!')
                    : score < -0.3
                      ? (lang.isEnglish ? 'Might need some support.' : '지원이 필요할 수 있습니다.')
                      : (lang.isEnglish ? 'Stable interaction.' : '안정적입니다.'),
                ),
                trailing: Text(
                  score >= 0 ? '👍' : '⚠️',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Privacy Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.privacy_tip_outlined, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lang.isEnglish 
                      ? 'Detailed chat logs and specific task names are private to the student.' 
                      : '상세 채팅 로그와 구체적인 일정 명칭은 학생만의 비밀입니다.',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
    );
  }

  Widget _buildPrivacyBlocked(LanguageController lang, IconData icon, String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, LanguageController lang) {
    final moodController = context.read<MoodController>();
    // exportService not needed here, method is static or unused
    // final exportService = ClinicalExportService();
    
    // Generate summary report for parent view
    final report = moodController.getWeeklyReport();
    final csvData = '''
SINO Parent Dashboard Export
Generated: ${DateTime.now().toIso8601String()}

=== WEEKLY SUMMARY ===
Average Sentiment: ${(report.averageSentiment * 100).round()}%
Trend: ${report.trend.name}
Concern Count: ${report.concernCount}

=== ACTIVITY BREAKDOWN ===
${moodController.getAverageBySource().entries.map((e) => '${e.key.label}: ${(e.value * 100).round()}%').join('\n')}

=== INSIGHTS ===
${report.insights.join('\n')}

---
Note: Specific chat content is not included for privacy.
''';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.isEnglish ? 'Research Data Export' : '연구 데이터 내보내기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.isEnglish ? 'Copy this data for your records:' : '기록을 위해 데이터를 복사하세요:'),
            const SizedBox(height: 12),
            Container(
              height: 200,
              width: double.maxFinite,
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: SingleChildScrollView(
                child: SelectableText(csvData, style: const TextStyle(fontFamily: 'monospace', fontSize: 10)),
              ),
            ),
          ],
        ),
        actions: [
           TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.isEnglish ? 'Close' : '닫기'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvData));
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(lang.isEnglish ? 'Copied to clipboard!' : '클립보드에 복사되었습니다!')),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.copy),
            label: Text(lang.isEnglish ? 'Copy to Clipboard' : '복사하기'),
          ),
        ],
      ),
    );
  }
}

class _CrisisAlertBanner extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;
  final LanguageController lang;

  const _CrisisAlertBanner({required this.alerts, required this.lang});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    
    final latestAlert = alerts.last;
    // final riskLevel = RiskLevel.values[latestAlert['level']]; // Unused
    final timestamp = DateTime.parse(latestAlert['timestamp']);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lang.isEnglish ? 'SAFETY ALERT' : '안전 경고',
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 18, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                DateFormat('HH:mm').format(timestamp),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lang.isEnglish 
              ? 'Potentially harmful language was detected.' 
              : '위험할 수 있는 언어가 감지되었습니다.',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            lang.isEnglish 
              ? 'SINO has provided resources. Please check in with them.' 
              : 'SINO가 학생에게 도움 정보를 제공했습니다. 상태를 확인해 주세요.',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '"${latestAlert['context']}"',
              style: const TextStyle(
                color: Colors.white, 
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskIndicatorCard extends StatelessWidget {
  final WeeklyMoodReport report;
  final LanguageController lang;

  const _RiskIndicatorCard({required this.report, required this.lang});

  @override
  Widget build(BuildContext context) {
    final bool isHighRisk = report.averageSentiment < -0.4 || report.concernCount > 4;
    final bool isMediumRisk = report.averageSentiment < -0.1 || report.concernCount > 1;

    Color statusColor = Colors.green;
    String statusText = lang.isEnglish ? 'Stable' : '안정';
    String statusDesc = lang.isEnglish 
      ? 'No immediate concerns detected.' 
      : '현재 감지된 즉각적인 우려 사항이 없습니다.';

    if (isHighRisk) {
      statusColor = Colors.red;
      statusText = lang.isEnglish ? 'Concern Detected' : '우려 감지됨';
      statusDesc = lang.isEnglish 
        ? 'Multiple negative patterns detected. Consider checking in.' 
        : '여러 부정적인 패턴이 감지되었습니다. 대화를 고려해보세요.';
    } else if (isMediumRisk) {
      statusColor = Colors.orange;
      statusText = lang.isEnglish ? 'Monitoring' : '관찰 필요';
      statusDesc = lang.isEnglish 
        ? 'Some stress spikes detected this week.' 
        : '이번 주에 몇 차례 스트레스 수치가 상승했습니다.';
    }

    return Card(
      elevation: 0,
      color: statusColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      lang.isEnglish ? 'Emotional Health Status' : '정서 평온 상태',
                      style: TextStyle(color: statusColor.withOpacity(0.8)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              statusDesc,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
