import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/health_cubit.dart';
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
                    final reminders = context.read<HealthCubit>().getReminders();

                    return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  '${reminders.length} reminder${reminders.length == 1 ? '' : 's'}',
                                  style: GoogleFonts.arimo(
                                    color: Colors.white38,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                            child: reminders.isEmpty
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
                              children: reminders
                                  .map((r) => ReminderTile(
                                entry: r,
                              ))
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
            )],
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
