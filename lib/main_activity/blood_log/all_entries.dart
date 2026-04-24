import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/lang/lang_strings.dart';
import '../../cubit/locale_cubit.dart';
import '../../widgets/components.dart';
import '../../models/blood_pressure_entry.dart';
import 'blood_pressure_details_screen.dart';

class AllEntriesScreen extends StatefulWidget {
  final List<BloodPressureEntry> entries;

  const AllEntriesScreen({super.key, required this.entries});

  @override
  State<AllEntriesScreen> createState() => _AllEntriesScreenState();
}

class _AllEntriesScreenState extends State<AllEntriesScreen> {
  DateTime? _filterStart;
  DateTime? _filterEnd;

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

  bool get _hasFilter => _filterStart != null && _filterEnd != null;

  List<BloodPressureEntry> get _filtered {
    final sorted = List<BloodPressureEntry>.from(widget.entries)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    if (!_hasFilter) return sorted;
    final end = DateTime(
        _filterEnd!.year, _filterEnd!.month, _filterEnd!.day, 23, 59, 59);
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
    final lang    = context.watch<LocaleCubit>().state;
    final c       = context.colors;
    final entries = _filtered;
    final isRtl   = lang == 'ar';

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
                      AppStrings.get('all_entries', lang),
                      style: GoogleFonts.arimo(
                          color: c.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      "${entries.length} ${AppStrings.get('records', lang)}",
                      style: GoogleFonts.arimo(
                          color: c.hintText, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.only(
                    left: isRtl ? 0 : 16, right: isRtl ? 16 : 0),
                child: Align(
                  alignment: isRtl
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
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
                        color: c.reminderTileBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/icons/calendar.png',
                              height: 20, width: 20),
                          const SizedBox(width: 6),
                          Text(
                            "${_formatShort(_filterStart!)} – ${_formatShort(_filterEnd!)}",
                            style: GoogleFonts.arimo(
                                color: c.primaryText,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.close,
                              color: c.primaryText, size: 14),
                        ],
                      ),
                    )
                        : Container(
                      width: 118,
                      height: 32,
                      decoration: ShapeDecoration(
                        color: c.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Image.asset('assets/icons/calendar.png',
                              height: 20, width: 20),
                          const SizedBox(width: 10),
                          Text(
                            AppStrings.get('all_time', lang),
                            style: GoogleFonts.arimo(
                                color: c.primaryText,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
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
                    _hasFilter
                        ? AppStrings.get('no_entries_range', lang)
                        : AppStrings.get('no_entries', lang),
                    style:
                    GoogleFonts.arimo(color: c.hintText),
                  ),
                )
                    : ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final e      = entries[index];
                    final status = getBPStatus(
                        e.systolic, e.diastolic);
                    final color  = getStatusColor(status);

                    return GestureDetector(
                      onTap: () =>
                          _showEntryDetail(context, e, lang),
                      child: Container(
                        margin:
                        const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${e.systolic}/${e.diastolic} ${AppStrings.get('mmhg', lang)}",
                                    style: GoogleFonts.arimo(
                                        color: c.primaryText,
                                        fontSize: 18,
                                        fontWeight:
                                        FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}",
                                    style: GoogleFonts.arimo(
                                        color: c.hintText,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.3),
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              child: Text(
                                _localizedStatus(status, lang),
                                style: GoogleFonts.arimo(
                                    color: Colors.white),
                              ),
                            ),
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
      ),
    );
  }


  void _showEntryDetail(
      BuildContext context, BloodPressureEntry e, String lang) {
    final c      = context.colors;
    final status = getBPStatus(e.systolic, e.diastolic);
    final color  = getStatusColor(status);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.bottomSheet,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: c.subtleText,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${e.systolic}/${e.diastolic} ${AppStrings.get('mmhg', lang)}",
                  style: GoogleFonts.arimo(
                      color: c.primaryText,
                      fontSize: 26,
                      fontWeight: FontWeight.w700),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
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

            const SizedBox(height: 6),

            Text(
              "${_formatDate(e.dateTime)}  ${_formatTime(e.dateTime)}",
              style:
              GoogleFonts.arimo(color: c.hintText, fontSize: 13),
            ),

            const SizedBox(height: 20),
            Divider(color: c.divider),
            const SizedBox(height: 16),

            _detailRow(
              context: context,
              icon: Icons.favorite,
              iconColor: Colors.redAccent,
              label: AppStrings.get('heart_rate', lang),
              value: e.heartRate != null
                  ? "${e.heartRate} ${AppStrings.get('bpm', lang)}"
                  : AppStrings.get('not_recorded', lang),
            ),

            const SizedBox(height: 14),

            _detailRow(
              context: context,
              icon: Icons.notes,
              iconColor: c.hintText,
              label: AppStrings.get('notes', lang),
              value: (e.notes != null && e.notes!.trim().isNotEmpty)
                  ? e.notes!
                  : AppStrings.get('no_notes', lang),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _detailRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.arimo(
                    color: c.hintText, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.arimo(
                    color: c.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

String _localizedStatus(String status, String lang) {
  const map = {
    'en': {'Low': 'Low', 'Normal': 'Normal', 'Elevated': 'Elevated', 'High': 'High'},
    'ar': {'Low': 'منخفض', 'Normal': 'طبيعي', 'Elevated': 'مرتفع قليلاً', 'High': 'مرتفع'},
  };
  return map[lang]?[status] ?? status;
}