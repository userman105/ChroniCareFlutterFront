import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return "$m/${d}/${dt.year}";
  }

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

  List<BloodPressureEntry> get _filtered {
    final sorted = List<BloodPressureEntry>.from(widget.entries)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    if (_filterStart == null || _filterEnd == null) return sorted;

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
          onApply: (start, end) {
            setState(() {
              _filterStart = start;
              _filterEnd = end;
            });
          },
        ),
      ),
    );
  }

  bool get _hasFilter => _filterStart != null && _filterEnd != null;

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
                  Text(
                    "All Entries",
                    style: GoogleFonts.arimo(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Text(
                    "${entries.length} records",
                    style: GoogleFonts.arimo(
                        color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left :16.0),
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
                  // Active filter chip
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
                        Image.asset("assets/icons/calendar.png",
                        height: 50,width: 50,),
                        Text(
                          "${_formatShort(_filterStart!)} – ${_formatShort(_filterEnd!)}",
                          style: GoogleFonts.arimo(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.close, color: Colors.white, size: 14),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = entries[index];
                  final status =
                  getStatus(e.systolic, e.diastolic);
                  final color = getStatusColor(status);

                  return Container(
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
                                "${e.systolic}/${e.diastolic} mmHg",
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
                            color: color.withOpacity(0.3),
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: Text(status,
                              style: GoogleFonts.arimo(
                                  color: Colors.white)),
                        ),
                      ],
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
}