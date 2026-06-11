import 'package:chronic_care/main_activity/food_log/food_log_screen.dart';
import 'package:chronic_care/main_activity/glucose_log/glucose_log_screen.dart';
import 'package:chronic_care/main_activity/lab_tests_log/lab_log.dart';
import 'package:chronic_care/main_activity/med_log/medication_log_screen.dart';
import 'package:chronic_care/main_activity/symptom_log/symptom_screen.dart';
import 'package:chronic_care/main_activity/weight_log/weight_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/lang/lang_strings.dart';
import '../cubit/health_cubit.dart';
import '../cubit/locale_cubit.dart';
import '../services/connectivity_service.dart';
import '../services/notification_service.dart';
import '../widgets/components.dart';
import 'blood_log/blood_log_screen.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reminders = context.read<HealthCubit>().getReminders();
      NotificationService.syncUpcomingToDrawer(reminders);
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthCubit = context.watch<HealthCubit>();
    final tiles = healthCubit.getTiles();
    final lang = context.watch<LocaleCubit>().state;

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              TodayDateBar(calendarIconAsset: 'assets/icons/calendar.png'),
              Positioned(
                top: 6,
                right:80,
                child: _BackendIndicator(),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...List.generate(tiles.length, (index) {
                      final tile = tiles[index];

                      return ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 100, // minimum cell width — adjust to taste
                        ),
                        child: IntrinsicWidth(
                          child: HighlightableGridTile(
                            iconAsset: tile.icon,
                            label: AppStrings.get(tile.labelKey, lang),
                            selected: false,
                            onTap: () {
                              switch (tile.type) {
                                case HealthMetricType.bloodPressure:
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodPressureScreen()));
                                  break;
                                case HealthMetricType.glucose:
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => GlucoseScreen()));
                                  break;
                                case HealthMetricType.weight:
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => WeightLogScreen()));
                                  break;
                                case HealthMetricType.meds:
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => MedicationLogScreen()));
                                  break;
                                case HealthMetricType.symptoms:
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => SymptomScreen()));
                                  break;
                                case HealthMetricType.food:
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => FoodLogScreen()));
                                  break;
                                case HealthMetricType.testLogs:
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => LabTestLogScreen()));
                                  break;
                                default:
                                  break;
                              }
                            },
                          ),
                        ),
                      );
                    }),

                    // Add Entry button — unchanged
                    GestureDetector(
                      onTap: () async {
                        final selectedTile = await AddEntryPopup.show(context, tiles);
                        if (selectedTile == null) return;
                        context.read<HealthCubit>().addTile(selectedTile.labelKey);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D2D),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/icons/add.png', width: 20, height: 20),
                            const SizedBox(width: 6),
                            Text(
                              AppStrings.get('add_entry', lang),
                              style: GoogleFonts.arimo(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                LogDrawers(
                  reminders: healthCubit.getReminders(),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackendIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BackendStatus>(
      stream: ConnectivityService().status,
      initialData: ConnectivityService().current,
      builder: (context, snap) {
        final status = snap.data ?? BackendStatus.checking;

        final (icon, color, tooltip) = switch (status) {
          BackendStatus.connected    => (Icons.cloud_done_rounded,   const Color(0xFF4CAF50), 'Synced'),
          BackendStatus.disconnected => (Icons.cloud_off_rounded,    const Color(0xFFFF5252), 'Offline'),
          BackendStatus.checking     => (Icons.cloud_sync_rounded,   const Color(0xFFFFB300), 'Connecting…'),
        };

        return Tooltip(
          message: tooltip,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(status),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
              ),
              child: status == BackendStatus.checking
                  ? Padding(
                padding: const EdgeInsets.all(7),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
                  : Icon(icon, size: 17, color: color),
            ),
          ),
        );
      },
    );
  }
}