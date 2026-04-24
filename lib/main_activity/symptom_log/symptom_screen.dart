import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/lang/lang_strings.dart';
import '../../cubit/locale_cubit.dart';
import '../../widgets/log_screen.dart';
import '../../cubit/health_cubit.dart';
import '../../models/symptom_entry.dart';

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});

  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final symptomController = TextEditingController();

  bool buttonEnabled = false;
  int  severity      = 5;

  // English keys used internally; localised at display time.
  static const List<String> _quickSymptomKeys = [
    'symptom_headache',
    'symptom_fever',
    'symptom_cough',
    'symptom_fatigue',
    'symptom_nausea',
    'symptom_dizziness',
  ];

  // English values stored in the entry — independent of UI language.
  static const List<String> _quickSymptomValues = [
    'Headache',
    'Fever',
    'Cough',
    'Fatigue',
    'Nausea',
    'Dizziness',
  ];

  @override
  void initState() {
    super.initState();
    symptomController.addListener(_validate);
  }

  void _validate() {
    final enabled = symptomController.text.isNotEmpty;
    if (enabled != buttonEnabled) setState(() => buttonEnabled = enabled);
  }

  @override
  void dispose() {
    symptomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang  = context.watch<LocaleCubit>().state;
    final isRtl = lang == 'ar';

    return LogEntryScreen(
      title: AppStrings.get('log_symptom', lang),

      buttonEnabled: buttonEnabled,

      onSubmit: (selectedDateTime, notes) {
        context.read<HealthCubit>().addSymptom(
          SymptomEntry(
            symptom:  symptomController.text,
            severity: severity,
            notes:    notes.isEmpty ? null : notes,
            dateTime: selectedDateTime,
          ),
        );
        Navigator.pop(context);
      },

      content: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_quickSymptomKeys.length, (i) {
            return GestureDetector(
              onTap: () {
                // Store the English value so saved entries are
                // language-independent; the chip label is localised.
                symptomController.text = _quickSymptomValues[i];
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppStrings.get(_quickSymptomKeys[i], lang),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: symptomController,
          textDirection:
          isRtl ? TextDirection.rtl : TextDirection.ltr,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: AppStrings.get('enter_symptom', lang),
            hintStyle:
            const TextStyle(color: Color(0xFFB4B4B4)),
            filled: true,
            fillColor: const Color(0xFF0C0C0C),
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 20),
        Text(
          '${AppStrings.get('severity', lang)}: $severity',
          style: const TextStyle(color: Colors.white),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF00C950),
            inactiveTrackColor: Colors.white24,
            thumbColor: const Color(0xFF00C950),
            overlayColor:
            const Color(0xFF00C950).withOpacity(0.2),
            valueIndicatorColor: const Color(0xFF00C950),
            thumbShape:
            const RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 4,
          ),
          child: Slider(
            value: severity.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: severity.toString(),
            onChanged: (value) =>
                setState(() => severity = value.toInt()),
          ),
        ),
      ],
    );
  }
}