import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/lang/lang_strings.dart';
import '../../cubit/locale_cubit.dart';
import '../../widgets/alarm_screen.dart';

class GlucoseReminderScreen extends StatelessWidget {
  const GlucoseReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleCubit>().state;

    return ReminderTemplateScreen(
      headerTitle:   AppStrings.get('glucose_reminder', lang),
      reminderType:  'glucose',
      medicineLabel: AppStrings.get('reminder_label_glucose', lang),
      medicineHint:  AppStrings.get('eg_fasting', lang),
      showAddMore:   false,
    );
  }
}