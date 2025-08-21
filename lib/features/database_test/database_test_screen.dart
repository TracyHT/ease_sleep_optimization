import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_spacings.dart';
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
      ),
      body: Padding(
        padding: AppSpacing.screenEdgePadding,
        child: Column(
          children: [
            // Database Stats Card
            if (_dbStats != null) ...[
              Card(
                color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                child: Padding(
                  padding: AppSpacing.mediumPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Database Statistics',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      ...(_dbStats!.entries.where((e) => e.key != 'totalRecords' && e.key != 'error').map((e) =>
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: theme.textTheme.bodyMedium),
                              Text('${e.value}', style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: colorScheme.primary,
                              )),
                            ],
                          ),
                        ),
                      ).toList()),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Records',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${_dbStats!['totalRecords'] ?? 0}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
            ],

            // Test Buttons
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _runAllTests,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run All Tests'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _generateSampleData,
                  icon: const Icon(Icons.data_object),
                  label: const Text('Generate Sample Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _showUserSessions,
                  icon: const Icon(Icons.list),
                  label: const Text('Show Sessions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    foregroundColor: colorScheme.onTertiary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _clearAllData,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.medium),

            // Output Section
            Expanded(
              child: Card(
                color: colorScheme.surfaceContainer,
                child: Padding(
                  padding: AppSpacing.mediumPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.terminal, color: colorScheme.primary),
                          const SizedBox(width: AppSpacing.small),
                          Text(
                            'Output',
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
                        ],
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: AppSpacing.smallPadding,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _output,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}