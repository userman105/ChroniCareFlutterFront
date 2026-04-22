import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/health_cubit.dart';
import '../../models/med_entry.dart';
import '../../widgets/components.dart';
import 'medication_log_screen.dart';

class MedicationDetailsScreen extends StatefulWidget {
  const MedicationDetailsScreen({super.key});

  @override
  State<MedicationDetailsScreen> createState() =>
      _MedicationDetailsScreenState();
}

class _MedicationDetailsScreenState
    extends State<MedicationDetailsScreen> {
  int _selectedRange = 7;
  int? _expandedDot;

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final allEntries = List<MedicationEntry>.from(
      context.watch<HealthCubit>().getMedicationEntries(),
    )..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (allEntries.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _topBar(context),
              Expanded(
                child: Center(
                  child: Text('No Data',
                      style: TextStyle(color: c.primaryText)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final now        = DateTime.now();
    final rangeStart = now.subtract(Duration(days: _selectedRange - 1));
    final chartEntries = allEntries
        .where((e) => e.dateTime
        .isAfter(rangeStart.subtract(const Duration(seconds: 1))))
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _latestCard(context, allEntries.last),
                    const SizedBox(height: 20),
                    _dotChartCard(context, chartEntries),
                    const SizedBox(height: 20),

                    Text('History',
                        style: GoogleFonts.arimo(
                            color: c.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),

                    const SizedBox(height: 10),

                    ...allEntries.reversed
                        .take(3)
                        .map((e) => _historyTile(context, e)),

                    const SizedBox(height: 12),

                    // ── All Entries button ─────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AllMedicationEntriesScreen(
                                    entries: allEntries),
                          ),
                        ),
                        child: Container(
                          width: 87,
                          height: 31,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: c.reminderTileBg,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(21),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'All Entries',
                              style: GoogleFonts.arimo(
                                  color: c.primaryText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
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

  // ── Top bar ───────────────────────────────────────────────

  Widget _topBar(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: c.surface,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: c.primaryText),
          ),
          const SizedBox(width: 16),
          Text('Medication',
              style: GoogleFonts.arimo(
                  color: c.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const MedicationLogScreen()),
            ),
            child: Image.asset('assets/icons/add.png',
                width: 26, height: 26),
          ),
        ],
      ),
    );
  }

  // ── Latest card ───────────────────────────────────────────

  Widget _latestCard(BuildContext context, MedicationEntry e) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: c.subtleBorder),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Latest Entry',
                  style: GoogleFonts.arimo(
                      color: c.primaryText, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            e.medicationName,
            style: GoogleFonts.arimo(
                color: c.primaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _chip('${e.dose} ${e.doseUnit}'),
              const SizedBox(width: 6),
              _chip('x${e.quantity}'),
              const SizedBox(width: 6),
              _chip(e.form),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Taken ${_formatDate(e.dateTime)} at ${_formatTime(e.dateTime)}',
            style: GoogleFonts.arimo(color: c.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
          color: AppColors.primary.withOpacity(0.3)),
    ),
    child: Text(label,
        style: GoogleFonts.arimo(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w500)),
  );

  // ── Dot chart card ────────────────────────────────────────

  Widget _dotChartCard(
      BuildContext context, List<MedicationEntry> entries) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: c.subtleBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Intake Chart',
                  style: GoogleFonts.arimo(
                      color: c.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              _rangePicker(context),
            ],
          ),
          const SizedBox(height: 16),
          entries.isEmpty
              ? Center(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 40),
              child: Text('No data in range',
                  style: GoogleFonts.arimo(
                      color: c.hintText)),
            ),
          )
              : _dotChart(context, entries),
        ],
      ),
    );
  }

  Widget _dotChart(
      BuildContext context, List<MedicationEntry> entries) {
    final c = context.colors;

    final Map<int, List<MedicationEntry>> byDay = {};
    for (final e in entries) {
      byDay.putIfAbsent(e.dateTime.day, () => []).add(e);
    }
    final days = byDay.keys.toList()..sort();

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Y labels
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('More',
                  style: GoogleFonts.arimo(
                      color: c.subtleText, fontSize: 10)),
              Text('Less',
                  style: GoogleFonts.arimo(
                      color: c.subtleText, fontSize: 10)),
            ],
          ),
          const SizedBox(width: 8),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: days.map((day) {
                  final dayEntries = byDay[day]!;
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          children: dayEntries
                              .asMap()
                              .entries
                              .map((e) {
                            final idx    = entries.indexOf(e.value);
                            final isExpanded = _expandedDot == idx;

                            return GestureDetector(
                              onTap: () => setState(() =>
                              _expandedDot =
                              isExpanded ? null : idx),
                              child: AnimatedContainer(
                                duration: const Duration(
                                    milliseconds: 250),
                                margin: const EdgeInsets.only(
                                    bottom: 4),
                                padding: isExpanded
                                    ? const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4)
                                    : EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  color: isExpanded
                                      ? c.sectionBg
                                      : Colors.transparent,
                                  borderRadius:
                                  BorderRadius.circular(8),
                                  border: isExpanded
                                      ? Border.all(
                                      color: AppColors.primary
                                          .withOpacity(0.4))
                                      : null,
                                ),
                                child: isExpanded
                                    ? Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.value.medicationName,
                                      style: GoogleFonts.arimo(
                                          color: c.primaryText,
                                          fontSize: 10,
                                          fontWeight:
                                          FontWeight.w600),
                                    ),
                                    Text(
                                      '${e.value.dose}${e.value.doseUnit} x${e.value.quantity}',
                                      style: GoogleFonts.arimo(
                                          color:
                                          AppColors.primary,
                                          fontSize: 9),
                                    ),
                                  ],
                                )
                                    : Container(
                                  width: 10,
                                  height: 10,
                                  decoration:
                                  const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$day',
                          style: GoogleFonts.arimo(
                              color: c.hintText, fontSize: 11),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rangePicker(BuildContext context) {
    final c = context.colors;
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: _selectedRange,
        dropdownColor: c.cardBg,
        style: GoogleFonts.arimo(
            color: c.primaryText, fontSize: 13),
        icon: Icon(Icons.arrow_drop_down, color: c.primaryText),
        items: [
          DropdownMenuItem(
              value: 7,
              child: Text('Last 7 days',
                  style: TextStyle(color: c.primaryText))),
          DropdownMenuItem(
              value: 14,
              child: Text('Last 14 days',
                  style: TextStyle(color: c.primaryText))),
          DropdownMenuItem(
              value: 30,
              child: Text('Last 30 days',
                  style: TextStyle(color: c.primaryText))),
        ],
        onChanged: (v) => setState(() => _selectedRange = v!),
      ),
    );
  }

  // ── History tile ──────────────────────────────────────────

  Widget _historyTile(BuildContext context, MedicationEntry e) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showEntryDetails(context, e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.medication_outlined,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.medicationName,
                      style: GoogleFonts.arimo(
                          color: c.primaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    '${e.dose} ${e.doseUnit} · x${e.quantity} · ${e.form}',
                    style: GoogleFonts.arimo(
                        color: c.hintText, fontSize: 12),
                  ),
                  Text(
                    '${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}',
                    style: GoogleFonts.arimo(
                        color: c.subtleText, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: c.subtleText, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Entry detail sheet ────────────────────────────────────

  void _showEntryDetails(BuildContext context, MedicationEntry e) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.bottomSheet,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: c.subtleText,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.medication_outlined,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text('Medication Entry',
                    style: GoogleFonts.arimo(
                        color: c.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                if (e.isCustom) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Custom',
                        style: GoogleFonts.arimo(
                            color: Colors.orange, fontSize: 11)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(e.medicationName,
                style: GoogleFonts.arimo(
                    color: c.primaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _detailChip(context, 'Dose', '${e.dose} ${e.doseUnit}'),
                const SizedBox(width: 12),
                _detailChip(context, 'Qty', 'x${e.quantity}'),
                const SizedBox(width: 12),
                _detailChip(context, 'Form', e.form),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow(context, Icons.calendar_today_outlined,
                '${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}'),
            if (e.notes != null && e.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _detailRow(context, Icons.notes_outlined, e.notes!),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _detailChip(BuildContext context, String label, String value) {
    final c = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.arimo(
                    color: c.hintText, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.arimo(
                    color: c.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
      BuildContext context, IconData icon, String text) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: c.subtleText, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: GoogleFonts.arimo(
                  color: c.secondaryText, fontSize: 14)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ALL ENTRIES SCREEN
// ─────────────────────────────────────────────────────────────

class AllMedicationEntriesScreen extends StatefulWidget {
  final List<MedicationEntry> entries;

  const AllMedicationEntriesScreen(
      {super.key, required this.entries});

  @override
  State<AllMedicationEntriesScreen> createState() =>
      _AllMedicationEntriesScreenState();
}

class _AllMedicationEntriesScreenState
    extends State<AllMedicationEntriesScreen> {
  DateTime? _filterStart;
  DateTime? _filterEnd;

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  String _formatShort(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$m/$d/${dt.year}';
  }

  bool get _hasFilter => _filterStart != null && _filterEnd != null;

  List<MedicationEntry> get _filtered {
    final sorted = List<MedicationEntry>.from(widget.entries)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    if (!_hasFilter) return sorted;
    final end = DateTime(_filterEnd!.year, _filterEnd!.month,
        _filterEnd!.day, 23, 59, 59);
    return sorted
        .where((e) =>
    !e.dateTime.isBefore(_filterStart!) &&
        !e.dateTime.isAfter(end))
        .toList();
  }

  void _openPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: DateRangePickerWidget(
          initialStart: _filterStart,
          initialEnd: _filterEnd,
          onApply: (s, e) =>
              setState(() {
                _filterStart = s;
                _filterEnd   = e;
              }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c       = context.colors;
    final entries = _filtered;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            // ── Top bar ──────────────────────────────────────
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              color: c.surface,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back,
                        color: c.primaryText),
                  ),
                  const SizedBox(width: 16),
                  Text('All Entries',
                      style: GoogleFonts.arimo(
                          color: c.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text('${entries.length} records',
                      style: GoogleFonts.arimo(
                          color: c.hintText, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Date filter pill ─────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _hasFilter
                      ? () => setState(() {
                    _filterStart = null;
                    _filterEnd   = null;
                  })
                      : _openPicker,
                  child: _hasFilter
                      ? Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14),
                    decoration: ShapeDecoration(
                      color: c.reminderTileBg,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_formatShort(_filterStart!)} – ${_formatShort(_filterEnd!)}',
                          style: GoogleFonts.arimo(
                              color: c.primaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.close,
                            color: c.primaryText, size: 14),
                      ],
                    ),
                  )
                      : Container(
                    width: 118,
                    height: 32,
                    decoration: ShapeDecoration(
                      color: c.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Image.asset(
                            'assets/icons/calendar.png',
                            height: 20,
                            width: 20),
                        const SizedBox(width: 10),
                        Text('All Time',
                            style: GoogleFonts.arimo(
                                color: c.primaryText,
                                fontSize: 15,
                                fontWeight:
                                FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Entry list ───────────────────────────────────
            Expanded(
              child: entries.isEmpty
                  ? Center(
                child: Text(
                  _hasFilter
                      ? 'No entries in this range'
                      : 'No entries',
                  style: GoogleFonts.arimo(
                      color: c.hintText),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = entries[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        _showEntryDetails(context, e),
                    child: Container(
                      margin: const EdgeInsets.only(
                          bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                              Icons.medication_outlined,
                              color: AppColors.primary,
                              size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(e.medicationName,
                                    style:
                                    GoogleFonts.arimo(
                                        color: c.primaryText,
                                        fontSize: 15,
                                        fontWeight:
                                        FontWeight
                                            .w600)),
                                Text(
                                  '${e.dose} ${e.doseUnit} · x${e.quantity} · ${e.form}',
                                  style: GoogleFonts.arimo(
                                      color: c.hintText,
                                      fontSize: 12),
                                ),
                                Text(
                                  '${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}',
                                  style: GoogleFonts.arimo(
                                      color: c.subtleText,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: c.subtleText,
                              size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEntryDetails(BuildContext context, MedicationEntry e) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.bottomSheet,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: c.subtleText,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.medication_outlined,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(e.medicationName,
                      style: GoogleFonts.arimo(
                          color: c.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                ),
                if (e.isCustom)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Custom',
                        style: GoogleFonts.arimo(
                            color: Colors.orange,
                            fontSize: 11)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _detailChip(context, 'Dose',
                    '${e.dose} ${e.doseUnit}'),
                const SizedBox(width: 8),
                _detailChip(context, 'Qty', 'x${e.quantity}'),
                const SizedBox(width: 8),
                _detailChip(context, 'Form', e.form),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    color: c.subtleText, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}',
                  style: GoogleFonts.arimo(
                      color: c.secondaryText, fontSize: 14),
                ),
              ],
            ),
            if (e.notes != null &&
                e.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_outlined,
                      color: c.subtleText, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(e.notes!,
                        style: GoogleFonts.arimo(
                            color: c.secondaryText,
                            fontSize: 14)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _detailChip(
      BuildContext context, String label, String value) {
    final c = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.arimo(
                    color: c.hintText, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.arimo(
                    color: c.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}