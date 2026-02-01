import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui'; 

import '../../controllers/language_controller.dart';
import '../../services/companion_service.dart';
import '../../controllers/mood_controller.dart';

// Screens
import '../character/character_screen.dart';
import '../resources/resources_screen.dart';
import '../../screens/account.dart'; 
import '../../services/academics_service.dart';
import '../../services/gemini_service.dart'; // For Daily Quote
import '../../models/academics_models.dart'; // For TodoItem 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeView(),
    const CharacterScreen(),
    const ResourcesScreen(),
    const AccountScreen(), // Using AccountScreen as Profile tab
  ];

  @override
  Widget build(BuildContext context) {
    // Premium Palette for Nav Bar
    final primaryColor = const Color(0xFF2D4A3E); 
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              selectedItemColor: primaryColor,
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.white.withOpacity(0.9), // Glassy look
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
                BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Explore'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HOME VIEW (BENTO GRID)
// ---------------------------------------------------------------------------

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF2D4A3E);
    final surfaceColor = const Color(0xFFE8F3E8);
    
    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, primaryColor),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: StaggeredGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 1,
                        child: _buildWelcomeCard(context),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1,
                        child: _buildMoodCard(context),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1,
                        child: _buildQuickActionCard(
                          context, 
                          title: 'Breathe', 
                          icon: Icons.air, 
                          color: const Color(0xFF4ECDC4),
                          onTap: () => Navigator.pushNamed(context, '/mindfulness'),
                        ),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1,
                        child: _buildQuickActionCard(
                          context, 
                          title: 'Play', 
                          icon: Icons.videogame_asset_outlined, 
                          color: const Color(0xFFFF6584),
                          onTap: () => Navigator.pushNamed(context, '/games'),
                        ),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1,
                        child: _buildQuickActionCard(
                          context, 
                          title: 'Study', 
                          icon: Icons.school_outlined, 
                          color: const Color(0xFFFFC75F),
                          onTap: () => Navigator.pushNamed(context, '/academics'),
                        ),
                      ),
                      StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: 1,
                        child: _buildTaskSummaryCard(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color color) {
    final lang = context.watch<LanguageController>();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang.isEnglish ? 'Welcome back,' : '환영합니다,',
                style: TextStyle(fontSize: 16, color: color.withOpacity(0.7)),
              ),
              const Text(
                'Student', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D4A3E)),
              ),
              const SizedBox(height: 8),
              FutureBuilder<String>(
                future: GeminiService().getDailyQuote(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  return Text(
                    '"${snapshot.data}"',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                      color: color.withOpacity(0.6),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final companion = context.watch<CompanionService>().activeCompanion;
    final name = companion?.name ?? 'SINO';
    final role = companion?.role.name ?? 'Buddy';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2D4A3E), const Color(0xFF4A7A6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D4A3E).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$name is here.',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your $role is ready to talk.',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context) {
    final moodController = context.watch<MoodController>();
    final history = moodController.recentEntries;

    // Convert history to FlSpots for the last 7 entries
    final spots = history.asMap().entries.map((e) {
      // Map sentiment (-1 to 1) to chart range (0 to 5)
      final yValue = (e.value.sentimentScore + 1) * 2.5; 
      return FlSpot(e.key.toDouble(), yValue);
    }).toList();
    
    // Fallback if empty
    final displaySpots = spots.isNotEmpty 
      ? spots 
      : const [FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3), FlSpot(3, 3)];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mood', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          SizedBox(
            height: 80,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: displaySpots,
                    isCurved: true,
                    color: const Color(0xFFFF9E9E),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFFF9E9E).withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSummaryCard(BuildContext context) {
    final academics = context.watch<AcademicsService>();
    final todos = academics.incompleteTodos.take(3).toList(); // Show top 3
    final doneCount = academics.completedTodos.length;
    final totalCount = academics.todos.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('$doneCount/$totalCount', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          if (todos.isEmpty)
            const Text("No pending tasks!", style: TextStyle(color: Colors.grey, fontSize: 12))
          else
            ...todos.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildTaskItem(t.title, t.isCompleted),
            )),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String title, bool isDone) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle : Icons.circle_outlined,
          color: isDone ? const Color(0xFF2D4A3E) : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? Colors.grey : Colors.black87,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
