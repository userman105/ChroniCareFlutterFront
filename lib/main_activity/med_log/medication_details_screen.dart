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
  int? _expandedDot; // index of tapped dot

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final allEntries = List<MedicationEntry>.from(
      context.watch<HealthCubit>().getMedicationEntries(),
    )..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (allEntries.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: SafeArea(
          child: Column(
            children: [
              _topBar(context),
              const Expanded(
                child: Center(
                  child: Text('No Data',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final rangeStart =
    now.subtract(Duration(days: _selectedRange - 1));
    final chartEntries = allEntries
        .where((e) => e.dateTime.isAfter(
        rangeStart.subtract(const Duration(seconds: 1))))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
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
                    _latestCard(allEntries.last),
                    const SizedBox(height: 20),
                    _dotChartCard(chartEntries),
                    const SizedBox(height: 20),

                    Text('History',
                        style: GoogleFonts.arimo(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),

                    const SizedBox(height: 10),

                    ...allEntries.reversed
                        .take(3)
                        .map((e) => _historyTile(context, e))
                        .toList(),

                    const SizedBox(height: 12),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllMedicationEntriesScreen(
                                entries: allEntries),
                          ),
                        ),
                        child: Container(
                          width: 87,
                          height: 31,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF474747),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                            ),
                          ),
                          child: const Stack(children: [
                            Positioned(
                              left: 15, top: 8,
                              child: Text('All Entries',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500)),
                            ),
                          ]),
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

  Widget _topBar(BuildContext context) {
    return Container(
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
          Text('Medication',
              style: GoogleFonts.arimo(
                  color: Colors.white,
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

  Widget _latestCard(MedicationEntry e) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF4B4B4B)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication_outlined,
                  color: Color(0xFF00C950), size: 20),
              const SizedBox(width: 8),
              Text('Latest Entry',
                  style: GoogleFonts.arimo(
                      color: Colors.white, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            e.medicationName,
            style: GoogleFonts.arimo(
                color: Colors.white,
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
            style: GoogleFonts.arimo(
                color: const Color(0xFFCDCDCD)),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) => Container(
    padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF00C950).withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
          color: const Color(0xFF00C950).withOpacity(0.3)),
    ),
    child: Text(label,
        style: GoogleFonts.arimo(
            color: const Color(0xFF00C950),
            fontSize: 12,
            fontWeight: FontWeight.w500)),
  );

  Widget _dotChartCard(List<MedicationEntry> entries) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF4B4B4B)),
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
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              _rangePicker(),
            ],
          ),
          const SizedBox(height: 16),
          entries.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text('No data in range',
                  style: GoogleFonts.arimo(
                      color: Colors.white54)),
            ),
          )
              : _dotChart(entries),
        ],
      ),
    );
  }

  Widget _dotChart(List<MedicationEntry> entries) {
    // Group by day
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
          // Y label
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('More',
                  style: GoogleFonts.arimo(
                      color: Colors.white38, fontSize: 10)),
              Text('Less',
                  style: GoogleFonts.arimo(
                      color: Colors.white38, fontSize: 10)),
            ],
          ),
          const SizedBox(width: 8),

          // Chart area
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
                        // Dots stack
                        Column(
                          children:
                          dayEntries.asMap().entries.map((e) {
                            final idx =
                            entries.indexOf(e.value);
                            final isExpanded =
                                _expandedDot == idx;

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
                                    horizontal: 8,
                                    vertical: 4)
                                    : EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  color: isExpanded
                                      ? const Color(0xFF1E1E1E)
                                      : Colors.transparent,
                                  borderRadius:
                                  BorderRadius.circular(8),
                                  border: isExpanded
                                      ? Border.all(
                                      color: const Color(
                                          0xFF00C950)
                                          .withOpacity(0.4))
                                      : null,
                                ),
                                child: isExpanded
                                    ? Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    Text(
                                      e.value.medicationName,
                                      style: GoogleFonts.arimo(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight:
                                          FontWeight.w600),
                                    ),
                                    Text(
                                      '${e.value.dose}${e.value.doseUnit} x${e.value.quantity}',
                                      style: GoogleFonts.arimo(
                                          color: const Color(
                                              0xFF00C950),
                                          fontSize: 9),
                                    ),
                                  ],
                                )
                                    : Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00C950),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        // Day label
                        const SizedBox(height: 6),
                        Text(
                          '$day',
                          style: GoogleFonts.arimo(
                              color: Colors.white54,
                              fontSize: 11),
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

  Widget _rangePicker() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: _selectedRange,
        dropdownColor: const Color(0xFF3A3A3A),
        style: GoogleFonts.arimo(color: Colors.white, fontSize: 13),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        items: const [
          DropdownMenuItem(value: 7, child: Text('Last 7 days')),
          DropdownMenuItem(value: 14, child: Text('Last 14 days')),
          DropdownMenuItem(value: 30, child: Text('Last 30 days')),
        ],
        onChanged: (v) => setState(() => _selectedRange = v!),
      ),
    );
  }
  Widget _historyTile(BuildContext context, MedicationEntry e) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showEntryDetails(context, e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.medication_outlined,
                color: Color(0xFF00C950), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.medicationName,
                      style: GoogleFonts.arimo(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    '${e.dose} ${e.doseUnit} · x${e.quantity} · ${e.form}',
                    style: GoogleFonts.arimo(
                        color: Colors.white54, fontSize: 12),
                  ),
                  Text(
                    '${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}',
                    style: GoogleFonts.arimo(
                        color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }

  void _showEntryDetails(BuildContext context, MedicationEntry e) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF212121),
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Row(
              children: [
                const Icon(Icons.medication_outlined,
                    color: Color(0xFF00C950), size: 22),
                const SizedBox(width: 8),
                Text('Medication Entry',
                    style: GoogleFonts.arimo(
                        color: Colors.white,
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
                            color: Colors.orange,
                            fontSize: 11)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(e.medicationName,
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _detailChip('Dose', '${e.dose} ${e.doseUnit}'),
                const SizedBox(width: 12),
                _detailChip('Qty', 'x${e.quantity}'),
                const SizedBox(width: 12),
                _detailChip('Form', e.form),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow(Icons.calendar_today_outlined,
                '${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}'),
            if (e.notes != null && e.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _detailRow(Icons.notes_outlined, e.notes!),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _detailChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.arimo(
                    color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: GoogleFonts.arimo(
                  color: Colors.white70, fontSize: 14)),
        ),
      ],
    );
  }
}

class AllMedicationEntriesScreen extends StatefulWidget {
  final List<MedicationEntry> entries;

  const AllMedicationEntriesScreen({super.key, required this.entries});

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

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  String _formatShort(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$m/${d}/${dt.year}';
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
          left: 16, right: 16, top: 16,
        ),
        child: DateRangePickerWidget(
          initialStart: _filterStart,
          initialEnd: _filterEnd,
          onApply: (s, e) =>
              setState(() { _filterStart = s; _filterEnd = e; }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
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
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text('All Entries',
                      style: GoogleFonts.arimo(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text('${entries.length} records',
                      style: GoogleFonts.arimo(
                          color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _hasFilter
                      ? () => setState(() {
                    _filterStart = null;
                    _filterEnd = null;
                  })
                      : _openPicker,
                  child: _hasFilter
                      ? Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF474747),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_formatShort(_filterStart!)} – ${_formatShort(_filterEnd!)}',
                          style: GoogleFonts.arimo(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.close,
                            color: Colors.white, size: 14),
                      ],
                    ),
                  )
                      : Container(
                    width: 118,
                    height: 32,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF2D2D2D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Image.asset(
                              'assets/icons/calendar.png',
                              height: 20, width: 20),
                          const SizedBox(width: 10),
                          Text('All Time',
                              style: GoogleFonts.arimo(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: entries.isEmpty
                  ? Center(
                child: Text(
                  _hasFilter
                      ? 'No entries in this range'
                      : 'No entries',
                  style: GoogleFonts.arimo(
                      color: Colors.white54),
                ),
              )
                  : ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = entries[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        _showEntryDetails(context, e),
                    child: Container(
                      margin:
                      const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                              Icons.medication_outlined,
                              color: Color(0xFF00C950),
                              size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(e.medicationName,
                                    style: GoogleFonts.arimo(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight:
                                        FontWeight.w600)),
                                Text(
                                  '${e.dose} ${e.doseUnit} · x${e.quantity} · ${e.form}',
                                  style: GoogleFonts.arimo(
                                      color: Colors.white54,
                                      fontSize: 12),
                                ),
                                Text(
                                  '${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}',
                                  style: GoogleFonts.arimo(
                                      color: Colors.white38,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Colors.white38, size: 18),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF212121),
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Row(
              children: [
                const Icon(Icons.medication_outlined,
                    color: Color(0xFF00C950), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(e.medicationName,
                      style: GoogleFonts.arimo(
                          color: Colors.white,
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
                            color: Colors.orange, fontSize: 11)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _detailChip('Dose', '${e.dose} ${e.doseUnit}'),
                const SizedBox(width: 8),
                _detailChip('Qty', 'x${e.quantity}'),
                const SizedBox(width: 8),
                _detailChip('Form', e.form),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: Colors.white38, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}',
                  style: GoogleFonts.arimo(
                      color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            if (e.notes != null && e.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_outlined,
                      color: Colors.white38, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(e.notes!,
                        style: GoogleFonts.arimo(
                            color: Colors.white70, fontSize: 14)),
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

  Widget _detailChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.arimo(
                    color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}