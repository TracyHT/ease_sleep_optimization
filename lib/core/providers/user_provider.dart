// This file is deprecated - use auth_state_provider.dart instead
// Keeping for backward compatibility during migration

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import './auth_state_provider.dart';

// For backward compatibility - redirects to new auth provider
final userProvider = Provider<AppUser?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});
