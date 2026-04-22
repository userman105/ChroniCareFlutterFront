import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/health_cubit.dart';
import '../../models/glucose_entry.dart';
import '../../widgets/components.dart';
import 'glucose_log_screen.dart';

class GlucoseDetailsScreen extends StatefulWidget {
  const GlucoseDetailsScreen({super.key});

  @override
  State<GlucoseDetailsScreen> createState() => _GlucoseDetailsScreenState();
}

class _GlucoseDetailsScreenState extends State<GlucoseDetailsScreen> {
  int _selectedRange = 7;
  bool _showMmol = false; // false = mg/dL, true = mmol/L

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  String _formatDate(DateTime dt) => "${dt.day}/${dt.month}/${dt.year}";

  String get _unit => _showMmol ? "mmol/L" : "mg/dL";

  double _convert(GlucoseEntry e) {
    final storedInMmol = e.unit == 'mmol/L';
    if (_showMmol && !storedInMmol) return e.value / 18.0182;
    if (!_showMmol && storedInMmol) return e.value * 18.0182;
    return e.value;
  }

  String _glucoseStatus(double mgDl) {
    if (mgDl < 70) return "Low";
    if (mgDl <= 99) return "Normal";
    if (mgDl <= 125) return "Pre-diabetic";
    return "High";
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Normal":       return const Color(0xFF00C950);
      case "Pre-diabetic": return Colors.orange;
      case "High":         return Colors.red;
      case "Low":          return Colors.blue;
      default:             return Colors.grey;
    }
  }

  String _entryStatus(GlucoseEntry e) {
    final mgDl = e.unit == 'mmol/L' ? e.value * 18.0182 : e.value;
    return _glucoseStatus(mgDl);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allEntries = List<GlucoseEntry>.from(
      context.watch<HealthCubit>().getGlucoseEntries(),
    )..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (allEntries.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _topBar(context),
              Expanded(
                child: Center(
                  child: Text("No Data",
                      style: TextStyle(color: theme.colorScheme.onSurface)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final latest = allEntries.last;
    final now = DateTime.now();
    final rangeStart = now.subtract(Duration(days: _selectedRange - 1));
    final chartEntries = allEntries
        .where((e) => e.dateTime
        .isAfter(rangeStart.subtract(const Duration(seconds: 1))))
        .toList();

    final values = chartEntries.map(_convert).toList();
    final minVal = values.isEmpty ? 0.0 : values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    final avgVal = values.isEmpty ? 0.0 : values.reduce((a, b) => a + b) / values.length;

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
                    _latestCard(latest),
                    const SizedBox(height: 20),
                    _chartCard(chartEntries, minVal, avgVal, maxVal),
                    const SizedBox(height: 20),
                    Text("History",
                        style: GoogleFonts.arimo(
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    ...allEntries.reversed
                        .take(3)
                        .map((e) => _historyTile(e))
                        .toList(),
                    const SizedBox(height: 12),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllGlucoseEntriesScreen(
                                entries: allEntries),
                          ),
                        ),
                        child: Container(
                          width: 100,
                          height: 36,
                          decoration: ShapeDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'All Entries',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
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
          Text("Glucose",
              style: GoogleFonts.arimo(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const GlucoseScreen())),
            child: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _latestCard(GlucoseEntry e) {
    final theme = Theme.of(context);
    final value = _convert(e);
    final status = _entryStatus(e);
    final color = _statusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bloodtype, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text("Latest Entry",
                  style: GoogleFonts.arimo(
                      color: theme.colorScheme.onSurface, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${value.toStringAsFixed(1)} $_unit",
                style: GoogleFonts.arimo(
                    color: theme.colorScheme.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(status,
                        style: GoogleFonts.arimo(
                            color: color, fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  _unitToggle("mg/dL", !_showMmol,
                          () => setState(() => _showMmol = false)),
                  const SizedBox(width: 6),
                  _unitToggle("mmol/L", _showMmol,
                          () => setState(() => _showMmol = true)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Measured ${_formatDate(e.dateTime)} at ${_formatTime(e.dateTime)}",
            style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _chartCard(List<GlucoseEntry> entries, double minVal, double avgVal, double maxVal) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("History Chart",
                  style: GoogleFonts.arimo(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              _rangePicker(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statChip("Min", "${minVal.toStringAsFixed(1)} $_unit"),
              _statChip("Avg", "${avgVal.toStringAsFixed(1)} $_unit"),
              _statChip("Max", "${maxVal.toStringAsFixed(1)} $_unit"),
            ],
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text("No data in range",
                    style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant)),
              ),
            )
          else
            SizedBox(height: 220, child: _buildChart(entries)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text("Glucose ($_unit)",
                  style: GoogleFonts.arimo(
                      color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rangePicker() {
    final theme = Theme.of(context);
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: _selectedRange,
        dropdownColor: theme.colorScheme.surfaceContainerHighest,
        style: GoogleFonts.arimo(color: theme.colorScheme.onSurface, fontSize: 13),
        icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurface),
        items: const [
          DropdownMenuItem(value: 7,  child: Text("Last 7 days")),
          DropdownMenuItem(value: 14, child: Text("Last 14 days")),
          DropdownMenuItem(value: 30, child: Text("Last 30 days")),
        ],
        onChanged: (v) => setState(() => _selectedRange = v!),
      ),
    );
  }

  Widget _statChip(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.arimo(
                color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.arimo(
                color: theme.colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _legendDot(Color color) => Container(
    width: 10, height: 10,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  Widget _unitToggle(String label, bool active, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: GoogleFonts.arimo(
                color: active ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                fontSize: 11)),
      ),
    );
  }

  Widget _buildChart(List<GlucoseEntry> entries) {
    final theme = Theme.of(context);
    final spots = entries
        .map((e) => FlSpot(e.dateTime.day.toDouble(), _convert(e)))
        .toList();

    final values = entries.map(_convert).toList();
    final minY = values.reduce((a, b) => a < b ? a : b) - (_showMmol ? 0.5 : 10);
    final maxY = values.reduce((a, b) => a > b ? a : b) + (_showMmol ? 0.5 : 10);

    final normalMin = _showMmol ? 3.9 : 70.0;
    final normalMax = _showMmol ? 5.6 : 100.0;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: normalMin, y2: normalMax,
              color: Colors.green.withOpacity(0.15),
            ),
          ],
        ),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (_) => FlLine(color: theme.colorScheme.outlineVariant, strokeWidth: 0.5),
          getDrawingVerticalLine: (_) => FlLine(color: theme.colorScheme.outlineVariant, strokeWidth: 0.5),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (val, _) => Text(
                val.toStringAsFixed(_showMmol ? 1 : 0),
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) => Text(
                val.toInt().toString(),
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _historyTile(GlucoseEntry e) {
    final theme = Theme.of(context);
    final value = _convert(e);
    final status = _entryStatus(e);
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${value.toStringAsFixed(1)} $_unit",
                  style: GoogleFonts.arimo(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  "${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}",
                  style: GoogleFonts.arimo(
                      color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status,
                style: GoogleFonts.arimo(
                    color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}


class AllGlucoseEntriesScreen extends StatefulWidget {
  final List<GlucoseEntry> entries;

  const AllGlucoseEntriesScreen({super.key, required this.entries});

  @override
  State<AllGlucoseEntriesScreen> createState() =>
      _AllGlucoseEntriesScreenState();
}

class _AllGlucoseEntriesScreenState extends State<AllGlucoseEntriesScreen> {
  DateTime? _filterStart;
  DateTime? _filterEnd;
  bool _showMmol = false;

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  String _formatDate(DateTime dt) => "${dt.day}/${dt.month}/${dt.year}";

  String _formatShort(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return "$m/$d/${dt.year}";
  }

  String get _unit => _showMmol ? "mmol/L" : "mg/dL";

  double _convert(GlucoseEntry e) {
    final storedInMmol = e.unit == 'mmol/L';
    if (_showMmol && !storedInMmol) return e.value / 18.0182;
    if (!_showMmol && storedInMmol) return e.value * 18.0182;
    return e.value;
  }

  String _entryStatus(GlucoseEntry e) {
    final mgDl = e.unit == 'mmol/L' ? e.value * 18.0182 : e.value;
    if (mgDl < 70) return "Low";
    if (mgDl <= 99) return "Normal";
    if (mgDl <= 125) return "Pre-diabetic";
    return "High";
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Normal":       return const Color(0xFF00C950);
      case "Pre-diabetic": return Colors.orange;
      case "High":         return Colors.red;
      case "Low":          return Colors.blue;
      default:             return Colors.grey;
    }
  }

  bool get _hasFilter => _filterStart != null && _filterEnd != null;

  List<GlucoseEntry> get _filtered {
    final sorted = List<GlucoseEntry>.from(widget.entries)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    if (!_hasFilter) return sorted;

    final end = DateTime(_filterEnd!.year, _filterEnd!.month,
        _filterEnd!.day, 23, 59, 59);

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
          onApply: (start, end) =>
              setState(() { _filterStart = start; _filterEnd = end; }),
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
                  Text("All Entries",
                      style: GoogleFonts.arimo(
                          color: theme.colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  _unitToggle("mg/dL", !_showMmol,
                          () => setState(() => _showMmol = false)),
                  const SizedBox(width: 6),
                  _unitToggle("mmol/L", _showMmol,
                          () => setState(() => _showMmol = true)),
                  const SizedBox(width: 10),
                  Text("${entries.length} records",
                      style: GoogleFonts.arimo(
                          color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
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
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: ShapeDecoration(
                      color: _hasFilter
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16,
                            color: _hasFilter ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          _hasFilter
                              ? "${_formatShort(_filterStart!)} – ${_formatShort(_filterEnd!)}"
                              : 'All Time',
                          style: GoogleFonts.arimo(
                              color: _hasFilter ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                        if (_hasFilter) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.close,
                              color: theme.colorScheme.onPrimaryContainer, size: 16),
                        ],
                      ],
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
                  _hasFilter ? "No entries in this range" : "No entries",
                  style: GoogleFonts.arimo(color: theme.colorScheme.onSurfaceVariant),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = entries[index];
                  final value = _convert(e);
                  final status = _entryStatus(e);
                  final color = _statusColor(status);

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showEntryDetails(context, e),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${value.toStringAsFixed(1)} $_unit",
                                  style: GoogleFonts.arimo(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}",
                                  style: GoogleFonts.arimo(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(status,
                                style: GoogleFonts.arimo(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5), size: 18),
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

  Widget _unitToggle(String label, bool active, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: GoogleFonts.arimo(
                color: active ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                fontSize: 11)),
      ),
    );
  }

  void _showEntryDetails(BuildContext context, GlucoseEntry e) {
    final theme = Theme.of(context);
    final mgDl = e.unit == 'mmol/L' ? e.value * 18.0182 : e.value;
    final mmol = e.unit == 'mmol/L' ? e.value : e.value / 18.0182;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
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
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.bloodtype, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text("Glucose Entry",
                    style: GoogleFonts.arimo(
                        color: theme.colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _detailChip("mg/dL", "${mgDl.toStringAsFixed(0)} mg/dL"),
                const SizedBox(width: 12),
                _detailChip("mmol/L", "${mmol.toStringAsFixed(1)} mmol/L"),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow(Icons.calendar_today_outlined,
                "${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}"),
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
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.arimo(
                    color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.arimo(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: GoogleFonts.arimo(
                  color: theme.colorScheme.onSurface, fontSize: 14)),
        ),
      ],
    );
  }
}