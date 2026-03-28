import 'package:flutter/material.dart';
import '../../widgets/alarm_screen.dart';


class BloodPressureReminderScreen extends StatelessWidget {
  const BloodPressureReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReminderTemplateScreen(
      headerTitle: 'Blood Pressure Reminder',
      reminderType: 'blood_pressure',
      medicineLabel: 'Reminder label',
      medicineHint: 'eg. Morning BP check',
      showAddMore: false,
    );
  }
}