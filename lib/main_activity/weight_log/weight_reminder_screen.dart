import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/lang/lang_strings.dart';
import '../../cubit/locale_cubit.dart';
import '../../widgets/alarm_screen.dart';

class WeightReminderScreen extends StatelessWidget {
  const WeightReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleCubit>().state;

    return ReminderTemplateScreen(
      headerTitle:   AppStrings.get('weight_reminder', lang),
      reminderType:  'weight',
      medicineLabel: AppStrings.get('reminder_label_weight', lang),
      medicineHint:  AppStrings.get('eg_morning_weight', lang),
      showAddMore:   false,
    );
  }
}