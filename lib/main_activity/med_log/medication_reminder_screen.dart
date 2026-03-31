import 'package:flutter/material.dart';
import '../../widgets/alarm_screen.dart';


class MedicationReminderScreen extends StatelessWidget {
  const MedicationReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReminderTemplateScreen(
      headerTitle: 'Medications Reminder',
      reminderType: 'meds',
      medicineLabel: 'Reminder label',
      medicineHint: 'eg. Take after food',
      showAddMore: false,
    );
  }
}