import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/quiz_service.dart';
import '../../services/sentiment_service.dart';
import '../../controllers/mood_controller.dart';
import '../../models/mood_models.dart';
import '../../controllers/language_controller.dart';

class QuizScreen extends StatefulWidget {
  final String title;
  final bool isPeerClash;

  const QuizScreen({super.key, required this.title, required this.isPeerClash});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question>? _questions;
  int _currentIndex = 0;
  int _score = 0;
  bool _isFinished = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final quizService = context.read<QuizService>();
    final lang = context.read<LanguageController>();
    
    List<Question> questions;
    if (widget.isPeerClash) {
      questions = await quizService.getPeerClashQuestions(lang.isEnglish);
    } else {
      questions = await quizService.getStudyDrillQuestions(lang.isEnglish);
    }
    
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  void _answer(int index) {
    if (_questions == null) return;
    
    if (_questions![_currentIndex].correctIndex == index) {
      _score++;
    }

    if (_currentIndex < _questions!.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      setState(() {
        _isFinished = true;
      });

      // Log mood based on quiz performance
      _logQuizMood();
    }
  }

  void _logQuizMood() {
    if (_questions == null) return;
    
    final sentiment = SentimentService.analyzePerformance(_score, _questions!.length);
    context.read<MoodController>().addMoodFromService(
      MoodSource.games,
      sentiment,
      context: 'Quiz: ${widget.title} ($_score/${_questions!.length})',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isFinished) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
              const SizedBox(height: 24),
              Text(
                'Quiz Complete!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Score: $_score / ${_questions!.length}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Games'),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions![_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('${widget.title} (${_currentIndex + 1}/${_questions!.length})')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.isPeerClash)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("You", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("VS", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    Text("Opponent", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            
            Expanded(
              child: Center(
                child: Text(
                  question.text,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(question.options.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  onPressed: () => _answer(index),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    question.options[index],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
