import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/academics_service.dart';
import '../../models/academics_models.dart';
import 'package:intl/intl.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  int _selectedDay = DateTime.now().weekday; // 1-7

  final List<String> _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final academicsService = context.watch<AcademicsService>();
    final scheduleForDay = academicsService.getScheduleForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddClassDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Day selector
          Container(
            height: 60,
            color: theme.colorScheme.surface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final dayIndex = index + 1;
                final isSelected = dayIndex == _selectedDay;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = dayIndex),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? theme.primaryColor : theme.dividerColor,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _dayNames[index].substring(0, 3),
                        style: TextStyle(
                          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Schedule list
          Expanded(
            child: scheduleForDay.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 64, color: theme.disabledColor),
                        const SizedBox(height: 16),
                        Text(
                          'No classes scheduled for ${_dayNames[_selectedDay - 1]}',
                          style: TextStyle(color: theme.disabledColor),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: scheduleForDay.length,
                    itemBuilder: (context, index) {
                      final entry = scheduleForDay[index];
                      return _ClassCard(
                        entry: entry,
                        onEdit: () => _showEditClassDialog(context, entry),
                        onDelete: () => _confirmDelete(context, entry),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddClassDialog(BuildContext context) {
    _showClassDialog(context);
  }

  void _showEditClassDialog(BuildContext context, ScheduleEntry entry) {
    _showClassDialog(context, entry: entry);
  }

  void _showClassDialog(BuildContext context, {ScheduleEntry? entry}) {
    final isEditing = entry != null;
    final subjectController = TextEditingController(text: entry?.subject ?? '');
    final teacherController = TextEditingController(text: entry?.teacher ?? '');
    final roomController = TextEditingController(text: entry?.room ?? '');
    
    TimeOfDay startTime = entry != null 
        ? TimeOfDay.fromDateTime(entry.startTime) 
        : const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = entry != null 
        ? TimeOfDay.fromDateTime(entry.endTime) 
        : const TimeOfDay(hour: 10, minute: 0);
    
    Color selectedColor = entry?.color ?? Colors.blue;
    int selectedDay = entry?.dayOfWeek ?? _selectedDay;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Class' : 'Add Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(labelText: 'Subject Name'),
                ),
                TextField(
                  controller: teacherController,
                  decoration: const InputDecoration(labelText: 'Teacher'),
                ),
                TextField(
                  controller: roomController,
                  decoration: const InputDecoration(labelText: 'Room'),
                ),
                const SizedBox(height: 16),
                
                // Day Selection
                DropdownButtonFormField<int>(
                  initialValue: selectedDay,
                  decoration: const InputDecoration(labelText: 'Day of Week'),
                  items: List.generate(7, (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text(_dayNames[index]),
                  )),
                  onChanged: (val) => setDialogState(() => selectedDay = val!),
                ),
                const SizedBox(height: 16),

                // Time Pickers
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(context: context, initialTime: startTime);
                          if (picked != null) setDialogState(() => startTime = picked);
                        },
                        child: Text('Start: ${startTime.format(context)}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(context: context, initialTime: endTime);
                          if (picked != null) setDialogState(() => endTime = picked);
                        },
                        child: Text('End: ${endTime.format(context)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Color Selection
                const Text('Choose Color'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal
                  ].map((color) => GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = color),
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 14,
                      child: selectedColor == color ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (subjectController.text.isEmpty) return;

                final now = DateTime.now();
                final startDateTime = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
                final endDateTime = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);

                final newEntry = ScheduleEntry(
                  id: isEditing ? entry.id : DateTime.now().millisecondsSinceEpoch.toString(),
                  subject: subjectController.text,
                  teacher: teacherController.text,
                  room: roomController.text,
                  startTime: startDateTime,
                  endTime: endDateTime,
                  dayOfWeek: selectedDay,
                  color: selectedColor,
                );

                final service = context.read<AcademicsService>();
                if (isEditing) {
                  service.updateScheduleEntry(newEntry);
                } else {
                  service.addScheduleEntry(newEntry);
                }
                
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save Changes' : 'Add Class'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ScheduleEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Remove ${entry.subject} from your schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AcademicsService>().deleteScheduleEntry(entry.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final ScheduleEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClassCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: entry.color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Color bar
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: entry.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.subject,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${timeFormat.format(entry.startTime)} - ${timeFormat.format(entry.endTime)}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 16, color: theme.disabledColor),
                        const SizedBox(width: 4),
                        Text(
                          entry.teacher,
                          style: TextStyle(color: theme.disabledColor),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.room_outlined, size: 16, color: theme.disabledColor),
                        const SizedBox(width: 4),
                        Text(
                          entry.room,
                          style: TextStyle(color: theme.disabledColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
