import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/health_cubit.dart';
import 'components.dart';

class ReminderEntry {
  final String type;         // e.g. "Blood Pressure", "Meds"
  final String medicineName; // primary name field
  final String? reminderName;
  final String schedule;     // "Recurring" | "Once"
  final String frequency;    // "Daily", "Weekly", etc.
  final List<TimeOfDay> times;
  final DateTime startDate;
  final DateTime? endDate;   // null = Never
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
    this.medicineLabel = 'Name of the medicine',
    this.medicineHint = 'eg. Aspirin',
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
  String _frequency = 'Daily';
  final List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  bool get _canSave => _nameCtrl.text.trim().isNotEmpty;

  String _formatDate(DateTime dt) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  void _openDateRange() {
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

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index],
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
      setState(() => _times[index] = picked);
    }
  }

  void _pickFrequency() {
    final options = ['Daily', 'Weekly', 'Every 2 days', 'Monthly'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF212121),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Frequency',
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...options.map((o) => GestureDetector(
              onTap: () { setState(() => _frequency = o); Navigator.pop(context); },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _frequency == o
                      ? const Color(0xFF00C950).withOpacity(0.15)
                      : const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _frequency == o
                          ? const Color(0xFF00C950)
                          : Colors.transparent),
                ),
                child: Center(
                  child: Text(o,
                      style: GoogleFonts.arimo(
                          color: _frequency == o
                              ? const Color(0xFF00C950)
                              : Colors.white,
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
      schedule: _isRecurring ? 'Recurring' : 'Once',
      frequency: _isRecurring ? _frequency : 'Once',
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
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      body: SafeArea(
        child: Column(
          children: [

            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              color: const Color(0xFF2D2D2D),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text(widget.headerTitle,
                      style: GoogleFonts.arimo(
                          color: Colors.white,
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

                    _label(widget.medicineLabel),
                    const SizedBox(height: 6),
                    _textField(
                      controller: _nameCtrl,
                      hint: widget.medicineHint,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 6),


                    if (widget.showAddMore) ...[
                      const SizedBox(height: 6),
                      Center(
                        child: Text('+ Add More Meds',
                            style: GoogleFonts.arimo(
                                color: const Color(0xFFA0A0A0),
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 20),
                    ],

                    const SizedBox(height: 20),


                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Center(child: _scheduleToggle()),

                          const SizedBox(height: 16),

                          // Schedule / frequency row
                          _infoRow(
                            label: 'Schedule',
                            value: _isRecurring ? _frequency : 'Once',
                            onTap: _isRecurring ? _pickFrequency : null,
                          ),

                          _divider(),

                          // Times
                          ..._times.asMap().entries.map((entry) {
                            final i = entry.key;
                            final t = entry.value;
                            return Column(
                              children: [
                                _infoRow(
                                  label: i == 0 ? 'Times' : '',
                                  value: _formatTime(t),
                                  onTap: () => _pickTime(i),
                                  trailing: i > 0
                                      ? GestureDetector(
                                    onTap: () => setState(
                                            () => _times.removeAt(i)),
                                    child: const Icon(Icons.close,
                                        color: Colors.white38,
                                        size: 16),
                                  )
                                      : null,
                                ),
                                _divider(),
                              ],
                            );
                          }),

                          // Add time
                          GestureDetector(
                            onTap: () => setState(() =>
                                _times.add(const TimeOfDay(hour: 8, minute: 0))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text('+ Add time',
                                  style: GoogleFonts.arimo(
                                      color: const Color(0xFF00C950),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),

                          _divider(),

                          // Start & End date — one button opens DateRangePicker
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _openDateRange,
                            child: Column(
                              children: [
                                _infoRow(
                                  label: 'Start date',
                                  value: _formatDate(_startDate),
                                  onTap: null, // handled by parent
                                ),
                                _divider(),
                                _infoRow(
                                  label: 'End date',
                                  value: _endDate != null
                                      ? _formatDate(_endDate!)
                                      : 'Never',
                                  onTap: null,
                                ),
                              ],
                            ),
                          ),

                          _divider(),

                          // Reminder name (optional)
                          _infoRowField(
                            label: 'Reminder name',
                            hint: 'eg. Morning meds',
                            controller: _reminderNameCtrl,
                            optional: true,
                          ),

                          _divider(),

                          // Notes (optional)
                          _infoRowField(
                            label: 'Notes',
                            hint: 'eg. take after food',
                            controller: _notesCtrl,
                            optional: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    const SizedBox(height: 125),
                    Center(
                      child: MainButton(
                        text: 'Add',
                        enabled: _canSave,
                        onTap: _canSave ? _save : null,
                      ),
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


  Widget _label(String text) => Text(text,
      style: GoogleFonts.arimo(
          color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w400));

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.arimo(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.arimo(
            color: const Color(0xFFCDCDCD), fontSize: 16),
        filled: true,
        fillColor: const Color(0xFF4F4F4F),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _scheduleToggle() {
    return Container(
      height: 26,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(34),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleOption('Recurring', _isRecurring,
                  () => setState(() => _isRecurring = true)),
          _toggleOption('Once', !_isRecurring,
                  () => setState(() => _isRecurring = false)),
        ],
      ),
    );
  }

  Widget _toggleOption(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF5A5A5A) : Colors.transparent,
          borderRadius: BorderRadius.circular(33),
        ),
        child: Text(label,
            style: GoogleFonts.arimo(
                color: active
                    ? const Color(0xFF00C950)
                    : Colors.white.withOpacity(0.48),
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
                      color: Colors.white.withOpacity(0.77),
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            const Spacer(),
            if (trailing != null) ...[trailing, const SizedBox(width: 6)],
            Text(value,
                style: GoogleFonts.arimo(
                    color: const Color(0xFF00C950),
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
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400)),
              const Spacer(),
              if (optional)
                Text('optional',
                    style: GoogleFonts.arimo(
                        color: Colors.white.withOpacity(0.49),
                        fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            style: GoogleFonts.arimo(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.arimo(
                  color: const Color(0xFFB4B4B4), fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF0C0C0C),
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

  Widget _divider() => Container(
    height: 0.5,
    color: Colors.white12,
  );
}