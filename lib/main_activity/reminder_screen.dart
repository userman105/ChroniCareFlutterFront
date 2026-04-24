import 'package:chronic_care/main_activity/doctor_log/appointment_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/lang/lang_strings.dart';
import '../cubit/health_cubit.dart';
import '../cubit/locale_cubit.dart'; // Added
import '../models/blood_pressure_entry.dart';
import '../widgets/components.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _measurementsExpanded = false;
  bool _medsExpanded = false;
  String _formatCount(int count, String lang) {
    String text = AppStrings.get('reminder_count', lang);
    if (lang == 'en') {
      text = text.replaceFirst('{s}', count == 1 ? '' : 's');
    }
    return text.replaceFirst('{n}', '$count');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final lang = context.watch<LocaleCubit>().state; // Listen to language

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              height: 52,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              color: color.surface,
              child: Align(
                alignment: lang == 'ar' ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(
                  AppStrings.get('reminders', lang),
                  style: GoogleFonts.arimo(
                    color: color.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            /// BODY
            Expanded(
              child: BlocListener<HealthCubit, List<BloodPressureEntry>>(
                listener: (context, _) => setState(() {}),
                child: Builder(
                  builder: (context) {
                    final allReminders = context.read<HealthCubit>().getReminders();
                    final medsReminders = allReminders.where((r) => r.type == 'meds').toList();
                    final measurementReminders = allReminders.where((r) => r.type != 'meds').toList();

                    Widget buildSection({
                      required String title,
                      required List items,
                      required bool expanded,
                      required VoidCallback onToggle,
                    }) {
                      return Column(
                        children: [
                          /// HEADER
                          GestureDetector(
                            onTap: onToggle,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: color.surfaceContainerHighest,
                                borderRadius: BorderRadius.vertical(
                                  top: const Radius.circular(12),
                                  bottom: Radius.circular(expanded ? 0 : 12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  AnimatedRotation(
                                    turns: expanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 250),
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: color.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    title,
                                    style: GoogleFonts.arimo(
                                      color: color.onSurface,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatCount(items.length, lang),
                                    style: GoogleFonts.arimo(
                                      color: color.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          /// CONTENT
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 250),
                            crossFadeState: expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                            firstChild: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.surface,
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                border: Border.all(color: color.outlineVariant),
                              ),
                              child: items.isEmpty
                                  ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text(
                                    AppStrings.get('no_reminders', lang),
                                    style: GoogleFonts.arimo(
                                      color: color.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                                  : Column(
                                children: items.map((r) => ReminderTile(entry: r)).toList(),
                              ),
                            ),
                            secondChild: const SizedBox(width: double.infinity),
                          ),
                        ],
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          buildSection(
                            title: AppStrings.get("measurements", lang),
                            items: measurementReminders,
                            expanded: _measurementsExpanded,
                            onToggle: () => setState(() => _measurementsExpanded = !_measurementsExpanded),
                          ),
                          const SizedBox(height: 16),
                          buildSection(
                            title: AppStrings.get("meds_section", lang),
                            items: medsReminders,
                            expanded: _medsExpanded,
                            onToggle: () => setState(() => _medsExpanded = !_medsExpanded),
                          ),
                          const SizedBox(height: 20),

                          /// APPOINTMENTS CARD
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AppointmentDetailsScreen()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: color.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.add_chart, color: color.onSurface),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      AppStrings.get("view_appointments", lang),
                                      style: GoogleFonts.arimo(
                                        color: color.onSurface,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    lang == 'ar' ? Icons.folder_shared : Icons.folder,
                                    color: color.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}