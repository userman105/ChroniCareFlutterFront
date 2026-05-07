import 'dart:io';
import 'dart:ui' as ui; // Fixed: Explicitly import for TextDirection

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../core/lang/lang_strings.dart';
import '../cubit/locale_cubit.dart';

class ExportedReportsScreen extends StatefulWidget {
  const ExportedReportsScreen({super.key});

  @override
  State<ExportedReportsScreen> createState() => _ExportedReportsScreenState();
}

class _ExportedReportsScreenState extends State<ExportedReportsScreen> {
  List<File> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final dir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${dir.path}/reports');

    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final files = reportsDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.pdf'))
        .toList();

    files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

    setState(() {
      reports = files;
      isLoading = false;
    });
  }

  String _formatSize(int bytes) {
    double kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    double mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  Future<void> _openPdf(File file) async {
    await OpenFilex.open(file.path);
  }

  Future<void> _deletePdf(File file, String lang) async {
    await file.delete();
    await _loadReports();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.get('report_deleted', lang),
          style: GoogleFonts.arimo(),
        ),
      ),
    );
  }

  void _showDeleteDialog(File file, String lang) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2B2B2B) : Colors.white,
          title: Text(
            AppStrings.get('delete_report_title', lang),
            style: GoogleFonts.arimo(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            AppStrings.get('delete_report_confirm', lang),
            style: GoogleFonts.arimo(color: isDark ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.get('cancel', lang), style: GoogleFonts.arimo()),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deletePdf(file, lang);
              },
              child: Text(
                AppStrings.get('delete', lang),
                style: GoogleFonts.arimo(color: Colors.red, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _emptyState(bool isDark, String lang) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_rounded,
              size: 90,
              color: Theme.of(context).primaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.get('no_reports_title', lang),
              style: GoogleFonts.arimo(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.get('no_reports_desc', lang),
              textAlign: TextAlign.center,
              style: GoogleFonts.arimo(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportTile(File file, String lang) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stat = file.statSync();
    final fileName = file.path.split('/').last;
    final modified = DateFormat.yMMMd().add_jm().format(stat.modified);
    final size = _formatSize(stat.size);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B2B2B) : const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _openPdf(file),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.green, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.arimo(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        modified,
                        style: GoogleFonts.arimo(fontSize: 13, color: isDark ? Colors.white70 : Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        size,
                        style: GoogleFonts.arimo(fontSize: 13, color: isDark ? Colors.white60 : Colors.black45),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: isDark ? Colors.white70 : Colors.black54),
                  onSelected: (value) async {
                    if (value == 'open') await _openPdf(file);
                    if (value == 'delete') _showDeleteDialog(file, lang);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'open',
                      child: Row(
                        children: [
                          const Icon(Icons.open_in_new),
                          const SizedBox(width: 10),
                          Text(AppStrings.get('open', lang), style: GoogleFonts.arimo()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_rounded, color: Colors.red),
                          const SizedBox(width: 10),
                          Text(AppStrings.get('delete', lang), style: GoogleFonts.arimo(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, lang) {
        final isArabic = lang == 'ar';
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Directionality(
          textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                AppStrings.get('exported_reports_title', lang),
                style: GoogleFonts.arimo(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            body: isLoading
                ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
                : reports.isEmpty
                ? _emptyState(isDark, lang)
                : RefreshIndicator(
              onRefresh: _loadReports,
              child: ListView.builder(
                padding: const EdgeInsets.all(18),
                itemCount: reports.length,
                itemBuilder: (_, index) => _reportTile(reports[index], lang),
              ),
            ),
          ),
        );
      },
    );
  }
}