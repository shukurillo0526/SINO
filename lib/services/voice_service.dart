/// SINO - Voice Recording Service
/// 
/// This service handles audio recording for voice mood notes.
/// It uses the `record` package to capture audio and saves files
/// to the application documents directory.
/// 
/// ## Features
/// - Audio recording permission handling
/// - M4A format recording
/// - Unique filename generation
/// - Recording state management
/// 
/// ## Usage
/// ```dart
/// final voiceService = VoiceService();
/// 
/// if (await voiceService.hasPermission()) {
///   await voiceService.startRecording();
///   // ... user records
///   final path = await voiceService.stopRecording();
///   print('Saved to: $path');
/// }
/// ```
/// 
/// @author SINO Team
/// @version 1.3.0
/// @since 2026-01-20
library;

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

// ============================================================
// VOICE SERVICE
// ============================================================

/// Service for recording voice notes.
/// 
/// Voice notes can be used for:
/// - Mood logging via voice (analyzed by sentiment service)
/// - Personal journal entries
/// - Voice messages to SINO
class VoiceService {
  // ============================================================
  // PROPERTIES
  // ============================================================
  
  /// The audio recorder instance.
  final AudioRecorder _recorder = AudioRecorder();
  
  /// Whether recording is currently in progress.
  bool _isRecording = false;
  
  /// Path to the current (or most recent) recording.
  String? _lastRecordingPath;

  // ============================================================
  // GETTERS
  // ============================================================
  
  /// Whether recording is currently in progress.
  bool get isRecording => _isRecording;
  
  /// Path to the last completed recording.
  String? get lastRecordingPath => _lastRecordingPath;

  // ============================================================
  // PUBLIC METHODS
  // ============================================================

  /// Checks if the app has microphone permission.
  /// 
  /// Returns `true` if permission is granted.
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  /// Starts recording audio.
  /// 
  /// Recording is saved to the app's documents directory with
  /// a unique timestamp-based filename.
  /// 
  /// Throws if permission is not granted.
  /// 
  /// Example:
  /// ```dart
  /// await voiceService.startRecording();
  /// // File: /documents/voice_note_1642345678901.m4a
  /// ```
  Future<void> startRecording() async {
    if (_isRecording) {
      debugPrint('⚠️ Already recording, ignoring startRecording call');
      return;
    }
    
    try {
      if (await hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '${directory.path}/voice_note_$timestamp.m4a';
        
        await _recorder.start(const RecordConfig(), path: path);
        _isRecording = true;
        _lastRecordingPath = path;
        
        debugPrint('🎤 Recording started: $path');
      } else {
        debugPrint('❌ Microphone permission not granted');
      }
    } catch (e) {
      debugPrint('❌ Error starting recording: $e');
      _isRecording = false;
    }
  }

  /// Stops the current recording.
  /// 
  /// Returns the path to the saved audio file, or `null` if
  /// no recording was in progress or an error occurred.
  Future<String?> stopRecording() async {
    if (!_isRecording) {
      debugPrint('⚠️ Not recording, ignoring stopRecording call');
      return null;
    }
    
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      
      debugPrint('🎤 Recording stopped: $path');
      return path;
    } catch (e) {
      debugPrint('❌ Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Cancels the current recording without saving.
  Future<void> cancelRecording() async {
    if (_isRecording) {
      await _recorder.cancel();
      _isRecording = false;
      debugPrint('🎤 Recording cancelled');
    }
  }

  /// Disposes of the recorder resources.
  /// 
  /// Call this when the service is no longer needed.
  void dispose() {
    _recorder.dispose();
    debugPrint('🎤 VoiceService disposed');
  }
}
