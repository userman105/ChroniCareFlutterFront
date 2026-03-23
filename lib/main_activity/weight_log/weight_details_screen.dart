import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/health_cubit.dart';
import '../../models/weight_entry.dart';
import '../../widgets/components.dart';
import 'weight_log_screen.dart';

class WeightDetailsScreen extends StatefulWidget {
  const WeightDetailsScreen({super.key});

  @override
  State<WeightDetailsScreen> createState() => _WeightDetailsScreenState();
}

class _WeightDetailsScreenState extends State<WeightDetailsScreen> {
  int _selectedRange = 7;
  bool _showKg = true;

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  String _formatDate(DateTime dt) => "${dt.day}/${dt.month}/${dt.year}";

  double _convert(WeightEntry e) {
    if (_showKg) return e.kg ?? (e.lbs! / 2.20462);
    return e.lbs ?? (e.kg! * 2.20462);
  }

  String get _unit => _showKg ? "kg" : "lbs";

  @override
  Widget build(BuildContext context) {
    final allEntries = List<WeightEntry>.from(
      context.watch<HealthCubit>().getWeightEntries(),
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

                    Text(
                      "History",
                      style: GoogleFonts.arimo(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
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
                            builder: (_) => AllWeightEntriesScreen(
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
          Text("Weight",
              style: GoogleFonts.arimo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const WeightLogScreen())),
            child: Image.asset('assets/icons/add.png', width: 26, height: 26),
          ),
        ],
      ),
    );
  }

  Widget _latestCard(WeightEntry e) {
    final value = _convert(e);

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
              Image.asset('assets/icons/weight.png', width: 20),
              const SizedBox(width: 8),
              Text("Latest Entry",
                  style: GoogleFonts.arimo(color: Colors.white, fontSize: 16)),
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
              // KG / LBS toggle
              Row(
                children: [
                  _unitToggle("KG", _showKg,
                          () => setState(() => _showKg = true)),
                  const SizedBox(width: 6),
                  _unitToggle("LBS", !_showKg,
                          () => setState(() => _showKg = false)),
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
      List<WeightEntry> entries,
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
              _legendDot(const Color(0xFF00C950)),
              const SizedBox(width: 4),
              Text("Weight ($_unit)",
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
          DropdownMenuItem(value: 7, child: Text("Last 7 days")),
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
            style: GoogleFonts.arimo(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.arimo(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _unitToggle(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF00C950)
              : const Color(0xFF474747),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: GoogleFonts.arimo(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  Widget _buildChart(List<WeightEntry> entries) {
    final spots = entries
        .map((e) => FlSpot(e.dateTime.day.toDouble(), _convert(e)))
        .toList();

    final values = entries.map(_convert).toList();
    final minY = values.reduce((a, b) => a < b ? a : b) - 5;
    final maxY = values.reduce((a, b) => a > b ? a : b) + 5;

    const green = Color(0xFF00C950);

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        backgroundColor: const Color(0xFF2D2D2D),

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
              reservedSize: 40,
              getTitlesWidget: (val, _) => Text(
                val.toStringAsFixed(0),
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
            color: green,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 5,
                color: green,
                strokeColor: green,
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
              "${s.y.toStringAsFixed(1)} $_unit",
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

  Widget _historyTile(WeightEntry e) {
    final value = _convert(e);

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
                  style:
                  GoogleFonts.arimo(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AllWeightEntriesScreen extends StatefulWidget {
  final List<WeightEntry> entries;

  const AllWeightEntriesScreen({super.key, required this.entries});

  @override
  State<AllWeightEntriesScreen> createState() =>
      _AllWeightEntriesScreenState();
}

class _AllWeightEntriesScreenState extends State<AllWeightEntriesScreen> {
  DateTime? _filterStart;
  DateTime? _filterEnd;
  bool _showKg = true;

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

  String get _unit => _showKg ? "kg" : "lbs";

  double _convert(WeightEntry e) {
    if (_showKg) return e.kg ?? (e.lbs! / 2.20462);
    return e.lbs ?? (e.kg! * 2.20462);
  }

  bool get _hasFilter => _filterStart != null && _filterEnd != null;

  List<WeightEntry> get _filtered {
    final sorted = List<WeightEntry>.from(widget.entries)
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
                  // KG / LBS toggle
                  Row(
                    children: [
                      _unitToggle("KG", _showKg,
                              () => setState(() => _showKg = true)),
                      const SizedBox(width: 6),
                      _unitToggle("LBS", !_showKg,
                              () => setState(() => _showKg = false)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Text("${entries.length} records",
                      style: GoogleFonts.arimo(
                          color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.only(left :16.0),
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14),
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
                        const SizedBox(width: 12,),
                        Image.asset("assets/icons/calendar.png",
                          height: 20,width: 20,),
                        const SizedBox(width: 10,),
                        Text(
                          'All Time',
                          style: GoogleFonts.arimo(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
                  style:
                  GoogleFonts.arimo(color: Colors.white54),
                ),
              )
                  : ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                itemCount: entries.length,
                // Replace the existing Container in ListView.builder with this:
                itemBuilder: (context, index) {
                  final e = entries[index];
                  final value = _convert(e);

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showEntryDetails(context, e),
                    child: Container(
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
                          // Arrow hint
                          const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF00C950)
              : const Color(0xFF474747),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: GoogleFonts.arimo(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  void _showEntryDetails(BuildContext context, WeightEntry e) {
    final kg = e.kg ?? (e.lbs! / 2.20462);
    final lbs = e.lbs ?? (e.kg! * 2.20462);

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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Image.asset('assets/icons/weight.png', width: 20),
                const SizedBox(width: 8),
                Text(
                  "Weight Entry",
                  style: GoogleFonts.arimo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _detailChip("KG", "${kg.toStringAsFixed(1)} kg"),
                const SizedBox(width: 12),
                _detailChip("LBS", "${lbs.toStringAsFixed(1)} lbs"),
              ],
            ),

            const SizedBox(height: 16),

            _detailRow(
              Icons.calendar_today_outlined,
              "${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}",
            ),

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
          child: Text(
            text,
            style: GoogleFonts.arimo(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }
}