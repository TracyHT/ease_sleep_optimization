import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants/app_spacings.dart';
import '../../../ui/components/gradient_background.dart';
import '../../../services/api_services.dart';
import '../../../core/providers/user_provider.dart';
import 'database_cms_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  Future<void> handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out')));
  }

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
      body: GradientBackground(
        primaryOpacity: 0.05,
        child: SafeArea(
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
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary.withOpacity(0.1),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'lib/assets/images/placeholder.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  child: Icon(
                                    Iconsax.user5,
                                    size: 40,
                                    color: colorScheme.onPrimary,
                                  ),
                                );
                              },
                            ),
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
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
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
                            Iconsax.shield_tick5,
                            size: 28,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Your Data is Protected",
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Your privacy is our top priority. You can delete it anytime.",
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primaryContainer,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            "Learn More",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
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

                  // Database Test Button (Development only)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Database Test',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                    trailing: Icon(Iconsax.code5, color: colorScheme.primary),
                    onTap: () {
                      Navigator.pushNamed(context, '/database-test');
                    },
                  ),

                  // Database CMS Button (Development only)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Database CMS',
                      style: TextStyle(color: colorScheme.secondary),
                    ),
                    trailing: Icon(
                      Iconsax.archive_book,
                      color: colorScheme.secondary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DatabaseCMSScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // Action Buttons
                  ElevatedButton(
                    onPressed: _isLoading ? null : _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              "Log Out",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // Handle account deletion
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Delete Account",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
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
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing:
          trailing ??
          Icon(Iconsax.arrow_right_3, size: 16, color: colorScheme.onSurface),
      onTap: () {
        // Navigate to details if needed
      },
    );
  }
}
