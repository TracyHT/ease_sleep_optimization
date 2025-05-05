import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_repository.dart';

// Provider để inject FirebaseAuth
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);

// Provider cho AuthRepository
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(firebaseAuthProvider)),
);

// Provider giữ trạng thái người dùng hiện tại
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.read(authRepositoryProvider).authStateChanges,
);

// AuthController để gọi repo và handle logic
final authControllerProvider = Provider<AuthController>(
  (ref) => AuthController(ref.read(authRepositoryProvider)),
);

class AuthController {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  Future<User?> login(String email, String password) async {
    try {
      return await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
  }

  Future<User?> signup(String email, String password) async {
    return await _authRepository.signUp(email: email, password: password);
  }

  User? get currentUser => _authRepository.currentUser;
}
