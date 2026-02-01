import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // For ImageFilter

import '../../controllers/language_controller.dart';
import '../games/games_screen.dart';
import '../mindfulness/mindfulness_screen.dart';
import '../academics/academics_screen.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Premium Palette
    final primaryColor = const Color(0xFF2D4A3E);
    final gradientColors = [
      const Color(0xFFE8F3E8), // Calm Sage
      const Color(0xFFF0FDFC), // Light Blue
    ];

    final lang = context.watch<LanguageController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
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
                const Text(
                  'Explore',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D4A3E),
                  ),
                ),
                Text(
                  lang.isEnglish ? 'Tools for your mind & grades' : '마음과 성적을 위한 도구들',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF2D4A3E).withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    children: [
                      _buildGlassCard(
                        context,
                        title: lang.isEnglish ? 'Mindfulness' : '마음챙김',
                        subtitle: lang.isEnglish ? 'Meditation & Breathing' : '명상 및 호흡',
                        icon: Icons.self_improvement,
                        color: const Color(0xFF4ECDC4),
                        onTap: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => const MindfulnessScreen())
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildGlassCard(
                        context,
                        title: lang.isEnglish ? 'Games' : '미니게임',
                        subtitle: lang.isEnglish ? 'Stress busters & Fun' : '스트레스 해소 및 재미',
                        icon: Icons.videogame_asset_outlined,
                        color: const Color(0xFFFF6584),
                        onTap: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => const GamesScreen())
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildGlassCard(
                        context,
                        title: lang.isEnglish ? 'Academics' : '학업',
                        subtitle: lang.isEnglish ? 'Tasks & Timetables' : '할 일 및 시간표',
                        icon: Icons.school_outlined,
                        color: const Color(0xFF2D4A3E),
                        onTap: () => Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => const AcademicsScreen())
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, {
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
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
