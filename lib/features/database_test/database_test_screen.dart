import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_test_service.dart';
import '../../services/local_database_service.dart';

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  String _output = 'Tap a button to test the database...';
  bool _isRunning = false;
  Map<String, dynamic>? _testResults;
  Map<String, dynamic>? _dbStats;

  @override
  void initState() {
    super.initState();
    _updateStats();
  }

  void _updateStats() {
    setState(() {
      _dbStats = DatabaseTestService.getDatabaseStats();
    });
  }

  void _appendOutput(String text) {
    setState(() {
      _output += '\n$text';
    });
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunning = true;
      _output = 'Running all database tests...\n';
      _testResults = null;
    });

    try {
      final results = await DatabaseTestService.runAllTests();
      setState(() {
        _testResults = results;
        _output += '\n--- TEST RESULTS ---\n';
        
        final summary = results['summary'];
        if (summary != null) {
          _output += 'Total Tests: ${summary['totalTests']}\n';
          _output += 'Passed: ${summary['passed']}\n';
          _output += 'Failed: ${summary['failed']}\n';
          _output += 'Overall: ${summary['success'] ? '✅ SUCCESS' : '❌ FAILED'}\n';
        }

        // Show individual test results
        results.forEach((key, value) {
          if (key != 'summary' && key != 'error') {
            final success = value['success'] ?? false;
            _output += '\n$key: ${success ? '✅ PASSED' : '❌ FAILED'}';
            if (!success && value['error'] != null) {
              _output += '\n  Error: ${value['error']}';
            }
          }
        });

        if (results['error'] != null) {
          _output += '\nCritical Error: ${results['error']}';
        }
      });
      
      _updateStats();
    } catch (e) {
      setState(() {
        _output += '\nFailed to run tests: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _generateSampleData() async {
    setState(() {
      _isRunning = true;
      _output = 'Generating sample data...\n';
    });

    try {
      // Get current user ID to generate data for the logged-in user
      final currentUser = FirebaseAuth.instance.currentUser;
      final firebaseUid = currentUser?.uid;
      
      await DatabaseTestService.generateSampleData(
        days: 7,
        firebaseUid: firebaseUid,
      );
      
      setState(() {
        _output += 'Sample data generated successfully!\n';
        _output += 'Generated 7 days of sleep tracking data for user: ${firebaseUid ?? 'test_user'}\n';
        _output += 'You can now view real statistics in the Statistics screen.';
      });
      _updateStats();
    } catch (e) {
      setState(() {
        _output += 'Failed to generate sample data: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    setState(() {
      _isRunning = true;
      _output = 'Clearing all test data...\n';
    });

    try {
      await DatabaseTestService.clearTestData();
      setState(() {
        _output += 'Test data cleared successfully!';
      });
      _updateStats();
    } catch (e) {
      setState(() {
        _output += 'Failed to clear data: $e';
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _showUserSessions() async {
    setState(() {
      _output = 'Loading user sleep sessions...\n';
    });

    try {
      final sessions = LocalDatabaseService.getUserSleepSessions(DatabaseTestService.testUserId);
      setState(() {
        _output += 'Found ${sessions.length} sleep sessions:\n';
        
        for (int i = 0; i < sessions.length && i < 10; i++) {
          final session = sessions[i];
          _output += '\nSession ${session['sessionId']}:';
          _output += '\n  Start: ${session['startTime']}';
          _output += '\n  End: ${session['endTime']}';
          _output += '\n  User: ${session['firebaseUid']}';
        }
        
        if (sessions.length > 10) {
          _output += '\n... and ${sessions.length - 10} more sessions';
        }
      });
    } catch (e) {
      setState(() {
        _output += 'Error loading sessions: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        title: Text(
          'Database Test',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _output = 'Output cleared...';
              });
            },
            tooltip: 'Clear Output',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Database Stats Card - Make it more compact
              if (_dbStats != null) ...[
                Card(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Database Statistics',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Make stats more compact with grid layout
                        Wrap(
                          spacing: 16,
                          runSpacing: 4,
                          children: _dbStats!.entries
                              .where((e) => e.key != 'totalRecords' && e.key != 'error')
                              .map((e) => SizedBox(
                                    width: 100,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            e.key,
                                            style: theme.textTheme.bodySmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '${e.value}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                        if (_dbStats!['totalRecords'] != null) ...[
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Records',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${_dbStats!['totalRecords']}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Test Buttons - Make them smaller and more compact
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _CompactButton(
                        onPressed: _isRunning ? null : _runAllTests,
                        icon: Icons.play_arrow,
                        label: 'Run Tests',
                        color: colorScheme.primary,
                      ),
                      _CompactButton(
                        onPressed: _isRunning ? null : _generateSampleData,
                        icon: Icons.data_object,
                        label: 'Generate Data',
                        color: colorScheme.secondary,
                      ),
                      _CompactButton(
                        onPressed: _isRunning ? null : _showUserSessions,
                        icon: Icons.list,
                        label: 'Show Sessions',
                        color: colorScheme.tertiary,
                      ),
                      _CompactButton(
                        onPressed: _isRunning ? null : _clearAllData,
                        icon: Icons.clear_all,
                        label: 'Clear Data',
                        color: colorScheme.error,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Output Section - Much larger and better formatted
              Expanded(
                child: Card(
                  child: Column(
                    children: [
                      // Header with better controls
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.terminal, color: colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Output Console',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            if (_isRunning)
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                                ),
                              ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              onPressed: () {
                                // Copy output to clipboard functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Output copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              tooltip: 'Copy Output',
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                      // Output content with better formatting
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1117), // Dark terminal-like background
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _output,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                color: const Color(0xFFE6EDF3), // Light terminal text
                                height: 1.4, // Better line spacing
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Compact button widget for better layout
class _CompactButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _CompactButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}