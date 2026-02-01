import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';
import '../controllers/language_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final lang = context.watch<LanguageController>();

    return Scaffold(
      appBar: AppBar(title: Text(lang.isEnglish ? 'Settings' : '설정')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(lang.isEnglish ? 'Dark Mode' : '다크 모드'),
            subtitle: Text(lang.isEnglish ? 'Enable dark theme' : '어두운 테마 사용'),
            value: themeController.isDarkMode,
            onChanged: (bool value) {
              themeController.toggleTheme(value);
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          SwitchListTile(
            title: Text(lang.isEnglish ? 'Big Icon Mode' : '큰 아이콘 모드'),
            subtitle: Text(lang.isEnglish ? 'Simplify UI for children' : '아이들을 위해 UI 단순화'),
            value: themeController.isBigIconMode,
            onChanged: (bool value) {
              themeController.toggleBigIconMode(value);
            },
            secondary: const Icon(Icons.grid_view),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text(lang.isEnglish ? 'Privacy & Consent' : '개인정보 및 동의'),
            subtitle: Text(lang.isEnglish ? 'Manage your data' : '데이터 관리'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/privacy'),
          ),
          const Divider(),
          ListTile(
              leading: const Icon(Icons.language),
              title: Text(lang.isEnglish ? 'Language' : '언어'),
              subtitle: Text(lang.isEnglish ? 'English' : '한국어'),
              trailing: Switch(
                  value: !lang.isEnglish, // Toggle is checking if Korean
                  onChanged: (_) => lang.toggle(),
                  activeTrackColor: Colors.blueAccent,
                  activeThumbColor: Colors.white,
              ),
              onTap: lang.toggle,
          ),
        ],
      ),
    );
  }
}
