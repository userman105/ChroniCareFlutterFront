import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/health_cubit.dart';
import '../../models/symptom_entry.dart';
import '../../widgets/components.dart';
import 'symptom_screen.dart';


class SymptomsDetailsScreen extends StatefulWidget {
  const SymptomsDetailsScreen({super.key});

  @override
  State<SymptomsDetailsScreen> createState() => _SymptomsDetailsScreenState();
}

class _SymptomsDetailsScreenState extends State<SymptomsDetailsScreen> {
  int _selectedRange = 7;
  int? _expandedDot;
  final Color _accentGreen = const Color(0xFF00C950);

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  Color _severityColor(int severity) {
    if (severity <= 3) return _accentGreen;
    if (severity <= 6) return Colors.orange;
    return Colors.red;
  }

  String _severityLabel(int severity) {
    if (severity <= 3) return 'Mild';
    if (severity <= 6) return 'Moderate';
    return 'Severe';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allEntries = List<SymptomEntry>.from(
      context.watch<HealthCubit>().getSymptomEntries(),
    )..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (allEntries.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _topBar(context),
              Expanded(
                child: Center(
                  child: Text('No Data',
                      style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final rangeStart = now.subtract(Duration(days: _selectedRange - 1));
    final chartEntries = allEntries
        .where((e) => e.dateTime
        .isAfter(rangeStart.subtract(const Duration(seconds: 1))))
        .toList();

    return Scaffold(
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
                    _chartCard(chartEntries),
                    const SizedBox(height: 24),
                    Text('History',
                        style: GoogleFonts.arimo(
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ...allEntries.reversed
                        .take(3)
                        .map((e) => _historyTile(context, e))
                        .toList(),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllSymptomsEntriesScreen(entries: allEntries),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: ShapeDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text('View All Entries',
                              style: GoogleFonts.arimo(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
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
    final theme = Theme.of(context);
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: theme.colorScheme.surfaceContainer,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(width: 16),
          Text('Symptoms',
              style: GoogleFonts.arimo(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const SymptomScreen())),
            child: Icon(Icons.add_circle, color: _accentGreen, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _latestCard(SymptomEntry e) {
    final theme = Theme.of(context);
    final color = _severityColor(e.severity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart_outlined, color: _accentGreen, size: 20),
              const SizedBox(width: 8),
              Text('Latest Entry',
                  style: GoogleFonts.arimo(
                      color: theme.colorScheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  e.symptom,
                  style: GoogleFonts.arimo(
                      color: theme.colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _severityLabel(e.severity),
                  style: GoogleFonts.arimo(color: color, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: e.severity / 10,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${e.severity}/10',
                  style: GoogleFonts.arimo(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Logged ${_formatDate(e.dateTime)} at ${_formatTime(e.dateTime)}',
            style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
          ),
          if (e.notes != null && e.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_outlined, color: theme.colorScheme.onSurfaceVariant, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(e.notes!,
                        style: GoogleFonts.arimo(color: theme.colorScheme.onSurface, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chartCard(List<SymptomEntry> entries) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Severity Chart',
                  style: GoogleFonts.arimo(
                      color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w700)),
              _rangePicker(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _legendDot(_accentGreen),
              const SizedBox(width: 4),
              Text('Mild', style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
              const SizedBox(width: 12),
              _legendDot(Colors.orange),
              const SizedBox(width: 4),
              Text('Moderate', style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
              const SizedBox(width: 12),
              _legendDot(Colors.red),
              const SizedBox(width: 4),
              Text('Severe', style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 24),
          entries.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text('No data in range',
                  style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant)),
            ),
          )
              : SizedBox(height: 200, child: _dotChart(entries)),
        ],
      ),
    );
  }

  Widget _legendDot(Color color) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  Widget _dotChart(List<SymptomEntry> entries) {
    final theme = Theme.of(context);
    final Map<int, List<SymptomEntry>> byDay = {};
    for (final e in entries) {
      byDay.putIfAbsent(e.dateTime.day, () => []).add(e);
    }
    final days = byDay.keys.toList()..sort();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 28,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('10', style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant, fontSize: 10)),
              Text('5', style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant, fontSize: 10)),
              Text('0', style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant, fontSize: 10)),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((day) {
                final dayEntries = byDay[day]!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: dayEntries.map((entry) {
                          final idx = entries.indexOf(entry);
                          final isExpanded = _expandedDot == idx;
                          final color = _severityColor(entry.severity);

                          return GestureDetector(
                            onTap: () => setState(() => _expandedDot = isExpanded ? null : idx),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: isExpanded
                                  ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
                                  : EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: isExpanded ? theme.colorScheme.surfaceContainer : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: isExpanded ? Border.all(color: color.withOpacity(0.5)) : null,
                              ),
                              child: isExpanded
                                  ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.symptom,
                                      style: GoogleFonts.arimo(
                                          color: theme.colorScheme.onSurface,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700)),
                                  Text('${_severityLabel(entry.severity)} · ${entry.severity}/10',
                                      style: GoogleFonts.arimo(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
                                ],
                              )
                                  : Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 6),
                      Container(width: 1, height: 6, color: theme.colorScheme.outlineVariant),
                      const SizedBox(height: 4),
                      Text('$day',
                          style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rangePicker() {
    final theme = Theme.of(context);
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: _selectedRange,
        dropdownColor: theme.colorScheme.surfaceContainerHighest,
        style: GoogleFonts.arimo(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
        icon: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.primary, size: 18),
        items: const [
          DropdownMenuItem(value: 7, child: Text('Last 7 days')),
          DropdownMenuItem(value: 14, child: Text('Last 14 days')),
          DropdownMenuItem(value: 30, child: Text('Last 30 days')),
        ],
        onChanged: (v) => setState(() => _selectedRange = v!),
      ),
    );
  }

  Widget _historyTile(BuildContext context, SymptomEntry e) {
    final theme = Theme.of(context);
    final color = _severityColor(e.severity);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showEntryDetails(context, e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.monitor_heart_outlined, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.symptom,
                      style: GoogleFonts.arimo(
                          color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${_severityLabel(e.severity)} · ${e.severity}/10',
                      style: GoogleFonts.arimo(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('${_formatDate(e.dateTime)} at ${_formatTime(e.dateTime)}',
                      style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }

  void _showEntryDetails(BuildContext context, SymptomEntry e) {
    final theme = Theme.of(context);
    final color = _severityColor(e.severity);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.monitor_heart_outlined, color: color, size: 24),
                const SizedBox(width: 12),
                Text('Symptom Entry',
                    style: GoogleFonts.arimo(
                        color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 20),
            Text(e.symptom,
                style: GoogleFonts.arimo(
                    color: theme.colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _detailRow('Severity', '${_severityLabel(e.severity)} (${e.severity}/10)', color),
            const SizedBox(height: 12),
            _detailRow('Date & Time', '${_formatDate(e.dateTime)} at ${_formatTime(e.dateTime)}', theme.colorScheme.onSurface),
            if (e.notes != null && e.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('NOTES',
                  style: GoogleFonts.arimo(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
              const SizedBox(height: 8),
              Text(e.notes!,
                  style: GoogleFonts.arimo(color: theme.colorScheme.onSurface, fontSize: 15, height: 1.5)),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, Color valueColor) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
        Text(value, style: GoogleFonts.arimo(color: valueColor, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class AllSymptomsEntriesScreen extends StatefulWidget {
  final List<SymptomEntry> entries;

  const AllSymptomsEntriesScreen({super.key, required this.entries});

  @override
  State<AllSymptomsEntriesScreen> createState() =>
      _AllSymptomsEntriesScreenState();
}

class _AllSymptomsEntriesScreenState extends State<AllSymptomsEntriesScreen> {
  DateTime? _filterStart;
  DateTime? _filterEnd;
  final Color _accentGreen = const Color(0xFF00C950);

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  String _formatShort(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$m/$d/${dt.year}';
  }

  bool get _hasFilter => _filterStart != null && _filterEnd != null;

  Color _severityColor(int severity) {
    if (severity <= 3) return _accentGreen;
    if (severity <= 6) return Colors.orange;
    return Colors.red;
  }

  String _severityLabel(int severity) {
    if (severity <= 3) return 'Mild';
    if (severity <= 6) return 'Moderate';
    return 'Severe';
  }

  List<SymptomEntry> get _filtered {
    final sorted = List<SymptomEntry>.from(widget.entries)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    if (!_hasFilter) return sorted;
    final end = DateTime(
        _filterEnd!.year, _filterEnd!.month, _filterEnd!.day, 23, 59, 59);
    return sorted
        .where((e) =>
    !e.dateTime.isBefore(_filterStart!) && !e.dateTime.isAfter(end))
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
          onApply: (s, e) => setState(() {
            _filterStart = s;
            _filterEnd = e;
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = _filtered;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              color: theme.colorScheme.surfaceContainer,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(width: 16),
                  Text('All Entries',
                      style: GoogleFonts.arimo(
                          color: theme.colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${entries.length} records',
                      style: GoogleFonts.arimo(
                          color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _hasFilter
                      ? () => setState(() {
                    _filterStart = null;
                    _filterEnd = null;
                  })
                      : _openPicker,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _hasFilter
                          ? _accentGreen.withOpacity(0.1)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _hasFilter ? _accentGreen : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _hasFilter ? Icons.date_range : Icons.filter_list,
                          color: _hasFilter ? _accentGreen : theme.colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _hasFilter
                              ? '${_formatShort(_filterStart!)} – ${_formatShort(_filterEnd!)}'
                              : 'Filter by Date',
                          style: GoogleFonts.arimo(
                              color: _hasFilter ? _accentGreen : theme.colorScheme.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                        if (_hasFilter) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.close, color: _accentGreen, size: 14),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Entries List
            Expanded(
              child: entries.isEmpty
                  ? Center(
                child: Text(
                  _hasFilter ? 'No entries in this range' : 'No entries logged yet',
                  style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = entries[index];
                  return _entryTile(context, e);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _entryTile(BuildContext context, SymptomEntry e) {
    final theme = Theme.of(context);
    final color = _severityColor(e.severity);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showEntryDetails(context, e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.monitor_heart_outlined, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.symptom,
                      style: GoogleFonts.arimo(
                          color: theme.colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_severityLabel(e.severity)} · ${e.severity}/10',
                          style: GoogleFonts.arimo(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_formatDate(e.dateTime)} at ${_formatTime(e.dateTime)}',
                    style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }

  void _showEntryDetails(BuildContext context, SymptomEntry e) {
    final theme = Theme.of(context);
    final color = _severityColor(e.severity);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.monitor_heart_outlined, color: color, size: 24),
                const SizedBox(width: 12),
                Text('Entry Details',
                    style: GoogleFonts.arimo(
                        color: theme.colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 20),
            Text(e.symptom,
                style: GoogleFonts.arimo(
                    color: theme.colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // Severity Progress
            Row(
              children: [
                Text('Severity', style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.severity / 10,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${e.severity}/10',
                    style: GoogleFonts.arimo(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 24),

            // Metadata
            _detailRow(theme, Icons.calendar_today, 'Date', _formatDate(e.dateTime)),
            _detailRow(theme, Icons.access_time, 'Time', _formatTime(e.dateTime)),

            if (e.notes != null && e.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              Divider(color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 16),
              Text('NOTES',
                  style: GoogleFonts.arimo(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1)),
              const SizedBox(height: 8),
              Text(e.notes!,
                  style: GoogleFonts.arimo(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                      height: 1.5)),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 16),
          const SizedBox(width: 8),
          Text('$label: ', style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
          Text(value, style: GoogleFonts.arimo(color: theme.colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}