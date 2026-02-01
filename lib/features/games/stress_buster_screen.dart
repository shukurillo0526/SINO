import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../controllers/rewards_controller.dart';
import '../../controllers/mood_controller.dart';
import '../../models/mood_models.dart';
import '../../controllers/language_controller.dart';

class StressBusterScreen extends StatefulWidget {
  const StressBusterScreen({super.key});

  @override
  State<StressBusterScreen> createState() => _StressBusterScreenState();
}

class _StressBusterScreenState extends State<StressBusterScreen> {
  int _score = 0;
  int _timeLeft = 30;
  bool _isPlaying = false;
  Timer? _timer;
  final Random _random = Random();
  
  List<StressCloud> _clouds = [];

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isPlaying = true;
      _clouds = [];
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
        if (_timeLeft % 1 == 0) _spawnCloud();
      } else {
        _endGame();
      }
    });

    _spawnCloud();
  }

  void _spawnCloud() {
    if (!_isPlaying) return;
    setState(() {
      _clouds.add(StressCloud(
        id: DateTime.now().millisecondsSinceEpoch,
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        scale: 0.5 + _random.nextDouble() * 0.5,
      ));
    });
  }

  void _popCloud(int id) {
    if (!_isPlaying) return;
    setState(() {
      _clouds.removeWhere((c) => c.id == id);
      _score += 10;
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() => _isPlaying = false);
    
    final pointsEarned = _score ~/ 2;
    context.read<RewardsController>().addPoints(pointsEarned);
    
    // Log positive mood boost
    context.read<MoodController>().addMoodFromService(
      MoodSource.games,
      0.5,
      context: 'Popped stress clouds! Score: $_score',
    );

    _showGameOverDialog(pointsEarned);
  }

  void _showGameOverDialog(int points) {
    final lang = context.read<LanguageController>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(lang.isEnglish ? 'Great Job!' : '잘했어요!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(lang.isEnglish ? 'You popped $_score stress clouds!' : '$_score개의 스트레스 구름을 터뜨렸어요!'),
            const SizedBox(height: 8),
            Text(
              lang.isEnglish ? 'Earned $points SINO Points!' : '$points SINO 포인트를 획득했습니다!',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(lang.isEnglish ? 'Back to Games' : '게임 목록으로'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.isEnglish ? 'Stress Buster' : '스트레스 해소'),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [theme.primaryColor.withOpacity(0.1), Colors.white],
              ),
            ),
          ),
          
          // Game Area
          if (_isPlaying) ...[
            ..._clouds.map((cloud) => Positioned(
              left: cloud.x * (MediaQuery.of(context).size.width - 100),
              top: cloud.y * (MediaQuery.of(context).size.height - 200),
              child: GestureDetector(
                onTap: () => _popCloud(cloud.id),
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double val, child) {
                    return Transform.scale(
                      scale: val * cloud.scale,
                      child: Opacity(
                        opacity: val,
                        child: Icon(
                          Icons.cloud,
                          size: 100,
                          color: Colors.grey.withOpacity(0.6),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )),
          ] else ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.touch_app, size: 80, color: Colors.blue),
                   const SizedBox(height: 24),
                   Text(
                     lang.isEnglish ? 'Pop the stress clouds!' : '스트레스 구름을 터치해서 터뜨리세요!',
                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     lang.isEnglish ? 'Tap them before time runs out.' : '시간이 다 되기 전에 터뜨리세요.',
                     style: TextStyle(color: theme.disabledColor),
                   ),
                   const SizedBox(height: 32),
                   ElevatedButton(
                     onPressed: _startGame,
                     style: ElevatedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                     ),
                     child: Text(lang.isEnglish ? 'START' : '시작하기'),
                   ),
                ],
              ),
            ),
          ],
          
          // HUD
          if (_isPlaying)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HudItem(label: lang.isEnglish ? 'Score' : '점수', value: '$_score'),
                  _HudItem(label: lang.isEnglish ? 'Time' : '시간', value: '${_timeLeft}s'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HudItem extends StatelessWidget {
  final String label;
  final String value;

  const _HudItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class StressCloud {
  final int id;
  final double x;
  final double y;
  final double scale;

  StressCloud({required this.id, required this.x, required this.y, required this.scale});
}
