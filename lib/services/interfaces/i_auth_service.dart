import '../../models/user_model.dart';

abstract class IAuthService {
  Stream<User?> get currentUser;
  Future<void> signInWithKakao();
  Future<void> signInAsGuest();
  Future<void> signOut();
}
