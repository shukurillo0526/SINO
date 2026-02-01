import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../../controllers/language_controller.dart';
import 'timetable_screen.dart';
import 'todo_screen.dart';

class AcademicsScreen extends StatelessWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    
    // Premium Palette
    final gradientColors = [
      const Color(0xFFE8F3E8), // Calm Sage
      const Color(0xFFF0FDFC), // Light Blue
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          lang.isEnglish ? 'Academics' : '학업 관리',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D4A3E)),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.white.withOpacity(0.5)),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2D4A3E)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.isEnglish ? 'Manage your studies' : '학업을 관리하세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF2D4A3E).withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),
                _buildActionCard(
                  context,
                  title: lang.isEnglish ? 'Timetable' : '시간표',
                  subtitle: lang.isEnglish ? 'Check your schedule' : '오늘의 일정 확인',
                  icon: Icons.calendar_today,
                  color: const Color(0xFF2D4A3E),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TimetableScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionCard(
                  context,
                  title: lang.isEnglish ? 'Tasks' : '할 일',
                  subtitle: lang.isEnglish ? 'Track homework' : '숙제 및 과제 관리',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFFFFC75F),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TodoScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.8)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D4A3E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF2D4A3E).withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: color.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
