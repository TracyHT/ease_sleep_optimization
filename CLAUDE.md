# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter-based sleep optimization mobile application called "Ease Sleep Optimization". The app uses Firebase for authentication and data storage, and includes features for sleep tracking, sleep aids, statistics, and settings management.

## Technology Stack

- **Frontend**: Flutter 3.32.4 with Dart 3.8.1
- **State Management**: Riverpod
- **Backend Services**: Firebase (Auth, Firestore)
- **Local Storage**: Hive
- **Server**: Node.js/Express server with MongoDB (in /server directory)
- **UI Libraries**: fl_chart, pie_chart, date_picker_timeline

## Development Commands

### Flutter App Commands
```bash
# Install dependencies
flutter pub get

# Run the app in debug mode
flutter run

# Run on specific device
flutter run -d <device_id>

# Build for iOS
flutter build ios

# Build for Android  
flutter build apk

# Run tests
flutter test

# Analyze code for issues
flutter analyze

# Format code
dart format .
```

### Server Commands (if working with backend)
```bash
# Navigate to server directory
cd server

# Install dependencies
npm install

# Run server (no start script defined, use node directly)
node server.js
```

## Project Architecture

### Core Structure
The app follows a feature-based architecture with clear separation of concerns:

- **lib/core/**: Core app functionality
  - `constants/`: App-wide constants (colors, sizes, strings, breakpoints)
  - `models/`: Data models (User, Alarm, SleepSummaryData)
  - `providers/`: Global state providers (user, navigation)
  - `styles/`: Reusable UI styles
  - `theme/`: App theming and responsive utilities

- **lib/features/**: Feature modules
  - `auth/`: Authentication (login/signup screens and controllers)
  - `control/`: Alarm and control settings
  - `sleepAids/`: Sleep aid features (audio, suggestions)
  - `sleepMode/`: Sleep tracking and session management
  - `statistics/`: Sleep statistics and data visualization
  - `settings/`: App settings
  - `navigation_wrapper.dart`: Main navigation handler

- **lib/services/**: External service integrations
  - `api_services.dart`: API communication layer

- **lib/ui/**: Shared UI components
  - `components/`: Reusable UI components
  - `widgets/`: Custom widgets

### State Management
The app uses Riverpod for state management with providers located in:
- Core providers in `lib/core/providers/`
- Feature-specific providers in respective feature directories

### Navigation
- Uses named routes defined in `main.dart`
- Initial route: `/login`
- Main app wrapper: `NavigationWrapper` with custom bottom navigation

## Firebase Integration

The app initializes Firebase on startup and uses:
- Firebase Authentication for user management
- Cloud Firestore for data persistence
- Configuration files are platform-specific (GoogleService-Info.plist for iOS, google-services.json for Android)

## Important Considerations

1. **Firebase Initialization**: Always ensure Firebase is initialized before running the app (`Firebase.initializeApp()` in main.dart)

2. **Environment Variables**: The project uses dotenv for environment configuration. Check for .env files before running.

3. **Platform-specific Setup**: 
   - iOS requires proper Podfile configuration and pod install
   - Android requires google-services.json in the app directory

4. **Testing**: The default widget test needs updating as it references a counter example that doesn't exist in the actual app

5. **Assets**: Images are stored in `lib/assets/images/` and must be declared in pubspec.yaml

6. **Dark Mode**: The app is configured to use dark theme by default (`themeMode: ThemeMode.dark`)

## Current Branch Information
Working on branch: `hive-local-database` (indicates local storage implementation using Hive)