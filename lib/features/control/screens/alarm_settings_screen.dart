import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacings.dart';
import '../providers/controls_provider.dart';

class AlarmSettingsScreen extends ConsumerStatefulWidget {
  final String alarmType;
  final String initialValue;

  const AlarmSettingsScreen({
    super.key,
    required this.alarmType,
    required this.initialValue,
  });

  @override
  ConsumerState<AlarmSettingsScreen> createState() =>
      _AlarmSettingsScreenState();
}

class _AlarmSettingsScreenState extends ConsumerState<AlarmSettingsScreen> {
  late TextEditingController _labelController;
  late String _selectedTime;
  final List<String> _timeOptions = _generateTimeOptions();
  bool _snoozeEnabled = true;
  String _selectedSound = 'Default';
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialValue;
    _labelController = TextEditingController(text: widget.alarmType);
    _scrollController = FixedExtentScrollController(
      initialItem: _timeOptions.indexOf(_selectedTime),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  static List<String> _generateTimeOptions() {
    final times = <String>[];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute++) {
        times.add(
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
        );
      }
    }
    return times;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarmType),
        // backgroundColor: colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              ref.read(controlsProvider.notifier).state = {
                ...ref.read(controlsProvider),
                widget.alarmType.toLowerCase(): _selectedTime,
              };
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        color: colorScheme.background,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 40.0 + MediaQuery.of(context).padding.top,
              left: AppSpacing.screenEdgePadding.left,
              right: AppSpacing.screenEdgePadding.right,
              bottom: AppSpacing.screenEdgePadding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.medium),
                // Styled Time Selector with Fixed Highlight
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Scrolling wheel for times
                        ListWheelScrollView.useDelegate(
                          itemExtent: 50,
                          perspective: 0.005,
                          diameterRatio: 1.5,
                          useMagnifier: true,
                          magnification: 1.3,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedTime = _timeOptions[index];
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: _timeOptions.length,
                            builder: (context, index) {
                              final isSelected =
                                  _timeOptions[index] == _selectedTime;
                              return Center(
                                child: Text(
                                  _timeOptions[index],
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? Colors
                                                .transparent // Hide text when selected
                                            : colorScheme.onBackground
                                                .withOpacity(0.6),
                                  ),
                                ),
                              );
                            },
                          ),
                          controller: _scrollController,
                        ),
                        // Fixed highlight with selected time
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _selectedTime,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                // Smart Alarm Notification
                Container(
                  padding: const EdgeInsets.all(AppSpacing.small),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Colors.pink),
                      const SizedBox(width: AppSpacing.small),
                      Expanded(
                        child: Text(
                          'Smart Alarm will wake you up during your Wake Window from 7:00 to 7:30',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                // Settings Fields
                TextField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    labelText: 'Label',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    // Update label if needed
                  },
                ),
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Alarm Sound',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: _selectedSound,
                  items: const [
                    DropdownMenuItem(value: 'Default', child: Text('Default')),
                    DropdownMenuItem(value: 'Gentle', child: Text('Gentle')),
                    DropdownMenuItem(
                      value: 'Birdsong',
                      child: Text('Birdsong'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSound = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.medium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Snooze', style: theme.textTheme.bodyMedium),
                    Switch(
                      value: _snoozeEnabled,
                      onChanged: (value) {
                        setState(() {
                          _snoozeEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
