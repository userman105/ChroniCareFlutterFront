import 'package:chronic_care/main_activity/food_log/food_log_screen.dart';
import 'package:chronic_care/main_activity/glucose_log/glucose_log_screen.dart';
import 'package:chronic_care/main_activity/med_log/medication_log_screen.dart';
import 'package:chronic_care/main_activity/symptom_log/symptom_screen.dart';
import 'package:chronic_care/main_activity/weight_log/weight_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/health_cubit.dart';
import '../widgets/components.dart';
import 'blood_log/blood_log_screen.dart';




class TodayScreen extends StatefulWidget {
  final List<HealthTile> tiles;

  const TodayScreen({
    super.key,
    required this.tiles,
  });

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TodayDateBar(
          calendarIconAsset: 'assets/icons/calendar.png',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Column(
            children: [

              const SizedBox(height: 20),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.3,
                ),
                itemCount: widget.tiles.length + 1,
                itemBuilder: (context, index) {
                  if (index == widget.tiles.length) {
                    return GestureDetector(
                      onTap: () async {
                        final selectedTile =
                        await AddEntryPopup.show(context, widget.tiles);

                        if (selectedTile == null) return;

                        setState(() {
                          final alreadyExists = widget.tiles
                              .any((t) => t.label == selectedTile.label);
                          if (!alreadyExists) {
                            widget.tiles.add(
                              HealthTile(
                                icon: selectedTile.icon,
                                label: selectedTile.label,
                                selected: false,
                              ),
                            );
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D2D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/add.png',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Add Entry",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.arimo(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final tile = widget.tiles[index];

                  return HighlightableGridTile(
                    iconAsset: tile.icon,
                    label: tile.label,
                    selected: tile.selected,
                    onTap: () {
                      setState(() {
                        for (var t in widget.tiles) t.selected = false;
                        tile.selected = true;
                      });

                      switch (tile.type) {
                        case HealthMetricType.bloodPressure:
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const BloodPressureScreen(),
                          ));
                          break;
                        case HealthMetricType.glucose:
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_)=>GlucoseScreen()));
                          break;
                        case HealthMetricType.weight:
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_)=>WeightLogScreen()));
                          break;
                        case HealthMetricType.meds:
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_)=>MedicationLogScreen()));
                        case HealthMetricType.symptoms:
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_)=>SymptomScreen()));
                        case HealthMetricType.food:
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_)=>FoodLogScreen()));


                        default:
                          break;
                      }
                    },
                  );
                },
              ),

              const SizedBox(height: 16),
              LogDrawers(reminders: context.watch<HealthCubit>().getReminders()),

            ],
          ),
        ),
      ],
    );
  }
}