import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/mood_controller.dart';
import '../../models/mood_models.dart';
import '../../core/language/strings.dart';
import 'package:intl/intl.dart';
import 'weekly_report_screen.dart';
import 'parent_dashboard_screen.dart';
import '../../services/voice_service.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    final moodController = context.watch<MoodController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.mood(lang.current)),
        actions: [
          IconButton(
            icon: const Icon(Icons.family_restroom),
            tooltip: 'Parent Dashboard',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ParentDashboardScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Weekly Report',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WeeklyReportScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.science_outlined),
            tooltip: 'Load Sample Data',
            onPressed: () async {
              await moodController.loadSampleData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sample mood data loaded!')),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Mood Card
          _CurrentMoodCard(
            latestEntry: moodController.latestEntry,
            lang: lang,
            onAddMood: () => _showMoodPicker(context),
          ),

          const SizedBox(height: 24),

          // Quick Insights
          _QuickInsightsCard(moodController: moodController, lang: lang),

          const SizedBox(height: 24),

          // Recent History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lang.isEnglish ? 'Recent Activity' : '최근 활동',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeeklyReportScreen()),
                ),
                child: Text(lang.isEnglish ? 'View Report' : '보고서 보기'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ...moodController.recentEntries.take(10).map((entry) => _MoodEntryCard(entry: entry)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMoodPicker(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showMoodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _MoodPickerSheet(),
    );
  }
}

class _CurrentMoodCard extends StatelessWidget {
  final MoodEntry? latestEntry;
  final LanguageController lang;
  final VoidCallback onAddMood;

  const _CurrentMoodCard({
    required this.latestEntry,
    required this.lang,
    required this.onAddMood,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (latestEntry == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.mood_outlined, size: 64, color: theme.disabledColor),
              const SizedBox(height: 16),
              Text(
                lang.isEnglish ? 'No mood logged yet' : '아직 기록이 없어요',
                style: TextStyle(fontSize: 18, color: theme.disabledColor),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onAddMood,
                icon: const Icon(Icons.add),
                label: Text(lang.isEnglish ? 'Log Your Mood' : '기분 기록하기'),
              ),
            ],
          ),
        ),
      );
    }

    final timeSince = DateTime.now().difference(latestEntry!.timestamp);
    final timeText = timeSince.inHours < 1
        ? '${timeSince.inMinutes}m ago'
        : timeSince.inHours < 24
            ? '${timeSince.inHours}h ago'
            : '${timeSince.inDays}d ago';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              lang.isEnglish ? 'Current Mood' : '현재 기분',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              latestEntry!.mood.emoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 8),
            Text(
              latestEntry!.mood.label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: latestEntry!.mood.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              timeText,
              style: TextStyle(color: theme.disabledColor),
            ),
            if (latestEntry!.context != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(latestEntry!.source.icon, size: 16, color: theme.disabledColor),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        latestEntry!.context!,
                        style: TextStyle(fontSize: 12, color: theme.disabledColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickInsightsCard extends StatelessWidget {
  final MoodController moodController;
  final LanguageController lang;

  const _QuickInsightsCard({
    required this.moodController,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final report = moodController.getWeeklyReport();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  lang.isEnglish ? 'This Week' : '이번 주',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: lang.isEnglish ? 'Average' : '평균',
                    value: report.averageSentiment >= 0 ? '😊' : '😔',
                    color: report.averageSentiment >= 0
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF9800),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: lang.isEnglish ? 'Trend' : '추세',
                    value: report.trend.emoji,
                    color: report.trend.color,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: lang.isEnglish ? 'Concerns' : '우려',
                    value: '${report.concernCount}',
                    color: report.concernCount > 2
                        ? Colors.red
                        : theme.disabledColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
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
            fontSize: 24,
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

class _MoodEntryCard extends StatelessWidget {
  final MoodEntry entry;

  const _MoodEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('MMM d, h:mm a').format(entry.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Text(entry.mood.emoji, style: const TextStyle(fontSize: 30)),
        title: Text(entry.mood.label),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedDate),
            if (entry.context != null)
              Text(
                entry.context!,
                style: TextStyle(fontSize: 12, color: theme.disabledColor),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: entry.source == MoodSource.manual
                ? theme.primaryColor.withOpacity(0.1)
                : theme.disabledColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(entry.source.icon, size: 14, color: theme.disabledColor),
              const SizedBox(width: 4),
              Text(
                entry.source.label,
                style: TextStyle(fontSize: 10, color: theme.disabledColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodPickerSheet extends StatefulWidget {
  const _MoodPickerSheet();

  @override
  State<_MoodPickerSheet> createState() => _MoodPickerSheetState();
}

class _MoodPickerSheetState extends State<_MoodPickerSheet> {
  MoodLevel? _selectedMood;
  final _contextController = TextEditingController();
  final VoiceService _voiceService = VoiceService();
  bool _isRecording = false;
  String? _recordedPath;

  @override
  void dispose() {
    _contextController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _voiceService.stopRecording();
      setState(() {
        _isRecording = false;
        _recordedPath = path;
      });
    } else {
      await _voiceService.startRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            lang.isEnglish ? 'How are you feeling?' : '기분이 어때요?',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: MoodLevel.values.map((mood) {
              final isSelected = _selectedMood == mood;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = mood),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? mood.color.withOpacity(0.2)
                        : theme.colorScheme.surface,
                    border: Border.all(
                      color: isSelected ? mood.color : theme.dividerColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 4),
                      Text(
                        mood.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _contextController,
            decoration: InputDecoration(
              hintText: lang.isEnglish ? 'Add a note (optional)' : '메모 추가 (선택사항)',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: _toggleRecording,
                icon: Icon(
                  _isRecording ? Icons.stop_circle : Icons.mic,
                  color: _isRecording ? Colors.red : theme.primaryColor,
                ),
                tooltip: _isRecording ? 'Stop Recording' : 'Record Voice Note',
              ),
            ),
            maxLines: 2,
          ),
          if (_recordedPath != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.mic, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  lang.isEnglish ? 'Voice Note Attached' : '음성 메모 첨부됨',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => setState(() => _recordedPath = null),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedMood == null && !_isRecording // Disable if recording or no mood
                  ? null
                  : () async {
                      if (_isRecording) {
                        await _toggleRecording(); // Auto stop if saving
                      }
                      
                      if (_selectedMood != null) {
                        String contextText = _contextController.text.trim();
                        
                        if (_recordedPath != null) {
                           await context.read<MoodController>().addVoiceMood(
                             _selectedMood!,
                             context: contextText.isEmpty ? null : contextText,
                             audioPath: _recordedPath,
                           );
                        } else {
                           await context.read<MoodController>().addManualMood(
                             _selectedMood!,
                             context: contextText.isEmpty ? null : contextText,
                           );
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
              child: Text(lang.isEnglish ? 'Save' : '저장'),
            ),
          ),
        ],
      ),
    );
  }
}
