import 'package:chronic_care/main_activity/glucose_log/glucose_reminder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/lang/lang_strings.dart';
import '../../cubit/locale_cubit.dart';
import '../../models/glucose_entry.dart';
import '../../widgets/components.dart';
import '../../widgets/log_screen.dart';
import '../../cubit/health_cubit.dart';

class GlucoseScreen extends StatefulWidget {
  const GlucoseScreen({super.key});

  @override
  State<GlucoseScreen> createState() => _GlucoseScreenState();
}

class _GlucoseScreenState extends State<GlucoseScreen> {
  final glucoseController = TextEditingController();

  String selectedUnit  = 'mg/dl';
  bool   buttonEnabled = false;

  @override
  void initState() {
    super.initState();
    glucoseController.addListener(() {
      final enabled = glucoseController.text.isNotEmpty;
      if (enabled != buttonEnabled) setState(() => buttonEnabled = enabled);
    });
  }

  @override
  void dispose() {
    glucoseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleCubit>().state;

    return LogEntryScreen(
      title: AppStrings.get('log_glucose', lang),

      buttonEnabled: buttonEnabled,

      onAddReminder: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const GlucoseReminderScreen(),
        ),
      ),

      onSubmit: (selectedDateTime, notes) {
        final value = double.tryParse(glucoseController.text);
        if (value == null) return;

        context.read<HealthCubit>().addGlucose(
          GlucoseEntry(
            value: value,
            unit: selectedUnit,
            dateTime: selectedDateTime,
            notes: notes,
          ),
        );

        Navigator.pop(context);
      },

      content: [
        GlucoseInput(
          controller: glucoseController,
          onUnitChanged: (unit) => selectedUnit = unit,
        ),
      ],
    );
  }
}