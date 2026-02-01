import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/language_controller.dart';
import '../core/language/strings.dart';
import 'account.dart';
import '../controllers/theme_controller.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _readAloud(BuildContext context, LanguageController lang) async {
    final tts = FlutterTts();
    await tts.setLanguage(lang.isEnglish ? 'en-US' : 'ko-KR');
    final welcome = AppStrings.welcome(lang.current);
    final services = [
      AppStrings.character(lang.current),
      AppStrings.games(lang.current),
      AppStrings.mindfulness(lang.current),
      AppStrings.mood(lang.current),
      AppStrings.academics(lang.current),
    ].join(', ');
    await tts.speak('$welcome. ${lang.isEnglish ? 'How can I help you today?' : '오늘 무엇을 도와드릴까요?'}');
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    final themeController = context.watch<ThemeController>();
    final isBigMode = themeController.isBigIconMode;

    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('lib/assets/sino_fox.png'),
              radius: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'SINO',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: isBigMode ? 40 : 30),
            onPressed: () {
               Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const AccountScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const _HomeDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.welcome(lang.current),
              style: TextStyle(
                fontSize: isBigMode ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: isBigMode ? 1 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isBigMode ? 2.0 : 1.0,
                children: [
                  _ServiceCard(
                    title: AppStrings.character(lang.current),
                    icon: Icons.chat_bubble_outline,
                    color: theme.colorScheme.primary,
                    route: '/character',
                    isBigMode: isBigMode,
                  ),
                  _ServiceCard(
                    title: AppStrings.games(lang.current),
                    icon: Icons.videogame_asset_outlined,
                    color: const Color(0xFFFF6584),
                    route: '/games',
                    isBigMode: isBigMode,
                  ),
                  _ServiceCard(
                    title: AppStrings.mindfulness(lang.current),
                    icon: Icons.self_improvement,
                    color: const Color(0xFF4ECDC4),
                    route: '/mindfulness',
                    isBigMode: isBigMode,
                  ),
                  _ServiceCard(
                    title: AppStrings.mood(lang.current),
                    icon: Icons.mood,
                    color: const Color(0xFFFFC75F),
                    route: '/mood',
                    isBigMode: isBigMode,
                  ),
                  _ServiceCard(
                    title: AppStrings.academics(lang.current),
                    icon: Icons.school_outlined,
                    color: theme.colorScheme.secondary, 
                    route: '/academics',
                    isFullWidth: true,
                    isBigMode: isBigMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _readAloud(context, lang),
        label: Text(lang.isEnglish ? 'Help' : '도움말'),
        icon: const Icon(Icons.volume_up),
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  final bool isFullWidth;
  final bool isBigMode;

  const _ServiceCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    this.isFullWidth = false,
    this.isBigMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: isBigMode 
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 48, color: color),
                ),
                const SizedBox(width: 24),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    final themeController = context.watch<ThemeController>();
    final isBigMode = themeController.isBigIconMode;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  radius: isBigMode ? 40 : 30,
                  child: Icon(Icons.person, size: isBigMode ? 45 : 35, color: Theme.of(context).primaryColor),
                ),
                SizedBox(height: isBigMode ? 16 : 12),
                Text(
                  'SINO Menu',
                  style: TextStyle(color: Colors.white, fontSize: isBigMode ? 28 : 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.chat_bubble_outline, size: isBigMode ? 32 : 24),
            title: Text(AppStrings.character(lang.current), style: TextStyle(fontSize: isBigMode ? 20 : 16)),
            onTap: () => Navigator.pushNamed(context, '/character'),
          ),
          ListTile(
            leading: Icon(Icons.videogame_asset_outlined, size: isBigMode ? 32 : 24),
            title: Text(AppStrings.games(lang.current), style: TextStyle(fontSize: isBigMode ? 20 : 16)),
            onTap: () => Navigator.pushNamed(context, '/games'),
          ),
          ListTile(
            leading: Icon(Icons.self_improvement, size: isBigMode ? 32 : 24),
            title: Text(AppStrings.mindfulness(lang.current), style: TextStyle(fontSize: isBigMode ? 20 : 16)),
            onTap: () => Navigator.pushNamed(context, '/mindfulness'),
          ),
          ListTile(
            leading: Icon(Icons.mood, size: isBigMode ? 32 : 24),
            title: Text(AppStrings.mood(lang.current), style: TextStyle(fontSize: isBigMode ? 20 : 16)),
            onTap: () => Navigator.pushNamed(context, '/mood'),
          ),
          ListTile(
            leading: Icon(Icons.school_outlined, size: isBigMode ? 32 : 24),
            title: Text(AppStrings.academics(lang.current), style: TextStyle(fontSize: isBigMode ? 20 : 16)),
            onTap: () => Navigator.pushNamed(context, '/academics'),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.settings, size: isBigMode ? 32 : 24),
            title: Text('Settings', style: TextStyle(fontSize: isBigMode ? 20 : 16)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, size: isBigMode ? 32 : 24),
            title: Text('Logout', style: TextStyle(fontSize: isBigMode ? 20 : 16)),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
