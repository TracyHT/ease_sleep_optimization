import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/api_services.dart';

// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Stream of Firebase auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

// Current Firebase user (synchronous)
final firebaseUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Current AppUser with profile data from MongoDB
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final firebaseUser = ref.watch(firebaseUserProvider);

  if (firebaseUser == null) {
    return null;
  }

  // Try to fetch user profile from MongoDB backend
  try {
    final apiService = ApiService();
    return await apiService.getUser(firebaseUser.uid);
  } catch (e) {
    // If backend fails, create AppUser from Firebase data
    print('Failed to fetch user from backend: $e');
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName ?? 'User',
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }
});

// Check if user is authenticated (synchronous boolean)
final isAuthenticatedProvider = Provider<bool>((ref) {
  final firebaseUser = ref.watch(firebaseUserProvider);
  return firebaseUser != null;
});
