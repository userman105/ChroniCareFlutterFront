import 'dart:math' as math;
import 'package:chronic_care/main_activity/blood_log/blood_pressure_reminder_screen.dart';
import 'package:chronic_care/main_activity/doctor_log/appointment_log_screen.dart';
import 'package:chronic_care/main_activity/food_log/food_log_screen.dart';
import 'package:chronic_care/main_activity/glucose_log/glucose_log_screen.dart';
import 'package:chronic_care/main_activity/glucose_log/glucose_reminder_screen.dart';
import 'package:chronic_care/main_activity/lab_tests_log/lab_log.dart';
import 'package:chronic_care/main_activity/med_log/medication_log_screen.dart';
import 'package:chronic_care/main_activity/med_log/medication_reminder_screen.dart';
import 'package:chronic_care/main_activity/symptom_log/symptom_screen.dart';
import 'package:chronic_care/main_activity/weight_log/weight_reminder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../cubit/health_cubit.dart';
import '../cubit/locale_cubit.dart';
import '../core/lang/lang_strings.dart';
import '../main_activity/blood_log/blood_log_screen.dart';
import '../main_activity/weight_log/weight_log_screen.dart';
import '../models/appointment_entry.dart';
import 'alarm_screen.dart';

class AppColors {
  final bool isDark;
  const AppColors(this.isDark);

  Color get scaffoldBg     => isDark ? const Color(0xFF111111) : Colors.white;
  Color get surface        => isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF2F2F2);
  Color get bottomSheet    => isDark ? const Color(0xFF212121) : Colors.white;
  Color get cardBg         => isDark ? const Color(0xFF383838) : const Color(0xFFEBEBEB);
  Color get reminderTileBg => isDark ? const Color(0xFF444444) : const Color(0xFFE4E4E4);
  Color get inputFill      => isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);
  Color get compactInput   => isDark ? const Color(0xFF111111) : const Color(0xFFE8E8E8);
  Color get sectionBg      => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEEEEEE);
  Color get toggleBg       => isDark ? const Color(0xFF0F0F0F) : const Color(0xFFDDDDDD);
  Color get notesFill      => isDark ? const Color(0xFF0C0C0C) : const Color(0xFFEEEEEE);
  Color get editFieldFill  => isDark ? const Color(0xFF4F4F4F) : const Color(0xFFDDDDDD);
  Color get logTileBg      => isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);
  Color get datePickerBg   => isDark ? const Color(0xFF1C1C1C) : Colors.white;

  Color get primaryText    => isDark ? Colors.white        : Colors.black;
  Color get secondaryText  => isDark ? Colors.white70      : Colors.black54;
  Color get hintText       => isDark ? Colors.white54      : Colors.black38;
  Color get subtleText     => isDark ? Colors.white38      : Colors.black26;
  Color get ghostText      => isDark ? Colors.white24      : Colors.black12;
  Color get navInactive    => isDark ? const Color(0xFF929292) : const Color(0xFF666666);
  Color get hintGrey       => isDark ? const Color(0xFFB4B4B4) : const Color(0xFF888888);
  Color get offMonthText   => isDark ? Colors.white24      : Colors.black26;

  Color get border         => isDark ? Colors.white        : Colors.black87;
  Color get divider        => isDark ? Colors.white12      : Colors.black12;
  Color get subtleBorder   => isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.10);
  Color get optionBorder   => isDark ? Colors.white        : Colors.black38;

  Color get disabledBg     => isDark ? const Color(0xFF474747) : const Color(0xFFCCCCCC);
  Color get disabledText   => isDark ? Colors.white54      : Colors.black38;

  static const Color primary    = Color(0xFF00C950);
  static const Color primaryAlt = Color(0xFF05DF72);
}

extension AppThemeX on BuildContext {
  bool      get isDark => Theme.of(this).brightness == Brightness.dark;
  AppColors get colors => AppColors(isDark);
}


String translateFrequency(String freq, String lang) {
  switch (freq) {
    case 'Daily':      return AppStrings.get('daily', lang);
    case 'Weekly':     return AppStrings.get('weekly', lang);
    case 'Every 2 days': return AppStrings.get('every_2_days', lang);
    case 'Monthly':    return AppStrings.get('monthly', lang);
    default:           return freq;
  }
}

String formatTimeLocalized(TimeOfDay t, String lang) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final m = t.minute.toString().padLeft(2, '0');
  final period = t.period == DayPeriod.am
      ? AppStrings.get('am_label', lang)
      : AppStrings.get('pm_label', lang);
  return '$h:$m $period';
}


class RoundedInputBox extends StatelessWidget {
  final String hintTop;
  final String centerPlaceholder;
  final TextEditingController controller;
  final bool isPassword;

  const RoundedInputBox({
    super.key,
    required this.hintTop,
    required this.centerPlaceholder,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      textAlign: TextAlign.start,
      style: TextStyle(color: c.primaryText, fontSize: 16),
      cursorColor: c.primaryText,
      decoration: InputDecoration(
        labelText: hintTop,
        labelStyle: TextStyle(color: c.primaryText, fontSize: 14),
        hintText: centerPlaceholder,
        hintStyle: TextStyle(color: c.hintText),
        alignLabelWithHint: true,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        filled: true,
        fillColor: c.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: c.border, width: 1.5),
        ),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
    );
  }
}


class MainButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool enabled;

  const MainButton({
    super.key,
    required this.text,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 358,
        height: 56,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryAlt : c.disabledBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x19000000),
                blurRadius: 6,
                offset: Offset(0, 4),
                spreadRadius: -4),
            BoxShadow(
                color: Color(0x19000000),
                blurRadius: 15,
                offset: Offset(0, 10),
                spreadRadius: -3),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.arimo(
            color: enabled ? Colors.white : c.disabledText,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 0.75,
          ),
        ),
      ),
    );
  }
}


class ChronicLogo extends StatelessWidget {
  final double logoHeight;

  const ChronicLogo({super.key, this.logoHeight = 120});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: Transform.rotate(
                angle: -2.25 * math.pi / 180,
                child: Container(
                  height: 8,
                  width: MediaQuery.of(context).size.width * 2,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAlt,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Transform.rotate(
                angle: 2.25 * math.pi / 180,
                child: Container(
                  height: 8,
                  width: MediaQuery.of(context).size.width * 2,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAlt,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
        Image.asset("assets/logos/chronicareLogo.png", height: logoHeight),
      ],
    );
  }
}


class ConditionButton extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String description;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double iconSize;

  const ConditionButton({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.description,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.width = double.infinity,
    this.height = 125,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: AnimatedScale(
            scale: selected ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              width: width,
              height: height,
              padding: const EdgeInsets.all(20),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: c.cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected ? AppColors.primaryAlt : c.cardBg,
                  width: 2.75,
                ),
                boxShadow: [
                  const BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                      spreadRadius: -2),
                  const BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                      spreadRadius: -1),
                  if (selected)
                    const BoxShadow(
                        color: Color(0x6605DF72), blurRadius: 12, spreadRadius: 1),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: Center(
                        child: Image.asset(iconAsset, height: iconSize + 10)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: GoogleFonts.arimo(
                                color: c.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(description,
                            style: GoogleFonts.arimo(
                                color: c.secondaryText, fontSize: 14)),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child)),
                    child: selected
                        ? Container(
                      key: const ValueKey("check"),
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                          color: AppColors.primaryAlt, shape: BoxShape.circle),
                      child: const Center(
                        child: Text("✓",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                    )
                        : const SizedBox.shrink(key: ValueKey("empty")),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConditionGridButton extends StatelessWidget {
  final String iconAsset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ConditionGridButton({
    super.key,
    required this.iconAsset,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 181,
          height: 80,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: selected ? Colors.green[400] : c.cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            shadows: [
              BoxShadow(
                color: selected
                    ? Colors.green.withOpacity(0.5)
                    : Colors.black.withOpacity(0.1),
                blurRadius: selected ? 12 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 6,
                top: 13,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(iconAsset), fit: BoxFit.cover),
                  ),
                ),
              ),
              Positioned(
                left: 37,
                top: 14.5,
                child: Text(label,
                    style: GoogleFonts.arimo(
                        color: c.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class TodayDateBar extends StatefulWidget {
  final String calendarIconAsset;

  const TodayDateBar({super.key, required this.calendarIconAsset});

  @override
  State<TodayDateBar> createState() => _TodayDateBarState();
}

class _TodayDateBarState extends State<TodayDateBar> {
  final ScrollController _scrollController = ScrollController();

  List<DateTime> get visibleDates {
    final today = DateTime.now();
    return List.generate(365, (i) => today.subtract(Duration(days: 364 - i)));
  }

  bool isToday(DateTime selectedDate) {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  void _scrollToSelected(DateTime selectedDate) {
    final index = visibleDates.indexWhere((d) =>
    d.year == selectedDate.year &&
        d.month == selectedDate.month &&
        d.day == selectedDate.day);
    if (index == -1) return;
    const itemWidth = 64.0;
    final offset = (index * itemWidth) -
        (MediaQuery.of(context).size.width / 2) +
        (itemWidth / 2);
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickDate(DateTime current) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      context.read<HealthCubit>().setSelectedDate(picked);
      Future.delayed(
          const Duration(milliseconds: 50), () => _scrollToSelected(picked));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<HealthCubit>();
      _scrollToSelected(cubit.selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lang = context.watch<LocaleCubit>().state;
    final cubit = context.watch<HealthCubit>();
    final selectedDate = cubit.selectedDate;
    final dateText = DateFormat('MMM d, yyyy').format(selectedDate);

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 46,
          padding: const EdgeInsets.only(top: 8, left: 14, right: 22, bottom: 8),
          decoration: BoxDecoration(color: c.surface),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (isToday(selectedDate)) ...[
                    Text(
                      AppStrings.get('today', lang),
                      style: GoogleFonts.arimo(
                          color: c.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    dateText,
                    style: GoogleFonts.arimo(
                        color: c.secondaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _pickDate(selectedDate),
                child: Image.asset(widget.calendarIconAsset, width: 30, height: 30),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 73,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            itemCount: visibleDates.length,
            itemBuilder: (context, index) {
              final date = visibleDates[index];
              final selected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;

              return GestureDetector(
                onTap: () {
                  final today = DateTime.now();
                  if (date.isAfter(today)) return;
                  context.read<HealthCubit>().setSelectedDate(date);
                  _scrollToSelected(date);
                },
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date),
                        style: GoogleFonts.arimo(
                            color: c.primaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: 31,
                        height: 31,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? (context.isDark ? Colors.white : Colors.black)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.arimo(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: selected
                                ? (context.isDark ? Colors.black : Colors.white)
                                : c.hintGrey,
                          ),
                          child: Text(date.day.toString()),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


class TodayHeader extends StatelessWidget {
  final DateTime selectedDate;
  final String calendarIconAsset;
  final VoidCallback onCalendarTap;

  const TodayHeader({
    super.key,
    required this.selectedDate,
    required this.calendarIconAsset,
    required this.onCalendarTap,
  });

  bool isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lang = context.watch<LocaleCubit>().state;
    final dateText = DateFormat('MMM d, yyyy').format(selectedDate);

    return Container(
      width: double.infinity,
      height: 46,
      padding: const EdgeInsets.only(top: 8, left: 14, right: 22, bottom: 8),
      decoration: BoxDecoration(color: c.surface),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isToday(selectedDate)) ...[
                Text(
                  AppStrings.get('today', lang),
                  style: GoogleFonts.arimo(
                      color: c.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                dateText,
                style: GoogleFonts.arimo(
                    color: c.secondaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          GestureDetector(
            onTap: onCalendarTap,
            child: Image.asset(calendarIconAsset, width: 30, height: 30),
          ),
        ],
      ),
    );
  }
}


enum HealthMetricType {
  bloodPressure, glucose, weight, meds, symptoms, food, testLogs, unknown,
}

class HealthTile {
  final String icon;
  final String labelKey; // The unique key for AppStrings
  final HealthMetricType type;
  bool selected;

  HealthTile({
    required this.icon,
    required this.labelKey, // Required key for localization
    this.selected = false,
    HealthMetricType? type,
  }) : type = type ?? _inferType(labelKey);

  static HealthMetricType _inferType(String key) {
    // We match against the keys now, which are more stable than localized strings
    switch (key.toLowerCase()) {
      case 'blood_pressure': return HealthMetricType.bloodPressure;
      case 'glucose':        return HealthMetricType.glucose;
      case 'weight':         return HealthMetricType.weight;
      case 'meds':           return HealthMetricType.meds;
      case 'symptoms':       return HealthMetricType.symptoms;
      case 'food':           return HealthMetricType.food;
      case 'test_logs':      return HealthMetricType.testLogs;
      default:               return HealthMetricType.unknown;
    }
  }
}

List<HealthTile> allTiles = [
  HealthTile(icon: 'assets/icons/bloodPressure.png', labelKey: 'blood_pressure'),
  HealthTile(icon: 'assets/icons/capsule.png',       labelKey: 'meds'),
  HealthTile(icon: 'assets/icons/healthcare.png',    labelKey: 'symptoms'),
  HealthTile(icon: 'assets/icons/cutlery.png',       labelKey: 'food'),
  HealthTile(icon: 'assets/icons/weight.png',        labelKey: 'weight'),
  HealthTile(icon: 'assets/icons/diabetes.png',      labelKey: 'glucose'),
  HealthTile(icon: 'assets/icons/testImage.png',     labelKey: 'test_logs'),
];


class HighlightableGridTile extends StatelessWidget {
  final String iconAsset;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const HighlightableGridTile({
    super.key,
    required this.iconAsset,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: ShapeDecoration(
            color: selected ? Colors.green[400] : c.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            shadows: [
              BoxShadow(
                color: selected
                    ? Colors.green.withOpacity(0.5)
                    : Colors.black.withOpacity(0.1),
                blurRadius: selected ? 12 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset(iconAsset, width: 28, height: 28),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.arimo(
                      color: c.primaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class BottomNavigationBarCustom extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final Function(HealthTile) onTileSelected;

  const BottomNavigationBarCustom({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onTileSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lang = context.watch<LocaleCubit>().state;

    Widget navItem(int index, String icon, String activeIcon, String label) {
      final bool isActive = currentIndex == index;

      return GestureDetector(
        onTap: () => onTabSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(isActive ? activeIcon : icon, width: 26, height: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.arimo(
                color: isActive ? AppColors.primary : c.navInactive,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    Widget floatingButton() {
      return GestureDetector(
        onTap: () {
          AddEventSlider.show(
            context,
            onAddDoctorAppointment: () {},
            onScheduleReminder: () {},
            onAddOneTimeEntry: () {},
            onTileSelected: onTileSelected,
          );
        },
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      );
    }

    return SizedBox(
      height: 100, // more space for floating button
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [

          /// NAV BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                height: 75,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: c.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [

                    Expanded(
                      child: navItem(
                        0,
                        'assets/icons/today.png',
                        'assets/icons/today_active.png',
                        AppStrings.get('today', lang),
                      ),
                    ),

                    Expanded(
                      child: navItem(
                        1,
                        'assets/icons/insights.png',
                        'assets/icons/insights_active.png',
                        AppStrings.get('insights', lang),
                      ),
                    ),

                    /// GAP FOR CENTER BUTTON
                    const SizedBox(width: 70),

                    Expanded(
                      child: navItem(
                        2,
                        'assets/icons/reminders.png',
                        'assets/icons/reminders_active.png',
                        AppStrings.get('reminders', lang),
                      ),
                    ),

                    Expanded(
                      child: navItem(
                        3,
                        'assets/icons/profile.png',
                        'assets/icons/profile_active.png',
                        AppStrings.get('profile', lang),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// FLOATING BUTTON
          Positioned(
            bottom: 35, // 🔥 controls how high it floats
            child: floatingButton(),
          ),
        ],
      ),
    );
  }
}



class AddEntryPopup extends StatefulWidget {
  final List<HealthTile> currentTiles;

  const AddEntryPopup({super.key, required this.currentTiles});

  static Future<HealthTile?> show(
      BuildContext context, List<HealthTile> currentTiles) {
    return showModalBottomSheet<HealthTile>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddEntryPopup(currentTiles: currentTiles),
    );
  }

  @override
  State<AddEntryPopup> createState() => _AddEntryPopupState();
}

class _AddEntryPopupState extends State<AddEntryPopup> {
  late List<HealthTile> tiles;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    tiles = allTiles;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lang = context.watch<LocaleCubit>().state;

    return Container(
      height: 420,
      decoration: BoxDecoration(
        color: c.bottomSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset("assets/icons/close.png",
                      width: 22, height: 22),
                ),
                const SizedBox(width: 10),
                Text(
                  AppStrings.get('select_type', lang),
                  style: GoogleFonts.arimo(
                      color: c.primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: tiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3,
                ),
                itemBuilder: (context, index) {
                  final tile = tiles[index];
                  // Get the current language from your LocaleCubit
                  final lang = context.watch<LocaleCubit>().state;

                  return HighlightableGridTile(
                    iconAsset: tile.icon,
                    // Use the localization key instead of the hardcoded label
                    label: AppStrings.get(tile.labelKey, lang),
                    selected: selectedIndex == index,
                    onTap: () {
                      Navigator.pop(context, tile);
                      Future.microtask(() {
                        // CRITICAL: Switch on tile.type (Enum), NOT the label string
                        switch (tile.type) {
                          case HealthMetricType.bloodPressure:
                            Navigator.push(context, MaterialPageRoute(
                                builder: (_) => const BloodPressureScreen()));
                            break;
                          case HealthMetricType.meds:
                            Navigator.push(context, MaterialPageRoute(
                                builder: (_) => const MedicationLogScreen()));
                            break;
                          case HealthMetricType.symptoms:
                            Navigator.push(context, MaterialPageRoute(
                                builder: (_) => const SymptomScreen()));
                            break;
                          case HealthMetricType.food:
                            Navigator.push(context, MaterialPageRoute(
                                builder: (_) => const FoodLogScreen()));
                            break;
                          case HealthMetricType.weight:
                            Navigator.push(context, MaterialPageRoute(
                                builder: (_) => WeightLogScreen()));
                            break;
                          case HealthMetricType.glucose:
                            Navigator.push(context, MaterialPageRoute(
                                builder: (_) => GlucoseScreen()));
                            break;
                          case HealthMetricType.testLogs:
                            Navigator.push(context, MaterialPageRoute(
                                builder: (_) => LabTestLogScreen()));
                            break;
                          default:
                            break;
                        }
                      });
                    },
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


class AddReminderPopup extends StatefulWidget {
  final List<HealthTile> currentTiles;

  const AddReminderPopup({super.key, required this.currentTiles});

  static Future<HealthTile?> show(
      BuildContext context, List<HealthTile> currentTiles) {
    return showModalBottomSheet<HealthTile>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddReminderPopup(currentTiles: currentTiles),
    );
  }

  @override
  State<AddReminderPopup> createState() => _AddReminderPopupState();
}

class _AddReminderPopupState extends State<AddReminderPopup> {
  late List<HealthTile> tiles;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();

    final allowedTypes = {
      HealthMetricType.bloodPressure,
      HealthMetricType.meds,
      HealthMetricType.weight,
      HealthMetricType.glucose,
    };


    tiles = allTiles.where((t) => allowedTypes.contains(t.type)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lang = context.watch<LocaleCubit>().state;

    return Container(
      height: 420,
      decoration: BoxDecoration(
        color: c.bottomSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset("assets/icons/close.png",
                      width: 22, height: 22),
                ),
                const SizedBox(width: 10),
                Text(
                  AppStrings.get('select_type', lang),
                  style: GoogleFonts.arimo(
                      color: c.primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: tiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3,
                ),
                itemBuilder: (context, index) {
                  final tile = tiles[index];
                  final lang = context.watch<LocaleCubit>().state; // Get current language

                  return HighlightableGridTile(
                    iconAsset: tile.icon,
                    label: AppStrings.get(tile.labelKey, lang), // Translates the UI text
                    selected: selectedIndex == index,
                    onTap: () {
                      Navigator.pop(context, tile);
                      Future.microtask(() {
                        // FIX: Switch on tile.type (the Enum) instead of tile.label
                        switch (tile.type) {
                          case HealthMetricType.bloodPressure:
                            Navigator.push(context, MaterialPageRoute(
                                builder: (_) => const BloodPressureReminderScreen()));
                            break;
                          case HealthMetricType.meds:
                            Navigator.push(context, MaterialPageRoute(
                                builder: (_) => const MedicationReminderScreen()));
                            break;
                          case HealthMetricType.weight:
                            Navigator.push(context, MaterialPageRoute(
                                builder: (_) => const WeightReminderScreen()));
                            break;
                          case HealthMetricType.glucose:
                            Navigator.push(context, MaterialPageRoute(
                                builder: (_) => const GlucoseReminderScreen()));
                            break;
                          default:
                          // Handle other cases or test logs if necessary
                            break;
                        }
                      });
                    },
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


class AddEventSlider {
  static void show(
      BuildContext context, {
        required VoidCallback onAddDoctorAppointment,
        required VoidCallback onScheduleReminder,
        required VoidCallback onAddOneTimeEntry,
        required Function(HealthTile) onTileSelected,
      }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEventSliderContent(
        onAddDoctorAppointment: onAddDoctorAppointment,
        onScheduleReminder: onScheduleReminder,
        onAddOneTimeEntry: onAddOneTimeEntry,
        onTileSelected: onTileSelected,
      ),
    );
  }
}

class _AddEventSliderContent extends StatelessWidget {
  final VoidCallback onAddDoctorAppointment;
  final VoidCallback onScheduleReminder;
  final VoidCallback onAddOneTimeEntry;
  final Function(HealthTile) onTileSelected;

  const _AddEventSliderContent({
    required this.onAddDoctorAppointment,
    required this.onScheduleReminder,
    required this.onAddOneTimeEntry,
    required this.onTileSelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lang = context.watch<LocaleCubit>().state;

    Widget optionTile({
      required String title,
      required String description,
      required String icon,
      required VoidCallback onTap,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          splashColor: Colors.green.withOpacity(0.2),
          highlightColor: Colors.green.withOpacity(0.1),
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: c.optionBorder, width: 0.5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(icon, width: 20, height: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.arimo(
                              color: c.primaryText.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(description,
                          style: GoogleFonts.arimo(
                              color: c.primaryText.withOpacity(0.6),
                              fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Image.asset("assets/icons/Chevronup.png",
                    width: 18, height: 18),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints:
      BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: c.bottomSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.get('select_what_to_do', lang),
                      style: GoogleFonts.arimo(
                          color: c.primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset("assets/icons/close.png",
                        width: 22, height: 22),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              optionTile(
                title: AppStrings.get('add_doctor_appointment', lang),
                description: AppStrings.get('add_doctor_desc', lang),
                icon: "assets/icons/calendarEdit.png",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AppointmentLogScreen()));
                },
              ),
              const SizedBox(height: 12),
              optionTile(
                title: AppStrings.get('schedule_reminder', lang),
                description: AppStrings.get('schedule_reminder_desc', lang),
                icon: "assets/icons/bellCalendar.png",
                onTap: () async {
                  final selectedTile =
                  await AddReminderPopup.show(context, allTiles);
                  if (selectedTile == null) return;
                  onTileSelected(selectedTile);
                },
              ),
              const SizedBox(height: 12),
              optionTile(
                title: AppStrings.get('add_one_time_entry', lang),
                description: AppStrings.get('add_one_time_desc', lang),
                icon: "assets/icons/calendarSlider.png",
                onTap: () async {
                  final selectedTile =
                  await AddEntryPopup.show(context, allTiles);
                  if (selectedTile == null) return;
                  onTileSelected(selectedTile);
                },
              ),
              const SizedBox(height: 12),
              optionTile(
                title: AppStrings.get('photograph_tests', lang),
                description: AppStrings.get('photograph_tests_desc', lang),
                icon: "assets/icons/calendarSlider.png",
                onTap: () {
                  final testTile = HealthTile(
                    icon: 'assets/icons/testImage.png',
                    labelKey: 'test_logs',
                  );

                  onTileSelected(testTile);

                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const LabTestLogScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class BloodPressureInputs extends StatelessWidget {
  final TextEditingController systolicController;
  final TextEditingController diastolicController;
  final TextEditingController heartRateController;

  const BloodPressureInputs({
    super.key,
    required this.systolicController,
    required this.diastolicController,
    required this.heartRateController,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lang = context.watch<LocaleCubit>().state;

    Widget compactField(TextEditingController ctrl,
        {bool digitsOnly = false, double width = 68}) {
      return Container(
        width: width,
        height: 30,
        decoration: BoxDecoration(
            color: c.compactInput, borderRadius: BorderRadius.circular(3)),
        child: TextField(
          controller: ctrl,
          inputFormatters:
          digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
          keyboardType: TextInputType.number,
          style: TextStyle(color: c.primaryText),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding:
            EdgeInsets.symmetric(horizontal: 7, vertical: 6),
          ),
          textAlignVertical: TextAlignVertical.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get('blood_pressure_label', lang),
          style: GoogleFonts.arimo(color: c.primaryText, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            compactField(systolicController, digitsOnly: true),
            const SizedBox(width: 4),
            Text("/",
                style: GoogleFonts.arimo(color: c.primaryText, fontSize: 16)),
            const SizedBox(width: 4),
            compactField(diastolicController, digitsOnly: true),
            const SizedBox(width: 8),
            Text(
              AppStrings.get('mmhg', lang),
              style: GoogleFonts.arimo(color: c.hintText, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          AppStrings.get('heart_rate_optional', lang),
          style: GoogleFonts.arimo(color: c.primaryText, fontSize: 14),
        ),
        const SizedBox(height: 6),
        compactField(heartRateController, width: 79),
      ],
    );
  }
}


class DateRangePickerWidget extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final void Function(DateTime start, DateTime end) onApply;

  const DateRangePickerWidget({
    super.key,
    this.initialStart,
    this.initialEnd,
    required this.onApply,
  });

  @override
  State<DateRangePickerWidget> createState() => _DateRangePickerWidgetState();
}

class _DateRangePickerWidgetState extends State<DateRangePickerWidget> {
  DateTime? _start;
  DateTime? _end;
  late int _month;
  late int _year;

  final List<String> _monthNames = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end   = widget.initialEnd;
    final now = DateTime.now();
    _month = now.month;
    _year  = now.year;
  }

  void _onDayTap(DateTime tapped) {
    setState(() {
      if (_start == null || (_start != null && _end != null)) {
        _start = tapped;
        _end   = null;
      } else {
        if (tapped.isBefore(_start!)) {
          _end   = _start;
          _start = tapped;
        } else {
          _end = tapped;
        }
      }
    });
  }

  bool _inRange(DateTime day) {
    if (_start == null || _end == null) return false;
    return day.isAfter(_start!) && day.isBefore(_end!);
  }

  bool _isStart(DateTime day) =>
      _start != null &&
          day.year == _start!.year &&
          day.month == _start!.month &&
          day.day == _start!.day;

  bool _isEnd(DateTime day) =>
      _end != null &&
          day.year == _end!.year &&
          day.month == _end!.month &&
          day.day == _end!.day;

  String _formatDisplay(DateTime? dt) {
    if (dt == null) return '--/--/----';
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$m / $d / ${dt.year}';
  }

  List<DateTime?> _buildCalendarDays() {
    final firstDay    = DateTime(_year, _month, 1);
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final List<DateTime?> days = [];
    for (int i = 0; i < startWeekday; i++) days.add(null);
    for (int i = 1; i <= daysInMonth; i++) days.add(DateTime(_year, _month, i));
    while (days.length % 7 != 0) {
      final extra = days.length - startWeekday - daysInMonth + 1;
      days.add(DateTime(_year, _month + 1, extra));
    }
    return days;
  }

  void _prevMonth() => setState(() {
    if (_month == 1) { _month = 12; _year--; } else _month--;
  });

  void _nextMonth() => setState(() {
    if (_month == 12) { _month = 1; _year++; } else _month++;
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lang = context.watch<LocaleCubit>().state;
    final days = _buildCalendarDays();
    final yearList = List.generate(30, (i) => DateTime.now().year - 10 + i);
    final canApply = _start != null && _end != null;

    return Container(
      decoration: BoxDecoration(
          color: c.datePickerBg, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dateDisplay(context, AppStrings.get('start_date_display', lang), _start, lang),
              _dateDisplay(context, AppStrings.get('end_date_display', lang),   _end,   lang, alignRight: true),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
                color: c.surface, borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: _prevMonth,
                        child: Icon(Icons.chevron_left,
                            color: c.primaryText, size: 28)),
                    _styledDropdown<int>(
                      context: context,
                      value: _month,
                      items: List.generate(12, (i) => i + 1),
                      label: (v) => _monthNames[v - 1],
                      onChanged: (v) => setState(() => _month = v),
                    ),
                    const SizedBox(width: 8),
                    _styledDropdown<int>(
                      context: context,
                      value: _year,
                      items: yearList,
                      label: (v) => v.toString(),
                      onChanged: (v) => setState(() => _year = v),
                    ),
                    GestureDetector(
                        onTap: _nextMonth,
                        child: Icon(Icons.chevron_right,
                            color: c.primaryText, size: 28)),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                      .map((d) => SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(d,
                          style: GoogleFonts.arimo(
                              color: c.hintText, fontSize: 13)),
                    ),
                  ))
                      .toList(),
                ),

                const SizedBox(height: 8),

                GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1,
                  children: days.map((day) {
                    if (day == null) return const SizedBox();
                    final isCurrentMonth = day.month == _month;
                    final isS = _isStart(day);
                    final isE = _isEnd(day);
                    final isR = _inRange(day);
                    final isSelected = isS || isE;

                    return GestureDetector(
                      onTap: isCurrentMonth ? () => _onDayTap(day) : null,
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (context.isDark ? Colors.white : Colors.black)
                              : isR ? c.hintText : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            day.day.toString(),
                            style: GoogleFonts.arimo(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected
                                  ? (context.isDark ? Colors.black : Colors.white)
                                  : isCurrentMonth
                                  ? c.primaryText
                                  : c.offMonthText,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: canApply
                ? () {
              widget.onApply(_start!, _end!);
              Navigator.pop(context);
            }
                : null,
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: canApply
                    ? (context.isDark ? Colors.white : Colors.black)
                    : c.disabledBg,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  AppStrings.get('apply', lang),
                  style: GoogleFonts.arimo(
                    color: canApply
                        ? (context.isDark ? Colors.black : Colors.white)
                        : c.disabledText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateDisplay(BuildContext context, String label, DateTime? dt, String lang,
      {bool alignRight = false}) {
    final c = context.colors;
    return Column(
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.arimo(
                color: c.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: c.compactInput,
              borderRadius: BorderRadius.circular(4)),
          child: Text(
            _formatDisplay(dt),
            style: GoogleFonts.arimo(
                color: c.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _styledDropdown<T>({
    required BuildContext context,
    required T value,
    required List<T> items,
    required String Function(T) label,
    required void Function(T) onChanged,
  }) {
    final c = context.colors;
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
            border: Border.all(color: c.border),
            borderRadius: BorderRadius.circular(20)),
        child: DropdownButton<T>(
          value: value,
          dropdownColor: c.surface,
          icon: Icon(Icons.keyboard_arrow_down, color: c.primaryText, size: 20),
          style: GoogleFonts.arimo(color: c.primaryText, fontSize: 15),
          items: items
              .map((v) =>
              DropdownMenuItem<T>(value: v, child: Text(label(v))))
              .toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}


class WeightInputs extends StatefulWidget {
  final TextEditingController kgController;
  final TextEditingController lbsController;

  const WeightInputs({
    super.key,
    required this.kgController,
    required this.lbsController,
  });

  @override
  State<WeightInputs> createState() => _WeightInputsState();
}

class _WeightInputsState extends State<WeightInputs> {
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    widget.kgController.addListener(_onKgChanged);
    widget.lbsController.addListener(_onLbsChanged);
  }

  void _onKgChanged() {
    if (_isUpdating) return;
    final text = widget.kgController.text;
    if (text.isEmpty) { _setLbs(""); return; }
    final kg = double.tryParse(text);
    if (kg == null) return;
    _setLbs((kg * 2.20462).toStringAsFixed(1));
  }

  void _onLbsChanged() {
    if (_isUpdating) return;
    final text = widget.lbsController.text;
    if (text.isEmpty) { _setKg(""); return; }
    final lbs = double.tryParse(text);
    if (lbs == null) return;
    _setKg((lbs / 2.20462).toStringAsFixed(1));
  }

  void _setKg(String value) {
    _isUpdating = true;
    widget.kgController.text = value;
    widget.kgController.selection =
        TextSelection.fromPosition(TextPosition(offset: value.length));
    _isUpdating = false;
  }

  void _setLbs(String value) {
    _isUpdating = true;
    widget.lbsController.text = value;
    widget.lbsController.selection =
        TextSelection.fromPosition(TextPosition(offset: value.length));
    _isUpdating = false;
  }

  @override
  void dispose() {
    widget.kgController.removeListener(_onKgChanged);
    widget.lbsController.removeListener(_onLbsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lang = context.watch<LocaleCubit>().state;

    Widget field(TextEditingController ctrl, String hint) {
      return Container(
        width: 80,
        height: 30,
        decoration: BoxDecoration(
            color: c.compactInput, borderRadius: BorderRadius.circular(3)),
        child: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: c.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: c.hintText),
            border: InputBorder.none,
            isDense: true,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
          ),
          textAlignVertical: TextAlignVertical.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.get('weight', lang),
            style: GoogleFonts.arimo(color: c.primaryText, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            field(widget.kgController, AppStrings.get('kg', lang).toLowerCase()),
            const SizedBox(width: 6),
            Text(AppStrings.get('kg', lang),
                style: GoogleFonts.arimo(color: c.hintText, fontSize: 14)),
            const SizedBox(width: 16),
            field(widget.lbsController, AppStrings.get('lbs', lang).toLowerCase()),
            const SizedBox(width: 6),
            Text(AppStrings.get('lbs', lang),
                style: GoogleFonts.arimo(color: c.hintText, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}


class ReminderTile extends StatefulWidget {
  final ReminderEntry entry;

  const ReminderTile({super.key, required this.entry});

  @override
  State<ReminderTile> createState() => _ReminderTileState();
}

class _ReminderTileState extends State<ReminderTile> {
  late String _frequency;
  late bool _isRecurring;
  late List<TimeOfDay> _times;
  late DateTime _startDate;
  late DateTime? _endDate;
  late TextEditingController _nameCtrl;
  late TextEditingController _reminderNameCtrl;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _frequency        = widget.entry.frequency;
    _isRecurring      = widget.entry.schedule == 'Recurring';
    _times            = List.from(widget.entry.times);
    _startDate        = widget.entry.startDate;
    _endDate          = widget.entry.endDate;
    _nameCtrl         = TextEditingController(text: widget.entry.medicineName);
    _reminderNameCtrl = TextEditingController(text: widget.entry.reminderName ?? '');
    _notesCtrl        = TextEditingController(text: widget.entry.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _reminderNameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _iconAsset {
    switch (widget.entry.type) {
      case 'blood_pressure': return 'assets/icons/bloodPressure.png';
      case 'meds':           return 'assets/icons/capsule.png';
      case 'weight':         return 'assets/icons/weight.png';
      case 'glucose':        return 'assets/icons/diabetes.png';
      case 'symptom':        return 'assets/icons/healthcare.png';
      case 'food':           return 'assets/icons/cutlery.png';
      default:               return 'assets/icons/bell.png';
    }
  }

  String _scheduleLabel(String lang) {
    final timesStr = _times.map((t) => formatTimeLocalized(t, lang)).join(', ');
    final freq = _isRecurring
        ? translateFrequency(_frequency, lang)
        : AppStrings.get('once', lang);
    return '$freq - $timesStr';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Future<void> _pickTime(int index, StateSetter sheetSetState) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index],
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppColors.primary, surface: Color(0xFF2D2D2D)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      sheetSetState(() => _times[index] = picked);
      setState(() {});
    }
  }

  void _pickFrequency(StateSetter sheetSetState, String lang) {
    final c = context.colors;
    const optionCodes = ['Daily', 'Weekly', 'Every 2 days', 'Monthly'];
    final optionKeys  = ['daily', 'weekly', 'every_2_days', 'monthly'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: c.bottomSheet,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
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
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.get('frequency', lang),
                style: GoogleFonts.arimo(
                    color: c.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...List.generate(optionCodes.length, (i) {
              final code  = optionCodes[i];
              final label = AppStrings.get(optionKeys[i], lang);
              return GestureDetector(
                onTap: () {
                  sheetSetState(() => _frequency = code);
                  setState(() {});
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: _frequency == code
                        ? AppColors.primary.withOpacity(0.15)
                        : c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _frequency == code
                            ? AppColors.primary
                            : Colors.transparent),
                  ),
                  child: Center(
                    child: Text(label,
                        style: GoogleFonts.arimo(
                            color: _frequency == code
                                ? AppColors.primary
                                : c.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _openDateRange(StateSetter sheetSetState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16, right: 16, top: 16,
        ),
        child: DateRangePickerWidget(
          initialStart: _startDate,
          initialEnd: _endDate,
          onApply: (start, end) {
            sheetSetState(() { _startDate = start; _endDate = end; });
            setState(() {});
          },
        ),
      ),
    );
  }

  void _save() {
    final updated = ReminderEntry(
      type: widget.entry.type,
      medicineName: _nameCtrl.text.trim().isEmpty
          ? widget.entry.medicineName
          : _nameCtrl.text.trim(),
      reminderName: _reminderNameCtrl.text.trim().isEmpty
          ? null
          : _reminderNameCtrl.text.trim(),
      schedule: _isRecurring ? 'Recurring' : 'Once',
      frequency: _isRecurring ? _frequency : 'Once',
      times: List.from(_times),
      startDate: _startDate,
      endDate: _endDate,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: widget.entry.createdAt,
    );
    context.read<HealthCubit>().updateReminder(widget.entry, updated);
    Navigator.pop(context);
  }

  void _openEditSheet(String lang) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, sheetSetState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollCtrl) => Container(
            decoration: BoxDecoration(
              color: c.bottomSheet,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: c.subtleText,
                          borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Image.asset(_iconAsset, width: 20, height: 20),
                      const SizedBox(width: 8),
                      Text(AppStrings.get('edit_reminder', lang),
                          style: GoogleFonts.arimo(
                              color: c.primaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close, color: c.hintText, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Name field
                      Text(AppStrings.get('name', lang),
                          style: GoogleFonts.arimo(
                              color: c.hintText, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameCtrl,
                        onChanged: (_) => sheetSetState(() {}),
                        style:
                        GoogleFonts.arimo(color: c.primaryText, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: c.editFieldFill,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                            color: c.sectionBg,
                            borderRadius: BorderRadius.circular(14)),
                        child: Column(
                          children: [
                            // Recurring / Once toggle
                            Center(
                              child: Container(
                                height: 26,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    color: c.toggleBg,
                                    borderRadius: BorderRadius.circular(34)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _toggleOption(
                                      AppStrings.get('recurring', lang),
                                      _isRecurring,
                                          () => sheetSetState(
                                              () => _isRecurring = true),
                                      sheetSetState,
                                    ),
                                    _toggleOption(
                                      AppStrings.get('once', lang),
                                      !_isRecurring,
                                          () => sheetSetState(
                                              () => _isRecurring = false),
                                      sheetSetState,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _sheetInfoRow(
                              context: context,
                              label: AppStrings.get('schedule', lang),
                              value: _isRecurring
                                  ? translateFrequency(_frequency, lang)
                                  : AppStrings.get('once', lang),
                              onTap: _isRecurring
                                  ? () => _pickFrequency(sheetSetState, lang)
                                  : null,
                            ),
                            _divider(context),
                            ..._times.asMap().entries.map((e) {
                              final i = e.key;
                              final t = e.value;
                              return Column(children: [
                                _sheetInfoRow(
                                  context: context,
                                  label: i == 0
                                      ? AppStrings.get('times', lang)
                                      : '',
                                  value: formatTimeLocalized(t, lang),
                                  onTap: () => _pickTime(i, sheetSetState),
                                  trailing: i > 0
                                      ? GestureDetector(
                                      onTap: () => sheetSetState(
                                              () => _times.removeAt(i)),
                                      child: Icon(Icons.close,
                                          color: c.hintText, size: 16))
                                      : null,
                                ),
                                _divider(context),
                              ]);
                            }),
                            GestureDetector(
                              onTap: () => sheetSetState(() =>
                                  _times.add(const TimeOfDay(hour: 8, minute: 0))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Text(AppStrings.get('add_time', lang),
                                    style: GoogleFonts.arimo(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                            _divider(context),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _openDateRange(sheetSetState),
                              child: Column(children: [
                                _sheetInfoRow(
                                    context: context,
                                    label: AppStrings.get('start_date', lang),
                                    value: _formatDate(_startDate),
                                    onTap: null),
                                _divider(context),
                                _sheetInfoRow(
                                    context: context,
                                    label: AppStrings.get('end_date', lang),
                                    value: _endDate != null
                                        ? _formatDate(_endDate!)
                                        : AppStrings.get('never', lang),
                                    onTap: null),
                              ]),
                            ),
                            _divider(context),
                            _editableField(
                              context: context,
                              label: AppStrings.get('reminder_name', lang),
                              hint: AppStrings.get('eg_morning_meds', lang),
                              controller: _reminderNameCtrl,
                              optional: true,
                              optionalLabel: AppStrings.get('optional', lang),
                              sheetSetState: sheetSetState,
                            ),
                            _divider(context),
                            _editableField(
                              context: context,
                              label: AppStrings.get('notes', lang),
                              hint: AppStrings.get('eg_take_after_food', lang),
                              controller: _notesCtrl,
                              optional: true,
                              optionalLabel: AppStrings.get('optional', lang),
                              sheetSetState: sheetSetState,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      MainButton(
                        text: AppStrings.get('save', lang),
                        enabled: _nameCtrl.text.trim().isNotEmpty,
                        onTap: _save,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleOption(
      String label, bool active, VoidCallback onTap, StateSetter ss) {
    final c = context.colors;
    return GestureDetector(
      onTap: () { onTap(); setState(() {}); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: active ? c.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(33),
        ),
        child: Text(label,
            style: GoogleFonts.arimo(
                color: active
                    ? AppColors.primary
                    : c.primaryText.withOpacity(0.48),
                fontSize: 12,
                fontWeight: FontWeight.w400)),
      ),
    );
  }

  Widget _sheetInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            if (label.isNotEmpty)
              Text(label,
                  style: GoogleFonts.arimo(
                      color: c.primaryText.withOpacity(0.77),
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            const Spacer(),
            if (trailing != null) ...[trailing, const SizedBox(width: 6)],
            Text(value,
                style: GoogleFonts.arimo(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _editableField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    bool optional = false,
    String optionalLabel = 'optional',
    required StateSetter sheetSetState,
  }) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label,
                style: GoogleFonts.arimo(
                    color: c.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w400)),
            const Spacer(),
            if (optional)
              Text(optionalLabel,
                  style: GoogleFonts.arimo(color: c.hintText, fontSize: 14)),
          ]),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            onChanged: (_) => sheetSetState(() {}),
            style: GoogleFonts.arimo(color: c.primaryText, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.arimo(color: c.hintGrey, fontSize: 14),
              filled: true,
              fillColor: c.notesFill,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) =>
      Container(height: 0.5, color: context.colors.divider);

  void _confirmDelete(String lang) {
    final c = context.colors;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppStrings.get('delete_reminder', lang),
          style: GoogleFonts.arimo(
              color: c.primaryText, fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${AppStrings.get('delete_confirm', lang)} "${widget.entry.medicineName}"?',
          style: GoogleFonts.arimo(color: c.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get('cancel', lang),
                style: GoogleFonts.arimo(color: c.hintText)),
          ),
          TextButton(
            onPressed: () {
              context.read<HealthCubit>().deleteReminder(widget.entry);
              Navigator.pop(context);
            },
            child: Text(AppStrings.get('delete', lang),
                style: GoogleFonts.arimo(
                    color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lang = context.watch<LocaleCubit>().state;

    return Container(
      width: double.infinity,
      height: 84,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: c.reminderTileBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: c.subtleBorder),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(_iconAsset, width: 20, height: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    _nameCtrl.text.isNotEmpty
                        ? _nameCtrl.text
                        : widget.entry.medicineName,
                    style: GoogleFonts.arimo(
                        color: c.primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _scheduleLabel(lang),
                    style: GoogleFonts.arimo(
                        color: c.secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _confirmDelete(lang),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _openEditSheet(lang),
                  child: Icon(Icons.edit_outlined, color: c.hintText, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class GlucoseInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String unit) onUnitChanged;

  const GlucoseInput({
    super.key,
    required this.controller,
    required this.onUnitChanged,
  });

  @override
  State<GlucoseInput> createState() => _GlucoseInputState();
}

class _GlucoseInputState extends State<GlucoseInput> {
  String selectedUnit = 'mg/dl';

  void _switchUnit(String unit) {
    setState(() => selectedUnit = unit);
    widget.onUnitChanged(unit);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lang = context.watch<LocaleCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.get('glucose', lang),
            style: TextStyle(color: c.primaryText, fontSize: 16)),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 90,
              height: 40,
              decoration: BoxDecoration(
                  color: c.compactInput,
                  borderRadius: BorderRadius.circular(6)),
              child: TextField(
                controller: widget.controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: c.primaryText),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 40,
              decoration: BoxDecoration(
                  color: c.compactInput,
                  borderRadius: BorderRadius.circular(6)),
              child: Row(
                children: [
                  _unitButton(context, 'mg/dl'),
                  _unitButton(context, 'mmol'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _unitButton(BuildContext context, String unit) {
    final isSelected = selectedUnit == unit;
    return GestureDetector(
      onTap: () => _switchUnit(unit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? Colors.white : context.colors.secondaryText,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}


class LogDrawers extends StatefulWidget {
  final List<ReminderEntry> reminders;

  const LogDrawers({required this.reminders});

  @override
  State<LogDrawers> createState() => LogDrawersState();
}

class LogDrawersState extends State<LogDrawers> {
  bool _missedExpanded   = false;
  bool _upcomingExpanded = false;
  bool _resolvedExpanded = false;

  List<_LogInstance> _buildInstances(BuildContext context) {
    final cubit = context.read<HealthCubit>();
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final instances = <_LogInstance>[];

    for (final reminder in widget.reminders) {
      if (reminder.startDate.isAfter(now)) continue;
      if (reminder.endDate != null && reminder.endDate!.isBefore(today)) continue;

      for (int i = 0; i < reminder.times.length; i++) {
        final t   = reminder.times[i];
        final due = DateTime(today.year, today.month, today.day, t.hour, t.minute);

        final skipped  = cubit.isSkipped(reminder, i, today);
        final resolved = cubit.isResolved(reminder, i, today);

        final status = resolved
            ? 'resolved'
            : skipped
            ? 'skipped'
            : due.isBefore(now)
            ? 'missed'
            : 'upcoming';

        instances.add(
            _LogInstance(reminder: reminder, timeIndex: i, due: due, status: status));
      }
    }

    for (final appt in cubit.getAppointments()) {
      instances.add(_LogInstance(
        appointment: appt,
        due: appt.appointmentDateTime,
        status: appt.appointmentDateTime.isBefore(now) ? 'resolved' : 'upcoming',
      ));
    }

    instances.sort((a, b) => a.due.compareTo(b.due));
    return instances;
  }

  String _iconAsset(String type) {
    switch (type) {
      case 'blood_pressure': return 'assets/icons/bloodPressure.png';
      case 'meds':           return 'assets/icons/capsule.png';
      case 'weight':         return 'assets/icons/weight.png';
      case 'glucose':        return 'assets/icons/diabetes.png';
      default:               return 'assets/icons/bell.png';
    }
  }

  void _handleAddLog(BuildContext context, _LogInstance instance) {
    if (instance.reminder == null) return;
    final cubit = context.read<HealthCubit>();
    final today = DateTime.now();

    switch (instance.reminder!.type) {
      case 'blood_pressure':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => const BloodPressureScreen()));
        break;
      case 'meds':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => const MedicationLogScreen()));
        break;
      case 'weight':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => const WeightLogScreen()));
        break;
      case 'glucose':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => const GlucoseScreen()));
        break;
    }
    cubit.resolveReminderLog(instance.reminder!, instance.timeIndex!, today);
  }

  void _handleSkip(BuildContext context, _LogInstance instance) {
    if (instance.reminder == null) return;
    context.read<HealthCubit>().skipReminderLog(
        instance.reminder!, instance.timeIndex!, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final lang      = context.watch<LocaleCubit>().state;
    final instances = _buildInstances(context);

    final missed   = instances.where((i) => i.status == 'missed').toList();
    final upcoming = instances.where((i) => i.status == 'upcoming').toList();
    final resolved = instances
        .where((i) => i.status == 'resolved' || i.status == 'skipped')
        .toList();

    return Column(
      children: [
        _drawer(
          label: AppStrings.get('missed_logs', lang),
          count: missed.length,
          expanded: _missedExpanded,
          accentColor: Colors.redAccent,
          onTap: () => setState(() => _missedExpanded = !_missedExpanded),
          instances: missed,
          lang: lang,
        ),
        const SizedBox(height: 12),
        _drawer(
          label: AppStrings.get('upcoming_logs', lang),
          count: upcoming.length,
          expanded: _upcomingExpanded,
          accentColor: AppColors.primary,
          onTap: () => setState(() => _upcomingExpanded = !_upcomingExpanded),
          instances: upcoming,
          lang: lang,
        ),
        const SizedBox(height: 12),
        _drawer(
          label: AppStrings.get('resolved_logs', lang),
          count: resolved.length,
          expanded: _resolvedExpanded,
          accentColor: context.colors.hintText,
          onTap: () => setState(() => _resolvedExpanded = !_resolvedExpanded),
          instances: resolved,
          lang: lang,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _drawer({
    required String label,
    required int count,
    required bool expanded,
    required Color accentColor,
    required VoidCallback onTap,
    required List<_LogInstance> instances,
    required String lang,
  }) {
    final c = context.colors;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
                color: c.surface, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(Icons.keyboard_arrow_down,
                      color: accentColor, size: 22),
                ),
                const SizedBox(width: 10),
                Text(label,
                    style: GoogleFonts.arimo(
                        color: c.primaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                if (count > 0)
                  Text('$count',
                      style: GoogleFonts.arimo(color: accentColor)),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState:
          expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Column(
            children: instances
                .map((i) => _logTile(context, i, lang))
                .toList(),
          ),
          secondChild: const SizedBox(),
        ),
      ],
    );
  }

  Widget _logTile(BuildContext context, _LogInstance instance, String lang) {
    final c = context.colors;
    final isAppointment = instance.appointment != null;
    final isDone =
        instance.status == 'resolved' || instance.status == 'skipped';

    final title = isAppointment
        ? instance.appointment!.appointmentName
        : instance.reminder!.medicineName;

    final time = isAppointment
        ? TimeOfDay.fromDateTime(instance.appointment!.appointmentDateTime)
        : instance.reminder!.times[instance.timeIndex!];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: c.logTileBg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          isAppointment
              ? Icon(Icons.local_hospital, color: c.primaryText)
              : Image.asset(_iconAsset(instance.reminder!.type),
              width: 20, height: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.arimo(
                        color: isDone ? c.hintText : c.primaryText,
                        fontWeight: FontWeight.w600)),
                Text(formatTimeLocalized(time, lang),
                    style: GoogleFonts.arimo(color: c.hintText)),
              ],
            ),
          ),
          if (!isAppointment && !isDone) ...[
            GestureDetector(
              onTap: () => _handleSkip(context, instance),
              child: Icon(Icons.close, color: c.hintText),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _handleAddLog(context, instance),
              child: const Icon(Icons.add, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}

class _LogInstance {
  final ReminderEntry? reminder;
  final AppointmentEntry? appointment;
  final int? timeIndex;
  final DateTime due;
  final String status;

  const _LogInstance({
    this.reminder,
    this.appointment,
    this.timeIndex,
    required this.due,
    required this.status,
  });
}