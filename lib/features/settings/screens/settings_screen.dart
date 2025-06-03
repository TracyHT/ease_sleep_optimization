import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../services/api_services.dart';
import '../../../core/providers/user_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUser();
    //_fetchStatistics();
  }

  Future<void> _fetchUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final user = await ApiService().getUser(uid);
      ref.read(userProvider.notifier).state = user;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load user: $e')));
    }
  }

  // Future<void> _fetchStatistics() async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   if (uid == null) return;

  //   try {
  //     final stats = await ApiService().getStatistics(uid);
  //     ref.read(statisticProvider.notifier).state = stats;
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Failed to load statistics: $e')));
  //   }
  // }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
      ref.read(userProvider.notifier).state = null;

      // Navigate to login screen after logout
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to log out: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final user = ref.watch(userProvider);
    //final stats = ref.watch(statisticProvider);
    //final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top:
                  40.0 +
                  MediaQuery.of(
                    context,
                  ).padding.top, // 16px padding + status bar height
              left: AppSpacing.screenEdgePadding.left,
              right: AppSpacing.screenEdgePadding.right,
              bottom: AppSpacing.screenEdgePadding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Section
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: colorScheme.primary.withOpacity(0.3),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.displayName ?? 'User Name',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () {
                          // Navigate to edit profile screen
                        },
                        child: Text(
                          "Edit Information",
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Statistics
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     _StatCard(
                //       title: "Session Tracked",
                //       value: stats['sessionsTracked'].toString(),
                //     ),
                //     _StatCard(
                //       title: "Avg Score",
                //       value: stats['avgScore'].toString(),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 20),

                // Privacy Information Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.primary.withOpacity(0.3),
                        radius: 24,
                        child: Icon(
                          Icons.security,
                          size: 28,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Your Data is Protected",
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Your privacy is our top priority. You can delete it anytime.",
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.9,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondaryContainer,
                          foregroundColor: colorScheme.onSecondaryContainer,
                          elevation: 0,
                        ),
                        child: const Text("Learn More"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Settings List
                _SettingTile(
                  title: "Language",
                  trailing: Text(
                    "English",
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
                // _SettingTile(
                //   title: "Dark Mode",
                //   trailing: Switch(
                //     value: themeMode == ThemeMode.dark,
                //     onChanged: (val) {
                //       ref.read(themeModeProvider.notifier).state =
                //           val ? ThemeMode.dark : ThemeMode.light;
                //     },
                //     activeColor: colorScheme.primary,
                //   ),
                // ),
                const _SettingTile(title: "Privacy"),
                const _SettingTile(title: "Measurement Units"),
                const SizedBox(height: 40),

                // Action Buttons
                ElevatedButton(
                  onPressed: _isLoading ? null : _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
                    minimumSize: const Size.fromHeight(50),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Log Out"),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Handle account deletion
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                  child: const Text("Delete Account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SettingTile({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: colorScheme.onSurface)),
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
      onTap: () {
        // Navigate to details if needed
      },
    );
  }
}
