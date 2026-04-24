import 'package:chronic_care/main_activity/blood_log/blood_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/lang/lang_strings.dart';
import '../../cubit/health_cubit.dart';
import '../../cubit/locale_cubit.dart';
import '../../models/blood_pressure_entry.dart';
import '../../widgets/components.dart';
import 'all_entries.dart';

String getBPStatus(int sys, int dia) {
  if (sys < 90 || dia < 60) return "Low";
  if (sys <= 120 && dia <= 80) return "Normal";
  if (sys <= 139 || dia <= 89) return "Elevated";
  return "High";
}

Color getStatusColor(String status) {
  switch (status) {
    case "Normal":   return const Color(0xFF00C950);
    case "Elevated": return Colors.orange;
    case "High":     return Colors.red;
    case "Low":      return Colors.blue;
    default:         return Colors.grey;
  }
}

class BloodPressureDetailsScreen extends StatefulWidget {
  const BloodPressureDetailsScreen({super.key});

  @override
  State<BloodPressureDetailsScreen> createState() =>
      _BloodPressureDetailsScreenState();
}

class _BloodPressureDetailsScreenState
    extends State<BloodPressureDetailsScreen> {
  int _selectedRange = 7;

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  String _formatDate(DateTime dt) =>
      "${dt.day}/${dt.month}/${dt.year}";

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleCubit>().state;
    final c    = context.colors;
    final isRtl = lang == 'ar';

    final allEntries = List<BloodPressureEntry>.from(
      context.watch<HealthCubit>().state,
    )..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (allEntries.isEmpty) {
      return Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: c.surface,
            leading: IconButton(
              icon: Icon(
                isRtl ? Icons.arrow_forward : Icons.arrow_back,
                color: c.primaryText,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              AppStrings.get('blood_pressure', lang),
              style: GoogleFonts.arimo(color: c.primaryText),
            ),
          ),
          body: Center(
            child: Text(
              AppStrings.get('no_data', lang),
              style: TextStyle(color: c.primaryText),
            ),
          ),
        ),
      );
    }

    final latest = allEntries.last;
    final status = getBPStatus(latest.systolic, latest.diastolic);

    final now        = DateTime.now();
    final rangeStart = now.subtract(Duration(days: _selectedRange - 1));
    final chartEntries = allEntries
        .where((e) => e.dateTime
        .isAfter(rangeStart.subtract(const Duration(seconds: 1))))
        .toList();

    final sysValues = chartEntries.map((e) => e.systolic).toList();
    final diaValues = chartEntries.map((e) => e.diastolic).toList();
    final sysMin = sysValues.reduce((a, b) => a < b ? a : b);
    final sysMax = sysValues.reduce((a, b) => a > b ? a : b);
    final sysAvg =
    (sysValues.reduce((a, b) => a + b) / sysValues.length).round();
    final diaMin = diaValues.reduce((a, b) => a < b ? a : b);
    final diaMax = diaValues.reduce((a, b) => a > b ? a : b);
    final diaAvg =
    (diaValues.reduce((a, b) => a + b) / diaValues.length).round();

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                color: c.surface,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        isRtl ? Icons.arrow_forward : Icons.arrow_back,
                        color: c.primaryText,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      AppStrings.get('blood_pressure', lang),
                      style: GoogleFonts.arimo(
                        color: c.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BloodPressureScreen()),
                      ),
                      child: Image.asset('assets/icons/add.png',
                          width: 26, height: 26),
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

                      _latestCard(context, latest, status,
                          getStatusColor(status), lang),

                      const SizedBox(height: 20),

                      _chartCard(
                          context, chartEntries,
                          sysMin, sysAvg, sysMax,
                          diaMin, diaAvg, diaMax,
                          lang),

                      const SizedBox(height: 20),

                      Text(
                        AppStrings.get('history', lang),
                        style: GoogleFonts.arimo(
                            color: c.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),

                      ...allEntries.reversed
                          .take(3)
                          .map((e) => _historyTile(context, e, lang)),

                      const SizedBox(height: 12),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AllEntriesScreen(entries: allEntries),
                            ),
                          ),
                          child: Container(
                            width: 105,
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
                                AppStrings.get('all_entries', lang),
                                style: GoogleFonts.arimo(
                                  color: c.primaryText,
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
      ),
    );
  }


  Widget _latestCard(BuildContext context, BloodPressureEntry e,
      String status, Color statusColor, String lang) {
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
              Image.asset('assets/icons/bloodPressure.png', width: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.get('latest_reading', lang),
                style:
                GoogleFonts.arimo(color: c.primaryText, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${e.systolic}/${e.diastolic} ${AppStrings.get('mmhg', lang)}",
                style: GoogleFonts.arimo(
                    color: c.primaryText,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _localizedStatus(status, lang),
                  style: GoogleFonts.arimo(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${AppStrings.get('measured', lang)} ${_formatDate(e.dateTime)} ${AppStrings.get('at_time', lang)} ${_formatTime(e.dateTime)}",
            style: GoogleFonts.arimo(color: c.secondaryText),
          ),
        ],
      ),
    );
  }


  Widget _chartCard(
      BuildContext context,
      List<BloodPressureEntry> entries,
      int sysMin, int sysAvg, int sysMax,
      int diaMin, int diaAvg, int diaMax,
      String lang,
      ) {
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
              Text(
                AppStrings.get('history_chart', lang),
                style: GoogleFonts.arimo(
                    color: c.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              _rangePicker(context, lang),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statChip(context, AppStrings.get('min', lang),
                  "$sysMin/$diaMin"),
              _statChip(context, AppStrings.get('avg', lang),
                  "$sysAvg/$diaAvg"),
              _statChip(context, AppStrings.get('max', lang),
                  "$sysMax/$diaMax"),
            ],
          ),
          const SizedBox(height: 16),
          entries.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                AppStrings.get('no_data_range', lang),
                style: GoogleFonts.arimo(color: c.hintText),
              ),
            ),
          )
              : SizedBox(
            height: 220,
            child: _buildChart(context, entries),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(const Color(0xFFE8C44A)),
              const SizedBox(width: 4),
              Text(
                AppStrings.get('systolic', lang),
                style: GoogleFonts.arimo(
                    color: c.secondaryText, fontSize: 12),
              ),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFFE8C44A), hollow: true),
              const SizedBox(width: 4),
              Text(
                AppStrings.get('diastolic', lang),
                style: GoogleFonts.arimo(
                    color: c.secondaryText, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, {bool hollow = false}) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: hollow ? Colors.transparent : color,
      border: Border.all(color: color, width: 2),
    ),
  );

  Widget _rangePicker(BuildContext context, String lang) {
    final c = context.colors;
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: _selectedRange,
        dropdownColor: c.cardBg,
        style: GoogleFonts.arimo(color: c.primaryText, fontSize: 13),
        icon: Icon(Icons.arrow_drop_down, color: c.primaryText),
        items: [
          DropdownMenuItem(
              value: 7,
              child: Text(AppStrings.get('last_7_days', lang),
                  style: TextStyle(color: c.primaryText))),
          DropdownMenuItem(
              value: 14,
              child: Text(AppStrings.get('last_14_days', lang),
                  style: TextStyle(color: c.primaryText))),
          DropdownMenuItem(
              value: 30,
              child: Text(AppStrings.get('last_30_days', lang),
                  style: TextStyle(color: c.primaryText))),
        ],
        onChanged: (v) => setState(() => _selectedRange = v!),
      ),
    );
  }

  Widget _statChip(BuildContext context, String label, String value) {
    final c = context.colors;
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.arimo(color: c.hintText, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.arimo(
                color: c.primaryText,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildChart(
      BuildContext context, List<BloodPressureEntry> entries) {
    final c = context.colors;

    FlSpot toSpot(BloodPressureEntry e, int Function(BloodPressureEntry) val) =>
        FlSpot(e.dateTime.day.toDouble(), val(e).toDouble());

    final sysSpots =
    entries.map((e) => toSpot(e, (e) => e.systolic)).toList();
    final diaSpots =
    entries.map((e) => toSpot(e, (e) => e.diastolic)).toList();

    final allVals = [
      ...entries.map((e) => e.systolic),
      ...entries.map((e) => e.diastolic),
    ];
    final minY =
    (allVals.reduce((a, b) => a < b ? a : b) - 20).clamp(0, 999).toDouble();
    final maxY =
    (allVals.reduce((a, b) => a > b ? a : b) + 20).toDouble();

    const yellow       = Color(0xFFE8C44A);
    final gridLineColor = c.divider;
    final hollowFill    = c.surface;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        backgroundColor: c.surface,
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(
              y1: 60,
              y2: 80,
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
              FlLine(color: gridLineColor, strokeWidth: 1),
          getDrawingHorizontalLine: (_) =>
              FlLine(color: gridLineColor, strokeWidth: 1),
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
                style:
                GoogleFonts.arimo(color: c.hintText, fontSize: 11),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (val, _) => Text(
                val.toInt().toString(),
                style:
                GoogleFonts.arimo(color: c.hintText, fontSize: 11),
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
            spots: sysSpots,
            isCurved: false,
            color: yellow,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 5, color: yellow, strokeColor: yellow),
            ),
            aboveBarData: BarAreaData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: diaSpots,
            isCurved: false,
            color: yellow,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 5,
                  color: hollowFill,
                  strokeColor: yellow,
                  strokeWidth: 2),
            ),
            aboveBarData: BarAreaData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => c.cardBg,
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
              s.y.toInt().toString(),
              GoogleFonts.arimo(
                  color: c.primaryText,
                  fontWeight: FontWeight.bold),
            ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _historyTile(
      BuildContext context, BloodPressureEntry e, String lang) {
    final c      = context.colors;
    final status = getBPStatus(e.systolic, e.diastolic);
    final color  = getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${e.systolic}/${e.diastolic} ${AppStrings.get('mmhg', lang)}",
                  style: GoogleFonts.arimo(
                      color: c.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  "${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}",
                  style:
                  GoogleFonts.arimo(color: c.hintText, fontSize: 12),
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
            child: Text(
              _localizedStatus(status, lang),
              style: GoogleFonts.arimo(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  String _localizedStatus(String status, String lang) {
    const map = {
      'en': {'Low': 'Low', 'Normal': 'Normal', 'Elevated': 'Elevated', 'High': 'High'},
      'ar': {'Low': 'منخفض', 'Normal': 'طبيعي', 'Elevated': 'مرتفع قليلاً', 'High': 'مرتفع'},
    };
    return map[lang]?[status] ?? status;
  }
}