import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../cubit/health_cubit.dart';
import '../cubit/locale_cubit.dart';
import '../core/lang/lang_strings.dart';
import '../services/pdf_export_service.dart';

class ExportLogsScreen extends StatefulWidget {
  const ExportLogsScreen({super.key});

  @override
  State<ExportLogsScreen> createState() => _ExportLogsScreenState();
}

class _ExportLogsScreenState extends State<ExportLogsScreen> {
  DateTime? startDate;
  DateTime? endDate;
  bool isExporting = false;

  bool _inRange(DateTime dt) {
    if (startDate == null || endDate == null) return true;
    return dt.isAfter(startDate!.subtract(const Duration(days: 1))) &&
        dt.isBefore(endDate!.add(const Duration(days: 1)));
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) startDate = picked;
      else endDate = picked;
    });
  }

  Future<void> _exportReport(String lang) async {
    setState(() => isExporting = true);

    try {
      final cubit = context.read<HealthCubit>();
      final file = await PdfExportService.exportHealthReport(
        cubit: cubit,
        startDate: startDate,
        endDate: endDate,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.get('pdf_success', lang),
            style: GoogleFonts.arimo(),
          ),
        ),
      );

      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF212121)
                : Colors.white,
            title: Text(
              AppStrings.get('export_complete', lang),
              style: GoogleFonts.arimo(fontWeight: FontWeight.w700),
            ),
            content: Text(
              '${AppStrings.get('saved_to', lang)}\n\n${file.path}',
              style: GoogleFonts.arimo(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.get('done', lang)),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) setState(() => isExporting = false);
  }

  Widget _sectionTile({
    required String title,
    required int count,
    required IconData icon,
    required String lang,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B2B2B) : const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.arimo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.get('logs_detected_count', lang)
                      .replaceAll('{count}', count.toString()),
                  style: GoogleFonts.arimo(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, lang) {
        final isArabic = lang == 'ar';
        final cubit = context.watch<HealthCubit>();
        final isDark = Theme.of(context).brightness == Brightness.dark;

        // Count logic...
        final bloodCount = cubit.getEntries().where((e) => _inRange(e.dateTime)).length;
        final glucoseCount = cubit.getGlucoseEntries().where((e) => _inRange(e.dateTime)).length;
        final weightCount = cubit.getWeightEntries().where((e) => _inRange(e.dateTime)).length;
        final medicationCount = cubit.getMedicationEntries().where((e) => _inRange(e.dateTime)).length;
        final foodCount = cubit.getFoodEntries().where((e) => _inRange(e.dateTime)).length;
        final symptomCount = cubit.getSymptomEntries().where((e) => _inRange(e.dateTime)).length;
        final appointmentCount = cubit.getAppointments().where((e) => _inRange(e.appointmentDateTime)).length;
        final labCount = cubit.getLabTests().where((e) => _inRange(e.testDate)).length;

        final total = bloodCount + glucoseCount + weightCount + medicationCount + foodCount + symptomCount + appointmentCount + labCount;

        return Directionality(
          textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                AppStrings.get('export_title', lang),
                style: GoogleFonts.arimo(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2B2B2B) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.get('timeline_filter', lang),
                          style: GoogleFonts.arimo(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppStrings.get('timeline_desc', lang),
                          style: GoogleFonts.arimo(color: isDark ? Colors.white70 : Colors.black54),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _datePickerBox(true, AppStrings.get('start_date', lang), startDate, isDark, lang),
                            const SizedBox(width: 14),
                            _datePickerBox(false, AppStrings.get('end_date', lang), endDate, isDark, lang),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    AppStrings.get('detected_logs', lang),
                    style: GoogleFonts.arimo(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _sectionTile(title: AppStrings.get('blood_pressure_logs', lang), count: bloodCount, icon: Icons.favorite_rounded, lang: lang),
                  _sectionTile(title: AppStrings.get('glucose_logs', lang), count: glucoseCount, icon: Icons.water_drop_rounded, lang: lang),
                  _sectionTile(title: AppStrings.get('weight_logs', lang), count: weightCount, icon: Icons.monitor_weight_rounded, lang: lang),
                  _sectionTile(title: AppStrings.get('medication_logs', lang), count: medicationCount, icon: Icons.medication_rounded, lang: lang),
                  _sectionTile(title: AppStrings.get('food_logs', lang), count: foodCount, icon: Icons.restaurant_rounded, lang: lang),
                  _sectionTile(title: AppStrings.get('symptom_logs', lang), count: symptomCount, icon: Icons.sick_rounded, lang: lang),
                  _sectionTile(title: AppStrings.get('appointments', lang), count: appointmentCount, icon: Icons.calendar_month_rounded, lang: lang),
                  _sectionTile(title: AppStrings.get('lab_tests', lang), count: labCount, icon: Icons.science_rounded, lang: lang),

                  const SizedBox(height: 24),

                  // Export Summary Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.get('export_summary', lang),
                          style: GoogleFonts.arimo(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.get('total_logs_desc', lang).replaceAll('{total}', total.toString()),
                          style: GoogleFonts.arimo(color: Colors.white.withOpacity(0.92), fontSize: 15),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: isExporting ? null : () => _exportReport(lang),
                          child: Container(
                            width: double.infinity,
                            height: 58,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                            child: Center(
                              child: isExporting
                                  ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Theme.of(context).primaryColor),
                              )
                                  : Text(
                                AppStrings.get('generate_pdf', lang),
                                style: GoogleFonts.arimo(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _datePickerBox(bool isStart, String label, DateTime? date, bool isDark, String lang) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _pickDate(isStart),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.arimo(color: isDark ? Colors.white70 : Colors.black54)),
              const SizedBox(height: 8),
              Text(
                date == null ? AppStrings.get('not_selected', lang) : DateFormat.yMMMd().format(date),
                style: GoogleFonts.arimo(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}