import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;

  OpenAIService._internal() {
    final key = dotenv.env['OPENAI_API_KEY'];
    if (key != null) {
      OpenAI.apiKey = key;
    }
  }

  Future<String> getChatResponse(String message) async {
    try {
      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "You are SINO, a helpful and friendly fox character companion for students. You help with mindfulness, studying, and emotional support. Keep responses concise and encouraging."
          ),
        ],
        role: OpenAIChatMessageRole.system,
      );

      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(message),
        ],
        role: OpenAIChatMessageRole.user,
      );

      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [systemMessage, userMessage],
      );

      return chatCompletion.choices.first.message.content?.first.text ?? "I'm listening...";
    } catch (e) {
      return "I'm having trouble connecting right now. 🦊 (Error: $e)";
    }
  }
}
