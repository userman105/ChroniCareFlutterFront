import 'package:flutter/material.dart';
import '../../widgets/alarm_screen.dart';


class WeightReminderScreen extends StatelessWidget {
  const WeightReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReminderTemplateScreen(
      headerTitle: 'Weight Reminder',
      reminderType: 'weight',
      medicineLabel: 'Reminder label',
      medicineHint: 'eg. Morning BP check',
      showAddMore: false,
    );
  }
}