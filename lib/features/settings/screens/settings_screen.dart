import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
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
                            backgroundColor: colorScheme.primary.withOpacity(
                              0.3,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "User Name",
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Edit Information",
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Statistics
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _StatCard(title: "Session Tracked", value: "20"),
                        _StatCard(title: "Avg Score", value: "80"),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Privacy Information Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: colorScheme.primary.withOpacity(
                              0.3,
                            ),
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
                    _SettingTile(
                      title: "Dark Mode",
                      trailing: Switch(
                        value: false,
                        onChanged: (val) {},
                        activeColor: colorScheme.primary,
                      ),
                    ),
                    const _SettingTile(title: "Privacy"),
                    const _SettingTile(title: "Measurement Units"),
                    const SizedBox(height: 40),

                    // Action Buttons
                    ElevatedButton(
                      onPressed: () {
                        // handle logout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondaryContainer,
                        foregroundColor: colorScheme.onSecondaryContainer,
                        minimumSize: const Size.fromHeight(50),
                        elevation: 0,
                      ),
                      child: const Text("Log Out"),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        // handle account deletion
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
          );
        },
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
