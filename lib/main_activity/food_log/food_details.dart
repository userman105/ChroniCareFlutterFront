import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/health_cubit.dart';
import '../../models/food_entry.dart';
import '../../widgets/components.dart';
import 'food_log_screen.dart';

// ─────────────────────────────────────────────────────────────
//  FOOD DETAILS SCREEN
// ─────────────────────────────────────────────────────────────

class FoodDetailsScreen extends StatefulWidget {
  const FoodDetailsScreen({super.key});

  @override
  State<FoodDetailsScreen> createState() =>
      _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  DateTime _viewingDate = DateTime.now();

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  String _monthName(int m) => const [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ][m - 1];

  String get _dateLabel {
    final now       = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final isToday   = _viewingDate.year == now.year &&
        _viewingDate.month == now.month &&
        _viewingDate.day == now.day;
    final isYesterday = _viewingDate.year == yesterday.year &&
        _viewingDate.month == yesterday.month &&
        _viewingDate.day == yesterday.day;
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return '${_monthName(_viewingDate.month)} ${_viewingDate.day}, ${_viewingDate.year}';
  }

  void _goToPreviousDay() => setState(() =>
  _viewingDate = _viewingDate.subtract(const Duration(days: 1)));

  void _goToNextDay() {
    final next = _viewingDate.add(const Duration(days: 1));
    if (next.isAfter(DateTime.now())) return;
    setState(() => _viewingDate = next);
  }

  bool get _canGoNext =>
      !_viewingDate.add(const Duration(days: 1)).isAfter(DateTime.now());

  int _totalCalories(List<FoodEntry> entries) => entries
      .where((e) => e.calories != null)
      .fold(0, (sum, e) => sum + e.calories!);

  double _totalMacro(List<FoodEntry> entries,
      double? Function(FoodEntry) getter) =>
      entries.fold(0.0, (sum, e) => sum + (getter(e) ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final c          = context.colors;
    final allEntries = context.watch<HealthCubit>().getFoodEntries();

    final dayEntries = allEntries
        .where((e) =>
    e.dateTime.year == _viewingDate.year &&
        e.dateTime.month == _viewingDate.month &&
        e.dateTime.day == _viewingDate.day)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final mealOrder = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Other'];
    final Map<String, List<FoodEntry>> grouped = {};
    for (final e in dayEntries) {
      grouped.putIfAbsent(e.mealType ?? 'Other', () => []).add(e);
    }

    final totalCals    = _totalCalories(dayEntries);
    final totalCarbs   = _totalMacro(dayEntries, (e) => e.carbs);
    final totalProtein = _totalMacro(dayEntries, (e) => e.protein);
    final totalFat     = _totalMacro(dayEntries, (e) => e.fat);
    final hasMacroData = dayEntries.any((e) => e.hasMacros);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            // ── Top bar ──────────────────────────────────
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
                  Text('Food',
                      style: GoogleFonts.arimo(
                          color: c.primaryText,
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

            // ── Day navigator ────────────────────────────
            Container(
              color: c.sectionBg,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _goToPreviousDay,
                    child: Icon(Icons.chevron_left,
                        color: c.primaryText, size: 26),
                  ),
                  Text(
                    _dateLabel,
                    style: GoogleFonts.arimo(
                        color: c.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: _canGoNext ? _goToNextDay : null,
                    child: Icon(Icons.chevron_right,
                        color: _canGoNext
                            ? c.primaryText
                            : c.ghostText,
                        size: 26),
                  ),
                ],
              ),
            ),

            Expanded(
              child: dayEntries.isEmpty
                  ? _emptyState(context)
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    if (hasMacroData)
                      _summaryCard(context, totalCals,
                          totalCarbs, totalProtein,
                          totalFat, dayEntries.length),

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

                    // ── All Entries button ─────────
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
                                  fontWeight:
                                  FontWeight.w500),
                            ),
                          ),
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

  // ── Empty state ───────────────────────────────────────────

  Widget _emptyState(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_outlined,
              color: c.ghostText, size: 48),
          const SizedBox(height: 12),
          Text('No food logged for $_dateLabel',
              style: GoogleFonts.arimo(
                  color: c.subtleText, fontSize: 14)),
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
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4)),
              ),
              child: Text('Log something',
                  style: GoogleFonts.arimo(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary card ──────────────────────────────────────────

  Widget _summaryCard(BuildContext context, int cals,
      double carbs, double protein, double fat, int count) {
    final c = context.colors;
    return Container(
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
              const Icon(Icons.bar_chart_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              Text('Daily Summary',
                  style: GoogleFonts.arimo(
                      color: c.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('$count item${count == 1 ? '' : 's'}',
                  style: GoogleFonts.arimo(
                      color: c.subtleText, fontSize: 12)),
            ],
          ),

          const SizedBox(height: 14),

          if (cals > 0) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$cals',
                  style: GoogleFonts.arimo(
                      color: c.primaryText,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('kcal',
                      style: GoogleFonts.arimo(
                          color: c.hintText, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          if (carbs > 0 || protein > 0 || fat > 0) ...[
            _macroBar(carbs, protein, fat),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceAround,
              children: [
                _macroChip(context, 'Carbs',
                    '${carbs.toStringAsFixed(1)}g',
                    const Color(0xFF3B82F6)),
                _macroChip(context, 'Protein',
                    '${protein.toStringAsFixed(1)}g',
                    AppColors.primary),
                _macroChip(context, 'Fat',
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
                height: 8, color: AppColors.primary),
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

  Widget _macroChip(BuildContext context, String label,
      String value, Color color) {
    final c = context.colors;
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.arimo(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        Text(label,
            style: GoogleFonts.arimo(
                color: c.subtleText, fontSize: 11)),
      ],
    );
  }

  // ── Meal group ────────────────────────────────────────────

  Widget _mealGroup(BuildContext context, String meal,
      List<FoodEntry> entries) {
    final c       = context.colors;
    final mealCals = entries
        .where((e) => e.calories != null)
        .fold(0, (sum, e) => sum + e.calories!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(meal,
                  style: GoogleFonts.arimo(
                      color: c.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              if (mealCals > 0)
                Text('$mealCals kcal',
                    style: GoogleFonts.arimo(
                        color: c.subtleText, fontSize: 12)),
            ],
          ),
        ),
        ...entries.map((e) => _foodTile(context, e)),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Food tile ─────────────────────────────────────────────

  Widget _foodTile(BuildContext context, FoodEntry e) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showEntryDetails(context, e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: e.hasImage && File(e.imagePath!).existsSync()
                  ? Image.file(File(e.imagePath!),
                  width: 56, height: 56,
                  fit: BoxFit.cover, cacheWidth: 112)
                  : Container(
                width: 56,
                height: 56,
                color: c.sectionBg,
                child: Icon(Icons.restaurant_outlined,
                    color: c.ghostText, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.name,
                      style: GoogleFonts.arimo(
                          color: c.primaryText,
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
                          color: c.hintText, fontSize: 11),
                    ),
                  Text(_formatTime(e.dateTime),
                      style: GoogleFonts.arimo(
                          color: c.subtleText, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: c.ghostText, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Entry detail sheet ────────────────────────────────────

  void _showEntryDetails(BuildContext context, FoodEntry e) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(
            color: c.bottomSheet,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22)),
          ),
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: c.subtleText,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),

              if (e.hasImage && File(e.imagePath!).existsSync()) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(e.imagePath!),
                      width: double.infinity, height: 200,
                      fit: BoxFit.cover, cacheWidth: 512),
                ),
                const SizedBox(height: 16),
              ],

              // Name + meal type badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(e.name,
                        style: GoogleFonts.arimo(
                            color: c.primaryText,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ),
                  if (e.mealType != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary
                                .withOpacity(0.3)),
                      ),
                      child: Text(e.mealType!,
                          style: GoogleFonts.arimo(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              if (e.hasMacros) ...[
                Row(
                  children: [
                    if (e.calories != null)
                      _detailChip(context, 'Calories',
                          '${e.calories} kcal',
                          const Color(0xFFF59E0B)),
                  ],
                ),
                if (e.calories != null) const SizedBox(height: 8),
                if (e.carbs != null ||
                    e.protein != null ||
                    e.fat != null)
                  Row(
                    children: [
                      if (e.carbs != null) ...[
                        Expanded(
                          child: _detailChip(context, 'Carbs',
                              '${e.carbs!.toStringAsFixed(1)}g',
                              const Color(0xFF3B82F6)),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (e.protein != null) ...[
                        Expanded(
                          child: _detailChip(context, 'Protein',
                              '${e.protein!.toStringAsFixed(1)}g',
                              AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (e.fat != null)
                        Expanded(
                          child: _detailChip(context, 'Fat',
                              '${e.fat!.toStringAsFixed(1)}g',
                              const Color(0xFFF59E0B)),
                        ),
                    ],
                  ),
                const SizedBox(height: 16),
              ],

              Row(children: [
                Icon(Icons.calendar_today_outlined,
                    color: c.subtleText, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}',
                  style: GoogleFonts.arimo(
                      color: c.secondaryText, fontSize: 14),
                ),
              ]),

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

  Widget _detailChip(BuildContext context, String label,
      String value, Color color) {
    final c = context.colors;
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
                  color: c.hintText, fontSize: 11)),
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

// ─────────────────────────────────────────────────────────────
//  ALL FOOD ENTRIES SCREEN
// ─────────────────────────────────────────────────────────────

class AllFoodEntriesScreen extends StatefulWidget {
  final List<FoodEntry> entries;

  const AllFoodEntriesScreen(
      {super.key, required this.entries});

  @override
  State<AllFoodEntriesScreen> createState() =>
      _AllFoodEntriesScreenState();
}

class _AllFoodEntriesScreenState
    extends State<AllFoodEntriesScreen> {
  DateTime? _filterStart;
  DateTime? _filterEnd;
  String?   _filterMeal;

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  String _formatShort(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$m/$d/${dt.year}';
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
          .where((e) =>
      (e.mealType ?? 'Other') == _filterMeal)
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
          onApply: (s, e) => setState(
                  () { _filterStart = s; _filterEnd = e; }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c       = context.colors;
    final entries = _filtered;
    final meals   = [
      'Breakfast', 'Lunch', 'Dinner', 'Snack', 'Other'
    ];

    return Scaffold(
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            // ── Top bar ────────────────────────────────────
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14),
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
                  Text('${entries.length} items',
                      style: GoogleFonts.arimo(
                          color: c.hintText, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Date filter pill ──────────────────────────
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
                              fontWeight:
                              FontWeight.w500),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.close,
                            color: c.primaryText,
                            size: 14),
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
                            height: 20, width: 20),
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

            const SizedBox(height: 10),

            // ── Meal filter pills ─────────────────────────
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16),
                children: [
                  _mealPill(context, 'All',
                      _filterMeal == null,
                          () => setState(
                              () => _filterMeal = null)),
                  ...meals.map((m) => _mealPill(
                    context,
                    m,
                    _filterMeal == m,
                        () => setState(() => _filterMeal =
                    _filterMeal == m ? null : m),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Entry list ─────────────────────────────────
            Expanded(
              child: entries.isEmpty
                  ? Center(
                child: Text('No entries found',
                    style: GoogleFonts.arimo(
                        color: c.hintText)),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = entries[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showEntryDetails(
                        context, e),
                    child: Container(
                      margin: const EdgeInsets.only(
                          bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.surface,
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
                                cacheWidth: 100)
                                : Container(
                              width: 50,
                              height: 50,
                              color: c.sectionBg,
                              child: Icon(
                                  Icons
                                      .restaurant_outlined,
                                  color:
                                  c.ghostText,
                                  size: 22),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(e.name,
                                    style: GoogleFonts
                                        .arimo(
                                        color: c
                                            .primaryText,
                                        fontSize: 14,
                                        fontWeight:
                                        FontWeight
                                            .w600),
                                    overflow: TextOverflow
                                        .ellipsis),
                                if (e.mealType != null)
                                  Text(e.mealType!,
                                      style: GoogleFonts
                                          .arimo(
                                          color: AppColors
                                              .primary,
                                          fontSize:
                                          11)),
                                Text(
                                  '${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}',
                                  style: GoogleFonts.arimo(
                                      color: c.subtleText,
                                      fontSize: 11),
                                ),
                                if (e.calories != null)
                                  Text(
                                    '${e.calories} kcal',
                                    style: GoogleFonts.arimo(
                                        color: c.hintText,
                                        fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: c.ghostText,
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

  // ── Meal filter pill ──────────────────────────────────────

  Widget _mealPill(BuildContext context, String label,
      bool active, VoidCallback onTap) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withOpacity(0.15)
              : c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active
                  ? AppColors.primary
                  : Colors.transparent),
        ),
        child: Text(label,
            style: GoogleFonts.arimo(
                color: active
                    ? AppColors.primary
                    : c.hintText,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  // ── Entry detail sheet ────────────────────────────────────

  void _showEntryDetails(BuildContext context, FoodEntry e) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: BoxDecoration(
            color: c.bottomSheet,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22)),
          ),
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: c.subtleText,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),

              if (e.hasImage &&
                  File(e.imagePath!).existsSync()) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(e.imagePath!),
                      width: double.infinity, height: 200,
                      fit: BoxFit.cover, cacheWidth: 512),
                ),
                const SizedBox(height: 16),
              ],

              Text(e.name,
                  style: GoogleFonts.arimo(
                      color: c.primaryText,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              if (e.mealType != null)
                Text(e.mealType!,
                    style: GoogleFonts.arimo(
                        color: AppColors.primary,
                        fontSize: 13)),

              const SizedBox(height: 16),

              if (e.calories != null) ...[
                Text('${e.calories} kcal',
                    style: GoogleFonts.arimo(
                        color: c.primaryText,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
              ],

              if (e.carbs != null ||
                  e.protein != null ||
                  e.fat != null)
                Row(
                  children: [
                    if (e.carbs != null) ...[
                      Expanded(
                          child: _chip(context, 'Carbs',
                              '${e.carbs!.toStringAsFixed(1)}g',
                              const Color(0xFF3B82F6))),
                      const SizedBox(width: 8),
                    ],
                    if (e.protein != null) ...[
                      Expanded(
                          child: _chip(context, 'Protein',
                              '${e.protein!.toStringAsFixed(1)}g',
                              AppColors.primary)),
                      const SizedBox(width: 8),
                    ],
                    if (e.fat != null)
                      Expanded(
                          child: _chip(context, 'Fat',
                              '${e.fat!.toStringAsFixed(1)}g',
                              const Color(0xFFF59E0B))),
                  ],
                ),

              const SizedBox(height: 16),

              Row(children: [
                Icon(Icons.calendar_today_outlined,
                    color: c.subtleText, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}',
                  style: GoogleFonts.arimo(
                      color: c.secondaryText, fontSize: 14),
                ),
              ]),

              if (e.notes != null &&
                  e.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
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

  Widget _chip(BuildContext context, String label,
      String value, Color color) {
    final c = context.colors;
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
                  color: c.hintText, fontSize: 11)),
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