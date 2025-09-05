import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/models/alarm.dart';
import '../../../ui/components/gradient_background.dart';
import '../providers/alarm_provider.dart';

class AddEditAlarmScreen extends ConsumerStatefulWidget {
  final Alarm? alarm;
  
  const AddEditAlarmScreen({super.key, this.alarm});

  @override
  ConsumerState<AddEditAlarmScreen> createState() => _AddEditAlarmScreenState();
}

class _AddEditAlarmScreenState extends ConsumerState<AddEditAlarmScreen> {
  late TextEditingController _labelController;
  late TimeOfDay _selectedTime;
  late String _selectedSound;
  late bool _snoozeEnabled;
  late int _snoozeDuration;
  late List<int> _repeatDays;
  late String _alarmType;
  
  final List<String> _soundOptions = [
    'Gentle Rise',
    'Soft Bells',
    'Morning Birds',
    'Ocean Waves',
    'Classic Alarm',
    'Digital Beep',
  ];
  
  final List<String> _alarmTypes = [
    'workday',
    'weekend',
    'custom',
    'power_nap',
  ];

  @override
  void initState() {
    super.initState();
    final alarm = widget.alarm;
    
    if (alarm != null) {
      // Edit mode
      _labelController = TextEditingController(text: alarm.label);
      final timeParts = alarm.time.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      _selectedSound = alarm.sound;
      _snoozeEnabled = alarm.snoozeEnabled;
      _snoozeDuration = alarm.snoozeDuration;
      _repeatDays = List.from(alarm.repeatDays);
      _alarmType = alarm.alarmType;
    } else {
      // Add mode
      _labelController = TextEditingController();
      _selectedTime = TimeOfDay.now();
      _selectedSound = _soundOptions[0];
      _snoozeEnabled = true;
      _snoozeDuration = 5;
      _repeatDays = [];
      _alarmType = 'custom';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditMode = widget.alarm != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditMode ? 'Edit Alarm' : 'Add Alarm',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveAlarm,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: GradientBackground(
        primaryOpacity: 0.05,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Picker
              Center(
                child: GestureDetector(
                  onTap: _selectTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _selectedTime.format(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to change time',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Label
              _buildSection(
                'Label',
                TextField(
                  controller: _labelController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter alarm label',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Repeat Days
              _buildSection(
                'Repeat',
                _buildRepeatDaySelector(),
              ),
              
              const SizedBox(height: 24),
              
              // Sound
              _buildSection(
                'Sound',
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedSound,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: const Color(0xFF2E2E2E),
                    style: const TextStyle(color: Colors.white),
                    items: _soundOptions.map((sound) {
                      return DropdownMenuItem<String>(
                        value: sound,
                        child: Text(sound),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedSound = value);
                      }
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Snooze
              _buildSection(
                'Snooze',
                Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Enable Snooze',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: _snoozeEnabled,
                      activeColor: theme.colorScheme.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setState(() => _snoozeEnabled = value);
                      },
                    ),
                    if (_snoozeEnabled) ...[
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Snooze Duration: ',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [5, 10, 15, 20].map((duration) {
                              return ChoiceChip(
                                label: Text('$duration min'),
                                selected: _snoozeDuration == duration,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _snoozeDuration = duration);
                                  }
                                },
                                selectedColor: theme.colorScheme.primary,
                                labelStyle: TextStyle(
                                  color: _snoozeDuration == duration 
                                      ? Colors.white 
                                      : Colors.white70,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildRepeatDaySelector() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isSelected = _repeatDays.contains(index);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _repeatDays.remove(index);
              } else {
                _repeatDays.add(index);
              }
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                days[index].substring(0, 1),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              surface: const Color(0xFF2E2E2E),
            ),
            dialogBackgroundColor: const Color(0xFF2E2E2E),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveAlarm() {
    if (_labelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a label for the alarm'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final timeString = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    
    final alarm = Alarm(
      id: widget.alarm?.id ?? now.millisecondsSinceEpoch.toString(),
      time: timeString,
      label: _labelController.text,
      sound: _selectedSound,
      snoozeEnabled: _snoozeEnabled,
      snoozeDuration: _snoozeDuration,
      alarmType: _alarmType,
      repeatDays: _repeatDays,
      createdAt: widget.alarm?.createdAt ?? now,
      updatedAt: widget.alarm != null ? now : null,
    );

    if (widget.alarm != null) {
      ref.read(alarmsProvider.notifier).updateAlarm(alarm);
    } else {
      ref.read(alarmsProvider.notifier).addAlarm(alarm);
    }

    Navigator.pop(context);
  }
}