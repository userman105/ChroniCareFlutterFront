import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/health_cubit.dart';
import '../models/blood_pressure_entry.dart';
import '../widgets/components.dart';

class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        title: Text(
          "All Metrics",
          style: GoogleFonts.arimo(),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
      ),
      body: BlocBuilder<HealthCubit, List<BloodPressureEntry>>(
        builder: (context, entries) {

          if (entries.isEmpty) {
            return const Center(
              child: Text(
                "No data yet",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];

              return ListTile(
                title: Text(
                  "${entry.systolic}/${entry.diastolic} mmHg",
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  entry.dateTime.toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}