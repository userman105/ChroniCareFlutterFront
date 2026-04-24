import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/lang/lang_strings.dart';
import '../../widgets/components.dart';
import '../../widgets/log_screen.dart';
import '../../cubit/health_cubit.dart';
import '../../cubit/locale_cubit.dart';
import '../../models/blood_pressure_entry.dart';
import 'blood_pressure_reminder_screen.dart';

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key});

  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  final systolicController  = TextEditingController();
  final diastolicController = TextEditingController();
  final heartRateController = TextEditingController();

  bool buttonEnabled = false;

  @override
  void initState() {
    super.initState();
    systolicController.addListener(_validate);
    diastolicController.addListener(_validate);
  }

  void _validate() {
    final enabled =
        systolicController.text.isNotEmpty &&
            diastolicController.text.isNotEmpty;

    if (enabled != buttonEnabled) setState(() => buttonEnabled = enabled);
  }

  @override
  void dispose() {
    systolicController.dispose();
    diastolicController.dispose();
    heartRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleCubit>().state;

    return LogEntryScreen(
      title: AppStrings.get('log_blood_pressure', lang),

      buttonEnabled: buttonEnabled,

      onAddReminder: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const BloodPressureReminderScreen(),
        ),
      ),

      onSubmit: (selectedDateTime, notes) {
        final systolic  = int.tryParse(systolicController.text);
        final diastolic = int.tryParse(diastolicController.text);
        final heartRate = int.tryParse(heartRateController.text);

        if (systolic == null || diastolic == null) return;

        context.read<HealthCubit>().addBloodPressure(
          BloodPressureEntry(
            systolic: systolic,
            diastolic: diastolic,
            heartRate: heartRate,
            dateTime: selectedDateTime,
            notes: notes,
          ),
        );

        Navigator.pop(context);
      },

      content: [
        BloodPressureInputs(
          systolicController: systolicController,
          diastolicController: diastolicController,
          heartRateController: heartRateController,
        ),
      ],
    );
  }
}