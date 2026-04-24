import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/health_cubit.dart';
import '../core/lang/lang_strings.dart';
import '../cubit/locale_cubit.dart';
import 'components.dart';

class ReminderEntry {
  final String type;
  final String medicineName;
  final String? reminderName;
  final String schedule;
  final String frequency;
  final List<TimeOfDay> times;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final DateTime createdAt;

  ReminderEntry({
    required this.type,
    required this.medicineName,
    this.reminderName,
    required this.schedule,
    required this.frequency,
    required this.times,
    required this.startDate,
    this.endDate,
    this.notes,
    required this.createdAt,
  });

  static String _timeToString(TimeOfDay t) {
    return '${t.hour}:${t.minute}';
  }

  static TimeOfDay _timeFromString(String s) {
    final parts = s.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String toJson() {
    final map = {
      'type': type,
      'medicineName': medicineName,
      'reminderName': reminderName,
      'schedule': schedule,
      'frequency': frequency,
      'times': times.map(_timeToString).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };

    return jsonEncode(map);
  }

  factory ReminderEntry.fromJson(String source) {
    final map = jsonDecode(source);

    return ReminderEntry(
      type: map['type'],
      medicineName: map['medicineName'],
      reminderName: map['reminderName'],
      schedule: map['schedule'],
      frequency: map['frequency'],
      times: (map['times'] as List)
          .map((t) => _timeFromString(t))
          .toList(),
      startDate: DateTime.parse(map['startDate']),
      endDate:
      map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class ReminderTemplateScreen extends StatefulWidget {
  final String headerTitle;
  final String reminderType;
  final String medicineLabel;
  final String medicineHint;
  final bool showAddMore;

  const ReminderTemplateScreen({
    super.key,
    required this.headerTitle,
    required this.reminderType,
    this.medicineLabel = 'name_of_medicine', // Changed to key
    this.medicineHint = 'eg_aspirin',       // Changed to key
    this.showAddMore = true,
  });

  @override
  State<ReminderTemplateScreen> createState() =>
      _ReminderTemplateScreenState();
}

class _ReminderTemplateScreenState
    extends State<ReminderTemplateScreen> {
  final _nameCtrl = TextEditingController();
  final _reminderNameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _isRecurring = true;
  String _frequencyKey = 'daily';
  final List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  bool get _canSave => _nameCtrl.text.trim().isNotEmpty;

  String _formatDate(DateTime dt, String lang) {
    final months = [
      AppStrings.get('month_short_1', lang),
      AppStrings.get('month_short_2', lang),
      AppStrings.get('month_short_3', lang),
      AppStrings.get('month_short_4', lang),
      AppStrings.get('month_short_5', lang),
      AppStrings.get('month_short_6', lang),
      AppStrings.get('month_short_7', lang),
      AppStrings.get('month_short_8', lang),
      AppStrings.get('month_short_9', lang),
      AppStrings.get('month_short_10', lang),
      AppStrings.get('month_short_11', lang),
      AppStrings.get('month_short_12', lang)
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(TimeOfDay t, String lang) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am
        ? AppStrings.get('am_label', lang)
        : AppStrings.get('pm_label', lang);
    return '$h:$m $period';
  }

  void _openDateRange(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16, right: 16, top: 16,
        ),
        child: DateRangePickerWidget(
          initialStart: _startDate,
          initialEnd: _endDate,
          onApply: (start, end) =>
              setState(() { _startDate = start; _endDate = end; }),
        ),
      ),
    );
  }

  Future<void> _pickTime(int index, BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index],
      builder: (ctx, child) => Theme(
        data: isDark ? ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: theme.primaryColor,
            surface: theme.scaffoldBackgroundColor,
            onSurface: Colors.white,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
          ),
        ) : ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: theme.primaryColor,
            surface: theme.scaffoldBackgroundColor,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: theme.primaryColor),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _times[index] = picked);
    }
  }

  void _pickFrequency(BuildContext context, String lang) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use keys here to separate the logic state from the UI display
    final optionKeys = ['daily', 'weekly', 'every_2_days', 'monthly'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF212121) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.get('frequency', lang),
                style: GoogleFonts.arimo(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...optionKeys.map((key) => GestureDetector(
              onTap: () {
                setState(() => _frequencyKey = key);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _frequencyKey == key
                      ? theme.primaryColor.withOpacity(0.15)
                      : (isDark ? const Color(0xFF2D2D2D) : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _frequencyKey == key
                          ? theme.primaryColor
                          : Colors.transparent),
                ),
                child: Center(
                  child: Text(AppStrings.get(key, lang),
                      style: GoogleFonts.arimo(
                          color: _frequencyKey == key
                              ? theme.primaryColor
                              : (isDark ? Colors.white : Colors.black),
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _save() {
    final entry = ReminderEntry(
      type: widget.reminderType,
      medicineName: _nameCtrl.text.trim(),
      reminderName: _reminderNameCtrl.text.trim().isEmpty
          ? null
          : _reminderNameCtrl.text.trim(),
      // Saving the logical keys into the model instead of localized strings
      schedule: _isRecurring ? 'recurring' : 'once',
      frequency: _isRecurring ? _frequencyKey : 'once',
      times: List.from(_times),
      startDate: _startDate,
      endDate: _endDate,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    context.read<HealthCubit>().addReminder(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = context.watch<LocaleCubit>().state;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              color: isDark ? const Color(0xFF2D2D2D) : Colors.grey[100],
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                  ),
                  const SizedBox(width: 16),
                  // Assuming the parent widget passes down the translated title or key
                  Text(AppStrings.get(widget.headerTitle, lang),
                      style: GoogleFonts.arimo(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(AppStrings.get(widget.medicineLabel, lang), isDark),
                    const SizedBox(height: 6),
                    _textField(
                      controller: _nameCtrl,
                      hint: AppStrings.get(widget.medicineHint, lang),
                      onChanged: (_) => setState(() {}),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 6),
                    if (widget.showAddMore) ...[
                      const SizedBox(height: 6),
                      Center(
                        child: Text(AppStrings.get('add_more_meds', lang),
                            style: GoogleFonts.arimo(
                                color: isDark ? const Color(0xFFA0A0A0) : Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 20),
                    ],
                    const SizedBox(height: 20),
                    _sectionCard(
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: _scheduleToggle(theme, isDark, lang)),
                          const SizedBox(height: 16),
                          _label(AppStrings.get('schedule', lang), isDark),
                          _infoRow(
                            label: AppStrings.get('schedule', lang),
                            value: _isRecurring
                                ? AppStrings.get(_frequencyKey, lang)
                                : AppStrings.get('once', lang),
                            onTap: _isRecurring
                                ? () => _pickFrequency(context, lang)
                                : null,
                            isDark: isDark,
                            theme: theme,
                          ),
                          _divider(isDark),
                          ..._times.asMap().entries.map((e) {
                            final i = e.key;
                            final t = e.value;
                            return Column(children: [
                              _infoRow(
                                label: i == 0 ? AppStrings.get('times', lang) : '',
                                value: _formatTime(t, lang),
                                onTap: () => _pickTime(i, context),
                                trailing: i > 0
                                    ? GestureDetector(
                                    onTap: () => setState(
                                            () => _times.removeAt(i)),
                                    child: Icon(Icons.close,
                                        color: isDark ? Colors.white38 : Colors.grey,
                                        size: 16))
                                    : null,
                                isDark: isDark,
                                theme: theme,
                              ),
                              _divider(isDark),
                            ]);
                          }),
                          GestureDetector(
                            onTap: () => setState(
                                    () => _times.add(const TimeOfDay(hour: 8, minute: 0))),
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 6),
                              child: Text(AppStrings.get('add_time', lang),
                                  style: GoogleFonts.arimo(
                                      color: theme.primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                          _divider(isDark),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _openDateRange(context),
                            child: Column(children: [
                              _infoRow(
                                  label: AppStrings.get('start_date', lang),
                                  value: _formatDate(_startDate, lang),
                                  onTap: null,
                                  isDark: isDark,
                                  theme: theme),
                              _divider(isDark),
                              _infoRow(
                                  label: AppStrings.get('end_date', lang),
                                  value: _endDate != null
                                      ? _formatDate(_endDate!, lang)
                                      : AppStrings.get('never', lang),
                                  onTap: null,
                                  isDark: isDark,
                                  theme: theme),
                            ]),
                          ),
                          _divider(isDark),
                          _infoRowField(
                            label: AppStrings.get('reminder_name', lang),
                            hint: AppStrings.get('eg_morning_meds', lang),
                            controller: _reminderNameCtrl,
                            optionalText: AppStrings.get('optional', lang),
                            optional: true,
                            isDark: isDark,
                          ),
                          _divider(isDark),
                          _infoRowField(
                            label: AppStrings.get('notes', lang),
                            hint: AppStrings.get('eg_take_after_food', lang),
                            controller: _notesCtrl,
                            optionalText: AppStrings.get('optional', lang),
                            optional: true,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    MainButton(
                      text: AppStrings.get('save', lang),
                      enabled: _canSave,
                      onTap: _save,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.arimo(
        color: isDark ? Colors.white : Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.arimo(color: isDark ? Colors.white : Colors.black, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.arimo(color: isDark ? const Color(0xFFA0A0A0) : Colors.grey[600], fontSize: 14),
        filled: true,
        fillColor: isDark ? const Color(0xFF2D2D2D) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _sectionCard({required Widget child, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _scheduleToggle(ThemeData theme, bool isDark, String lang) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.grey[200],
        borderRadius: BorderRadius.circular(33),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleOption(AppStrings.get('once', lang), !_isRecurring, () => setState(() => _isRecurring = false), theme, isDark),
          _toggleOption(AppStrings.get('recurring', lang), _isRecurring, () => setState(() => _isRecurring = true), theme, isDark),
        ],
      ),
    );
  }

  Widget _toggleOption(String label, bool active, VoidCallback onTap, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: active ? theme.primaryColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(33),
        ),
        child: Text(label,
            style: GoogleFonts.arimo(
                color: active
                    ? theme.primaryColor
                    : (isDark ? Colors.white.withOpacity(0.48) : Colors.grey[600]),
                fontSize: 12,
                fontWeight: FontWeight.w400)),
      ),
    );
  }

  Widget _infoRow({
    required String label,
    required String value,
    VoidCallback? onTap,
    Widget? trailing,
    required bool isDark,
    required ThemeData theme,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            if (label.isNotEmpty)
              Text(label,
                  style: GoogleFonts.arimo(
                      color: isDark ? Colors.white.withOpacity(0.77) : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            const Spacer(),
            if (trailing != null) ...[trailing, const SizedBox(width: 6)],
            Text(value,
                style: GoogleFonts.arimo(
                    color: theme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _infoRowField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool optional = false,
    String optionalText = 'optional',
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: GoogleFonts.arimo(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400)),
              const Spacer(),
              if (optional)
                Text(optionalText,
                    style: GoogleFonts.arimo(
                        color: isDark ? Colors.white.withOpacity(0.49) : Colors.grey[600],
                        fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            style: GoogleFonts.arimo(color: isDark ? Colors.white : Colors.black, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.arimo(
                  color: isDark ? const Color(0xFFB4B4B4) : Colors.grey[500], fontSize: 14),
              filled: true,
              fillColor: isDark ? const Color(0xFF0C0C0C) : Colors.grey[100],
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) => Container(
    height: 0.5,
    color: isDark ? Colors.white12 : Colors.grey[300],
  );
}