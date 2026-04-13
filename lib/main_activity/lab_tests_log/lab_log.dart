import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../cubit/health_cubit.dart';
import '../../models/labTest_entry.dart';
import '../../services/lab_image_service.dart';
import '../../widgets/components.dart';

class LabTestLogScreen extends StatefulWidget {
  const LabTestLogScreen({super.key});

  @override
  State<LabTestLogScreen> createState() => _LabTestLogScreenState();
}

class _LabTestLogScreenState extends State<LabTestLogScreen> {
  String? _imagePath;
  DateTime? _selectedDate;
  bool _isProcessing = false;

  final _testNameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool get _isValid =>
      _imagePath != null &&
          _selectedDate != null &&
          _testNameCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _testNameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _testNameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    setState(() => _isProcessing = true);
    try {
      final path =
      await LabImageService.pickAndProcess(source: source);
      if (path != null) setState(() => _imagePath = path);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00C950),
            surface: Color(0xFF2D2D2D),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (!_isValid) return;

    final entry = LabTestEntry(
      testName: _testNameCtrl.text.trim(),
      imagePath: _imagePath!,
      testDate: _selectedDate!,
      notes: _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    context.read<HealthCubit>().addLabTest(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      body: SafeArea(
        child: Column(
          children: [

            Container(
              height: 46,
              color: const Color(0xFF2D2D2D),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('Log Lab Test',
                      style: GoogleFonts.arimo(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Image preview or upload cards ────────
                    if (_imagePath != null) ...[
                      _imagePreview(),
                    ] else ...[
                      // Camera card
                      _uploadCard(
                        onTap: () => _pick(ImageSource.camera),
                        icon: 'assets/icons/testImage.png',
                        title: 'Take a Photo of Your Results',
                        subtitle: 'Scan physical documents instantly',
                        isProcessing: _isProcessing,
                        iconSize: 50,
                      ),

                      const SizedBox(height: 12),

                      // Gallery card
                      _uploadCard(
                        onTap: () => _pick(ImageSource.gallery),
                        icon: 'assets/icons/uploadGallery.png',
                        title: 'Upload from Gallery',
                        subtitle: 'PDF or JPEG',
                        isProcessing: false,
                        iconSize: 38,
                        compact: true,
                      ),
                    ],

                    const SizedBox(height: 20),

                    _fieldLabel('TEST NAME'),
                    const SizedBox(height: 6),
                    _textField(
                      controller: _testNameCtrl,
                      hint: 'e.g., Blood Test, CBC, Lipid Panel',
                    ),

                    const SizedBox(height: 16),

                    _fieldLabel('DATE OF TEST'),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white10, width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? 'mm / dd / yyyy'
                                    : '${_selectedDate!.month.toString().padLeft(2, '0')} / ${_selectedDate!.day.toString().padLeft(2, '0')} / ${_selectedDate!.year}',
                                style: GoogleFonts.arimo(
                                  color: _selectedDate == null
                                      ? const Color(0xFFB4B4B4)
                                      : Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Image.asset('assets/icons/calendar.png',
                                width: 20, height: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _fieldLabel('NOTES (OPTIONAL)'),
                    const SizedBox(height: 6),
                    _textField(
                      controller: _notesCtrl,
                      hint:
                      'eg. take after food or details about the laboratory',
                      maxLines: 4,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: MainButton(
                text: 'Add',
                enabled: _isValid,
                onTap: _isValid ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_imagePath!),
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
            // Retake button
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => setState(() => _imagePath = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border:
                    Border.all(color: Colors.white24, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('Retake',
                          style: GoogleFonts.arimo(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                color: Color(0xFF00C950), size: 14),
            const SizedBox(width: 4),
            Text('Image captured & processed',
                style: GoogleFonts.arimo(
                    color: const Color(0xFF00C950), fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _uploadCard({
    required VoidCallback onTap,
    required String icon,
    required String title,
    required String subtitle,
    required bool isProcessing,
    required double iconSize,
    bool compact = false,
  }) {
    return GestureDetector(
      onTap: isProcessing ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            vertical: compact ? 20 : 32, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF201F1F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.white.withOpacity(0.05), width: 1),
        ),
        child: isProcessing
            ? Column(
          children: [
            const CircularProgressIndicator(
                color: Color(0xFF00C950), strokeWidth: 2),
            const SizedBox(height: 10),
            Text('Processing image...',
                style: GoogleFonts.arimo(
                    color: Colors.white54, fontSize: 13)),
          ],
        )
            : Column(
          children: [
            Image.asset(icon, height: iconSize),
            SizedBox(height: compact ? 8 : 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.arimo(
                color: const Color(0xFFE5E2E1),
                fontSize: compact ? 15 : 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.arimo(
                  color: const Color(0xFFBBCBB8),
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(
    label,
    style: GoogleFonts.arimo(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.arimo(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.arimo(
              color: const Color(0xFFB4B4B4), fontSize: 16),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}