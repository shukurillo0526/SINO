import '../../controllers/language_controller.dart';

class AppStrings {
  static String loginTitle(AppLanguage lang) {
    return lang == AppLanguage.en ? 'Login' : '로그인';
  }

  static String loginButton(AppLanguage lang) {
    return lang == AppLanguage.en ? 'Login' : '로그인';
  }

  static String settings(AppLanguage lang) {
    return lang == AppLanguage.en ? 'Settings' : '설정';
  }

  static String howFeeling(AppLanguage lang) {
    return lang == AppLanguage.en ? 'How are you feeling?' : '오늘 기분은 어때요?';
  }

  static String welcome(AppLanguage lang) {
    return lang == AppLanguage.en ? 'Welcome back!' : '환영합니다!';
  }

  static String character(AppLanguage lang) => lang == AppLanguage.en ? 'Character' : '캐릭터';
  static String games(AppLanguage lang) => lang == AppLanguage.en ? 'Games' : '게임';
  static String mindfulness(AppLanguage lang) => lang == AppLanguage.en ? 'Mindfulness' : '마음 챙김';
  static String mood(AppLanguage lang) => lang == AppLanguage.en ? 'Mood Tracking' : '기분 기록';
  static String academics(AppLanguage lang) => lang == AppLanguage.en ? 'Academics' : '학업 관리';

  // Games
  static String studyDrill(AppLanguage lang) => lang == AppLanguage.en ? 'Study Drill' : '스터디 퀴즈';
  static String peerClash(AppLanguage lang) => lang == AppLanguage.en ? 'Peer Clash' : '친구 대결';
  static String shortReel(AppLanguage lang) => lang == AppLanguage.en ? 'Short Reel Therapy' : '힐링 숏폼';
  static String bossFight(AppLanguage lang) => lang == AppLanguage.en ? 'Breathing Boss Fight' : '스트레스 보스전';

  // Mindfulness
  static String breathing(AppLanguage lang) => lang == AppLanguage.en ? 'Breathing' : '호흡';
  static String questions(AppLanguage lang) => lang == AppLanguage.en ? 'Questions' : '질문';
  static String cloudFloat(AppLanguage lang) => lang == AppLanguage.en ? 'Cloud Float' : '근심 구름 날리기';
}
