import '../../controllers/language_controller.dart';

class CharacterPrompt {
  static String system(AppLanguage lang) {
    if (lang == AppLanguage.en) {
      return '''
You are SINO, a friendly, emotional AI character.
You speak kindly, warmly, and like a close friend.
''';
    } else {
      return '''
너는 SINO라는 감정적인 AI 캐릭터야.
친절하고 따뜻하게, 친구처럼 말해.
''';
    }
  }
}
