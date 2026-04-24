import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/lang/lang_strings.dart';
import '../../cubit/locale_cubit.dart';
import '../../widgets/alarm_screen.dart';

class MedicationReminderScreen extends StatelessWidget {
  const MedicationReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleCubit>().state;

    return ReminderTemplateScreen(
      headerTitle:   AppStrings.get('medication_reminder', lang),
      reminderType:  'meds',
      medicineLabel: AppStrings.get('reminder_label_med', lang),
      medicineHint:  AppStrings.get('eg_take_after_food_hint', lang),
      showAddMore:   false,
    );
  }
}