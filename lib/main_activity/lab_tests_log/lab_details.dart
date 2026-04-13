import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/health_cubit.dart';
import '../../models/labTest_entry.dart';
import '../../widgets/components.dart';
import 'lab_log.dart';

class LabTestDetailsScreen extends StatefulWidget {
  const LabTestDetailsScreen({super.key});

  @override
  State<LabTestDetailsScreen> createState() =>
      _LabTestDetailsScreenState();
}

class _LabTestDetailsScreenState extends State<LabTestDetailsScreen> {
  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final tests = List<LabTestEntry>.from(
      context.watch<HealthCubit>().getLabTests(),
    )..sort((a, b) => b.testDate.compareTo(a.testDate));

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
                  Text('Lab Tests',
                      style: GoogleFonts.arimo(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text('${tests.length} test${tests.length == 1 ? '' : 's'}',
                      style: GoogleFonts.arimo(
                          color: Colors.white38, fontSize: 13)),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LabTestLogScreen()),
                    ),
                    child: Image.asset('assets/icons/add.png',
                        width: 26, height: 26),
                  ),
                ],
              ),
            ),

            Expanded(
              child: tests.isEmpty
                  ? _emptyState(context)
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tests.length,
                itemBuilder: (context, index) =>
                    _testCard(context, tests[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF00C950).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.science_outlined,
                color: Color(0xFF00C950), size: 32),
          ),
          const SizedBox(height: 16),
          Text('No lab tests yet',
              style: GoogleFonts.arimo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Tap + to photograph or upload a lab result',
              style: GoogleFonts.arimo(
                  color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const LabTestLogScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF00C950).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF00C950).withOpacity(0.4)),
              ),
              child: Text('Add first test',
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

  Widget _testCard(BuildContext context, LabTestEntry test) {
    final fileExists = File(test.imagePath).existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: ShapeDecoration(
        color: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFF3A3A3A), width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

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
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              child: fileExists
                  ? Stack(
                children: [
                  Image.file(
                    File(test.imagePath),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    cacheWidth: 800,
                  ),
                  // Tap to expand hint
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.zoom_out_map,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text('View full',
                              style: GoogleFonts.arimo(
                                  color: Colors.white,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
                  : Container(
                width: double.infinity,
                height: 120,
                color: const Color(0xFF1E1E1E),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image_outlined,
                        color: Colors.white24, size: 32),
                    const SizedBox(height: 6),
                    Text('Image not found',
                        style: GoogleFonts.arimo(
                            color: Colors.white24,
                            fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        test.testName,
                        style: GoogleFonts.arimo(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    // Delete button
                    GestureDetector(
                      onTap: () => _confirmDelete(context, test),
                      child: const Icon(Icons.delete_outline,
                          color: Colors.white24, size: 18),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Colors.white38, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      'Test date: ${_formatDate(test.testDate)}',
                      style: GoogleFonts.arimo(
                          color: Colors.white54, fontSize: 13),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time,
                        color: Colors.white38, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      'Added: ${_formatDate(test.createdAt)}',
                      style: GoogleFonts.arimo(
                          color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),

                if (test.notes != null &&
                    test.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.notes_outlined,
                            color: Colors.white38, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            test.notes!,
                            style: GoogleFonts.arimo(
                                color: Colors.white70,
                                fontSize: 13),
                          ),
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

  void _confirmDelete(BuildContext context, LabTestEntry test) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Test',
            style: GoogleFonts.arimo(
                color: Colors.white, fontWeight: FontWeight.w600)),
        content: Text(
          'Delete "${test.testName}"? This cannot be undone.',
          style: GoogleFonts.arimo(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.arimo(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              context.read<HealthCubit>().deleteLabTest(test);
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: GoogleFonts.arimo(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _FullImageScreen extends StatelessWidget {
  final String path;

  const _FullImageScreen({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Zoomable image
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5.0,
                child: Image.file(File(path)),
              ),
            ),
            // Close button
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}