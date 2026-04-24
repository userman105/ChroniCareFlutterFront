import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/lang/lang_strings.dart';
import '../../cubit/health_cubit.dart';
import '../../cubit/locale_cubit.dart';
import '../../models/labTest_entry.dart';
import '../../widgets/components.dart';
import '../main_container.dart';

class LabTestLogScreen extends StatefulWidget {
  const LabTestLogScreen({super.key});

  @override
  State<LabTestLogScreen> createState() => _LabTestLogScreenState();
}

class _LabTestLogScreenState extends State<LabTestLogScreen> {
  final _ocrNotesController = TextEditingController();
  final _testNameCtrl       = TextEditingController();
  File?          _selectedImage;
  bool           _isUploading = false;
  final ImagePicker _picker  = ImagePicker();
  DateTime?      _selectedDate;

  final Color _accentGreen = const Color(0xFF00C950);

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

  Future<void> _pickImage(ImageSource source, String lang) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      _showSnackBar('${AppStrings.get('pick_failed', lang)}: $e');
    }
  }

  void _showImageSourceDialog(String lang) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant
                      .withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.get('select_image_source', lang),
              style: GoogleFonts.arimo(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _imageSourceOption(
              icon: Icons.camera_alt,
              label: AppStrings.get('camera', lang),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, lang);
              },
            ),
            const SizedBox(height: 12),
            _imageSourceOption(
              icon: Icons.photo_library,
              label: AppStrings.get('gallery', lang),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, lang);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _imageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _accentGreen, size: 24),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.arimo(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadLabTest(String lang) async {
    if (_selectedImage == null) {
      _showSnackBar(AppStrings.get('select_image_first', lang));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final result =
      await context.read<HealthCubit>().uploadLabTest(_selectedImage!);
      setState(() {
        _ocrNotesController.text =
            result['ocr_text'] ?? AppStrings.get('no_text_extracted', lang);
      });
      _showSnackBar(AppStrings.get('upload_success', lang));
    } catch (e) {
      _showSnackBar('${AppStrings.get('upload_failed', lang)}: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showSnackBar(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: GoogleFonts.arimo(color: Colors.white)),
        backgroundColor: theme.colorScheme.inverseSurface,
      ),
    );
  }

  Future<void> _pickDate() async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: _accentGreen,
            onPrimary: Colors.white,
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
      testName:  _testNameCtrl.text.trim(),
      imagePath: _selectedImage!.path,
      testDate:  _selectedDate!,
      notes: _ocrNotesController.text.trim().isEmpty
          ? null
          : _ocrNotesController.text.trim(),
      createdAt: DateTime.now(),
    );

    context.read<HealthCubit>().addLabTest(entry);

    safePopOrHome(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang  = context.watch<LocaleCubit>().state;
    final theme = Theme.of(context);
    final isRtl = lang == 'ar';

    final dateText = _selectedDate == null
        ? AppStrings.get('date_placeholder', lang)
        : '${_selectedDate!.day.toString().padLeft(2, '0')} / '
        '${_selectedDate!.month.toString().padLeft(2, '0')} / '
        '${_selectedDate!.year}';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surfaceContainer,
          elevation: 0,
          title: Text(
            AppStrings.get('log_lab_test', lang),
            style: GoogleFonts.arimo(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: Icon(
              isRtl ? Icons.arrow_forward : Icons.arrow_back,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label(AppStrings.get('lab_test_image', lang)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _isUploading
                    ? null
                    : () => _showImageSourceDialog(lang),
                child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                        width: 1),
                  ),
                  child: _selectedImage == null
                      ? Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: _accentGreen,
                        size: 64,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.get(
                            'tap_to_select_image', lang),
                        style: GoogleFonts.arimo(
                            color: theme.colorScheme
                                .onSurfaceVariant,
                            fontSize: 14),
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
                  onTap: () => _showImageSourceDialog(lang),
                  child: Center(
                    child: Text(
                      AppStrings.get('change_image', lang),
                      style: GoogleFonts.arimo(
                          color: _accentGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              GestureDetector(
                onTap: _isUploading
                    ? null
                    : () => _uploadLabTest(lang),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _isUploading
                        ? _accentGreen.withOpacity(0.5)
                        : _accentGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isUploading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2),
                    )
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.upload_file,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.get(
                              'upload_extract', lang),
                          style: GoogleFonts.arimo(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              _fieldLabel(AppStrings.get('test_name', lang)),
              const SizedBox(height: 6),
              _textField(
                controller: _testNameCtrl,
                hint: AppStrings.get('eg_test_name', lang),
                isRtl: isRtl,
              ),

              const SizedBox(height: 16),

              _fieldLabel(AppStrings.get('date_of_test', lang)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                        width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          dateText,
                          style: GoogleFonts.arimo(
                            color: _selectedDate == null
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Icon(Icons.calendar_today,
                          color: _accentGreen, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _fieldLabel(AppStrings.get('extracted_notes', lang)),
              const SizedBox(height: 6),
              _textField(
                controller: _ocrNotesController,
                hint: AppStrings.get('ocr_hint', lang),
                maxLines: 8,
                isRtl: isRtl,
              ),

              const SizedBox(height: 32),

              MainButton(
                text: AppStrings.get('add', lang),
                enabled: _isValid,
                onTap: _isValid ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _fieldLabel(String label) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: GoogleFonts.arimo(
          color: theme.colorScheme.onSurface,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    bool isRtl   = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textDirection:
        isRtl ? TextDirection.rtl : TextDirection.ltr,
        style: GoogleFonts.arimo(
            color: theme.colorScheme.onSurface, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.arimo(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 16),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _label(String text) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: GoogleFonts.arimo(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5),
    );
  }

  void safePopOrHome(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainContainer()),
            (_) => false,
      );
    }
  }
}