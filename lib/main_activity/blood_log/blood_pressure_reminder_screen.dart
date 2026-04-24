import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/lang/lang_strings.dart';
import '../../cubit/locale_cubit.dart';
import '../../widgets/alarm_screen.dart';

class BloodPressureReminderScreen extends StatelessWidget {
  const BloodPressureReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleCubit>().state;

    return ReminderTemplateScreen(
      headerTitle:   AppStrings.get('blood_pressure_reminder', lang),
      reminderType:  'blood_pressure',
      medicineLabel: AppStrings.get('reminder_label_bp', lang),
      medicineHint:  AppStrings.get('eg_morning_bp', lang),
      showAddMore:   false,
    );
  }
}