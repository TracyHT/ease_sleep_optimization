import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/services/hive_service.dart';
import '../../../ui/components/gradient_background.dart';

class DatabaseCMSScreen extends ConsumerStatefulWidget {
  const DatabaseCMSScreen({super.key});

  @override
  ConsumerState<DatabaseCMSScreen> createState() => _DatabaseCMSScreenState();
}

class _DatabaseCMSScreenState extends ConsumerState<DatabaseCMSScreen> {
  String selectedBox = HiveService.alarmsBox;
  
  final List<String> allBoxes = const [
    HiveService.sleepSessionsBox,
    HiveService.devicesBox,
    HiveService.eegRawDataBox,
    HiveService.sleepQualityMetricsBox,
    HiveService.envDataBox,
    HiveService.sleepStagesScoringBox,
    HiveService.eegFeaturesBox,
    HiveService.envLogBox,
    HiveService.userPreferencesBox,
    HiveService.alarmsBox,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Database CMS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: Colors.white),
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Iconsax.trash, color: Colors.redAccent),
            onPressed: _clearAllData,
            tooltip: 'Clear All Data',
          ),
        ],
      ),
      body: GradientBackground(
        primaryOpacity: 0.05,
        child: Column(
          children: [
            // Box Selector
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: DropdownButton<String>(
                value: selectedBox,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white),
                items: allBoxes.map((box) {
                  return DropdownMenuItem<String>(
                    value: box,
                    child: Row(
                      children: [
                        Icon(
                          _getBoxIcon(box),
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        Text(box),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedBox = value);
                  }
                },
              ),
            ),
            
            // Box Contents
            Expanded(
              child: _buildBoxContents(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxContents() {
    if (!HiveService.getBox(selectedBox).isOpen) {
      return const Center(
        child: Text(
          'Box is not open',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final box = HiveService.getBox(selectedBox);
    
    if (box.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.folder_minus,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No records in $selectedBox',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: box.length,
      itemBuilder: (context, index) {
        final key = box.keys.elementAt(index);
        final value = box.get(key);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Key: $key',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Iconsax.copy, size: 16, color: Colors.white70),
                        onPressed: () => _copyToClipboard('$value'),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.trash, size: 16, color: Colors.redAccent),
                        onPressed: () => _deleteRecord(key),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    _formatValue(value),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getBoxIcon(String boxName) {
    switch (boxName) {
      case HiveService.alarmsBox:
        return Iconsax.clock;
      case HiveService.sleepSessionsBox:
        return Iconsax.moon;
      case HiveService.devicesBox:
        return Iconsax.cpu_charge;
      case HiveService.userPreferencesBox:
        return Iconsax.setting_2;
      default:
        return Iconsax.archive_book;
    }
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is Map) {
      return value.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');
    }
    return value.toString();
  }

  void _copyToClipboard(String text) {
    // Import clipboard package if needed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteRecord(dynamic key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E2E),
        title: const Text(
          'Delete Record',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete record with key "$key"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              HiveService.getBox(selectedBox).delete(key);
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Record deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E2E),
        title: const Row(
          children: [
            Icon(Iconsax.warning_2, color: Colors.redAccent),
            SizedBox(width: 12),
            Text(
              'Clear All Database',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ This will permanently delete ALL data from ALL boxes:',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              '• All alarms\n• Sleep sessions\n• Device data\n• User preferences\n• All other records',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 12),
            Text(
              'This action cannot be undone!',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await HiveService.clearAllData();
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to clear data: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'DELETE ALL',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}