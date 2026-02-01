import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/language_controller.dart';
import '../../core/language/strings.dart';
import 'quiz_screen.dart';
import 'stress_buster_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.games(lang.current))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GameCard(
            title: lang.isEnglish ? 'Stress Buster' : '스트레스 해소',
            subtitle: lang.isEnglish ? 'Pop the stress clouds away!' : '톡톡! 스트레스 구름 터뜨리기',
            icon: Icons.cloud_queue,
            color: Colors.lightBlue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StressBusterScreen()),
              );
            },
          ),
          _GameCard(
            title: AppStrings.studyDrill(lang.current),
            subtitle: lang.isEnglish ? 'Quick subject quizzes with Cena' : 'Cena와 함께하는 스피드 퀴즈!',
            icon: Icons.quiz,
            color: Colors.blueAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    title: AppStrings.studyDrill(lang.current),
                    isPeerClash: false,
                  ),
                ),
              );
            },
          ),
          _GameCard(
            title: AppStrings.peerClash(lang.current),
            subtitle: lang.isEnglish ? '1v1 quiz duel with classmates' : '친구들과 1:1 퀴즈 대결',
            icon: Icons.people,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    title: AppStrings.peerClash(lang.current),
                    isPeerClash: true,
                  ),
                ),
              );
            },
          ),
          _GameCard(
            title: AppStrings.shortReel(lang.current),
            subtitle: lang.isEnglish ? 'Funny & relaxing clips' : '웃음 가득 힐링 영상',
            icon: Icons.movie_filter,
            color: Colors.purple,
            onTap: () => Navigator.pushNamed(context, '/reels'),
          ),
          _GameCard(
            title: AppStrings.bossFight(lang.current),
            subtitle: lang.isEnglish ? 'Slay the dragon with box breathing' : '호흡으로 드래곤 물리치기',
            icon: Icons.sports_martial_arts,
            color: Colors.redAccent,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(lang.isEnglish ? 'Coming Soon!' : '곧 만나요!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
