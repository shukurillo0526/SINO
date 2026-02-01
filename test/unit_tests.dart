
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sino/controllers/mood_controller.dart';
import 'package:sino/models/mood_models.dart';
import 'package:sino/controllers/rewards_controller.dart';
import 'package:sino/controllers/language_controller.dart';
import 'package:sino/controllers/theme_controller.dart';
import 'package:sino/services/crisis_service.dart';
import 'package:sino/services/academics_service.dart';
import 'package:sino/models/academics_models.dart';
// ClinicalExportService import removed - API was refactored


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

/*
  group('DatabaseService Tests', () {
    test('Register and Login User', () async {
      SharedPreferences.setMockInitialValues({});
      final db = DatabaseService();

      // Register
      final registerResult = await db.registerUser('testuser', 'password123');
      expect(registerResult, 1);

      // Check user exists
      final exists = await db.checkUserExists('testuser');
      expect(exists, true);

      // Login success
      final loginResult = await db.loginUser('testuser', 'password123');
      expect(loginResult, isNotNull);
      expect(loginResult?['username'], 'testuser');

      // Login fail
      final loginFail = await db.loginUser('testuser', 'wrongpass');
      expect(loginFail, isNull);
    });
  });

  group('AuthService Tests', () {
    test('Login Flow', () async {
      SharedPreferences.setMockInitialValues({});
      final auth = AuthService();
      final db = DatabaseService();
      
      // Setup user in DB first
      await db.registerUser('testuser', 'password123');

      // Test login
      final success = await auth.login('testuser', 'password123');
      expect(success, true);
      expect(auth.isAuthenticated, true);
      expect(auth.currentUser?.name, 'testuser');

      // Test guest login
      await auth.logout();
      expect(auth.isAuthenticated, false);
      
      await auth.loginAsGuest();
      expect(auth.isAuthenticated, true);
      expect(auth.currentUser?.isGuest, true);
    });
  });
*/

  /* 
  // TODO: These tests require Supabase mocking. 
  // Use mockito or integration_test to test Supabase-dependent logic.
  
  group('MoodController Tests', () {
    test('Add Manual Mood and Analytics', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = MoodController();

      // Ensure initial state is empty
      // Note: MoodController loads entries in constructor, so we wait briefly
      await Future.delayed(Duration(milliseconds: 100));
      expect(controller.entries.isEmpty, true);

      // Add mood
      await controller.addManualMood(MoodLevel.happy, context: 'Test context');
      expect(controller.entries.length, 1);
      expect(controller.entries.first.mood, MoodLevel.happy);

      // Check weekly report
      final report = controller.getWeeklyReport();
      expect(report.averageSentiment, closeTo(0.5, 0.01)); // Happy is 0.5
    });
    
    test('Load Sample Data', () async {
       SharedPreferences.setMockInitialValues({});
       final controller = MoodController();
       
       await controller.loadSampleData();
       expect(controller.entries.isNotEmpty, true);
       expect(controller.entries.length, 7);
    });

    test('Log Mood from Academics', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = MoodController();
      
      // Log mood from task completion
      await controller.addMoodFromService(
        MoodSource.academics,
        0.5, // Happy
        context: 'Completed task: Math'
      );
      
      expect(controller.entries.length, 1);
      expect(controller.entries.first.source, MoodSource.academics);
      expect(controller.entries.first.sentimentScore, 0.5);
    });

    test('Log Voice Mood', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = MoodController();
      
      await controller.addVoiceMood(
        MoodLevel.sad, 
        context: 'Feeling down',
        audioPath: '/path/to/audio.m4a'
      );
      
      expect(controller.entries.length, 1);
      expect(controller.entries.first.source, MoodSource.voice);
      expect(controller.entries.first.metadata?['audioPath'], '/path/to/audio.m4a');
    });
  });
  */

  /*
  group('RewardsController Tests', () {
    test('Points and Skin Purchase', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = RewardsController();
      
      await Future.delayed(Duration(milliseconds: 50)); // Allow async load

      expect(controller.points, 100); // Default points

      // Add points
      controller.addPoints(500);
      expect(controller.points, 600);

      // Purchase skin (cost 300)
      final success = controller.purchaseSkin('confu');
      expect(success, true);
      expect(controller.points, 300);
      expect(controller.skins.firstWhere((s) => s.id == 'confu').isUnlocked, true);

      // Select skin
      controller.selectSkin('confu');
      expect(controller.selectedSkinId, 'confu');
    });

    test('Purchase Coupon', () async {
      SharedPreferences.setMockInitialValues({}); // Ensure fresh state for this test
      final controller = RewardsController();
      await Future.delayed(Duration(milliseconds: 50)); // Allow async load

      controller.addPoints(200); // Add points to reach 300 (100 default + 200 added)
      
      final success = controller.purchaseCoupon('coffee'); // Coffee coupon cost is 200
      expect(success, true);
      expect(controller.points, 100); // 100 base + 200 added - 200 cost = 100
      expect(controller.coupons.firstWhere((c) => c.id == 'coffee').isPurchased, true);
    });
  });
  */

  group('LanguageController Tests', () {
    test('Toggle Language', () {
      final controller = LanguageController();
      expect(controller.isEnglish, true);
      
      controller.toggle();
      expect(controller.isKorean, true);
      
      controller.toggle();
      expect(controller.isEnglish, true);
    });
  });

  group('ThemeController Tests', () {
    test('Theme Toggles', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = ThemeController();
      
      await Future.delayed(Duration(milliseconds: 50));

      expect(controller.themeMode, ThemeMode.light);

      controller.toggleTheme(true);
      expect(controller.themeMode, ThemeMode.dark);
      expect(controller.isDarkMode, true);

      controller.toggleBigIconMode(true);
      expect(controller.isBigIconMode, true);
    });
  });

  group('CrisisService Tests', () {
    test('Risk Detection', () {
      expect(CrisisService.analyzeForCrisis('I want to suicide'), RiskLevel.high);
      expect(CrisisService.analyzeForCrisis('Life is pointless'), RiskLevel.medium);
      expect(CrisisService.analyzeForCrisis('I am happy'), isNull);
      
      // Test keyword with different casing
      expect(CrisisService.analyzeForCrisis('SUICIDE'), RiskLevel.high);

      // Test punctuation normalization
      expect(CrisisService.analyzeForCrisis("don't want to live"), RiskLevel.high); // "don't" -> "dont"
    });


    test('Safety Info Content', () {
      final response = CrisisService.getSafetyInfo(RiskLevel.high, true);
      expect(response.actionLabel, contains('109'));
      expect(response.actionUrl, 'tel:109');
      
      final mediumResponse = CrisisService.getSafetyInfo(RiskLevel.medium, true);
      expect(mediumResponse.actionLabel, isNotNull); // Now has "Talk to a Counselor"
    });
  });

  /*
  group('AcademicsService Tests', () {
    test('Schedule and Todo Management', () async {
      SharedPreferences.setMockInitialValues({});
      final service = AcademicsService();
      
      await Future.delayed(Duration(milliseconds: 50));

      // Schedule
      final scheduleEntry = ScheduleEntry(
         id: '1', 
         subject: 'Math', 
         teacher: 'Mr. X', 
         room: '101', 
         startTime: DateTime.now(), 
         endTime: DateTime.now().add(Duration(hours: 1)), 
         dayOfWeek: 1, 
         color: Colors.red
      );
      
      await service.addScheduleEntry(scheduleEntry);
      expect(service.schedule.length, 1);
      
      // Todo
      final todo = TodoItem(
        id: '1', 
        title: 'Homework', 
        description: 'Do it', 
        priority: Priority.high, 
        subject: 'Math'
      );
      
      await service.addTodo(todo);
      expect(service.todos.length, 1);
      
      await service.toggleTodoComplete('1');
      expect(service.todos.first.isCompleted, true);
      
      expect(service.completedTodos.length, 1);
      expect(service.incompleteTodos.length, 0);
    });
  });
  */

  // NOTE: ClinicalExportService was refactored to use instance methods.
  // These tests need to be updated to match the new API.
  // group('ClinicalExportService Tests', () {
  //   test('Generate CSV', () async {
  //     SharedPreferences.setMockInitialValues({});
  //     final moodController = MoodController();
  //     final academicsService = AcademicsService();
  //     
  //     // Add data
  //     await moodController.addManualMood(MoodLevel.happy);
  //     
  //     final csv = ClinicalExportService.generateCsv(moodController, academicsService);
  //     
  //     expect(csv, contains('user_hash,timestamp,event_type,sentiment_score,metadata'));
  //     expect(csv, contains('mood_log'));
  //     expect(csv, contains('0.50')); // happy score
  //   });
  // });
}
