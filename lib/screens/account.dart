import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/supabase_auth_service.dart';
import '../models/user_model.dart';
import '../controllers/language_controller.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  
  Future<void> _pickImage(BuildContext context) async {
    // Avatar update not currently supported in SupabaseAuthService MVP
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Avatar update not yet implemented.")));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<SupabaseAuthService>();
    final lang = context.watch<LanguageController>();

    return Scaffold(
      appBar: AppBar(title: Text(lang.isEnglish ? 'Account' : '계정')),
      body: StreamBuilder<User?>(
        stream: auth.currentUser,
        builder: (context, snapshot) {
          final user = snapshot.data;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: (user != null && !user.isGuest) ? () => _pickImage(context) : null,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: (user?.photoUrl != null)
                              ? NetworkImage(user!.photoUrl!) // Changed to NetworkImage for Supabase
                              : null,
                          child: (user?.photoUrl == null)
                              ? const Icon(Icons.person, size: 60, color: Colors.white)
                              : null,
                        ),
                        if (user != null && !user.isGuest)
                            Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                            ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                if (user != null) ...[
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.role,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ] else ...[
                  Text(
                    lang.isEnglish ? "Guest / Loading..." : "게스트 / 로딩중...",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                         Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    },
                    child: Text(lang.isEnglish ? "Sign In" : "로그인"),
                  ),
                ],

                const SizedBox(height: 40),
                
                ListTile(
                  leading: const Icon(Icons.star),
                  title: Text(lang.isEnglish ? 'Rewards' : '리워드'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.pushNamed(context, '/rewards'),
                ),
                
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(lang.isEnglish ? 'About' : '앱 정보'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.pushNamed(context, '/about'),
                ),

                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(lang.isEnglish ? 'Settings' : '설정'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
                
                const Divider(),

                if (user != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: SizedBox(
                       width: double.infinity,
                       child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.logout),
                          label: Text(lang.isEnglish ? 'Logout' : '로그아웃'),
                          onPressed: () async {
                              await auth.signOut();
                              if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                          },
                       ),
                    ),
                  ),
              ],
            ),
          );
        }
      ),
    );
  }
}
