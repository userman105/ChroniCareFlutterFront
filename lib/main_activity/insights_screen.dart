import 'package:chronic_care/main_activity/symptom_log/symptoms_details_screen.dart';
import 'package:chronic_care/main_activity/weight_log/weight_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/lang/lang_strings.dart';
import '../cubit/health_cubit.dart';
import '../cubit/locale_cubit.dart';
import '../models/blood_pressure_entry.dart';
import '../models/food_entry.dart';
import '../models/symptom_entry.dart';
import '../models/med_entry.dart';
import '../widgets/components.dart';
import 'blood_log/blood_pressure_details_screen.dart';
import 'food_log/food_details.dart';
import 'glucose_log/glucose_details_screen.dart';
import 'lab_tests_log/lab_details.dart';
import 'med_log/medication_details_screen.dart';


class InsightsScreen extends StatelessWidget {
  final List<HealthTile> tiles;

  const InsightsScreen({super.key, required this.tiles});

  String timeAgo(DateTime dateTime, String lang) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppStrings.get('just_now', lang);
    }
    if (difference.inMinutes < 60) {
      return AppStrings.get('min_ago', lang).replaceFirst('{n}', '${difference.inMinutes}');
    }
    if (difference.inHours < 24) {
      return AppStrings.get('h_ago', lang).replaceFirst('{n}', '${difference.inHours}');
    }
    if (difference.inDays <= 7) {
      return AppStrings.get('days_ago', lang).replaceFirst('{n}', '${difference.inDays}');
    }
    return "${dateTime.month}/${dateTime.day}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = context.watch<LocaleCubit>().state;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: isDark ? const Color(0xFF2D2D2D) : Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get("insights", lang), // Localized
                    style: GoogleFonts.arimo(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Image.asset(
                    'assets/icons/insights.png',
                    width: 30,
                    height: 30,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<HealthCubit, List<BloodPressureEntry>>(
                builder: (context, bpEntries) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tiles.length,
                    itemBuilder: (context, index) {
                      final tile = tiles[index];
                      String value = "";
                      String subtitle = "";

                      switch (tile.type) {
                        case HealthMetricType.bloodPressure:
                          final sorted = List<BloodPressureEntry>.from(bpEntries)
                            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
                          if (sorted.isNotEmpty) {
                            final latest = sorted.last;
                            value = "${latest.systolic}/${latest.diastolic}";
                            subtitle = timeAgo(latest.dateTime, lang);
                          } else {
                            value = "--";
                            subtitle = AppStrings.get("no_data_tile", lang);
                          }
                          break;

                        case HealthMetricType.glucose:
                          final glucoseEntries = List.from(
                            context.read<HealthCubit>().getGlucoseEntries(),
                          )..sort((a, b) => a.dateTime.compareTo(b.dateTime));
                          if (glucoseEntries.isNotEmpty) {
                            final latest = glucoseEntries.last;
                            final mgDl = latest.unit == 'mmol/L' ? latest.value * 18.0182 : latest.value;
                            value = "${mgDl.toStringAsFixed(0)} ${AppStrings.get('mgdl', lang)}";
                            subtitle = timeAgo(latest.dateTime, lang);
                          } else {
                            value = "--";
                            subtitle = AppStrings.get("no_data_tile", lang);
                          }
                          break;

                        case HealthMetricType.weight:
                          final weightEntries = List.from(
                            context.read<HealthCubit>().getWeightEntries(),
                          )..sort((a, b) => a.dateTime.compareTo(b.dateTime));
                          if (weightEntries.isNotEmpty) {
                            final latest = weightEntries.last;
                            final kg = latest.kg ?? (latest.lbs! / 2.20462);
                            value = "${kg.toStringAsFixed(1)} ${AppStrings.get('kg', lang)}";
                            subtitle = timeAgo(latest.dateTime, lang);
                          } else {
                            value = "--";
                            subtitle = AppStrings.get("no_data_tile", lang);
                          }
                          break;

                        case HealthMetricType.symptoms:
                          final symptomEntries = List.from(
                            context.read<HealthCubit>().getSymptomEntries(),
                          )..sort((a, b) => a.dateTime.compareTo(b.dateTime));
                          if (symptomEntries.isNotEmpty) {
                            final latest = symptomEntries.last as SymptomEntry;
                            // Check if the symptom name itself is a key (e.g. "headache")
                            value = AppStrings.get(latest.symptom.toLowerCase(), lang);
                            subtitle = timeAgo(latest.dateTime, lang);
                          } else {
                            value = "--";
                            subtitle = AppStrings.get("no_data_tile", lang);
                          }
                          break;

                        case HealthMetricType.meds:
                          final medicationEntries = List.from(
                            context.read<HealthCubit>().getMedicationEntries(),
                          )..sort((a, b) => a.dateTime.compareTo(b.dateTime));
                          if (medicationEntries.isNotEmpty) {
                            final latest = medicationEntries.last as MedicationEntry;
                            value = latest.medicationName; // Med names usually don't localize
                            subtitle = timeAgo(latest.dateTime, lang);
                          } else {
                            value = "--";
                            subtitle = AppStrings.get("no_data_tile", lang);
                          }
                          break;

                        case HealthMetricType.food:
                          final foodEntries = List.from(
                            context.read<HealthCubit>().getFoodEntries(),
                          )..sort((a, b) => a.dateTime.compareTo(b.dateTime));
                          if (foodEntries.isNotEmpty) {
                            final latest = foodEntries.last as FoodEntry;
                            value = latest.name;
                            subtitle = timeAgo(latest.dateTime, lang);
                          } else {
                            value = "--";
                            subtitle = AppStrings.get("no_data_tile", lang);
                          }
                          break;

                        case HealthMetricType.testLogs:
                          final testEntries = List.from(
                            context.read<HealthCubit>().getLabTests(),
                          )..sort((a, b) => a.testDate.compareTo(b.testDate));
                          if (testEntries.isNotEmpty) {
                            final latest = testEntries.last;
                            value = latest.testName;
                            subtitle = timeAgo(latest.testDate, lang);
                          } else {
                            value = "--";
                            subtitle = AppStrings.get("no_data_tile", lang);
                          }
                          break;
                        default: break;
                      }

                      return _buildMetricTile(
                        context: context,
                        tile: tile,
                        value: value,
                        subtitle: subtitle,
                        isDark: isDark,
                        lang: lang,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required BuildContext context,
    required HealthTile tile,
    required String value,
    required String subtitle,
    required bool isDark,
    required String lang,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // Navigation logic remains the same
          if (tile.type == HealthMetricType.bloodPressure) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodPressureDetailsScreen()));
          } else if(tile.type == HealthMetricType.weight){
            Navigator.push(context, MaterialPageRoute(builder: (_) => WeightDetailsScreen()));
          } else if(tile.type == HealthMetricType.glucose) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => GlucoseDetailsScreen()));
          } else if(tile.type == HealthMetricType.meds) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => MedicationDetailsScreen()));
          } else if(tile.type == HealthMetricType.symptoms) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => SymptomsDetailsScreen()));
          } else if(tile.type == HealthMetricType.food) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => FoodDetailsScreen()));
          } else if (tile.type == HealthMetricType.testLogs) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LabTestDetailsScreen()));
          }
        },
        child: Container(
          width: double.infinity,
          height: 73,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: ShapeDecoration(
            color: isDark ? const Color(0xFF2D2D2D) : Colors.grey[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Row(
            children: [
              Image.asset(tile.icon, width: 28, height: 28, color: isDark ? Colors.white : Colors.black,),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // Localize the tile label key (e.g., 'blood_pressure')
                      AppStrings.get(tile.labelKey, lang),
                      style: GoogleFonts.arimo(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: GoogleFonts.arimo(
                          color: isDark ? Colors.white.withOpacity(0.52) : Colors.black54,
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                  ],
                ),
              ),
              if (value.isNotEmpty)
                Text(
                  value,
                  style: GoogleFonts.arimo(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}