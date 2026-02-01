import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/language_controller.dart';
import '../../core/language/strings.dart';
import '../../services/academics_service.dart';
import '../../models/academics_models.dart';
import 'timetable_screen.dart';
import 'todo_screen.dart';
import 'study_help_screen.dart';

class AcademicsScreen extends StatelessWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    final theme = Theme.of(context);
    final academicsService = context.watch<AcademicsService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.academics(lang.current)),
        actions: [
          IconButton(
            icon: const Icon(Icons.science_outlined),
            tooltip: 'Load Sample Data',
            onPressed: () async {
              await academicsService.loadSampleData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sample data loaded!')),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.assignment_outlined,
                  label: lang.isEnglish ? 'Active Tasks' : '활성 작업',
                  value: '${academicsService.incompleteTodos.length}',
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.warning_amber_outlined,
                  label: lang.isEnglish ? 'Overdue' : '기한 초과',
                  value: '${academicsService.getOverdueTodos().length}',
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Main Features
          _FeatureCard(
            icon: Icons.calendar_today,
            title: lang.isEnglish ? 'Timetable' : '시간표',
            subtitle: lang.isEnglish ? 'View your class schedule' : '수업 일정 보기',
            color: const Color(0xFF6C63FF),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TimetableScreen()),
            ),
          ),

          const SizedBox(height: 12),

          _FeatureCard(
            icon: Icons.checklist,
            title: lang.isEnglish ? 'To-Do List' : '할 일 목록',
            subtitle: lang.isEnglish 
              ? '${academicsService.incompleteTodos.length} tasks remaining'
              : '${academicsService.incompleteTodos.length}개 작업 남음',
            color: theme.primaryColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TodoScreen()),
            ),
          ),

          const SizedBox(height: 12),

          _FeatureCard(
            icon: Icons.school_outlined,
            title: lang.isEnglish ? 'Study Help' : '학습 도움',
            subtitle: lang.isEnglish ? 'Get AI-powered explanations' : 'AI 기반 설명 받기',
            color: const Color(0xFF4ECDC4),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudyHelpScreen()),
            ),
          ),

          const SizedBox(height: 24),

          // Upcoming Tasks Preview
          if (academicsService.incompleteTodos.isNotEmpty) ...[
            Text(
              lang.isEnglish ? 'Upcoming Tasks' : '다가오는 작업',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...academicsService.incompleteTodos.take(3).map((todo) => 
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: todo.priority.color.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: todo.priority.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (todo.dueDate != null)
                            Text(
                              'Due: ${todo.dueDate!.month}/${todo.dueDate!.day}',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.disabledColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: theme.disabledColor),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TodoScreen()),
              ),
              child: Text(lang.isEnglish ? 'View All Tasks' : '모든 작업 보기'),
            ),
          ],

          const SizedBox(height: 32),

          // Export/Import Section
          Text(
            lang.isEnglish ? 'Data Backup & Portability' : '데이터 백업 및 이동',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                   Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final data = academicsService.exportData();
                            _showExportDialog(context, data);
                          },
                          icon: const Icon(Icons.download),
                          label: Text(lang.isEnglish ? 'Export Code' : '코드 내보내기'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showImportDialog(context),
                          icon: const Icon(Icons.upload),
                          label: Text(lang.isEnglish ? 'Import Code' : '코드 가져오기'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.isEnglish 
                      ? 'Copy your schedule code to move it to another device.' 
                      : '다른 기기로 이동하려면 시간표 코드를 복사하세요.',
                    style: TextStyle(fontSize: 12, color: theme.disabledColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Schedule Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Copy this code to backup your data:'),
            const SizedBox(height: 12),
            SelectableText(
              data,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                backgroundColor: Color(0xFFEEEEEE),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Schedule'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Paste schedule code here...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<AcademicsService>().importData(controller.text);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Import successful!' : 'Invalid code. Please try again.'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.disabledColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.disabledColor),
          ],
        ),
      ),
    );
  }
}
