/// SINO - Student Companion Application
/// 
/// This is the main entry point for the SINO Flutter application.
/// SINO is a comprehensive student wellness platform that provides:
/// - AI-powered companion chat
/// - Mood tracking and crisis detection
/// - Academic task management
/// - Gamification and rewards
/// - B2B analytics for schools
/// 
/// ## Architecture
/// The app uses Provider for state management with the following layers:
/// - Controllers: State management (ChangeNotifier)
/// - Services: Business logic and API integrations
/// - Features: Feature-specific screens and widgets
/// - Models: Data classes and enums
/// 
/// ## Initialization Flow
/// 1. Load environment variables (.env)
/// 2. Initialize Supabase client
/// 3. Wire up services (GeminiService ↔ ConversationService)
/// 4. Register providers
/// 5. Launch MaterialApp
/// 
/// @author SINO Team
/// @version 1.3.0
/// @since 2026-01-20
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================
// CONTROLLERS (State Management)
// ============================================================
import 'controllers/language_controller.dart';
import 'controllers/mood_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/rewards_controller.dart';
import 'controllers/mindfulness_controller.dart';
import 'controllers/consent_controller.dart';
import 'core/theme/app_theme.dart';

// ============================================================
// SERVICES (Business Logic)
// ============================================================
import 'services/quiz_service.dart';
import 'services/academics_service.dart';
import 'services/gemini_service.dart';
import 'services/conversation_service.dart';
import 'services/supabase_auth_service.dart';
import 'services/companion_service.dart';

// ============================================================
// SCREENS (Main Navigation)
// ============================================================
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/home.dart';
import 'screens/settings.dart';
import 'screens/account.dart';
import 'screens/about_screen.dart';
import 'screens/rewards_screen.dart';

// ============================================================
// FEATURES (Feature-specific Screens)
// ============================================================
import 'features/character/character_screen.dart';
import 'features/games/games_screen.dart';
import 'features/mindfulness/mindfulness_screen.dart';
import 'features/mood/mood_screen.dart';
import 'features/academics/academics_screen.dart';
import 'features/privacy/privacy_screen.dart';
import 'features/reels/short_reel_screen.dart';
import 'features/dashboard/dashboard_screen.dart';

// ============================================================
// MAIN ENTRY POINT
// ============================================================

/// Application entry point.
/// 
/// Initializes required services and launches the app with
/// all providers registered.
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize external services
  await _initializeServices();
  
  // Wire up inter-service dependencies
  final conversationService = ConversationService();
  final geminiService = GeminiService();
  geminiService.setConversationService(conversationService);
  
  // Launch the application
  runApp(
    MultiProvider(
      providers: [
        // ---- State Controllers ----
        ChangeNotifierProvider(create: (_) => LanguageController()),
        ChangeNotifierProvider(create: (_) => MoodController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => RewardsController()),
        ChangeNotifierProvider(create: (_) => MindfulnessController()),
        ChangeNotifierProvider(create: (_) => ConsentController()),
        
        // ---- Services ----
        ChangeNotifierProvider(create: (_) => SupabaseAuthService()),
        ChangeNotifierProvider(create: (_) => AcademicsService()),
        ChangeNotifierProvider(create: (_) => CompanionService()),
        
        // ---- Wired Services (already instantiated) ----
        ChangeNotifierProvider.value(value: conversationService),
        Provider.value(value: geminiService),
        Provider(create: (_) => QuizService()),
      ],
      child: const SinoApp(),
    ),
  );
}

/// Initializes external services required by the application.
/// 
/// This includes:
/// - Loading environment variables from .env
/// - Initializing Supabase client for backend services
Future<void> _initializeServices() async {
  try {
    // Load environment variables if file exists
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("ℹ️ No .env file found, using hardcoded fallback keys (Prototype Mode)");
    }
    
    // Initialize Supabase
    // Uses provided keys as fallback for immediate prototype functionality
    String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    String supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    // Fix for CI/CD: If .env contains "placeholder" (from GitHub Actions), ignore it and use real keys
    if (supabaseUrl.isEmpty || supabaseUrl == 'placeholder') {
      supabaseUrl = 'https://kvmoirajybmjyrrgdsld.supabase.co';
    }
    if (supabaseKey.isEmpty || supabaseKey == 'placeholder') {
      supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt2bW9pcmFqeWJtanlycmdkc2xkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1NDg4ODQsImV4cCI6MjA4NDEyNDg4NH0.Fcl7DWDvrV_vn1OMKtgSHtjK9b7HMQYtyjGDzA4Igd8';
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );

    // Initialize Kakao SDK (Mock/Wrapper depending on platform)
    // Note: Actual Kakao initialization often happens in native code or via a specific plugin 
    // This is where you would call KakaoSdk.init if using packages like kakao_flutter_sdk
    // KakaoSdk.init(
    //   nativeAppKey: 'a6c0a7012bf9e9aca720e86f291124f3',
    //   javaScriptAppKey: '385d014009a45fb3e923b2974b6ec7bd',
    // );
    
  } catch (e) {
    debugPrint("⚠️ Service initialization error: $e");
  }
}

// ============================================================
// ROOT APPLICATION WIDGET
// ============================================================

/// The root widget of the SINO application.
/// 
/// Configures MaterialApp with:
/// - Theme support (light/dark)
/// - Named routes for navigation
/// - Material 3 design system
class SinoApp extends StatelessWidget {
  const SinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    
    return MaterialApp(
      // ---- App Configuration ----
      debugShowCheckedModeBanner: false,
      title: 'SINO',
      
      // ---- Theme Configuration ----
      themeMode: themeController.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      
      // ---- Navigation ----
      initialRoute: '/', // Start at root
      routes: _buildRoutes(),
      onUnknownRoute: _handleUnknownRoute,
    );
  }

  /// Builds the route map for named navigation.
  /// 
  /// All main screens are registered here for easy navigation
  /// using `Navigator.pushNamed(context, '/routeName')`.
  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      // ---- Authentication ----
      '/': (_) => const LoginPage(), // Handle root path
      '/login': (_) => const LoginPage(),
      '/signup': (_) => const SignUpScreen(),
      
      // ---- Main Screens ----
      '/home': (_) => const DashboardScreen(),
      '/dashboard': (_) => const DashboardScreen(),
      '/character': (_) => const CharacterScreen(),
      '/settings': (_) => const SettingsScreen(),
      '/account': (_) => const AccountScreen(),
      '/about': (_) => const AboutScreen(),
      '/rewards': (_) => const RewardsScreen(),
      
      // ---- Feature Screens ----
      '/games': (_) => const GamesScreen(),
      '/reels': (_) => const ShortReelScreen(),
      '/mindfulness': (_) => const MindfulnessScreen(),
      '/mood': (_) => const MoodScreen(),
      '/academics': (_) => const AcademicsScreen(),
      '/privacy': (_) => const PrivacyScreen(),
    };
  }
  
  // Handle deep links or unknown routes (like OAuth callbacks) gracefully
  Route<dynamic>? _handleUnknownRoute(RouteSettings settings) {
    // If we land on a weird route from an OAuth redirect, just go to Login/Home
    // The Supabase Auth listener will handle the actual session state
    return MaterialPageRoute(builder: (_) => const LoginPage());
  }
}
