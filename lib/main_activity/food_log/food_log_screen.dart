import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../cubit/health_cubit.dart';
import '../../models/food_entry.dart';
import '../../services/image_service.dart';
import '../../widgets/components.dart';

class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  final _nameCtrl     = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _carbsCtrl    = TextEditingController();
  final _proteinCtrl  = TextEditingController();
  final _fatCtrl      = TextEditingController();
  final _notesCtrl    = TextEditingController();

  String?   _imagePath;
  String    _mealType          = 'Breakfast';
  bool      _showMacros        = false;
  bool      _isProcessingImage = false;

  DateTime  _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String    _currentDate  = '';
  String    _currentTime  = '';

  bool get _canSubmit => _nameCtrl.text.trim().isNotEmpty;

  final List<String> _mealTypes = [
    'Breakfast', 'Lunch', 'Dinner', 'Snack',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = context.read<HealthCubit>().getSelectedDate();
    _updateDateLabel(_selectedDate);
    _updateTimeLabel(_selectedTime);
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _caloriesCtrl.dispose();
    _carbsCtrl.dispose();
    _proteinCtrl.dispose();
    _fatCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _monthName(int m) => const [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ][m - 1];

  void _updateDateLabel(DateTime date) {
    final now     = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    setState(() {
      _currentDate = isToday
          ? 'Today: ${_monthName(date.month)} ${date.day}'
          : '${_monthName(date.month)} ${date.day}';
    });
  }

  void _updateTimeLabel(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final p = t.period == DayPeriod.pm ? 'pm' : 'am';
    setState(() =>
    _currentTime = '$h:${t.minute.toString().padLeft(2, '0')}$p');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _updateDateLabel(picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
        context: context, initialTime: _selectedTime);
    if (picked == null) return;
    final now       = DateTime.now();
    final candidate = DateTime(_selectedDate.year,
        _selectedDate.month, _selectedDate.day,
        picked.hour, picked.minute);
    if (candidate.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Future time cannot be selected')));
      return;
    }
    setState(() => _selectedTime = picked);
    _updateTimeLabel(picked);
  }

  // ── Image option sheet ────────────────────────────────────

  void _showImageOptions() {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.bottomSheet,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            Text(
              'Add Photo',
              style: GoogleFonts.arimo(
                  color: c.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _imageOption(
              context: context,
              icon: Icons.camera_alt_outlined,
              label: 'Take Photo',
              onTap: () {
                Navigator.pop(context);
                _processImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 10),
            _imageOption(
              context: context,
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(context);
                _processImage(ImageSource.gallery);
              },
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: 10),
              _imageOption(
                context: context,
                icon: Icons.delete_outline,
                label: 'Remove Photo',
                color: Colors.redAccent,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imagePath = null);
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _imageOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c          = context.colors;
    final labelColor = color ?? c.primaryText;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: labelColor, size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.arimo(
                    color: labelColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _processImage(ImageSource source) async {
    setState(() => _isProcessingImage = true);
    try {
      final path =
      await ImageService.pickAndProcess(source: source);
      if (path != null) setState(() => _imagePath = path);
    } finally {
      setState(() => _isProcessingImage = false);
    }
  }

  void _submit() {
    final dt = DateTime(
        _selectedDate.year, _selectedDate.month,
        _selectedDate.day, _selectedTime.hour,
        _selectedTime.minute);

    context.read<HealthCubit>().addFood(FoodEntry(
      name:      _nameCtrl.text.trim(),
      imagePath: _imagePath,
      mealType:  _mealType,
      calories:  int.tryParse(_caloriesCtrl.text),
      carbs:     double.tryParse(_carbsCtrl.text),
      protein:   double.tryParse(_proteinCtrl.text),
      fat:       double.tryParse(_fatCtrl.text),
      notes:     _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
      dateTime: dt,
    ));

    Navigator.pop(context);
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bottomSheet,
      body: SafeArea(
        child: Column(
          children: [

            // ── Top bar ──────────────────────────────────
            Container(
              height: 46,
              color: c.surface,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: c.primaryText, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Log Food',
                    style: GoogleFonts.arimo(
                        color: c.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.fromLTRB(20, 25, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Photo picker ─────────────────────
                    GestureDetector(
                      onTap: _showImageOptions,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: c.sectionBg,
                          borderRadius:
                          BorderRadius.circular(16),
                          border: Border.all(
                              color: c.divider, width: 1),
                        ),
                        child: _isProcessingImage
                            ? Center(
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                              const SizedBox(height: 12),
                              Text('Processing...',
                                  style: GoogleFonts.arimo(
                                      color: c.hintText,
                                      fontSize: 13)),
                            ],
                          ),
                        )
                            : _imagePath != null
                            ? ClipRRect(
                          borderRadius:
                          BorderRadius.circular(15),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            cacheWidth: 512,
                          ),
                        )
                            : Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: AppColors.primary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('Add Photo',
                                style: GoogleFonts.arimo(
                                    color: c.primaryText,
                                    fontSize: 14,
                                    fontWeight:
                                    FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('optional',
                                style: GoogleFonts.arimo(
                                    color: c.subtleText,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Date / Time ───────────────────────
                    Text('Date/Time:',
                        style: GoogleFonts.arimo(
                            color: c.primaryText, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _chip(
                            context: context,
                            onTap: _pickDate,
                            icon: 'assets/icons/calendar.png',
                            label: _currentDate),
                        const SizedBox(width: 10),
                        _chip(
                            context: context,
                            onTap: _pickTime,
                            icon: 'assets/icons/clock.png',
                            label: _currentTime),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Meal type selector ────────────────
                    Text('Meal',
                        style: GoogleFonts.arimo(
                            color: c.primaryText, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: _mealTypes.map((type) {
                        final active = _mealType == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                                    () => _mealType = type),
                            child: Container(
                              margin: const EdgeInsets.only(
                                  right: 6),
                              padding:
                              const EdgeInsets.symmetric(
                                  vertical: 8),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.primary
                                    .withOpacity(0.15)
                                    : c.surface,
                                borderRadius:
                                BorderRadius.circular(10),
                                border: Border.all(
                                  color: active
                                      ? AppColors.primary
                                      : Colors.transparent,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  type,
                                  style: GoogleFonts.arimo(
                                    color: active
                                        ? AppColors.primary
                                        : c.hintText,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // ── Food name ─────────────────────────
                    Text('Food name',
                        style: GoogleFonts.arimo(
                            color: c.primaryText, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      style: GoogleFonts.arimo(
                          color: c.primaryText, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'eg. Grilled chicken salad',
                        hintStyle: GoogleFonts.arimo(
                            color: c.hintGrey, fontSize: 15),
                        filled: true,
                        fillColor: c.notesFill,
                        contentPadding:
                        const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Nutrition info toggle ─────────────
                    GestureDetector(
                      onTap: () => setState(
                              () => _showMacros = !_showMacros),
                      child: Row(
                        children: [
                          Text('Nutrition Info',
                              style: GoogleFonts.arimo(
                                  color: c.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(width: 6),
                          Text('optional',
                              style: GoogleFonts.arimo(
                                  color: c.subtleText,
                                  fontSize: 12)),
                          const Spacer(),
                          AnimatedRotation(
                            turns: _showMacros ? 0.5 : 0,
                            duration: const Duration(
                                milliseconds: 200),
                            child: Icon(
                                Icons.keyboard_arrow_down,
                                color: c.hintText,
                                size: 20),
                          ),
                        ],
                      ),
                    ),

                    // ── Macro fields ──────────────────────
                    AnimatedCrossFade(
                      duration:
                      const Duration(milliseconds: 250),
                      crossFadeState: _showMacros
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: Column(
                        children: [
                          const SizedBox(height: 12),
                          _macroField(
                            context: context,
                            controller: _caloriesCtrl,
                            label: 'Calories',
                            hint: '0',
                            suffix: 'kcal',
                            isInt: true,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _macroField(
                                  context: context,
                                  controller: _carbsCtrl,
                                  label: 'Carbs',
                                  hint: '0',
                                  suffix: 'g',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _macroField(
                                  context: context,
                                  controller: _proteinCtrl,
                                  label: 'Protein',
                                  hint: '0',
                                  suffix: 'g',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _macroField(
                                  context: context,
                                  controller: _fatCtrl,
                                  label: 'Fat',
                                  hint: '0',
                                  suffix: 'g',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      secondChild:
                      const SizedBox(width: double.infinity),
                    ),

                    const SizedBox(height: 20),

                    // ── Notes ─────────────────────────────
                    Text('Notes',
                        style: GoogleFonts.arimo(
                            color: c.primaryText, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesCtrl,
                      style: GoogleFonts.arimo(
                          color: c.primaryText, fontSize: 14),
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'eg. Had this after workout',
                        hintStyle: GoogleFonts.arimo(
                            color: c.hintGrey, fontSize: 13),
                        filled: true,
                        fillColor: c.notesFill,
                        contentPadding:
                        const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: MainButton(
                text: 'Add',
                enabled: _canSubmit,
                onTap: _canSubmit ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Small helpers ─────────────────────────────────────────

  Widget _chip({
    required BuildContext context,
    required VoidCallback onTap,
    required String icon,
    required String label,
  }) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: c.cardBg,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 14, height: 14),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.arimo(
                    color: c.primaryText, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _macroField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    bool isInt = false,
  }) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.arimo(
                color: c.hintText, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: isInt
              ? TextInputType.number
              : const TextInputType.numberWithOptions(
              decimal: true),
          inputFormatters: [
            isInt
                ? FilteringTextInputFormatter.digitsOnly
                : FilteringTextInputFormatter.allow(
                RegExp(r'^\d*\.?\d*')),
          ],
          style: GoogleFonts.arimo(
              color: c.primaryText, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.arimo(
                color: c.subtleText, fontSize: 13),
            suffixText: suffix,
            suffixStyle: GoogleFonts.arimo(
                color: c.subtleText, fontSize: 12),
            filled: true,
            fillColor: c.notesFill,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
