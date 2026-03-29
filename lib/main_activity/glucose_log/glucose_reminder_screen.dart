import 'package:flutter/material.dart';
import '../../widgets/alarm_screen.dart';


class GlucoseReminderScreen extends StatelessWidget {
  const GlucoseReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReminderTemplateScreen(
      headerTitle: 'Glucose Reminder',
      reminderType: 'glucose',
      medicineLabel: 'Reminder label',
      medicineHint: 'eg. Morning BP check',
      showAddMore: false,
    );
  }
}