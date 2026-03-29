import 'package:chronic_care/main_activity/doctor_log/appointment_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/lang/lang_strings.dart';
import '../cubit/health_cubit.dart';
import '../cubit/locale_cubit.dart'; // Added
import '../models/blood_pressure_entry.dart';
import '../widgets/components.dart';

/*

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
*/

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Reminder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/settings.png',
              width: 24,
              height: 24,
              colorBlendMode: BlendMode.multiply,
            ),
            onPressed: null,
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 45, 45, 45),
      ),

      body: ListView(
        children: [
          SizedBox(height: 20),
          //
          ExpansionTile(
            collapsedIconColor: Colors.white,
            iconColor: Colors.white,
            title: Text(
              "Measurements",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              Card(
                color: const Color.fromARGB(255, 68, 68, 68),
                child: ListTile(
                  leading: Image.asset(
                    'assets/icons/bloodPressure.png',
                    width: 24,
                    height: 24,
                    colorBlendMode: BlendMode.multiply,
                  ),
                  title: Text(
                    "Blood Pressure",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "Daily - 2:00 pm",
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Image.asset(
                    'assets/icons/calendarEdit.png',
                    width: 24,
                    height: 24,
                    colorBlendMode: BlendMode.multiply,
                  ),
                ),
              ),

              Card(
                color: const Color.fromARGB(255, 68, 68, 68),
                child: ListTile(
                  leading: Image.asset(
                    'assets/icons/diabetes.png',
                    width: 24,
                    height: 24,
                    colorBlendMode: BlendMode.multiply,
                  ),
                  title: Text("Glucose", style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    "Daily - 4:00 pm",
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Image.asset(
                    'assets/icons/calendarEdit.png',
                    width: 24,
                    height: 24,
                    colorBlendMode: BlendMode.multiply,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          ExpansionTile(
            collapsedIconColor: Colors.white,
            iconColor: Colors.white,
            title: Text(
              "Meds",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              Card(
                color: const Color.fromARGB(255, 68, 68, 68),
                child: ListTile(
                  leading: Image.asset(
                    'assets/icons/capsule.png',
                    width: 24,
                    height: 24,
                    colorBlendMode: BlendMode.multiply,
                  ),
                  title: Text(
                    "Cordarone 200 mg",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "Daily - 8:00 am",
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Image.asset(
                    'assets/icons/calendarEdit.png',
                    width: 24,
                    height: 24,
                    colorBlendMode: BlendMode.multiply,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          ExpansionTile(
            collapsedIconColor: Colors.white,
            iconColor: Colors.white,
            title: Text(
              "Other",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              Card(
                color: const Color.fromARGB(255, 68, 68, 68),
                child: ListTile(
                  title: Text(
                    "None added yet",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
