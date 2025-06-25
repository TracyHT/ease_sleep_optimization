import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart'; // adjust the path if needed

final userProvider = StateProvider<AppUser?>((ref) => null);
