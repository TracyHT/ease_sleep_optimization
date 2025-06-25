import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/api_services.dart';
import '../../../core/models/user.dart'; // your AppUser model

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

final currentUserProvider = StateProvider<AppUser?>((ref) => null);

class AuthController {
  final Ref ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();

  AuthController(this.ref);

  Future<void> signIn(String email, String password) async {
    // Firebase sign in
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user?.uid;
    if (uid != null) {
      // Fetch user profile from backend by UID
      final userProfile = await _apiService.getUser(uid);
      // Update current user state
      ref.read(currentUserProvider.notifier).state = userProfile;
    } else {
      throw Exception('Failed to get user UID after login');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    ref.read(currentUserProvider.notifier).state = null;
  }
}
