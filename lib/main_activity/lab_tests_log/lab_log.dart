import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../cubit/health_cubit.dart';
import '../../models/labTest_entry.dart';
import '../../widgets/components.dart';

class LabTestLogScreen extends StatefulWidget {
  const LabTestLogScreen({super.key});

  @override
  State<LabTestLogScreen> createState() => _LabTestLogScreenState();
}

class _LabTestLogScreenState extends State<LabTestLogScreen> {
  // From LabTestUploadScreen
  final _ocrNotesController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // From LabTestLogScreen (adapted)
  DateTime? _selectedDate;
  final _testNameCtrl = TextEditingController();

  bool get _isValid =>
      _selectedImage != null &&
          _selectedDate != null &&
          _testNameCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _testNameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ocrNotesController.dispose();
    _testNameCtrl.dispose();
    super.dispose();
  }

  // From LabTestUploadScreen
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: $e');
    }
  }

  // From LabTestUploadScreen
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF212121),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Image Source',
              style: GoogleFonts.arimo(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _imageSourceOption(
              icon: Icons.camera_alt,
              label: 'Camera',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
            _imageSourceOption(
              icon: Icons.photo_library,
              label: 'Gallery',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // From LabTestUploadScreen
  Widget _imageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF00C950), size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.arimo(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // From LabTestUploadScreen
  Future<void> _uploadLabTest() async {
    if (_selectedImage == null) {
      _showSnackBar('Please select an image first');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final result = await context.read<HealthCubit>().uploadLabTest(_selectedImage!);

      setState(() {
        _ocrNotesController.text = result['ocr_text'] ?? 'No text extracted';
      });

      _showSnackBar('Lab test uploaded successfully!');
    } catch (e) {
      _showSnackBar('Upload failed: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // From LabTestUploadScreen
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.arimo()),
        backgroundColor: const Color(0xFF2D2D2D),
      ),
    );
  }

  // From LabTestLogScreen
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

  // From LabTestLogScreen
  void _submit() {
    if (!_isValid) return;

    final entry = LabTestEntry(
      testName: _testNameCtrl.text.trim(),
      imagePath: _selectedImage!.path, // Changed to use _selectedImage
      testDate: _selectedDate!,
      notes: _ocrNotesController.text.trim().isEmpty // Changed to use _ocrNotesController
          ? null
          : _ocrNotesController.text.trim(),
      createdAt: DateTime.now(),
    );

    context.read<HealthCubit>().addLabTest(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        title: Text(
          'Log Lab Test',
          style: GoogleFonts.arimo(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview Section (from LabTestUploadScreen)
            _label('Lab Test Image'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _isUploading ? null : _showImageSourceDialog,
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF242424),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white12,
                    width: 1,
                  ),
                ),
                child: _selectedImage == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Color(0xFF00C950),
                      size: 64,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to select image',
                      style: GoogleFonts.arimo(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            if (_selectedImage != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Center(
                  child: Text(
                    'Change Image',
                    style: GoogleFonts.arimo(
                      color: const Color(0xFF2B7FFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Upload Button (from LabTestUploadScreen)
            GestureDetector(
              onTap: _isUploading ? null : _uploadLabTest,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: _isUploading
                      ? const Color(0xFF00C950).withOpacity(0.5)
                      : const Color(0xFF00C950),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _isUploading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.upload_file,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Upload & Extract Text',
                        style: GoogleFonts.arimo(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Test Name Field (from LabTestLogScreen)
            _fieldLabel('TEST NAME'),
            const SizedBox(height: 6),
            _textField(
              controller: _testNameCtrl,
              hint: 'e.g., Blood Test, CBC, Lipid Panel',
            ),

            const SizedBox(height: 16),

            // Date of Test Field (from LabTestLogScreen)
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

            // Extracted Notes Field (from LabTestUploadScreen, adapted)
            _fieldLabel('EXTRACTED NOTES (OPTIONAL)'),
            const SizedBox(height: 6),
            _textField(
              controller: _ocrNotesController,
              hint: 'OCR extracted text will appear here...',
              maxLines: 8,
            ),

            const SizedBox(height: 32),

            MainButton(
              text: 'Add',
              enabled: _isValid,
              onTap: _isValid ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widgets from LabTestLogScreen (adapted _fieldLabel and _textField)
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

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.arimo(
      color: Colors.white70,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );
}
