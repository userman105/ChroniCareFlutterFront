import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/health_cubit.dart';
import '../../models/food_entry.dart';
import '../../widgets/components.dart';
import 'food_log_screen.dart';

class FoodDetailsScreen extends StatefulWidget {
  const FoodDetailsScreen({super.key});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  DateTime _viewingDate = DateTime.now();

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  String _monthName(int m) => const [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ][m - 1];

  String get _dateLabel {
    final now = DateTime.now();
    final isToday = _viewingDate.year == now.year &&
        _viewingDate.month == now.month &&
        _viewingDate.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = _viewingDate.year == yesterday.year &&
        _viewingDate.month == yesterday.month &&
        _viewingDate.day == yesterday.day;
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return '${_monthName(_viewingDate.month)} ${_viewingDate.day}, ${_viewingDate.year}';
  }

  void _goToPreviousDay() =>
      setState(() => _viewingDate =
          _viewingDate.subtract(const Duration(days: 1)));

  void _goToNextDay() {
    final now = DateTime.now();
    final next = _viewingDate.add(const Duration(days: 1));
    if (next.isAfter(now)) return;
    setState(() => _viewingDate = next);
  }

  bool get _canGoNext {
    final now = DateTime.now();
    final next = _viewingDate.add(const Duration(days: 1));
    return !next.isAfter(now);
  }

  // Totals for the day
  int _totalCalories(List<FoodEntry> entries) => entries
      .where((e) => e.calories != null)
      .fold(0, (sum, e) => sum + e.calories!);

  double _totalMacro(List<FoodEntry> entries,
      double? Function(FoodEntry) getter) =>
      entries.fold(0.0, (sum, e) => sum + (getter(e) ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final allEntries = context.watch<HealthCubit>().getFoodEntries();

    // Filter to viewing date
    final dayEntries = allEntries
        .where((e) =>
    e.dateTime.year == _viewingDate.year &&
        e.dateTime.month == _viewingDate.month &&
        e.dateTime.day == _viewingDate.day)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Group by meal type in order
    final mealOrder = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Other'];
    final Map<String, List<FoodEntry>> grouped = {};
    for (final e in dayEntries) {
      final key = e.mealType ?? 'Other';
      grouped.putIfAbsent(key, () => []).add(e);
    }

    final totalCals = _totalCalories(dayEntries);
    final totalCarbs =
    _totalMacro(dayEntries, (e) => e.carbs);
    final totalProtein =
    _totalMacro(dayEntries, (e) => e.protein);
    final totalFat = _totalMacro(dayEntries, (e) => e.fat);
    final hasMacroData = dayEntries.any((e) => e.hasMacros);

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
                  Text('Food',
                      style: GoogleFonts.arimo(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FoodLogScreen()),
                    ),
                    child: Image.asset('assets/icons/add.png',
                        width: 26, height: 26),
                  ),
                ],
              ),
            ),

            Container(
              color: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _goToPreviousDay,
                    child: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 26),
                  ),
                  Text(
                    _dateLabel,
                    style: GoogleFonts.arimo(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: _canGoNext ? _goToNextDay : null,
                    child: Icon(Icons.chevron_right,
                        color: _canGoNext
                            ? Colors.white
                            : Colors.white24,
                        size: 26),
                  ),
                ],
              ),
            ),

            Expanded(
              child: dayEntries.isEmpty
                  ? _emptyState()
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    if (hasMacroData)
                      _summaryCard(
                        totalCals,
                        totalCarbs,
                        totalProtein,
                        totalFat,
                        dayEntries.length,
                      ),

                    if (hasMacroData)
                      const SizedBox(height: 20),

                    ...mealOrder
                        .where((m) =>
                        grouped.containsKey(m))
                        .map((meal) => _mealGroup(
                      context,
                      meal,
                      grouped[meal]!,
                    )),

                    const SizedBox(height: 20),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AllFoodEntriesScreen(
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
                              borderRadius:
                              BorderRadius.circular(21),
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
                                      fontWeight:
                                      FontWeight.w500)),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_outlined,
              color: Colors.white24, size: 48),
          const SizedBox(height: 12),
          Text('No food logged for $_dateLabel',
              style: GoogleFonts.arimo(
                  color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const FoodLogScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF00C950).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF00C950)
                        .withOpacity(0.4)),
              ),
              child: Text('Log something',
                  style: GoogleFonts.arimo(
                      color: const Color(0xFF00C950),
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(int cals, double carbs, double protein,
      double fat, int count) {
    return Container(
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
              const Icon(Icons.bar_chart_rounded,
                  color: Color(0xFF00C950), size: 18),
              const SizedBox(width: 6),
              Text('Daily Summary',
                  style: GoogleFonts.arimo(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('$count item${count == 1 ? '' : 's'}',
                  style: GoogleFonts.arimo(
                      color: Colors.white38, fontSize: 12)),
            ],
          ),

          const SizedBox(height: 14),

          // Calories big number
          if (cals > 0) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$cals',
                  style: GoogleFonts.arimo(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('kcal',
                      style: GoogleFonts.arimo(
                          color: Colors.white54, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Macro bar
          if (carbs > 0 || protein > 0 || fat > 0) ...[
            _macroBar(carbs, protein, fat),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _macroChip('Carbs',
                    '${carbs.toStringAsFixed(1)}g',
                    const Color(0xFF3B82F6)),
                _macroChip('Protein',
                    '${protein.toStringAsFixed(1)}g',
                    const Color(0xFF00C950)),
                _macroChip('Fat',
                    '${fat.toStringAsFixed(1)}g',
                    const Color(0xFFF59E0B)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _macroBar(double carbs, double protein, double fat) {
    final total = carbs + protein + fat;
    if (total == 0) return const SizedBox();
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Row(
        children: [
          Flexible(
            flex: (carbs / total * 100).round(),
            child: Container(
                height: 8, color: const Color(0xFF3B82F6)),
          ),
          Flexible(
            flex: (protein / total * 100).round(),
            child: Container(
                height: 8, color: const Color(0xFF00C950)),
          ),
          Flexible(
            flex: (fat / total * 100).round(),
            child: Container(
                height: 8, color: const Color(0xFFF59E0B)),
          ),
        ],
      ),
    );
  }

  Widget _macroChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.arimo(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        Text(label,
            style: GoogleFonts.arimo(
                color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  Widget _mealGroup(BuildContext context, String meal,
      List<FoodEntry> entries) {
    final mealCals = entries
        .where((e) => e.calories != null)
        .fold(0, (sum, e) => sum + e.calories!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meal header
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(meal,
                  style: GoogleFonts.arimo(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              if (mealCals > 0)
                Text('$mealCals kcal',
                    style: GoogleFonts.arimo(
                        color: Colors.white38,
                        fontSize: 12)),
            ],
          ),
        ),
        ...entries.map(
                (e) => _foodTile(context, e)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _foodTile(BuildContext context, FoodEntry e) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showEntryDetails(context, e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Food image or icon
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: e.hasImage &&
                  File(e.imagePath!).existsSync()
                  ? Image.file(
                File(e.imagePath!),
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                cacheWidth: 112,
              )
                  : Container(
                width: 56,
                height: 56,
                color: const Color(0xFF1E1E1E),
                child: const Icon(
                    Icons.restaurant_outlined,
                    color: Colors.white24,
                    size: 24),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.name,
                      style: GoogleFonts.arimo(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  if (e.hasMacros)
                    Text(
                      [
                        if (e.calories != null)
                          '${e.calories} kcal',
                        if (e.carbs != null)
                          'C ${e.carbs!.toStringAsFixed(0)}g',
                        if (e.protein != null)
                          'P ${e.protein!.toStringAsFixed(0)}g',
                        if (e.fat != null)
                          'F ${e.fat!.toStringAsFixed(0)}g',
                      ].join('  ·  '),
                      style: GoogleFonts.arimo(
                          color: Colors.white54,
                          fontSize: 11),
                    ),
                  Text(
                    _formatTime(e.dateTime),
                    style: GoogleFonts.arimo(
                        color: Colors.white38,
                        fontSize: 11),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right,
                color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }

  void _showEntryDetails(BuildContext context, FoodEntry e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF212121),
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.all(24),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),

              // Photo
              if (e.hasImage && File(e.imagePath!).existsSync()) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(e.imagePath!),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    cacheWidth: 512,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Name + meal type
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(e.name,
                        style: GoogleFonts.arimo(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ),
                  if (e.mealType != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C950)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF00C950)
                                .withOpacity(0.3)),
                      ),
                      child: Text(e.mealType!,
                          style: GoogleFonts.arimo(
                              color: const Color(0xFF00C950),
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Macros
              if (e.hasMacros) ...[
                Row(
                  children: [
                    if (e.calories != null)
                      _detailChip('Calories',
                          '${e.calories} kcal',
                          const Color(0xFFF59E0B)),
                  ],
                ),
                if (e.calories != null)
                  const SizedBox(height: 8),
                if (e.carbs != null ||
                    e.protein != null ||
                    e.fat != null)
                  Row(
                    children: [
                      if (e.carbs != null) ...[
                        Expanded(
                          child: _detailChip(
                            'Carbs',
                            '${e.carbs!.toStringAsFixed(1)}g',
                            const Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (e.protein != null) ...[
                        Expanded(
                          child: _detailChip(
                            'Protein',
                            '${e.protein!.toStringAsFixed(1)}g',
                            const Color(0xFF00C950),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (e.fat != null)
                        Expanded(
                          child: _detailChip(
                            'Fat',
                            '${e.fat!.toStringAsFixed(1)}g',
                            const Color(0xFFF59E0B),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 16),
              ],

              // Date/time
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

              // Notes
              if (e.notes != null &&
                  e.notes!.trim().isNotEmpty) ...[
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
                              color: Colors.white70,
                              fontSize: 14)),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Delete button
              GestureDetector(
                onTap: () {
                  context
                      .read<HealthCubit>()
                      .deleteFood(e);
                  Navigator.pop(context);
                },
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 18),
                        const SizedBox(width: 6),
                        Text('Delete Entry',
                            style: GoogleFonts.arimo(
                                color: Colors.redAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border:
        Border.all(color: color.withOpacity(0.3)),
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
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class AllFoodEntriesScreen extends StatefulWidget {
  final List<FoodEntry> entries;

  const AllFoodEntriesScreen({super.key, required this.entries});

  @override
  State<AllFoodEntriesScreen> createState() =>
      _AllFoodEntriesScreenState();
}

class _AllFoodEntriesScreenState
    extends State<AllFoodEntriesScreen> {
  DateTime? _filterStart;
  DateTime? _filterEnd;
  String? _filterMeal; // null = all meals

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  String _formatShort(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$m/${d}/${dt.year}';
  }

  bool get _hasFilter =>
      _filterStart != null && _filterEnd != null;

  List<FoodEntry> get _filtered {
    var sorted = List<FoodEntry>.from(widget.entries)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    if (_hasFilter) {
      final end = DateTime(_filterEnd!.year,
          _filterEnd!.month, _filterEnd!.day, 23, 59, 59);
      sorted = sorted
          .where((e) =>
      !e.dateTime.isBefore(_filterStart!) &&
          !e.dateTime.isAfter(end))
          .toList();
    }

    if (_filterMeal != null) {
      sorted = sorted
          .where((e) => (e.mealType ?? 'Other') == _filterMeal)
          .toList();
    }

    return sorted;
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
    final meals = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Other'];

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
                  Text('${entries.length} items',
                      style: GoogleFonts.arimo(
                          color: Colors.white54,
                          fontSize: 13)),
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
                        borderRadius:
                        BorderRadius.circular(25),
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
                                  fontWeight:
                                  FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _mealPill('All', _filterMeal == null,
                          () => setState(() => _filterMeal = null)),
                  ...meals.map((m) => _mealPill(
                    m,
                    _filterMeal == m,
                        () => setState(() => _filterMeal =
                    _filterMeal == m ? null : m),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: entries.isEmpty
                  ? Center(
                child: Text(
                  'No entries found',
                  style: GoogleFonts.arimo(
                      color: Colors.white54),
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(8),
                            child: e.hasImage &&
                                File(e.imagePath!)
                                    .existsSync()
                                ? Image.file(
                              File(e.imagePath!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              cacheWidth: 100,
                            )
                                : Container(
                              width: 50,
                              height: 50,
                              color: const Color(
                                  0xFF1E1E1E),
                              child: const Icon(
                                  Icons
                                      .restaurant_outlined,
                                  color:
                                  Colors.white24,
                                  size: 22),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(e.name,
                                    style: GoogleFonts.arimo(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight:
                                        FontWeight.w600),
                                    overflow:
                                    TextOverflow.ellipsis),
                                if (e.mealType != null)
                                  Text(e.mealType!,
                                      style:
                                      GoogleFonts.arimo(
                                          color: const Color(
                                              0xFF00C950),
                                          fontSize: 11)),
                                Text(
                                  '${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}',
                                  style: GoogleFonts.arimo(
                                      color: Colors.white38,
                                      fontSize: 11),
                                ),
                                if (e.calories != null)
                                  Text(
                                    '${e.calories} kcal',
                                    style: GoogleFonts.arimo(
                                        color: Colors.white54,
                                        fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Colors.white24,
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

  Widget _mealPill(
      String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF00C950).withOpacity(0.15)
              : const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active
                  ? const Color(0xFF00C950)
                  : Colors.transparent),
        ),
        child: Text(label,
            style: GoogleFonts.arimo(
                color: active
                    ? const Color(0xFF00C950)
                    : Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  void _showEntryDetails(BuildContext context, FoodEntry e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF212121),
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.all(24),
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
              if (e.hasImage && File(e.imagePath!).existsSync()) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(e.imagePath!),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    cacheWidth: 512,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(e.name,
                  style: GoogleFonts.arimo(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              if (e.mealType != null)
                Text(e.mealType!,
                    style: GoogleFonts.arimo(
                        color: const Color(0xFF00C950),
                        fontSize: 13)),
              const SizedBox(height: 16),
              if (e.calories != null) ...[
                Text('${e.calories} kcal',
                    style: GoogleFonts.arimo(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
              ],
              if (e.carbs != null || e.protein != null || e.fat != null)
                Row(
                  children: [
                    if (e.carbs != null) ...[
                      Expanded(child: _chip('Carbs',
                          '${e.carbs!.toStringAsFixed(1)}g',
                          const Color(0xFF3B82F6))),
                      const SizedBox(width: 8),
                    ],
                    if (e.protein != null) ...[
                      Expanded(child: _chip('Protein',
                          '${e.protein!.toStringAsFixed(1)}g',
                          const Color(0xFF00C950))),
                      const SizedBox(width: 8),
                    ],
                    if (e.fat != null)
                      Expanded(child: _chip('Fat',
                          '${e.fat!.toStringAsFixed(1)}g',
                          const Color(0xFFF59E0B))),
                  ],
                ),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    color: Colors.white38, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}',
                  style: GoogleFonts.arimo(
                      color: Colors.white70, fontSize: 14),
                ),
              ]),
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
                                color: Colors.white70,
                                fontSize: 14))),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  context.read<HealthCubit>().deleteFood(e);
                  Navigator.pop(context);
                },
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 18),
                        const SizedBox(width: 6),
                        Text('Delete Entry',
                            style: GoogleFonts.arimo(
                                color: Colors.redAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.arimo(
                  color: Colors.white54, fontSize: 11)),
          Text(value,
              style: GoogleFonts.arimo(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}