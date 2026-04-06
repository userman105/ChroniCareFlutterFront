import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/health_cubit.dart';
import '../models/blood_pressure_entry.dart';
import '../widgets/components.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _measurementsExpanded = false;
  bool _medsExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 46,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              color: const Color(0xFF2D2D2D),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reminders',
                  style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocListener<HealthCubit, List<BloodPressureEntry>>(
                listener: (context, _) => setState(() {}), // rebuilds screen on cubit emit
                child: Builder(
                  builder: (context) {
                    final allReminders = context.read<HealthCubit>().getReminders();

                    final medsReminders =
                    allReminders.where((r) => r.type == 'meds').toList();

                    final measurementReminders =
                    allReminders.where((r) => r.type != 'meds').toList();

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Measurements Header ---
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() =>
                            _measurementsExpanded = !_measurementsExpanded),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D2D2D),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12),
                                  topRight: const Radius.circular(12),
                                  bottomLeft: Radius.circular(
                                      _measurementsExpanded ? 0 : 12),
                                  bottomRight: Radius.circular(
                                      _measurementsExpanded ? 0 : 12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  AnimatedRotation(
                                    turns:
                                    _measurementsExpanded ? 0.5 : 0,
                                    duration:
                                    const Duration(milliseconds: 250),
                                    child: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Measurements',
                                    style: GoogleFonts.arimo(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${measurementReminders.length} reminder${measurementReminders.length == 1 ? '' : 's'}',
                                    style: GoogleFonts.arimo(
                                      color: Colors.white38,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // --- Measurements Content ---
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 250),
                            crossFadeState: _measurementsExpanded
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            firstChild: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                border: Border.all(
                                    color: Colors.white12, width: 0.5),
                              ),
                              child: measurementReminders.isEmpty
                                  ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20),
                                child: Center(
                                  child: Text(
                                    'No reminders yet',
                                    style: GoogleFonts.arimo(
                                        color: Colors.white38,
                                        fontSize: 14),
                                  ),
                                ),
                              )
                                  : Column(
                                children: measurementReminders
                                    .map((r) => ReminderTile(
                                  entry: r,
                                ))
                                    .toList(),
                              ),
                            ),
                            secondChild: const SizedBox(width: double.infinity),
                          ),

                          const SizedBox(height: 16), // Adjusted from 100 to standard spacing

                          // --- Meds Header ---
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _medsExpanded = !_medsExpanded),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D2D2D),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12),
                                  topRight: const Radius.circular(12),
                                  bottomLeft: Radius.circular(_medsExpanded ? 0 : 12),
                                  bottomRight: Radius.circular(_medsExpanded ? 0 : 12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  AnimatedRotation(
                                    turns: _medsExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 250),
                                    child: const Icon(Icons.keyboard_arrow_down,
                                        color: Colors.white, size: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Meds',
                                    style: GoogleFonts.arimo(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${medsReminders.length} reminder${medsReminders.length == 1 ? '' : 's'}',
                                    style: GoogleFonts.arimo(
                                      color: Colors.white38,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // --- Meds Content ---
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 250),
                            crossFadeState:
                            _medsExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                            firstChild: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                border: Border.all(color: Colors.white12, width: 0.5),
                              ),
                              child: medsReminders.isEmpty
                                  ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text(
                                    'No medication reminders',
                                    style: GoogleFonts.arimo(
                                        color: Colors.white38, fontSize: 14),
                                  ),
                                ),
                              )
                                  : Column(
                                children: medsReminders
                                    .map((r) => ReminderTile(entry: r))
                                    .toList(),
                              ),
                            ),
                            secondChild: const SizedBox(width: double.infinity),
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
