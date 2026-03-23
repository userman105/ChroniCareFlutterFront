import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/components.dart';
import '../../widgets/log_screen.dart';
import '../../cubit/health_cubit.dart';
import '../../models/blood_pressure_entry.dart';

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key});

  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {

  final systolicController = TextEditingController();
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

    if (enabled != buttonEnabled) {
      setState(() {
        buttonEnabled = enabled;
      });
    }
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
    return LogEntryScreen(
      title: "Log Blood Pressure",

      buttonEnabled: buttonEnabled,

      onSubmit: (selectedDateTime, notes) {
        final systolic = int.tryParse(systolicController.text);
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