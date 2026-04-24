import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/lang/lang_strings.dart';
import '../../cubit/health_cubit.dart';
import '../../cubit/locale_cubit.dart';
import '../../models/appointment_entry.dart';
import '../../widgets/components.dart';

class AppointmentLogScreen extends StatefulWidget {
  const AppointmentLogScreen({super.key});

  @override
  State<AppointmentLogScreen> createState() =>
      _AppointmentLogScreenState();
}

class _AppointmentLogScreenState extends State<AppointmentLogScreen> {
  final _nameCtrl     = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl    = TextEditingController();

  DateTime  _selectedDate =
  DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String    _currentDate  = '';
  String    _currentTime  = '';

  bool get _canSubmit => _nameCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Labels are language-aware, so we defer to first build
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

  // ── Label builders ──────────────────────────────────────

  String _monthShort(DateTime date, String lang) {
    final name = AppStrings.get('month_${date.month}', lang);
    return lang == 'ar' ? name : name.substring(0, 3);
  }

  void _updateDateLabel(DateTime date, String lang) {
    final now      = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final isToday  = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final isTomorrow = date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;

    setState(() {
      final month = _monthShort(date, lang);
      if (isToday) {
        _currentDate =
        '${AppStrings.get('today_int', lang)}: $month ${date.day}';
      } else if (isTomorrow) {
        _currentDate =
        '${AppStrings.get('tomorrow', lang)}: $month ${date.day}';
      } else {
        _currentDate = '$month ${date.day}, ${date.year}';
      }
    });
  }

  void _updateTimeLabel(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'am' : 'pm';
    setState(() => _currentTime = '$h:$m$p');
  }

  // ── Pickers ─────────────────────────────────────────────

  Future<void> _pickDate(String lang) async {
    final isDark = context.isDark;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: isDark
            ? ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: Color(0xFF2D2D2D),
          ),
        )
            : ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _updateDateLabel(picked, lang);
    }
  }

  Future<void> _pickTime() async {
    final isDark = context.isDark;
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: isDark
            ? ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: Color(0xFF2D2D2D),
          ),
        )
            : ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
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
    final lang  = context.watch<LocaleCubit>().state;
    final c     = context.colors;
    final isRtl = lang == 'ar';

    // Keep date label in sync with language changes
    if (_currentDate.isEmpty) _updateDateLabel(_selectedDate, lang);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: c.bottomSheet,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 46,
                color: c.surface,
                padding:
                const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isRtl
                            ? Icons.arrow_forward_ios
                            : Icons.arrow_back_ios_new,
                        color: c.primaryText,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      AppStrings.get('log_appointment', lang),
                      style: GoogleFonts.arimo(
                          color: c.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.fromLTRB(20, 25, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        '${AppStrings.get('date_time', lang)}:',
                        style: GoogleFonts.arimo(
                            color: c.primaryText, fontSize: 16),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          _chip(
                            context: context,
                            onTap: () => _pickDate(lang),
                            icon: 'assets/icons/calendar.png',
                            label: _currentDate,
                          ),
                          const SizedBox(width: 10),
                          _chip(
                            context: context,
                            onTap: _pickTime,
                            icon: 'assets/icons/clock.png',
                            label: _currentTime,
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),
                      _fieldLabel(context,
                          AppStrings.get('appointment_name', lang)),
                      const SizedBox(height: 8),
                      _textField(
                        context: context,
                        controller: _nameCtrl,
                        hint: AppStrings.get('eg_appointment', lang),
                      ),

                      const SizedBox(height: 20),
                      _fieldLabel(context,
                          AppStrings.get('location', lang)),
                      const SizedBox(height: 8),
                      _textField(
                        context: context,
                        controller: _locationCtrl,
                        hint: AppStrings.get('eg_location', lang),
                        prefixIcon: Icons.location_on_outlined,
                      ),

                      const SizedBox(height: 20),
                      _fieldLabel(context,
                          AppStrings.get('notes', lang)),
                      const SizedBox(height: 8),
                      _textField(
                        context: context,
                        controller: _notesCtrl,
                        hint: AppStrings.get('eg_bring_results', lang),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              Padding(
                padding:
                const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: MainButton(
                  text: AppStrings.get('add', lang),
                  enabled: _canSubmit,
                  onTap: _canSubmit ? _submit : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required BuildContext context,
    required VoidCallback onTap,
    required String icon,
    required String label,
  }) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: c.cardBg,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 14, height: 14),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.arimo(
                    color: c.primaryText, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String label) => Text(
    label,
    style: GoogleFonts.arimo(
        color: context.colors.primaryText,
        fontSize: 14,
        fontWeight: FontWeight.w500),
  );

  Widget _textField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    final c = context.colors;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textDirection: context.watch<LocaleCubit>().state == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      style: GoogleFonts.arimo(color: c.primaryText, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        GoogleFonts.arimo(color: c.hintGrey, fontSize: 15),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: c.subtleText, size: 18)
            : null,
        filled: true,
        fillColor: c.notesFill,
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