import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/lang/lang_strings.dart';
import '../../cubit/health_cubit.dart';
import '../../cubit/locale_cubit.dart';
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
  // Internal English key — localised only at display time
  String    _mealType          = 'Breakfast';
  bool      _showMacros        = false;
  bool      _isProcessingImage = false;

  DateTime  _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String    _currentDate  = '';
  String    _currentTime  = '';

  bool get _canSubmit => _nameCtrl.text.trim().isNotEmpty;

  // English keys kept for logic; localised in build()
  static const List<String> _mealKeys = [
    'Breakfast', 'Lunch', 'Dinner', 'Snack',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = context.read<HealthCubit>().getSelectedDate();
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

  void _updateDateLabel(DateTime date, String lang) {
    final now     = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final monthName = AppStrings.get('month_${date.month}', lang);
    final month = lang == 'ar' ? monthName : monthName.substring(0, 3);

    setState(() {
      _currentDate = isToday
          ? '${AppStrings.get('today_int', lang)}: $month ${date.day}'
          : '$month ${date.day}';
    });
  }

  void _updateTimeLabel(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final p = t.period == DayPeriod.pm ? 'pm' : 'am';
    setState(() =>
    _currentTime = '$h:${t.minute.toString().padLeft(2, '0')}$p');
  }

  String _localMeal(String key, String lang) {
    const map = {
      'Breakfast': 'meal_breakfast',
      'Lunch':     'meal_lunch',
      'Dinner':    'meal_dinner',
      'Snack':     'meal_snack',
    };
    return AppStrings.get(map[key] ?? 'meal_other', lang);
  }

  Future<void> _pickDate(String lang) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _updateDateLabel(picked, lang);
    }
  }

  Future<void> _pickTime(String lang) async {
    final picked = await showTimePicker(
        context: context, initialTime: _selectedTime);
    if (picked == null) return;
    final now       = DateTime.now();
    final candidate = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, picked.hour, picked.minute);
    if (candidate.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.get('future_time_error', lang))));
      return;
    }
    setState(() => _selectedTime = picked);
    _updateTimeLabel(picked);
  }

  void _showImageOptions(String lang) {
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
              AppStrings.get('add_photo', lang),
              style: GoogleFonts.arimo(
                  color: c.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _imageOption(
              context: context,
              icon: Icons.camera_alt_outlined,
              label: AppStrings.get('take_photo', lang),
              onTap: () {
                Navigator.pop(context);
                _processImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 10),
            _imageOption(
              context: context,
              icon: Icons.photo_library_outlined,
              label: AppStrings.get('choose_gallery', lang),
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
                label: AppStrings.get('remove_photo', lang),
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
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _selectedTime.hour, _selectedTime.minute);

    context.read<HealthCubit>().addFood(FoodEntry(
      name:      _nameCtrl.text.trim(),
      imagePath: _imagePath,
      mealType:  _mealType, // stored as English key
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

  @override
  Widget build(BuildContext context) {
    final lang  = context.watch<LocaleCubit>().state;
    final c     = context.colors;
    final isRtl = lang == 'ar';

    // Keep date label in sync with language on first build
    if (_currentDate.isEmpty) _updateDateLabel(_selectedDate, lang);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: c.bottomSheet,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height: 46,
                color: c.surface,
                padding:
                const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isRtl
                            ? Icons.arrow_forward_ios
                            : Icons.arrow_back_ios_new,
                        color: c.primaryText,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      AppStrings.get('log_food', lang),
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
                      GestureDetector(
                        onTap: () => _showImageOptions(lang),
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: c.sectionBg,
                            borderRadius: BorderRadius.circular(16),
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
                                Text(
                                  AppStrings.get(
                                      'processing', lang),
                                  style: GoogleFonts.arimo(
                                      color: c.hintText,
                                      fontSize: 13),
                                ),
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
                              Text(
                                AppStrings.get(
                                    'add_photo', lang),
                                style: GoogleFonts.arimo(
                                    color: c.primaryText,
                                    fontSize: 14,
                                    fontWeight:
                                    FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.get(
                                    'optional', lang),
                                style: GoogleFonts.arimo(
                                    color: c.subtleText,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text(
                        '${AppStrings.get('date_time', lang)}:',
                        style: GoogleFonts.arimo(
                            color: c.primaryText, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _chip(
                            context: context,
                            onTap: () => _pickDate(lang),
                            icon: 'assets/icons/calendar.png',
                            label: _currentDate,
                          ),
                          const SizedBox(width: 10),
                          _chip(
                            context: context,
                            onTap: () => _pickTime(lang),
                            icon: 'assets/icons/clock.png',
                            label: _currentTime,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Text(
                        AppStrings.get('meal', lang),
                        style: GoogleFonts.arimo(
                            color: c.primaryText, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: _mealKeys.map((key) {
                          final active = _mealType == key;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _mealType = key),
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
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
                                    _localMeal(key, lang),
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
                      Text(
                        AppStrings.get('food_name', lang),
                        style: GoogleFonts.arimo(
                            color: c.primaryText, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameCtrl,
                        textDirection: isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        style: GoogleFonts.arimo(
                            color: c.primaryText, fontSize: 15),
                        decoration: InputDecoration(
                          hintText:
                          AppStrings.get('eg_food', lang),
                          hintStyle: GoogleFonts.arimo(
                              color: c.hintGrey, fontSize: 15),
                          filled: true,
                          fillColor: c.notesFill,
                          contentPadding:
                          const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => setState(
                                () => _showMacros = !_showMacros),
                        child: Row(
                          children: [
                            Text(
                              AppStrings.get(
                                  'nutrition_info', lang),
                              style: GoogleFonts.arimo(
                                  color: c.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppStrings.get('optional', lang),
                              style: GoogleFonts.arimo(
                                  color: c.subtleText,
                                  fontSize: 12),
                            ),
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
                              label: AppStrings.get(
                                  'macro_calories', lang),
                              hint: '0',
                              suffix: AppStrings.get('kcal', lang),
                              isInt: true,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _macroField(
                                    context: context,
                                    controller: _carbsCtrl,
                                    label: AppStrings.get(
                                        'macro_carbs', lang),
                                    hint: '0',
                                    suffix: 'g',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _macroField(
                                    context: context,
                                    controller: _proteinCtrl,
                                    label: AppStrings.get(
                                        'macro_protein', lang),
                                    hint: '0',
                                    suffix: 'g',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _macroField(
                                    context: context,
                                    controller: _fatCtrl,
                                    label: AppStrings.get(
                                        'macro_fat', lang),
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
                      Text(
                        AppStrings.get('notes', lang),
                        style: GoogleFonts.arimo(
                            color: c.primaryText, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesCtrl,
                        textDirection: isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        style: GoogleFonts.arimo(
                            color: c.primaryText, fontSize: 14),
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: AppStrings.get(
                              'eg_notes_food', lang),
                          hintStyle: GoogleFonts.arimo(
                              color: c.hintGrey, fontSize: 13),
                          filled: true,
                          fillColor: c.notesFill,
                          contentPadding:
                          const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
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
                  text: AppStrings.get('add', lang),
                  enabled: _canSubmit,
                  onTap: _canSubmit ? _submit : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            style:
            GoogleFonts.arimo(color: c.hintText, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: isInt
              ? TextInputType.number
              : const TextInputType.numberWithOptions(decimal: true),
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