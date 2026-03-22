import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/health_cubit.dart';
import '../models/blood_pressure_entry.dart';
import '../widgets/components.dart';
import 'blood_log/blood_pressure_details_screen.dart';
class MetricsScreen extends StatelessWidget {
  final List<HealthTile> tiles;

  const MetricsScreen({super.key, required this.tiles});

  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} h ago';
    if (difference.inDays <= 7) return '${difference.inDays} days ago';
    return "${dateTime.month}/${dateTime.day}";
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFF111111),
          body: Column(
            children: [
              const SizedBox(height: 22),

              Container(
                width: double.infinity,
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: const Color(0xFF2D2D2D),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      "Metrics",
                      style: GoogleFonts.arimo(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/icons/insights.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 16),

          // Tiles
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
                        if (bpEntries.isNotEmpty) {
                          final latest = bpEntries.last;
                          value = "${latest.systolic}/${latest.diastolic}";
                          subtitle = timeAgo(latest.dateTime);
                        }
                        break;

                      case HealthMetricType.glucose:
                        value = "--";
                        subtitle = "No data";
                        break;

                      case HealthMetricType.weight:
                        value = "--";
                        subtitle = "No data";
                        break;

                      default:
                        break;
                    }

                    return _buildMetricTile(
                      context: context,
                      label: tile.label,
                      icon: tile.icon,
                      value: value,
                      subtitle: subtitle,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
        ));
  }
  Widget _buildMetricTile({
    required String label,
    required String icon,
    required String value,
    required String subtitle,
    required BuildContext context,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          if (label == "Blood Pressure") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BloodPressureDetailsScreen(),
              ),
            );
          }
        },
        child: Container(
          width: double.infinity,
          height: 73,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: ShapeDecoration(
            color: const Color(0xFF2D2D2D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Image.asset(icon, width: 28, height: 28),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.arimo(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: GoogleFonts.arimo(
                          color: Colors.white.withOpacity(0.52),
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
                    color: Colors.white,
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