import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/mood_controller.dart';
import '../../models/mood_models.dart';
import '../../services/sentiment_service.dart';
import '../../controllers/rewards_controller.dart';

class BreathingScreen extends StatefulWidget {
  final bool showQuestions;
  final bool isCloudMeditation;

  const BreathingScreen({
    super.key, 
    this.showQuestions = false,
    this.isCloudMeditation = false,
  });

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
  int _selectedLevel = 1;
  bool _isPlaying = false;
  String _instruction = "Select a Level";
  double _circleSize = 150.0;
  int _cyclesCompleted = 0;
  
  Timer? _timer;
  Timer? _questionTimer;
  AnimationController? _animController;
  Animation<double>? _animation;

  final List<String> _questions = [
    "What are you grateful for today?",
    "How does your body feel right now?",
    "What is one thing you want to let go of?",
    "Visualize a place where you feel safe.",
    "Breathe into any tension you feel.",
  ];
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.showQuestions) {
      _startQuestionTimer();
    }
  }

  void _startQuestionTimer() {
    _questionTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && _isPlaying) {
        setState(() {
          _currentQuestionIndex = (_currentQuestionIndex + 1) % _questions.length;
        });
      }
    });
  }

  void _startBreathing() {
    setState(() {
      _isPlaying = true;
      _instruction = "Inhale...";
      _cyclesCompleted = 0;
    });
    _runCycle();
  }

  void _runCycle() async {
    if (!mounted || !_isPlaying) return;

    // Inhale
    setState(() => _instruction = "Inhale...");
    await _animateCircle(250.0, 4); // 4 seconds inhale

    if (!mounted || !_isPlaying) return;

    // Hold
    setState(() => _instruction = "Hold...");
    int holdTime = 4 + (_selectedLevel - 1) * 2; // L1: 4s, L2: 6s, L3: 8s
    await Future.delayed(Duration(seconds: holdTime));

    if (!mounted || !_isPlaying) return;

    // Exhale
    setState(() => _instruction = "Exhale...");
    await _animateCircle(150.0, 4); // 4 seconds exhale

    if (mounted && _isPlaying) {
      _cyclesCompleted++;
      _runCycle();
    }
  }

  Future<void> _animateCircle(double targetSize, int durationSec) {
    if (!mounted) return Future.value();
    
    final completer = Completer<void>();
    
    // Simple animation logic using setState directly for the size trigger
    // or we could use the AnimationController. simpler to just loop for prototype
    
    // Let's use AnimationController for smoothness
    _animController!.duration = Duration(seconds: durationSec);
    _animation = Tween<double>(begin: _circleSize, end: targetSize).animate(CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeInOut,
    ))
      ..addListener(() {
        setState(() {
          _circleSize = _animation!.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          completer.complete();
        }
      });

    _animController!.reset();
    _animController!.forward();
    
    return completer.future;
  }

  void _stopBreathing() {
    setState(() {
      _isPlaying = false;
      _instruction = "Select a Level";
      _circleSize = 150.0;
    });
    _animController?.stop();
    _timer?.cancel();
    _questionTimer?.cancel();

    // Log mood boost if they completed at least one cycle
    if (_cyclesCompleted > 0) {
      final sentiment = SentimentService.getMindfulnessSentiment();
      context.read<MoodController>().addMoodFromService(
        MoodSource.mindfulness,
        sentiment,
        context: 'Completed $_cyclesCompleted breathing cycles',
      );
      
      // Award SINO points (10 per cycle)
      context.read<RewardsController>().addPoints(_cyclesCompleted * 10);
    }
  }

  @override
  void dispose() {
    _animController?.dispose();
    _timer?.cancel();
    _questionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breathing Exercise')),
      body: Stack(
        children: [
          // Cloud Background
          if (widget.isCloudMeditation)
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: List.generate(10, (index) => Padding(
                      padding: EdgeInsets.only(left: index % 2 == 0 ? 0 : 100, top: 20),
                      child: const Icon(Icons.cloud, size: 150, color: Colors.lightBlueAccent),
                    )),
                  ),
                ),
              ),
            ),
            
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Guided Questions Overlay
                if (widget.showQuestions && _isPlaying)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child: Text(
                        _questions[_currentQuestionIndex],
                        key: ValueKey(_currentQuestionIndex),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontStyle: FontStyle.italic, color: Colors.blueGrey),
                      ),
                    ),
                  ),
                
                // Animation Area
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Container(
                      width: _circleSize,
                      height: _circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.withOpacity(0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _instruction,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          
          const SizedBox(height: 40),

          // Controls
          if (!_isPlaying) ...[
            const Text("Choose Difficulty (Hold Time)", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LevelButton(
                  level: 1, 
                  label: "Novice (4s)", 
                  isSelected: _selectedLevel == 1, 
                  onTap: () => setState(() => _selectedLevel = 1),
                ),
                const SizedBox(width: 10),
                _LevelButton(
                  level: 2, 
                  label: "Medium (6s)", 
                  isSelected: _selectedLevel == 2, 
                  onTap: () => setState(() => _selectedLevel = 2),
                ),
                const SizedBox(width: 10),
                _LevelButton(
                  level: 3, 
                  label: "Master (8s)", 
                  isSelected: _selectedLevel == 3, 
                  onTap: () => setState(() => _selectedLevel = 3),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _startBreathing,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Start", style: TextStyle(fontSize: 20)),
            ),
          ] else
            ElevatedButton(
              onPressed: _stopBreathing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Stop", style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final int level;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelButton({
    required this.level,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
