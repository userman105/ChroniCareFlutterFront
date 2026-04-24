import 'package:chronic_care/main_activity/weight_log/weight_reminder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/lang/lang_strings.dart';
import '../../cubit/locale_cubit.dart';
import '../../widgets/log_screen.dart';
import '../../widgets/components.dart';
import '../../cubit/health_cubit.dart';
import '../../models/weight_entry.dart';

class WeightLogScreen extends StatefulWidget {
  const WeightLogScreen({super.key});

  @override
  State<WeightLogScreen> createState() => _WeightLogScreenState();
}

class _WeightLogScreenState extends State<WeightLogScreen> {
  final kgController  = TextEditingController();
  final lbsController = TextEditingController();

  bool buttonEnabled = false;

  @override
  void initState() {
    super.initState();
    kgController.addListener(_validate);
    lbsController.addListener(_validate);
  }

  void _validate() {
    final enabled =
        kgController.text.isNotEmpty || lbsController.text.isNotEmpty;
    if (enabled != buttonEnabled) setState(() => buttonEnabled = enabled);
  }

  @override
  void dispose() {
    kgController.dispose();
    lbsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleCubit>().state;

    return LogEntryScreen(
      title: AppStrings.get('log_weight', lang),

      buttonEnabled: buttonEnabled,

      onAddReminder: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WeightReminderScreen(),
        ),
      ),

      onSubmit: (selectedDateTime, notes) {
        final kg  = double.tryParse(kgController.text);
        final lbs = double.tryParse(lbsController.text);

        if (kg == null && lbs == null) return;

        context.read<HealthCubit>().addWeight(
          WeightEntry(
            kg:       kg,
            lbs:      lbs,
            dateTime: selectedDateTime,
            notes:    notes,
          ),
        );

        Navigator.pop(context);
      },

      content: [
        WeightInputs(
          kgController:  kgController,
          lbsController: lbsController,
        ),
      ],
    );
  }
}