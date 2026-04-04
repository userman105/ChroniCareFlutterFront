import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  int severity = 5;

  final List<String> quickSymptoms = [
    "Headache",
    "Fever",
    "Cough",
    "Fatigue",
    "Nausea",
    "Dizziness",
  ];

  @override
  void initState() {
    super.initState();
    symptomController.addListener(_validate);
  }

  void _validate() {
    final enabled = symptomController.text.isNotEmpty;

    if (enabled != buttonEnabled) {
      setState(() {
        buttonEnabled = enabled;
      });
    }
  }

  @override
  void dispose() {
    symptomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LogEntryScreen(
      title: "Log Symptom",

      buttonEnabled: buttonEnabled,

      onSubmit: (selectedDateTime, notes) {
        context.read<HealthCubit>().addSymptom(
          SymptomEntry(
            symptom: symptomController.text,
            severity: severity,
            notes: notes.isEmpty ? null : notes,
            dateTime: selectedDateTime,
          ),
        );

        Navigator.pop(context);
      },

      content: [

        /// 🔹 Quick Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickSymptoms.map((symptom) {
            return GestureDetector(
              onTap: () {
                symptomController.text = symptom;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  symptom,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        /// 🔹 Manual input
        TextField(
          controller: symptomController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter symptom",
            hintStyle: TextStyle(color: Color(0xFFB4B4B4)),
            filled: true,
            fillColor: Color(0xFF0C0C0C),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          "Severity: $severity",
          style: const TextStyle(color: Colors.white),
        ),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF00C950),
            inactiveTrackColor: Colors.white24,
            thumbColor: const Color(0xFF00C950),
            overlayColor: const Color(0xFF00C950).withOpacity(0.2), // ripple
            valueIndicatorColor: const Color(0xFF00C950),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 4,
          ),
          child: Slider(
            value: severity.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: severity.toString(),
            onChanged: (value) {
              setState(() {
                severity = value.toInt();
              });
            },
          ),
        )
      ],
    );
  }
}