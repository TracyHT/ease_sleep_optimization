import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/api_services.dart';
import '../../../core/services/local_database_service.dart';
import '../../../core/models/user.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

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

    final firebaseUser = userCredential.user;
    if (firebaseUser != null) {
      AppUser? userProfile;
      
      // Try to fetch user profile from backend
      try {
        userProfile = await _apiService.getUser(firebaseUser.uid);
      } catch (e) {
        // Backend might not have the user or might be down
        // Create user profile from Firebase data
        print('Backend user fetch failed: $e');
        userProfile = AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          displayName: firebaseUser.displayName ?? 'User',
          createdAt: firebaseUser.metadata.creationTime,
        );
        
        // Try to create the user in backend for future use
        try {
          await _apiService.createUser(userProfile);
        } catch (createError) {
          print('Backend user creation during login failed: $createError');
        }
      }
      
      // User state is automatically updated by authStateProvider
      // No need to manually set it here
    } else {
      throw Exception('Failed to get user UID after login');
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    // Create Firebase user
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = userCredential.user;
    if (firebaseUser != null) {
      // Update Firebase user display name
      await firebaseUser.updateDisplayName(name);
      
      // Create user profile in backend
      final appUser = AppUser(
        uid: firebaseUser.uid,
        displayName: name,
        email: email,
        createdAt: DateTime.now(),
      );
      
      // Save user to backend (if backend is available)
      try {
        await _apiService.createUser(appUser);
      } catch (e) {
        // Backend might not be running, but Firebase user is created
        // This is acceptable for now
        print('Backend user creation failed: $e');
      }
      
      // Initialize user's local data storage
      await _initializeUserLocalData(firebaseUser.uid);
      
      // User state is automatically updated by authStateProvider
      // No need to manually set it here
    } else {
      throw Exception('Failed to create user account');
    }
  }

  /// Initialize local data for a new user
  Future<void> _initializeUserLocalData(String firebaseUid) async {
    try {
      // Set up default user preferences
      await LocalDatabaseService.saveUserPreference('userId', firebaseUid);
      await LocalDatabaseService.saveUserPreference('theme', 'dark');
      await LocalDatabaseService.saveUserPreference('notifications', true);
      await LocalDatabaseService.saveUserPreference('dataSync', true);
      
      print('Local data initialized for user: $firebaseUid');
    } catch (e) {
      print('Failed to initialize local data: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();

    // User state is automatically updated by authStateProvider
    // Optionally clear local data on sign out (comment out to keep data)
    // if needed, get user before signOut and clear their data
  }
}
