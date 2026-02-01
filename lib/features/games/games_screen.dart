import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../../controllers/language_controller.dart';
import 'stress_buster_screen.dart';
import 'quiz_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

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
          lang.isEnglish ? 'Games' : '미니게임',
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
                  lang.isEnglish ? 'Play & Relax' : '놀이와 휴식',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF2D4A3E).withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _buildGameCard(
                        context,
                        title: lang.isEnglish ? 'Stress Buster' : '스트레스 해소',
                        icon: Icons.bubble_chart,
                        color: const Color(0xFFFF6584),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StressBusterScreen()),
                        ),
                      ),
                      _buildGameCard(
                        context,
                        title: lang.isEnglish ? 'Emotion Quiz' : '감정 퀴즈',
                        icon: Icons.quiz,
                        color: const Color(0xFFFFC75F),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QuizScreen(
                            title: 'Emotion Quiz',
                            isPeerClash: false,
                          )),
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

  Widget _buildGameCard(BuildContext context, {
    required String title,
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
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.8)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 40, color: color),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D4A3E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
