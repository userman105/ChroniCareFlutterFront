import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/health_cubit.dart';
import '../../models/appointment_entry.dart';
import '../../widgets/components.dart';

class AppointmentLogScreen extends StatefulWidget {
  const AppointmentLogScreen({super.key});

  @override
  State<AppointmentLogScreen> createState() =>
      _AppointmentLogScreenState();
}

class _AppointmentLogScreenState extends State<AppointmentLogScreen> {
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _currentDate = '';
  String _currentTime = '';

  bool get _canSubmit => _nameCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _updateDateLabel(_selectedDate);
    _updateTimeLabel(_selectedTime);
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _monthName(int m) => const [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ][m - 1];

  void _updateDateLabel(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final tomorrow = now.add(const Duration(days: 1));
    final isTomorrow = date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;

    setState(() {
      if (isToday) {
        _currentDate = 'Today: ${_monthName(date.month)} ${date.day}';
      } else if (isTomorrow) {
        _currentDate = 'Tomorrow: ${_monthName(date.month)} ${date.day}';
      } else {
        _currentDate = '${_monthName(date.month)} ${date.day}, ${date.year}';
      }
    });
  }

  void _updateTimeLabel(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'am' : 'pm';
    setState(() => _currentTime = '$h:$m$p');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00C950),
            surface: Color(0xFF2D2D2D),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _updateDateLabel(picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00C950),
            surface: Color(0xFF2D2D2D),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
      _updateTimeLabel(picked);
    }
  }

  void _submit() {
    final dt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    context.read<HealthCubit>().addAppointment(AppointmentEntry(
      appointmentName: _nameCtrl.text.trim(),
      location: _locationCtrl.text.trim().isEmpty
          ? null
          : _locationCtrl.text.trim(),
      appointmentDateTime: dt,
      notes: _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
      createdAt: DateTime.now(),
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 46,
              color: const Color(0xFF2D2D2D),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('Log Appointment',
                      style: GoogleFonts.arimo(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date/Time:',
                        style: GoogleFonts.arimo(
                            color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _chip(
                          onTap: _pickDate,
                          icon: 'assets/icons/calendar.png',
                          label: _currentDate,
                        ),
                        const SizedBox(width: 10),
                        _chip(
                          onTap: _pickTime,
                          icon: 'assets/icons/clock.png',
                          label: _currentTime,
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    _fieldLabel('Appointment Name'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _nameCtrl,
                      hint: 'eg. Cardiology checkup',
                    ),

                    const SizedBox(height: 20),
                    _fieldLabel('Location'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _locationCtrl,
                      hint: 'eg. Cairo Medical Center, Room 204',
                      prefixIcon: Icons.location_on_outlined,
                    ),

                    const SizedBox(height: 20),
                    _fieldLabel('Notes'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _notesCtrl,
                      hint: 'eg. Bring previous test results',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: MainButton(
                text: 'Add',
                enabled: _canSubmit,
                onTap: _canSubmit ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required VoidCallback onTap,
    required String icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF313131),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 14, height: 14),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.arimo(
                    color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(
    label,
    style: GoogleFonts.arimo(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.arimo(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.arimo(
            color: const Color(0xFFB4B4B4), fontSize: 15),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.white38, size: 18)
            : null,
        filled: true,
        fillColor: const Color(0xFF0C0C0C),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}