import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/lang/lang_strings.dart';
import '../../cubit/health_cubit.dart';
import '../../cubit/locale_cubit.dart';
import '../../models/labTest_entry.dart';
import 'lab_log.dart';

class LabTestDetailsScreen extends StatefulWidget {
  const LabTestDetailsScreen({super.key});

  @override
  State<LabTestDetailsScreen> createState() =>
      _LabTestDetailsScreenState();
}

class _LabTestDetailsScreenState extends State<LabTestDetailsScreen> {
  final Color _accentGreen = const Color(0xFF00C950);

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final lang  = context.watch<LocaleCubit>().state;
    final theme = Theme.of(context);
    final isRtl = lang == 'ar';

    final tests = List<LabTestEntry>.from(
      context.watch<HealthCubit>().getLabTests(),
    )..sort((a, b) => b.testDate.compareTo(a.testDate));

    final countLabel = tests.length == 1
        ? '1 ${AppStrings.get('test', lang)}'
        : '${tests.length} ${AppStrings.get('tests', lang)}';

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
                      AppStrings.get('lab_tests', lang),
                      style: GoogleFonts.arimo(
                          color: theme.colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      countLabel,
                      style: GoogleFonts.arimo(
                          color:
                          theme.colorScheme.onSurfaceVariant,
                          fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                            const LabTestLogScreen()),
                      ),
                      child: Icon(Icons.add_circle,
                          color: _accentGreen, size: 28),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: tests.isEmpty
                    ? _emptyState(context, lang)
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tests.length,
                  itemBuilder: (context, index) =>
                      _testCard(context, tests[index], lang),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, String lang) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _accentGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.science_outlined,
                color: _accentGreen, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.get('no_lab_tests_yet', lang),
            style: GoogleFonts.arimo(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.get('tap_to_upload', lang),
            textAlign: TextAlign.center,
            style: GoogleFonts.arimo(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const LabTestLogScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: _accentGreen,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                AppStrings.get('add_first_test', lang),
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _testCard(
      BuildContext context, LabTestEntry test, String lang) {
    final theme      = Theme.of(context);
    final fileExists = File(test.imagePath).existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Image preview
          GestureDetector(
            onTap: fileExists
                ? () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    _FullImageScreen(path: test.imagePath),
              ),
            )
                : null,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
              child: fileExists
                  ? Stack(
                children: [
                  Image.file(
                    File(test.imagePath),
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    cacheWidth: 800,
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fullscreen,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            AppStrings.get(
                                'tap_to_expand', lang),
                            style: GoogleFonts.arimo(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
                  : Container(
                width: double.infinity,
                height: 120,
                color: theme
                    .colorScheme.surfaceContainerHighest,
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_outlined,
                        color: theme
                            .colorScheme.onSurfaceVariant,
                        size: 32),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.get(
                          'image_not_found', lang),
                      style: GoogleFonts.arimo(
                          color: theme.colorScheme
                              .onSurfaceVariant,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        test.testName,
                        style: GoogleFonts.arimo(
                            color: theme.colorScheme.onSurface,
                            fontSize: 17,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          _confirmDelete(context, test, lang),
                      child: Icon(Icons.delete_outline,
                          color: theme.colorScheme.error,
                          size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: _accentGreen, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${AppStrings.get('test_date_label', lang)}: ${_formatDate(test.testDate)}',
                      style: GoogleFonts.arimo(
                          color:
                          theme.colorScheme.onSurfaceVariant,
                          fontSize: 13),
                    ),
                  ],
                ),

                if (test.notes != null &&
                    test.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notes,
                                color: theme
                                    .colorScheme.onSurfaceVariant,
                                size: 14),
                            const SizedBox(width: 6),
                            Text(
                              AppStrings.get(
                                  'ocr_extracted_notes', lang),
                              style: GoogleFonts.arimo(
                                  color: theme.colorScheme
                                      .onSurfaceVariant,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          test.notes!,
                          style: GoogleFonts.arimo(
                              color: theme.colorScheme.onSurface,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _confirmDelete(
      BuildContext context, LabTestEntry test, String lang) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppStrings.get('delete_test', lang),
          style: GoogleFonts.arimo(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${AppStrings.get('delete_test_confirm', lang)} "${test.testName}"? ${AppStrings.get('cannot_be_undone', lang)}',
          style: GoogleFonts.arimo(
              color: theme.colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.get('cancel', lang),
              style: GoogleFonts.arimo(
                  color: theme.colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<HealthCubit>().deleteLabTest(test);
              Navigator.pop(context);
            },
            child: Text(
              AppStrings.get('delete', lang),
              style: GoogleFonts.arimo(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FULL IMAGE SCREEN  (language-agnostic)
// ─────────────────────────────────────────────────────────────

class _FullImageScreen extends StatelessWidget {
  final String path;
  const _FullImageScreen({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: Image.file(File(path)),
        ),
      ),
    );
  }
}