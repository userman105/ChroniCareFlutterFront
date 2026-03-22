import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/health_cubit.dart';
import 'components.dart';

class LogEntryScreen extends StatefulWidget {
  final String title;
  final List<Widget> content;
  final bool buttonEnabled;
  final Function(DateTime selectedDateTime, String notes) onSubmit;

  const LogEntryScreen({
    super.key,
    required this.title,
    this.content = const [],
    required this.buttonEnabled,
    required this.onSubmit,
  });

  @override
  State<LogEntryScreen> createState() => _LogEntryScreenState();
}

class _LogEntryScreenState extends State<LogEntryScreen> {

  final TextEditingController notesController = TextEditingController();

  String currentTime = "";
  String currentDate = "";
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();

    final cubit = context.read<HealthCubit>();
    selectedDate = cubit.getSelectedDate();

    selectedTime = TimeOfDay.now();

    _updateDateLabel(selectedDate);
    _updateTimeLabel(selectedTime);
  }

  void _setDateTime() {
    final now = DateTime.now();

    selectedDate = now;
    selectedTime = TimeOfDay.fromDateTime(now);

    _updateDateLabel(now);
    _updateTimeLabel(selectedTime);
  }

  String _monthName(int month) {
    const months = [
      "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF212121),

      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Container(
              height: 46,
              color: const Color(0xFF2D2D2D),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [

                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),

                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.arimo(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 25),

                    /// DATE / TIME LABEL
                    Text(
                      "Date/Time:",
                      style: GoogleFonts.arimo(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// DATE TIME CHIPS
                    Row(
                      children: [

                        /// DATE CHIP
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF313131),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [

                                Image.asset(
                                  "assets/icons/calendar.png",
                                  width: 14,
                                  height: 14,
                                ),

                                const SizedBox(width: 6),

                                Text(
                                  currentDate,
                                  style: GoogleFonts.arimo(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// TIME CHIP
                        GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF313131),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [

                                Image.asset(
                                  "assets/icons/clock.png",
                                  width: 14,
                                  height: 14,
                                ),

                                const SizedBox(width: 6),

                                Text(
                                  currentTime,
                                  style: GoogleFonts.arimo(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 25),

                    /// CUSTOM CONTENT SLOT
                    ...widget.content,

                    const SizedBox(height: 25),

                    /// NOTES LABEL
                    Text(
                      "Notes",
                      style: GoogleFonts.arimo(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// NOTES FIELD
                    TextField(
                      controller: notesController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "eg. take after food",
                        hintStyle: GoogleFonts.arimo(
                          color: const Color(0xFFB4B4B4),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0C0C0C),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// ADD REMINDER BUTTON
                    GestureDetector(
                      onTap: () {
                        // TODO open reminder picker
                      },
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Image.asset("assets/icons/bell.png",
                            width: 18,height: 18,),
                            const SizedBox(width: 6),

                            Center(
                              child: Text(
                                "Add reminder",
                                style: GoogleFonts.arimo(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    /// MAIN BUTTON
                    MainButton(
                      text: "Add",
                      enabled: widget.buttonEnabled,
                      onTap: () {
                        final selectedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                        widget.onSubmit(selectedDateTime, notesController.text);
                      },
                    ),

                    const SizedBox(height: 20),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: now, // prevents selecting future dates
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });

      _updateDateLabel(picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked == null) return;

    final now = DateTime.now();

    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      picked.hour,
      picked.minute,
    );

    if (selectedDateTime.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Future time cannot be selected"),
        ),
      );
      return;
    }

    setState(() {
      selectedTime = picked;

      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final period = picked.period == DayPeriod.pm ? "pm" : "am";

      currentTime =
      "$hour:${picked.minute.toString().padLeft(2, '0')}$period";
    });
  }
  void _updateDateLabel(DateTime date) {
    final now = DateTime.now();

    final isToday =
        date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

    setState(() {
      currentDate = isToday
          ? "Today: ${_monthName(date.month)} ${date.day}"
          : "${_monthName(date.month)} ${date.day}";

    });
  }

  void _updateTimeLabel(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.pm ? "pm" : "am";

    setState(() {
      currentTime =
      "$hour:${time.minute.toString().padLeft(2, '0')}$period";
    });
  }

}

