# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter-based sleep optimization mobile application called "Ease Sleep Optimization". The app uses Firebase for authentication and data storage, and includes features for sleep tracking, sleep aids, statistics, and settings management.

## Technology Stack

- **Frontend**: Flutter 3.32.4 with Dart 3.8.1
- **State Management**: Riverpod
- **Authentication**: Firebase Auth (user authentication only)
- **Shared Data Storage**: MongoDB via Node.js/Express API (in /server directory)
  - User profiles
  - Sleep sounds library
  - Shared resources across users
- **Local Data Storage**: Hive (local-first for sensitive data)
  - EEG raw data
  - Sleep sessions
  - Sleep quality metrics
  - Environmental sensor data
  - User preferences
  - Alarm settings
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
- Core providers in `lib/core/providers/`:
  - `auth_state_provider.dart`: Firebase auth state, current user
  - `bottom_nav_provider.dart`: Bottom navigation state
  - `user_provider.dart`: (Deprecated - use auth_state_provider instead)
- Feature-specific providers in respective feature directories

### Navigation
- Uses named routes defined in `main.dart`
- Initial route: `/login`
- Main app wrapper: `NavigationWrapper` with custom bottom navigation

## Data Architecture

### Firebase Integration
The app initializes Firebase on startup for authentication ONLY:
- **Firebase Authentication**: User login/signup, auth state management
- **NO Firestore**: Cloud Firestore dependency removed - using MongoDB instead
- Configuration files are platform-specific (GoogleService-Info.plist for iOS, google-services.json for Android)

### MongoDB Backend
The Node.js/Express server provides REST API for:
- User profile management (`/api/users`)
- Sleep sounds library (`/api/sleep-sounds`)
- Shared data across users

API base URL is dynamically discovered via `ApiService.baseUrl`

### Local Hive Database
All sensitive EEG and health data stored locally:
- **Sleep sessions**: Local sleep tracking data linked to Firebase UID
- **EEG raw data**: Brain wave data from BrainBit device
- **Sleep quality metrics**: Calculated sleep metrics
- **Environmental data**: Sensor readings during sleep
- **User preferences**: App settings and preferences
- **Alarms**: Alarm configurations

Benefits: Privacy, offline-first, fast access, no cloud storage costs for health data

## Important Considerations

1. **Firebase Initialization**: Always ensure Firebase is initialized before running the app (`Firebase.initializeApp()` in main.dart)

2. **Hive Initialization**: Hive must be initialized before Firebase in main.dart for local data storage

3. **Backend Server**: The MongoDB server must be running for sleep sounds and user profile features. Start with `cd server && node server.js`

4. **Environment Variables**:
   - Server uses `.env` file in `/server` directory with `MONGO_URI` and `PORT`
   - Flutter app does NOT use dotenv (removed dependency)

5. **Platform-specific Setup**:
   - iOS requires proper Podfile configuration and pod install
   - Android requires google-services.json in the app directory
   - BrainBit integration requires Bluetooth permissions

6. **Testing**: The default widget test needs updating as it references a counter example that doesn't exist in the actual app

7. **Assets**: Images are stored in `lib/assets/images/` and audio in `assets/audio/`

8. **Dark Mode**: The app is configured to use dark theme by default (`themeMode: ThemeMode.dark`)

9. **Data Flow**:
   - Authentication: Firebase Auth → `authStateProvider` → `currentUserProvider`
   - User Profiles: MongoDB via API
   - Sleep Sounds: MongoDB via API
   - EEG/Health Data: Local Hive database only
   - Alarms: Local Hive database only

## Current Branch Information
Working on branch: `develop` (main development branch)