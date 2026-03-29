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

  // Convert stored value to display unit
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

  // Always evaluate status in mg/dL
  String _entryStatus(GlucoseEntry e) {
    final mgDl = e.unit == 'mmol/L' ? e.value * 18.0182 : e.value;
    return _glucoseStatus(mgDl);
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = List<GlucoseEntry>.from(
      context.watch<HealthCubit>().getGlucoseEntries(),
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
                  child: Text("No Data",
                      style: TextStyle(color: Colors.white)),
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
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final avgVal = values.reduce((a, b) => a + b) / values.length;

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

                    _latestCard(latest),

                    const SizedBox(height: 20),

                    _chartCard(chartEntries, minVal, avgVal, maxVal),

                    const SizedBox(height: 20),

                    Text("History",
                        style: GoogleFonts.arimo(
                            color: Colors.white,
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
                          width: 87,
                          height: 31,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF474747),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21),
                            ),
                          ),
                          child: const Stack(
                            children: [
                              Positioned(
                                left: 15,
                                top: 8,
                                child: Text(
                                  'All Entries',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
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
          Text("Glucose",
              style: GoogleFonts.arimo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const GlucoseScreen())),
            child: Image.asset('assets/icons/add.png', width: 26, height: 26),
          ),
        ],
      ),
    );
  }

  Widget _latestCard(GlucoseEntry e) {
    final value = _convert(e);
    final status = _entryStatus(e);
    final color = _statusColor(status);

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
              Image.asset('assets/icons/diabetes.png', width: 20),
              const SizedBox(width: 8),
              Text("Latest Entry",
                  style: GoogleFonts.arimo(
                      color: Colors.white, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${value.toStringAsFixed(1)} $_unit",
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(status,
                        style: GoogleFonts.arimo(
                            color: color, fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  // Unit toggle
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
            style: GoogleFonts.arimo(color: const Color(0xFFCDCDCD)),
          ),
        ],
      ),
    );
  }
  Widget _chartCard(
      List<GlucoseEntry> entries,
      double minVal,
      double avgVal,
      double maxVal,
      ) {
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
              Text("History Chart",
                  style: GoogleFonts.arimo(
                      color: Colors.white,
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
                    style: GoogleFonts.arimo(color: Colors.white54)),
              ),
            )
          else
            SizedBox(height: 220, child: _buildChart(entries)),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(const Color(0xFF3B82F6)),
              const SizedBox(width: 4),
              Text("Glucose ($_unit)",
                  style: GoogleFonts.arimo(
                      color: Colors.white70, fontSize: 12)),
            ],
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
          DropdownMenuItem(value: 7,  child: Text("Last 7 days")),
          DropdownMenuItem(value: 14, child: Text("Last 14 days")),
          DropdownMenuItem(value: 30, child: Text("Last 30 days")),
        ],
        onChanged: (v) => setState(() => _selectedRange = v!),
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.arimo(
                color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.arimo(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _legendDot(Color color) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  Widget _unitToggle(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF3B82F6) : const Color(0xFF474747),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: GoogleFonts.arimo(
                color: Colors.white, fontSize: 11)),
      ),
    );
  }

  Widget _buildChart(List<GlucoseEntry> entries) {
    final spots = entries
        .map((e) => FlSpot(e.dateTime.day.toDouble(), _convert(e)))
        .toList();

    final values = entries.map(_convert).toList();
    final minY = values.reduce((a, b) => a < b ? a : b) - (_showMmol ? 0.5 : 10);
    final maxY = values.reduce((a, b) => a > b ? a : b) + (_showMmol ? 0.5 : 10);

    // Normal range band
    final normalMin = _showMmol ? 3.9 : 70.0;
    final normalMax = _showMmol ? 5.6 : 100.0;

    const blue = Color(0xFF3B82F6);

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        backgroundColor: const Color(0xFF2D2D2D),

        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: normalMin,
              y2: normalMax,
              color: const Color(0xFF1E5C38).withOpacity(0.4),
            ),
          ],
        ),

        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          verticalInterval: 1,
          getDrawingVerticalLine: (_) =>
          const FlLine(color: Color(0xFF3A3A3A), strokeWidth: 1),
          getDrawingHorizontalLine: (_) =>
          const FlLine(color: Color(0xFF3A3A3A), strokeWidth: 1),
        ),

        borderData: FlBorderData(show: false),

        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (val, _) => Text(
                val.toStringAsFixed(_showMmol ? 1 : 0),
                style: GoogleFonts.arimo(
                    color: Colors.white54, fontSize: 11),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (val, _) => Text(
                val.toInt().toString(),
                style: GoogleFonts.arimo(
                    color: Colors.white54, fontSize: 11),
              ),
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: blue,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 5,
                color: blue,
                strokeColor: blue,
              ),
            ),
            aboveBarData: BarAreaData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],

        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF3A3A3A),
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
              "${s.y.toStringAsFixed(_showMmol ? 1 : 0)} $_unit",
              GoogleFonts.arimo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _historyTile(GlucoseEntry e) {
    final value = _convert(e);
    final status = _entryStatus(e);
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(10),
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
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  "${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}",
                  style: GoogleFonts.arimo(
                      color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status,
                style: GoogleFonts.arimo(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
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
    return "$m/${d}/${dt.year}";
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
    if (mgDl < 70)  return "Low";
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
          onApply: (start, end) =>
              setState(() { _filterStart = start; _filterEnd = end; }),
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
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text("All Entries",
                      style: GoogleFonts.arimo(
                          color: Colors.white,
                          fontSize: 16,
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
                      ? () => setState(
                          () { _filterStart = null; _filterEnd = null; })
                      : _openPicker,
                  child: _hasFilter
                      ? Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
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
                          "${_formatShort(_filterStart!)} – ${_formatShort(_filterEnd!)}",
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
                          Image.asset("assets/icons/calendar.png",
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
                      ? "No entries in this range"
                      : "No entries",
                  style: GoogleFonts.arimo(color: Colors.white54),
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
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${value.toStringAsFixed(1)} $_unit",
                                  style: GoogleFonts.arimo(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}",
                                  style: GoogleFonts.arimo(
                                      color: Colors.white54,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(status,
                                style: GoogleFonts.arimo(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
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

  Widget _unitToggle(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF3B82F6) : const Color(0xFF474747),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: GoogleFonts.arimo(color: Colors.white, fontSize: 11)),
      ),
    );
  }

  void _showEntryDetails(BuildContext context, GlucoseEntry e) {
    final mgDl = e.unit == 'mmol/L' ? e.value * 18.0182 : e.value;
    final mmol = e.unit == 'mmol/L' ? e.value : e.value / 18.0182;

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
                Image.asset('assets/icons/diabetes.png', width: 20),
                const SizedBox(width: 8),
                Text("Glucose Entry",
                    style: GoogleFonts.arimo(
                        color: Colors.white,
                        fontSize: 16,
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.arimo(
                    color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 18,
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