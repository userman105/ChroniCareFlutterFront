import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/lang/lang_strings.dart';
import '../../cubit/health_cubit.dart';
import '../../cubit/locale_cubit.dart';
import '../../models/weight_entry.dart';
import '../../widgets/components.dart';
import 'weight_log_screen.dart';

class WeightDetailsScreen extends StatefulWidget {
  const WeightDetailsScreen({super.key});

  @override
  State<WeightDetailsScreen> createState() =>
      _WeightDetailsScreenState();
}

class _WeightDetailsScreenState extends State<WeightDetailsScreen> {
  int  _selectedRange = 7;
  bool _showKg        = true;
  final Color _accentGreen = const Color(0xFF00C950);

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  double _convert(WeightEntry e) {
    if (_showKg) return e.kg ?? (e.lbs! / 2.20462);
    return e.lbs ?? (e.kg! * 2.20462);
  }

  String _unit(String lang) =>
      _showKg ? AppStrings.get('kg', lang) : AppStrings.get('lbs', lang);

  @override
  Widget build(BuildContext context) {
    final lang  = context.watch<LocaleCubit>().state;
    final theme = Theme.of(context);
    final isRtl = lang == 'ar';

    final allEntries = List<WeightEntry>.from(
      context.watch<HealthCubit>().getWeightEntries(),
    )..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (allEntries.isEmpty) {
      return Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _topBar(context, lang, isRtl),
                Expanded(
                  child: Center(
                    child: Text(
                      AppStrings.get('no_data', lang),
                      style: GoogleFonts.arimo(
                          color:
                          theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final latest     = allEntries.last;
    final now        = DateTime.now();
    final rangeStart = now.subtract(Duration(days: _selectedRange - 1));
    final chartEntries = allEntries
        .where((e) => e.dateTime
        .isAfter(rangeStart.subtract(const Duration(seconds: 1))))
        .toList();

    final values = chartEntries.isNotEmpty
        ? chartEntries.map(_convert).toList()
        : [0.0];
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final avgVal = values.reduce((a, b) => a + b) / values.length;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [

              _topBar(context, lang, isRtl),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _latestCard(latest, lang),

                      const SizedBox(height: 20),

                      _chartCard(chartEntries, minVal, avgVal,
                          maxVal, lang),

                      const SizedBox(height: 24),

                      Text(
                        AppStrings.get('history', lang),
                        style: GoogleFonts.arimo(
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),

                      ...allEntries.reversed
                          .take(3)
                          .map((e) => _historyTile(e, lang)),

                      const SizedBox(height: 16),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AllWeightEntriesScreen(
                                      entries: allEntries),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme
                                  .surfaceContainerHighest,
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              AppStrings.get('all_entries', lang),
                              style: GoogleFonts.arimo(
                                color:
                                theme.colorScheme.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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


  Widget _topBar(
      BuildContext context, String lang, bool isRtl) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: theme.colorScheme.surfaceContainer,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              isRtl ? Icons.arrow_forward : Icons.arrow_back,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            AppStrings.get('weight_title', lang),
            style: GoogleFonts.arimo(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const WeightLogScreen()),
            ),
            child: Icon(Icons.add_circle,
                color: _accentGreen, size: 28),
          ),
        ],
      ),
    );
  }



  Widget _latestCard(WeightEntry e, String lang) {
    final theme = Theme.of(context);
    final value = _convert(e);

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
              Icon(Icons.scale_outlined,
                  color: _accentGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.get('latest_entry_weight', lang),
                style: GoogleFonts.arimo(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${value.toStringAsFixed(1)} ${_unit(lang)}',
                style: GoogleFonts.arimo(
                    color: theme.colorScheme.onSurface,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _unitToggle('KG', _showKg,
                            () => setState(() => _showKg = true)),
                    const SizedBox(width: 4),
                    _unitToggle('LBS', !_showKg,
                            () => setState(() => _showKg = false)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${AppStrings.get('measured', lang)} ${_formatDate(e.dateTime)} ${AppStrings.get('at_time', lang)} ${_formatTime(e.dateTime)}',
            style: GoogleFonts.arimo(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 13),
          ),
        ],
      ),
    );
  }



  Widget _chartCard(List<WeightEntry> entries, double minVal,
      double avgVal, double maxVal, String lang) {
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
              Text(
                AppStrings.get('weight_trend', lang),
                style: GoogleFonts.arimo(
                    color: theme.colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
              _rangePicker(lang),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statChip(AppStrings.get('min', lang),
                  '${minVal.toStringAsFixed(1)} ${_unit(lang)}'),
              _statChip(AppStrings.get('avg', lang),
                  '${avgVal.toStringAsFixed(1)} ${_unit(lang)}'),
              _statChip(AppStrings.get('max', lang),
                  '${maxVal.toStringAsFixed(1)} ${_unit(lang)}'),
            ],
          ),
          const SizedBox(height: 24),
          entries.isEmpty
              ? Center(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                AppStrings.get('no_data_range', lang),
                style: GoogleFonts.arimo(
                    color: theme
                        .colorScheme.onSurfaceVariant),
              ),
            ),
          )
              : SizedBox(
              height: 220,
              child: _buildChart(entries, lang)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _accentGreen),
              ),
              const SizedBox(width: 8),
              Text(
                '${AppStrings.get('weight_progress', lang)} (${_unit(lang)})',
                style: GoogleFonts.arimo(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rangePicker(String lang) {
    final theme = Theme.of(context);
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: _selectedRange,
        dropdownColor: theme.colorScheme.surfaceContainerHighest,
        style: GoogleFonts.arimo(
            color: _accentGreen,
            fontSize: 13,
            fontWeight: FontWeight.w600),
        icon: Icon(Icons.keyboard_arrow_down,
            color: _accentGreen, size: 18),
        items: [
          DropdownMenuItem(
              value: 7,
              child: Text(AppStrings.get('last_7_days', lang))),
          DropdownMenuItem(
              value: 14,
              child: Text(AppStrings.get('last_14_days', lang))),
          DropdownMenuItem(
              value: 30,
              child: Text(AppStrings.get('last_30_days', lang))),
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
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.arimo(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _unitToggle(
      String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _accentGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: GoogleFonts.arimo(
                color: active
                    ? Colors.white
                    : Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildChart(List<WeightEntry> entries, String lang) {
    final theme = Theme.of(context);
    final spots = entries
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), _convert(e.value)))
        .toList();

    final values = entries.map(_convert).toList();
    final minY = (values.reduce((a, b) => a < b ? a : b) - 2)
        .clamp(0.0, double.infinity)
        .toDouble();
    final maxY =
        values.reduce((a, b) => a > b ? a : b) + 2;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.outlineVariant
                .withOpacity(0.5),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (val, _) => Text(
                val.toStringAsFixed(0),
                style: GoogleFonts.arimo(
                    color:
                    theme.colorScheme.onSurfaceVariant,
                    fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) {
                final index = val.toInt();
                if (index >= 0 && index < entries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      entries[index].dateTime.day.toString(),
                      style: GoogleFonts.arimo(
                          color: theme
                              .colorScheme.onSurfaceVariant,
                          fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _accentGreen,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: theme.colorScheme.surface,
                    strokeColor: _accentGreen,
                    strokeWidth: 2,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: _accentGreen.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) =>
            theme.colorScheme.surfaceContainerHighest,
            getTooltipItems: (touchedSpots) =>
                touchedSpots.map((s) {
                  return LineTooltipItem(
                    '${s.y.toStringAsFixed(1)} ${_unit(lang)}',
                    GoogleFonts.arimo(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }


  Widget _historyTile(WeightEntry e, String lang) {
    final theme = Theme.of(context);
    final value = _convert(e);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
            theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${value.toStringAsFixed(1)} ${_unit(lang)}',
                style: GoogleFonts.arimo(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatDate(e.dateTime)} ${AppStrings.get('at_time', lang)} ${_formatTime(e.dateTime)}',
                style: GoogleFonts.arimo(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12),
              ),
            ],
          ),
          Icon(Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }
}



class AllWeightEntriesScreen extends StatefulWidget {
  final List<WeightEntry> entries;

  const AllWeightEntriesScreen(
      {super.key, required this.entries});

  @override
  State<AllWeightEntriesScreen> createState() =>
      _AllWeightEntriesScreenState();
}

class _AllWeightEntriesScreenState
    extends State<AllWeightEntriesScreen> {
  DateTime?  _filterStart;
  DateTime?  _filterEnd;
  bool       _showKg      = true;
  final Color _accentGreen = const Color(0xFF00C950);

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  String _formatShort(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$m/$d/${dt.year}';
  }

  String _unit(String lang) =>
      _showKg ? AppStrings.get('kg', lang) : AppStrings.get('lbs', lang);

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
          onApply: (start, end) => setState(() {
            _filterStart = start;
            _filterEnd   = end;
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang    = context.watch<LocaleCubit>().state;
    final theme   = Theme.of(context);
    final isRtl   = lang == 'ar';
    final entries = _filtered;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [

              Container(
                height: 56,
                padding:
                const EdgeInsets.symmetric(horizontal: 14),
                color: theme.colorScheme.surfaceContainer,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        isRtl
                            ? Icons.arrow_forward
                            : Icons.arrow_back,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      AppStrings.get('weight_history', lang),
                      style: GoogleFonts.arimo(
                          color: theme.colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    _unitToggleGroup(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    _filterButton(theme, lang),
                    Text(
                      '${entries.length} ${AppStrings.get('logs', lang)}',
                      style: GoogleFonts.arimo(
                          color: theme
                              .colorScheme.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: entries.isEmpty
                    ? _emptyState(theme, lang)
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) =>
                      _weightTile(
                          context, entries[index], lang),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _unitToggleGroup() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _unitToggle(
              'KG', _showKg, () => setState(() => _showKg = true)),
          const SizedBox(width: 2),
          _unitToggle('LBS', !_showKg,
                  () => setState(() => _showKg = false)),
        ],
      ),
    );
  }

  Widget _unitToggle(
      String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _accentGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: GoogleFonts.arimo(
                color: active
                    ? Colors.white
                    : Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _filterButton(ThemeData theme, String lang) {
    return GestureDetector(
      onTap: _hasFilter
          ? () => setState(() {
        _filterStart = null;
        _filterEnd   = null;
      })
          : _openPicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _hasFilter
              ? _accentGreen.withOpacity(0.1)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: _hasFilter
                  ? _accentGreen
                  : theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                color: _hasFilter
                    ? _accentGreen
                    : theme.colorScheme.onSurfaceVariant,
                size: 14),
            const SizedBox(width: 8),
            Text(
              _hasFilter
                  ? '${_formatShort(_filterStart!)} – ${_formatShort(_filterEnd!)}'
                  : AppStrings.get('all_time', lang),
              style: GoogleFonts.arimo(
                  color: _hasFilter
                      ? _accentGreen
                      : theme.colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
            if (_hasFilter) ...[
              const SizedBox(width: 8),
              Icon(Icons.close, color: _accentGreen, size: 14),
            ],
          ],
        ),
      ),
    );
  }

  Widget _weightTile(
      BuildContext context, WeightEntry e, String lang) {
    final theme = Theme.of(context);
    final value = _convert(e);

    return GestureDetector(
      onTap: () => _showEntryDetails(context, e, lang),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: theme.colorScheme.outlineVariant
                  .withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${value.toStringAsFixed(1)} ${_unit(lang)}',
                    style: GoogleFonts.arimo(
                        color: theme.colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(e.dateTime)} • ${_formatTime(e.dateTime)}',
                    style: GoogleFonts.arimo(
                        color:
                        theme.colorScheme.onSurfaceVariant,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20),
          ],
        ),
      ),
    );
  }

  void _showEntryDetails(
      BuildContext context, WeightEntry e, String lang) {
    final theme = Theme.of(context);
    final kg    = e.kg ?? (e.lbs! / 2.20462);
    final lbs   = e.lbs ?? (e.kg! * 2.20462);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24)),
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
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.scale,
                    color: _accentGreen, size: 22),
                const SizedBox(width: 12),
                Text(
                  AppStrings.get('log_details', lang),
                  style: GoogleFonts.arimo(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _detailChip(theme,
                    AppStrings.get('kilograms', lang),
                    '${kg.toStringAsFixed(1)} kg'),
                const SizedBox(width: 12),
                _detailChip(theme,
                    AppStrings.get('pounds', lang),
                    '${lbs.toStringAsFixed(1)} lbs'),
              ],
            ),
            const SizedBox(height: 24),
            _infoRow(
                theme,
                Icons.calendar_today,
                AppStrings.get('date_label', lang),
                _formatDate(e.dateTime)),
            _infoRow(
                theme,
                Icons.access_time,
                AppStrings.get('time_label', lang),
                _formatTime(e.dateTime)),
            if (e.notes != null && e.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Divider(color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 16),
              Text(
                AppStrings.get('notes_label', lang),
                style: GoogleFonts.arimo(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Text(e.notes!,
                  style: GoogleFonts.arimo(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                      height: 1.4)),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _detailChip(
      ThemeData theme, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border:
          Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.arimo(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.arimo(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label,
      String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon,
              color: theme.colorScheme.onSurfaceVariant, size: 16),
          const SizedBox(width: 12),
          Text('$label: ',
              style: GoogleFonts.arimo(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14)),
          Text(value,
              style: GoogleFonts.arimo(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _emptyState(ThemeData theme, String lang) {
    return Center(
      child: Text(
        _hasFilter
            ? AppStrings.get('no_entries_range', lang)
            : AppStrings.get('no_entries_logged_yet_weight', lang),
        style: GoogleFonts.arimo(
            color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}