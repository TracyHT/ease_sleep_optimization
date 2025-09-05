import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/styles/text_styles.dart';
import '../providers/selected_date_provider.dart';

class DatePickerWidget extends ConsumerWidget {
  const DatePickerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Normalize today's date to midnight
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // Calculate Sunday of the current week
    final int daysToSubtract =
        today.weekday % 7; // Sunday = 7, Monday = 1, etc.
    final startDate = today.subtract(Duration(days: daysToSubtract));

    // Get selected date, default to today
    final selectedDate = ref.watch(selectedDateProvider) ?? today;

    final availableWidth = screenWidth - 32;
    // Estimate total spacing between 6 gaps (e.g., 4px per gap)
    const totalSpacing = 24; // 4px * 6 gaps
    // Width per day, including minimal padding
    final dayWidth = (availableWidth - totalSpacing) / 7;

    // List of days for the current week
    final weekDays = List.generate(7, (index) {
      return startDate.add(Duration(days: index));
    });

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            weekDays.map((date) {
              final isSelected =
                  date.day == selectedDate.day &&
                  date.month == selectedDate.month &&
                  date.year == selectedDate.year;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(selectedDateProvider.notifier).state = DateTime(
                      date.year,
                      date.month,
                      date.day,
                    );
                  },
                  child: Container(
                    width: dayWidth,
                    // height: screenHeight * 0.15,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.month == startDate.month ? 'JUN' : ''}',
                          style:
                              textTheme.bodySmall?.copyWith(
                                fontSize: 7,
                                color:
                                    isSelected
                                        ? AppColors.white
                                        : colorScheme.onSurfaceVariant,
                              ) ??
                              AppTextStyles.bodyMedium.copyWith(
                                fontSize: 7,
                                color:
                                    isSelected
                                        ? AppColors.white
                                        : AppColors.grey,
                              ),
                        ),
                        Text(
                          '${date.day}',
                          style:
                              textTheme.titleMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? AppColors.white
                                        : colorScheme.onSurface,
                              ) ??
                              AppTextStyles.titleMedium.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? AppColors.white
                                        : AppColors.grey,
                              ),
                        ),
                        Text(
                          [
                            'SUN',
                            'MON',
                            'TUE',
                            'WED',
                            'THU',
                            'FRI',
                            'SAT',
                          ][date.weekday - 1],
                          style:
                              textTheme.bodyMedium?.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? AppColors.white
                                        : colorScheme.onSurface.withOpacity(
                                          0.6,
                                        ),
                              ) ??
                              AppTextStyles.bodyMedium.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? AppColors.white
                                        : AppColors.grey,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
