import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/gemini_service.dart';
import '../../controllers/language_controller.dart';

class StudyHelpScreen extends StatefulWidget {
  const StudyHelpScreen({super.key});

  @override
  State<StudyHelpScreen> createState() => _StudyHelpScreenState();
}

class _StudyHelpScreenState extends State<StudyHelpScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<_Message> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _messages.add(_Message(text: question, isUser: true));
      _isLoading = true;
    });

    _questionController.clear();

    try {
      final geminiService = context.read<GeminiService>();
      
      // System prompt to guide AI to provide explanations, not answers
      final systemPrompt = '''You are a helpful study assistant for students. 
Your role is to help students UNDERSTAND concepts, not to give them direct answers to homework.
- Provide explanations, hints, and guidance
- Break down complex problems into steps
- Ask guiding questions to help students think
- Never solve homework problems directly
- Encourage critical thinking

Student question: $question''';

      final response = await geminiService.getChatResponse(systemPrompt);
      
      setState(() {
        _messages.add(_Message(text: response, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(_Message(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.isEnglish ? 'Study Help' : '학습 도움'),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear chat',
              onPressed: () {
                setState(() => _messages.clear());
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: theme.primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lang.isEnglish
                        ? 'I\'ll help you understand, not give direct answers!'
                        : '직접적인 답변이 아닌 이해를 도와드립니다!',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: theme.disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          lang.isEnglish
                              ? 'Ask me anything about your studies!'
                              : '공부에 대해 무엇이든 물어보세요!',
                          style: TextStyle(color: theme.disabledColor),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            lang.isEnglish
                                ? 'Example: "Explain photosynthesis" or "Help me understand quadratic equations"'
                                : '예: "광합성을 설명해주세요" 또는 "이차방정식을 이해하도록 도와주세요"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.disabledColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _MessageBubble(message: message);
                    },
                  ),
          ),

          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    lang.isEnglish ? 'Thinking...' : '생각 중...',
                    style: TextStyle(color: theme.disabledColor),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: lang.isEnglish
                          ? 'Ask a question...'
                          : '질문을 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _askQuestion(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _askQuestion,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;

  _Message({required this.text, required this.isUser});
}

class _MessageBubble extends StatelessWidget {
  final _Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? theme.primaryColor
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: message.isUser
              ? null
              : Border.all(color: theme.dividerColor),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser
                ? Colors.white
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
