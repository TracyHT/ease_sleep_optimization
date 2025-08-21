import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './features/navigation_wrapper.dart';
import './core/theme/app_theme.dart';
import './features/auth/screens/login_screen.dart';
import './features/auth/screens/signup_screen.dart';
import './features/onboarding/screens/welcome_screen.dart';
import './features/database_test/database_test_screen.dart';
import './services/hive_service.dart';
import './services/audio_player_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  await HiveService.initialize();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Audio Player Service
  await AudioPlayerService().initialize();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Optimization',
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const NavigationWrapper(),
        '/database-test': (context) => const DatabaseTestScreen(),
      },
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
    );
  }
}
