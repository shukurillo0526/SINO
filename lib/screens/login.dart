import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_auth_service.dart';
import '../controllers/language_controller.dart';
import '../core/language/strings.dart';
import '../widgets/interactive_ibn_sina.dart';
import '../features/b2b/b2b_dashboard_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  String? _errorMessage;
  Offset _mousePos = Offset.zero;
  StreamSubscription? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for auth changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<SupabaseAuthService>();
      _authSubscription = auth.currentUser.listen((user) {
        if (user != null && mounted) {
           Navigator.pushReplacementNamed(context, '/home');
        }
      });
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleKakaoLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = context.read<SupabaseAuthService>();
      await auth.signInWithKakao();
      // Navigation handled by stream listener
    } catch (e) {
      debugPrint("Login error: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Login failed: $e";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<SupabaseAuthService>();
      await auth.signInAsGuest();
      // Navigation handled by stream listener
    } catch (e) {
      debugPrint("Guest login error: $e");
      if (mounted) {
         setState(() {
           _isLoading = false;
           _errorMessage = "Guest login failed: $e";
         });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: MouseRegion(
        onHover: (event) {
          setState(() {
            _mousePos = event.position;
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: -50,
              left: 0,
              right: 0,
              top: 50,
              child: InteractiveIbnSina(mousePosition: _mousePos),
            ),
            
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lang.isEnglish ? 'Welcome Back!' : '환영합니다!',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 20),
                          color: Colors.red.withOpacity(0.1),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleKakaoLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFEE500), // Kakao Yellow
                            foregroundColor: const Color(0xFF191919), // Kakao Text Black
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.chat_bubble),
                          label: _isLoading 
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : Text(
                                lang.isEnglish ? 'Sign in with Kakao' : '카카오 로그인',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                       SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _handleGuestLogin,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[800],
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            lang.isEnglish ? "Continue as Guest" : "게스트로 계속하기",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
        
                      TextButton.icon(
                        onPressed: lang.toggle,
                        icon: const Icon(Icons.language, size: 18),
                        label: Text(lang.isEnglish ? '한국어로 보기 🇰🇷' : 'View in English 🇺🇸'),
                      ),
                      
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => const B2BDashboardScreen()),
                          );
                        },
                        child: Text(
                          'School Admin Access',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
