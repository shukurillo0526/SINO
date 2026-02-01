/// SINO - Supabase Authentication Service
/// 
/// This service handles user authentication using Supabase Auth.
/// It supports OAuth login (Kakao) and guest mode access.
/// 
/// ## Features
/// - Kakao OAuth integration
/// - Guest mode with local state
/// - Reactive user stream
/// - Automatic session management
/// 
/// ## Usage
/// ```dart
/// final authService = SupabaseAuthService();
/// 
/// // Listen to auth state
/// authService.currentUser.listen((user) {
///   if (user != null) {
///     print('Logged in as: ${user.name}');
///   }
/// });
/// 
/// // Sign in with Kakao
/// await authService.signInWithKakao();
/// 
/// // Or as guest
/// await authService.signInAsGuest();
/// ```
/// 
/// ## Deep Linking
/// OAuth redirects use: `com.sino.app.sino://login-callback/`
/// 
/// @author SINO Team
/// @version 1.3.0
/// @since 2026-01-20
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../models/user_model.dart' as app_user;
import 'interfaces/i_auth_service.dart';

// ============================================================
// SUPABASE AUTH SERVICE
// ============================================================

/// Authentication service using Supabase Auth.
/// 
/// This service implements [IAuthService] and provides:
/// - Kakao OAuth login
/// - Guest mode (local-only session)
/// - Reactive user state via streams
/// - Automatic session restoration
class SupabaseAuthService extends ChangeNotifier implements IAuthService {
  // ============================================================
  // PROPERTIES
  // ============================================================
  
  /// Access to the Supabase client.
  SupabaseClient get _supabase => Supabase.instance.client;
  
  /// Subject for managing guest user state.
  /// Uses BehaviorSubject for immediate value emission.
  final _guestUserSubject = BehaviorSubject<app_user.User?>.seeded(null);

  // ============================================================
  // USER STREAM
  // ============================================================

  /// Stream of the current authenticated user.
  /// 
  /// Combines Supabase auth state with local guest state.
  /// Guest state takes priority when active.
  /// 
  /// Emits:
  /// - [app_user.User] when authenticated (Supabase or guest)
  /// - `null` when not authenticated
  @override
  Stream<app_user.User?> get currentUser {
    return Rx.combineLatest2<AuthState, app_user.User?, app_user.User?>(
      _supabase.auth.onAuthStateChange,
      _guestUserSubject.stream,
      (authState, guestUser) {
        // Priority 1: Guest user (local session)
        if (guestUser != null) {
          debugPrint('👤 Current user: Guest');
          return guestUser;
        }

        // Priority 2: Supabase authenticated user
        final session = authState.session;
        final user = session?.user;
        
        if (user == null) {
          debugPrint('👤 Current user: None');
          return null;
        }
        
        // Extract user metadata from OAuth provider
        final metadata = user.userMetadata;
        final name = _extractName(metadata, user.email);
        final avatarUrl = _extractAvatar(metadata);

        debugPrint('👤 Current user: $name');
        
        return app_user.User(
          name: name,
          role: 'Student',
          photoUrl: avatarUrl,
          isGuest: false,
        );
      },
    );
  }

  // ============================================================
  // AUTHENTICATION METHODS
  // ============================================================

  /// Signs in using Kakao OAuth.
  /// 
  /// Opens the Kakao login page and handles the OAuth callback.
  /// On mobile, uses deep link redirect.
  /// On web, uses popup/redirect flow.
  @override
  Future<void> signInWithKakao() async {
    debugPrint('🔐 Starting Kakao OAuth...');
    
    // Clear any existing guest session
    _guestUserSubject.add(null);
    
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.kakao,
      redirectTo: kIsWeb ? null : 'com.sino.app.sino://login-callback/',
    );
  }
  
  /// Signs in as a guest (offline mode).
  /// 
  /// Creates a local-only session without server authentication.
  /// Guest data is stored locally and not synced to the cloud.
  @override
  Future<void> signInAsGuest() async {
    debugPrint('🔐 Signing in as guest...');
    
    // Ensure no Supabase session conflicts
    await _supabase.auth.signOut();
    
    // Create local guest user
    final guest = app_user.User.guest();
    _guestUserSubject.add(guest);
    
    notifyListeners();
  }

  /// Signs out the current user.
  /// 
  /// Clears both Supabase session and local guest state.
  @override
  Future<void> signOut() async {
    debugPrint('🔐 Signing out...');
    
    // Clear guest state
    _guestUserSubject.add(null);
    
    // Sign out from Supabase
    await _supabase.auth.signOut();
    
    notifyListeners();
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Extracts the display name from OAuth metadata.
  String _extractName(Map<String, dynamic>? metadata, String? email) {
    if (metadata == null) {
      return email?.split('@')[0] ?? 'User';
    }
    
    return metadata['name'] 
        ?? metadata['full_name'] 
        ?? metadata['preferred_username']
        ?? email?.split('@')[0] 
        ?? 'User';
  }

  /// Extracts the avatar URL from OAuth metadata.
  String? _extractAvatar(Map<String, dynamic>? metadata) {
    if (metadata == null) return null;
    
    return metadata['avatar_url'] 
        ?? metadata['picture']
        ?? metadata['profile_image'];
  }

  /// Whether a user is currently authenticated.
  bool get isAuthenticated {
    return _guestUserSubject.value != null 
        || _supabase.auth.currentUser != null;
  }

  /// Whether the current session is a guest session.
  bool get isGuest => _guestUserSubject.value != null;

  // ============================================================
  // LIFECYCLE
  // ============================================================
  
  /// Disposes of resources.
  @override
  void dispose() {
    _guestUserSubject.close();
    super.dispose();
  }
}
