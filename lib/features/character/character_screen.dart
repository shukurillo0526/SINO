import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui'; // For ImageFilter

import '../../services/gemini_service.dart';
import '../../services/sentiment_service.dart';
import '../../services/crisis_service.dart';
import '../../services/companion_service.dart';
import '../../controllers/mood_controller.dart';
import '../../models/mood_models.dart';
import '../../controllers/language_controller.dart';
import '../crisis/crisis_resources_screen.dart';
import '../rewards/rewards_shop_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  String _response = '';
  bool _isVoiceEnabled = false;

  // Typing Analysis
  final List<DateTime> _keyTimes = [];
  String _typingStatus = 'normal';

  // Lottie State
  String _lottieAsset = 'lib/assets/lottie/companion_idle.json';

  @override
  void initState() {
    super.initState();
    _initTts();
    _controller.addListener(_onTextChanged);
    
    // Initial fetch of companion (load will happen in main/provider usually)
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<CompanionService>().loadCompanions();
    });
  }

  void _onTextChanged() {
    if (_controller.text.isEmpty) {
      _keyTimes.clear();
      return;
    }
    _keyTimes.add(DateTime.now());
    if (_keyTimes.length > 20) _keyTimes.removeAt(0);
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    if (!_isVoiceEnabled) return;
    
    final lang = context.read<LanguageController>();
    if (lang.isEnglish) {
      await _tts.setLanguage('en-US');
    } else {
      await _tts.setLanguage('ko-KR');
    }
    
    await _tts.speak(text);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = context.watch<LanguageController>();
    final companion = context.watch<CompanionService>().activeCompanion;
    final name = companion?.name ?? 'SINO';

    if (_response.isEmpty) {
      _response = lang.isEnglish
          ? 'Hi! I’m $name 😊 How are you feeling today?'
          : '안녕! 난 $name야 😊 오늘 기분은 어때?';
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final lang = context.read<LanguageController>();
    final geminiService = GeminiService();
    final companion = context.read<CompanionService>().activeCompanion;

    setState(() {
      _response = lang.isEnglish ? 'Thinking... 💭' : '생각 중이야... 💭';
    });

    // Crisis Check
    final risk = CrisisService.analyzeForCrisis(message);
    if (risk != null) {
      if (mounted) {
        context.read<MoodController>().addCrisisAlert(risk, message);
      }
      final safetyInfo = CrisisService.getSafetyInfo(risk, lang.isEnglish);
      setState(() => _response = safetyInfo.message);
      _speak(_response);
      if (risk == RiskLevel.high && mounted) _showCrisisDialog(context, safetyInfo);
      return;
    }

    try {
      final aiResponse = await geminiService.getChatResponse(
        message, 
        companion: companion
      );
      
      if (!mounted) return;
      
      setState(() {
        _response = aiResponse;
      });
      
      _speak(_response);
      
      // Log mood
      final sentimentScore = SentimentService.analyzeSentiment(message);
      if (mounted) {
        await context.read<MoodController>().addMoodFromService(
          MoodSource.character,
          sentimentScore,
          context: "Chat: ${message.substring(0, message.length.clamp(0, 20))}...",
          metadata: {'isAutoLog': true},
        );
      }
      
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _response = lang.isEnglish
            ? "I'm having a little trouble connecting. Try again? 🦊"
            : "연결에 문제가 있어요. 다시 시도해 줄래? 🦊";
      });
    }
  }

  void _showCrisisDialog(BuildContext context, CrisisResponse safetyInfo) {
    final lang = context.read<LanguageController>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(lang.isEnglish ? 'SINO is here for you' : 'SINO가 함께할게'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(safetyInfo.message),
            if (safetyInfo.actionLabel != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (safetyInfo.actionUrl != null) {
                      final Uri url = Uri.parse(safetyInfo.actionUrl!);
                      if (await canLaunchUrl(url)) await launchUrl(url);
                    }
                  },
                  icon: const Icon(Icons.phone),
                  label: Text(safetyInfo.actionLabel!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ]
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.isEnglish ? 'Maybe later' : '나중에'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CrisisResourcesScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200]),
            child: Text(lang.isEnglish ? 'See More Resources' : '더 많은 도움 정보'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    final companion = context.watch<CompanionService>().activeCompanion;
    final name = companion?.name ?? 'SINO';
    
    // Dynamic background based on active status/mood (could be expanded)
    // Using simple gradients for now
    final gradientColors = [
      const Color(0xFFE8F3E8), // Calm Sage
      const Color(0xFFF0FDFC), // Light Blue
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D4A3E))),
        backgroundColor: Colors.white.withOpacity(0.5),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF2D4A3E)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RewardsShopScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF2D4A3E)),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 60),
            
            // Companion Avatar Area (Lottie)
            Expanded(
              flex: 4,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 250,
                      width: 250,
                      child: Lottie.asset(
                        _lottieAsset,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Glassmorphic Chat Bubble
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Text(
                        _response,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.5,
                          color: Color(0xFF2D4A3E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Controls & Input
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         _buildControlChip(
                           icon: _isVoiceEnabled ? Icons.volume_up : Icons.volume_off,
                           label: _isVoiceEnabled ? 'Voice On' : 'Voice Off',
                           isActive: _isVoiceEnabled,
                           onTap: () => setState(() => _isVoiceEnabled = !_isVoiceEnabled),
                         ),
                         const SizedBox(width: 12),
                         _buildControlChip(
                           icon: Icons.security,
                           label: 'Private Mode',
                           isActive: true, // Always on for demo
                           onTap: () {},
                         ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: lang.isEnglish ? 'Talk to $name...' : '$name에게 말해봐...',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              ),
                              onSubmitted: (text) {
                                _sendMessage(text);
                                _controller.clear();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FloatingActionButton(
                          onPressed: () {
                            _sendMessage(_controller.text);
                            _controller.clear();
                          },
                          backgroundColor: const Color(0xFF2D4A3E),
                          child: const Icon(Icons.send, color: Colors.white),
                          elevation: 2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlChip({required IconData icon, required String label, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2D4A3E).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF2D4A3E) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? const Color(0xFF2D4A3E) : Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF2D4A3E) : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
