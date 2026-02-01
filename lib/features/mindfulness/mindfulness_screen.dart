import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/language_controller.dart';
import '../../core/language/strings.dart';
import '../../controllers/mindfulness_controller.dart';
import 'breathing_screen.dart';

class MindfulnessScreen extends StatelessWidget {
  const MindfulnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    final mindfulness = context.watch<MindfulnessController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.mindfulness(lang.current))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Audio Settings Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang.isEnglish ? 'Immersive Sounds' : '몰입형 사운드',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: mindfulness.isAudioEnabled,
                      onChanged: (val) => mindfulness.toggleAudio(val),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: mindfulness.sounds.map((sound) {
                      final isSelected = mindfulness.selectedSound?.id == sound.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: Icon(sound.icon, size: 18, color: isSelected ? Colors.white : theme.primaryColor),
                          label: Text(lang.isEnglish ? sound.nameEn : sound.nameKo),
                          selected: isSelected,
                          onSelected: (selected) {
                            mindfulness.selectSound(selected ? sound : null);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          _MindfulnessCard(
            title: AppStrings.breathing(lang.current),
            icon: Icons.air,
            color: Colors.cyan,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BreathingScreen()),
              );
            },
          ),
          _MindfulnessCard(
            title: AppStrings.questions(lang.current),
            icon: Icons.question_answer,
            color: Colors.indigo,
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BreathingScreen(showQuestions: true)),
              );
            },
          ),
          _MindfulnessCard(
            title: AppStrings.cloudFloat(lang.current),
            icon: Icons.cloud,
            color: Colors.lightBlueAccent,
            onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BreathingScreen(isCloudMeditation: true)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MindfulnessCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MindfulnessCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, color: color, size: 36),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.play_circle_fill, size: 32, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
