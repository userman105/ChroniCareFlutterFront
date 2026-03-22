import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/health_cubit.dart';
import '../../models/blood_pressure_entry.dart';

String getBPStatus(int sys, int dia) {
  if (sys < 90 || dia < 60) return "Low";
  if (sys <= 120 && dia <= 80) return "Normal";
  if (sys <= 139 || dia <= 89) return "Elevated";
  return "High";
}

class BloodPressureDetailsScreen extends StatefulWidget {
  const BloodPressureDetailsScreen({super.key});

  @override
  State<BloodPressureDetailsScreen> createState() =>
      _BloodPressureDetailsScreenState();
}

class _BloodPressureDetailsScreenState
    extends State<BloodPressureDetailsScreen> {
  int _selectedRange = 7; // days to show in chart

  String getStatus(int sys, int dia) => getBPStatus(sys, dia);

  Color getStatusColor(String status) {
    switch (status) {
      case "Normal":   return const Color(0xFF00C950);
      case "Elevated": return Colors.orange;
      case "High":     return Colors.red;
      case "Low":      return Colors.blue;
      default:         return Colors.grey;
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  String _formatDate(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = List<BloodPressureEntry>.from(
      context.watch<HealthCubit>().state,
    )..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (allEntries.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF111111),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2D2D2D),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Blood Pressure",
              style: GoogleFonts.arimo(color: Colors.white)),
        ),
        body: const Center(
            child: Text("No Data", style: TextStyle(color: Colors.white))),
      );
    }

    // Latest by date
    final latest = allEntries.last;
    final status = getStatus(latest.systolic, latest.diastolic);

    // Chart range entries
    final now = DateTime.now();
    final rangeStart = now.subtract(Duration(days: _selectedRange - 1));
    final chartEntries = allEntries.where((e) =>
        e.dateTime.isAfter(rangeStart.subtract(const Duration(seconds: 1)))).toList();

    // Stats
    final sysValues = chartEntries.map((e) => e.systolic).toList();
    final diaValues = chartEntries.map((e) => e.diastolic).toList();
    final sysMin = sysValues.reduce((a, b) => a < b ? a : b);
    final sysMax = sysValues.reduce((a, b) => a > b ? a : b);
    final sysAvg = (sysValues.reduce((a, b) => a + b) / sysValues.length).round();
    final diaMin = diaValues.reduce((a, b) => a < b ? a : b);
    final diaMax = diaValues.reduce((a, b) => a > b ? a : b);
    final diaAvg = (diaValues.reduce((a, b) => a + b) / diaValues.length).round();

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
                  Text(
                    "Blood Pressure",
                    style: GoogleFonts.arimo(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _latestCard(latest, status, getStatusColor(status)),

                    const SizedBox(height: 20),

                    _chartCard(chartEntries, sysMin, sysAvg, sysMax,
                        diaMin, diaAvg, diaMax),

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
                        .map((e) => _historyTile(e))
                        .toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _latestCard(BloodPressureEntry e, String status, Color color) {
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
              Image.asset('assets/icons/bloodPressure.png', width: 20),
              const SizedBox(width: 8),
              Text("Latest Reading",
                  style: GoogleFonts.arimo(color: Colors.white, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${e.systolic}/${e.diastolic} mmHg",
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status,
                    style: GoogleFonts.arimo(color: Colors.white)),
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
      List<BloodPressureEntry> entries,
      int sysMin, int sysAvg, int sysMax,
      int diaMin, int diaAvg, int diaMax,
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
              Text(
                "History Chart",
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              _rangePicker(),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statChip("Min", "$sysMin/$diaMin"),
              _statChip("Avg", "$sysAvg/$diaAvg"),
              _statChip("Max", "$sysMax/$diaMax"),
            ],
          ),

          const SizedBox(height: 16),

          if (entries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text("No data in range",
                    style:
                    GoogleFonts.arimo(color: Colors.white54)),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: _buildChart(entries),
            ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(const Color(0xFFE8C44A)),
              const SizedBox(width: 4),
              Text("Systolic",
                  style: GoogleFonts.arimo(
                      color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFFE8C44A), hollow: true),
              const SizedBox(width: 4),
              Text("Diastolic",
                  style: GoogleFonts.arimo(
                      color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, {bool hollow = false}) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hollow ? Colors.transparent : color,
        border: Border.all(color: color, width: 2),
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

  Widget _buildChart(List<BloodPressureEntry> entries) {
    // X axis = day-of-month, Y axis = BP value
    FlSpot toSpot(BloodPressureEntry e, int Function(BloodPressureEntry) val) {
      return FlSpot(e.dateTime.day.toDouble(), val(e).toDouble());
    }

    final sysSpots = entries.map((e) => toSpot(e, (e) => e.systolic)).toList();
    final diaSpots = entries.map((e) => toSpot(e, (e) => e.diastolic)).toList();

    final allVals = [
      ...entries.map((e) => e.systolic),
      ...entries.map((e) => e.diastolic),
    ];
    final minY = (allVals.reduce((a, b) => a < b ? a : b) - 20)
        .clamp(0, 999)
        .toDouble();
    final maxY =
    (allVals.reduce((a, b) => a > b ? a : b) + 20).toDouble();

    const yellow = Color(0xFFE8C44A);
    const normalBandMin = 60.0;
    const normalBandMax = 80.0; // diastolic normal band reference

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        backgroundColor: const Color(0xFF2D2D2D),

        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: normalBandMin,
              y2: normalBandMax,
              color: const Color(0xFF1E5C38).withOpacity(0.5),
            ),
          ],
        ),

        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          verticalInterval: 1,
          horizontalInterval: 50,
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
              reservedSize: 36,
              interval: 50,
              getTitlesWidget: (val, _) => Text(
                val.toInt().toString(),
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
          topTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        lineBarsData: [
          // Systolic line
          LineChartBarData(
            spots: sysSpots,
            isCurved: false,
            color: yellow,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 5,
                color: yellow,
                strokeColor: yellow,
              ),
            ),
            aboveBarData: BarAreaData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          // Diastolic line
          LineChartBarData(
            spots: diaSpots,
            isCurved: false,
            color: yellow,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 5,
                color: const Color(0xFF2D2D2D),
                strokeColor: yellow,
                strokeWidth: 2,
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
            getTooltipItems: (spots) => spots.map((s) {
              return LineTooltipItem(
                s.y.toInt().toString(),
                GoogleFonts.arimo(
                    color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _historyTile(BloodPressureEntry e) {
    final status = getStatus(e.systolic, e.diastolic);
    final color = getStatusColor(status);

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
                  "${e.systolic}/${e.diastolic} mmHg",
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
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status,
                style: GoogleFonts.arimo(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}