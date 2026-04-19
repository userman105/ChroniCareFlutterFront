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
import '../main_activity/blood_log/blood_log_screen.dart';
import '../main_activity/weight_log/weight_log_screen.dart';
import '../models/appointment_entry.dart';
import 'alarm_screen.dart';
///***
///
///list of components
///
/// RoundedInputBox
/// MainButton
/// ChronicLogo
/// conditionButton
/// TodayDateBar
/// HealthTile
/// TodayDateBar
/// BottomNavigationBar
/// addEventSlider
/// addEntryPopup
/// AddReminderPopup
/// BloodPressureInputs
/// DateRangePickerWidget
/// WeightInputs
/// ReminderTile
/// LogDrawers
///
///         ***///
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
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      textAlign: TextAlign.start,

      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),

      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: hintTop,
        labelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),

        hintText: centerPlaceholder,
        hintStyle: const TextStyle(
          color: Colors.white54,
        ),

        alignLabelWithHint: true,
        floatingLabelAlignment: FloatingLabelAlignment.start,

        filled: true,
        fillColor: const Color(0xFF2A2A2A),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 1.5,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
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
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 358,
        height: 56,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF05DF72)
              : const Color(0xFFD1D5DC),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 6,
              offset: Offset(0, 4),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 15,
              offset: Offset(0, 10),
              spreadRadius: -3,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.arimo(
            color: enabled
                ? Colors.white
                : const Color(0xFF6A7282),
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

  const ChronicLogo({
    super.key,
    this.logoHeight = 120,
  });

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
                    color: const Color(0xFF05DF72),
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
                    color: const Color(0xFF05DF72),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),

        Image.asset(
          "assets/logos/chronicareLogo.png",
          height: logoHeight,
        ),
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
    this.width = double.infinity,   // full width by default
    this.height = 125,              // previous default
    this.iconSize = 80,             // previous default
  });

  @override
  Widget build(BuildContext context) {
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

                color: selected ? const Color(0xFF383838) : Color(0xFF383838),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF05DF72)
                      : const Color(0xFF383838),
                  width: 2.75,
                ),
                boxShadow: [
                  const BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                    spreadRadius: -2,
                  ),
                  const BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                    spreadRadius: -1,
                  ),
                  if (selected)
                    const BoxShadow(
                      color: Color(0x6605DF72),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Row(
                children: [

                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: Center(
                      child: Image.asset(
                        iconAsset,
                        height: iconSize + 10, // slightly larger than box
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  /// Text
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.arimo(
                            color: const Color(0xFFFFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: GoogleFonts.arimo(
                            color: const Color(0xFFFFFFFF),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: selected
                        ? Container(
                      key: const ValueKey("check"),
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFF05DF72),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          "✓",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                        : const SizedBox.shrink(
                      key: ValueKey("empty"),
                    ),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.05 : 1.0, // Slightly bigger when selected
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 181,
          height: 80,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: selected ? Colors.green[400] : Color(0xFF383838),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
            shadows: [
              BoxShadow(
                color: selected
                    ? Colors.green.withOpacity(0.5)
                    : Colors.black.withOpacity(0.1), // Glow when selected
                blurRadius: selected ? 12 : 4,
                offset: const Offset(0, 2),
              )
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
                      image: AssetImage(iconAsset),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 37,
                top: 14.5,
                child: Text(
                  label,
                  style: GoogleFonts.arimo(
                    color: selected ? Colors.white : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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

  const TodayDateBar({
    super.key,
    required this.calendarIconAsset,
  });

  @override
  State<TodayDateBar> createState() => _TodayDateBarState();
}

class _TodayDateBarState extends State<TodayDateBar> {
  final ScrollController _scrollController = ScrollController();

  List<DateTime> get visibleDates {
    final today = DateTime.now();
    return List.generate(
      365,
          (i) => today.subtract(Duration(days: 364 - i)),
    );
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
        const Duration(milliseconds: 50),
            () => _scrollToSelected(picked),
      );
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
    final cubit = context.watch<HealthCubit>();
    final selectedDate = cubit.selectedDate;

    final dateText = DateFormat('MMM d, yyyy').format(selectedDate);

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 46,
          padding: const EdgeInsets.only(
            top: 8,
            left: 14,
            right: 22,
            bottom: 8,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF2D2D2D),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (isToday(selectedDate))
                    Text(
                      "Today",
                      style: GoogleFonts.arimo(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (isToday(selectedDate)) const SizedBox(width: 8),
                  Text(
                    dateText,
                    style: GoogleFonts.arimo(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _pickDate(selectedDate),
                child: Image.asset(
                  widget.calendarIconAsset,
                  width: 30,
                  height: 30,
                ),
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
                  behavior: HitTestBehavior.opaque;
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
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: 31,
                        height: 31,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? Colors.white : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.arimo(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: selected ? Colors.black : const Color(0xFFB4B4B4),
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

  bool isToday(DateTime selectedDate) {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('MMM d, yyyy').format(selectedDate);

    return Container(
      width: double.infinity,
      height: 46,
      padding: const EdgeInsets.only(
        top: 8,
        left: 14,
        right: 22,
        bottom: 8,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isToday(selectedDate))
                Text(
                  "Today",
                  style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (isToday(selectedDate)) const SizedBox(width: 8),
              Text(
                dateText,
                style: GoogleFonts.arimo(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onCalendarTap,
            child: Image.asset(
              calendarIconAsset,
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }
}

enum HealthMetricType {
  bloodPressure,
  glucose,
  weight,
  meds,
  symptoms,
  food,
  testLogs,
  unknown,
}

class HealthTile {
  final String icon;
  final String label;
  final HealthMetricType type;
  bool selected;

  HealthTile({
    required this.icon,
    required this.label,
    this.selected = false,
    HealthMetricType? type,
  }) : type = type ?? _inferType(label); // auto-detect if not provided

  static HealthMetricType _inferType(String label) {
    switch (label.toLowerCase()) {
      case 'blood pressure':
        return HealthMetricType.bloodPressure;
      case 'glucose':
        return HealthMetricType.glucose;
      case 'weight':
        return HealthMetricType.weight;
      case 'meds':
        return HealthMetricType.meds;
      case 'symptoms':
        return HealthMetricType.symptoms;
      case 'food':
        return HealthMetricType.food;
      case 'test logs':
        return HealthMetricType.testLogs;
      default:
        return HealthMetricType.unknown;
    }
  }
}
List<HealthTile> allTiles = [
  HealthTile(icon: 'assets/icons/bloodPressure.png', label: 'Blood Pressure',selected: false),
  HealthTile(icon: 'assets/icons/capsule.png', label: 'Meds',selected: false),
  HealthTile(icon: 'assets/icons/healthcare.png', label: 'Symptoms',selected: false),
  HealthTile(icon: 'assets/icons/cutlery.png', label: 'Food',selected: false),
  HealthTile(icon: 'assets/icons/weight.png', label: 'Weight',selected: false),
  HealthTile(icon: 'assets/icons/diabetes.png', label: 'Glucose',selected: false),
  HealthTile(icon: 'assets/icons/testImage.png', label: 'Test Logs',selected: false)
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
            color: selected ? Colors.green[400] : const Color(0xFF2D2D2D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: [
              BoxShadow(
                color: selected
                    ? Colors.green.withOpacity(0.5)
                    : Colors.black.withOpacity(0.1),
                blurRadius: selected ? 12 : 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Image.asset(
                iconAsset,
                width: 28,
                height: 28,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.arimo(
                    color: selected ? Colors.white : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
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

    Widget navItem(
        int index,
        String icon,
        String activeIcon,
        String label,
        ) {

      final bool isActive = currentIndex == index;

      return GestureDetector(
        onTap: () => onTabSelected(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.asset(
              isActive ? activeIcon : icon,
              width: 28,
              height: 28,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: GoogleFonts.arimo(
                color: isActive
                    ? const Color(0xFF05DF72)
                    : const Color(0xFF929292),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    Widget addButton() {
      return Transform.translate(
        offset: const Offset(9, 0),
        child: GestureDetector(
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
            width: 50,
            height: 50,
            decoration: const ShapeDecoration(
              color: Color(0xFF00C950),
              shape: OvalBorder(),
            ),
            child: const Center(
              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 80,
      color: const Color(0xFF2D2D2D),
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          navItem(0, 'assets/icons/today.png', 'assets/icons/today_active.png', 'Today'),
          navItem(1, 'assets/icons/insights.png', 'assets/icons/insights_active.png', 'Insights'),
          addButton(),
          navItem(2, 'assets/icons/reminders.png', 'assets/icons/reminders_active.png', 'Reminders'),
          navItem(3, 'assets/icons/profile.png', 'assets/icons/profile_active.png', 'Profile'),

        ],
      ),
    );
  }
}

class AddEntryPopup extends StatefulWidget {
  final List<HealthTile> currentTiles;

  const AddEntryPopup({
    super.key,
    required this.currentTiles,
  });

  static Future<HealthTile?> show(
      BuildContext context,
      List<HealthTile> currentTiles,
      ) {
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
    return Container(
      height: 420,
      decoration: const BoxDecoration(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    "assets/icons/close.png",
                    width: 22,
                    height: 22,
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  "Select Type",
                  style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// GRID
            Expanded(
              child: GridView.builder(
                itemCount: tiles.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3,
                ),
                  itemBuilder: (context, index) {
                    final tile = tiles[index];

                    return HighlightableGridTile(
                      iconAsset: tile.icon,
                      label: tile.label,
                      selected: selectedIndex == index,
                      onTap: () {

                        final selectedTile = tile;

                        Navigator.pop(context, selectedTile);

                        Future.microtask(() {
                          switch (tile.label) {
                            case "Blood Pressure":
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BloodPressureScreen(),
                                ),
                              );
                              break;

                            case "Meds":
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MedicationLogScreen(),
                                ),
                              );
                              break;

                            case "Symptoms":
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SymptomScreen(),
                                ),
                              );
                              break;

                            case "Food":
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FoodLogScreen(),
                                ),
                              );
                              break;

                            case "Weight":
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_)=>WeightLogScreen()));
                              break;

                            case "Glucose":
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_)=>GlucoseScreen()));
                              break;

                            case "Test Logs":
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_)=>LabTestLogScreen()));
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

  const AddReminderPopup({
    super.key,
    required this.currentTiles,
  });

  static Future<HealthTile?> show(
      BuildContext context,
      List<HealthTile> currentTiles,
      ) {
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
    const allowed = {'Blood Pressure', 'Meds', 'Weight', 'Glucose'};
    tiles = allTiles.where((t) => allowed.contains(t.label)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      decoration: const BoxDecoration(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    "assets/icons/close.png",
                    width: 22,
                    height: 22,
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  "Select Type",
                  style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// GRID
            Expanded(
              child: GridView.builder(
                itemCount: tiles.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3,
                ),
                itemBuilder: (context, index) {
                  final tile = tiles[index];

                  return HighlightableGridTile(
                    iconAsset: tile.icon,
                    label: tile.label,
                    selected: selectedIndex == index,
                    onTap: () {

                      final selectedTile = tile;

                      Navigator.pop(context, selectedTile);

                      Future.microtask(() {
                        switch (tile.label) {
                          case "Blood Pressure":
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BloodPressureReminderScreen(),
                              ),
                            );
                            break;

                          case "Meds":
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MedicationReminderScreen(),
                              ),
                            );
                            break;

                          case "Weight":
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_)=>WeightReminderScreen()));
                            break;

                          case "Glucose":
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_)=>GlucoseReminderScreen()));
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
              border: Border.all(color: Colors.white, width: 0.5),
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
                      Text(
                        title,
                        style: GoogleFonts.arimo(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        description,
                        style: GoogleFonts.arimo(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Image.asset(
                  "assets/icons/Chevronup.png",
                  width: 18,
                  height: 18,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
      decoration: const BoxDecoration(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(21),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            children: [

            /// Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Select what you want to do",
                    style: GoogleFonts.arimo(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    "assets/icons/close.png",
                    width: 22,
                    height: 22,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            optionTile(
              title: "Add a doctor appointment",
              description: "Set reminders to help you for your appointments",
              icon: "assets/icons/calendarEdit.png",
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AppointmentLogScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            optionTile(
              title: "Schedule a reminder",
              description:
              "Add medications and reminders for measurements, activities, symptoms and appointments.",
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
              title: "Add a one-time entry",
              description:
              "Document spontaneous medication intakes or other entries like measurements, activities or symptoms.",
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
              title: "Photograph medical tests",
              description:
              "Save medical information related to lab tests for feature insights.",
              icon: "assets/icons/calendarSlider.png",
              onTap: () {
                final testTile = HealthTile(
                  icon: 'assets/icons/testImage.png',
                  label: 'Test Logs',
                );

                onTileSelected(testTile);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LabTestLogScreen()),
                );
              },
            ),

          ],
        ),
      ),
    ));
  }
}
// AddEntryPopup.show(context, allTiles);

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          "Blood Pressure (systolic/diastolic)",
          style: GoogleFonts.arimo(
            color: Colors.white,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [

            Container(
              width: 68,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(3),
              ),
              child: TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                controller: systolicController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                ),
                textAlignVertical: TextAlignVertical.center,
              ),
            ),

            const SizedBox(width: 4),

            Text(
              "/",
              style: GoogleFonts.arimo(
                color: Colors.white,
                fontSize: 16,
              ),
            ),

            const SizedBox(width: 4),

            Container(
              width: 68,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(3),
              ),
              child: TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                controller: diastolicController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                ),
                textAlignVertical: TextAlignVertical.center,
              ),
            ),

            const SizedBox(width: 8),

            Text(
              "mmHg",
              style: GoogleFonts.arimo(
                color: Colors.white.withOpacity(0.4),
                fontSize: 16,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Text(
          "Heart Rate (optional)",
          style: GoogleFonts.arimo(
            color: Colors.white,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 6),

        Container(
          width: 79,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(3),
          ),
          child: TextField(
            controller: heartRateController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
            ),
            textAlignVertical: TextAlignVertical.center,
          ),
        ),
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
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
  }

  void _onDayTap(DateTime tapped) {
    setState(() {
      if (_start == null || (_start != null && _end != null)) {
        _start = tapped;
        _end = null;
      } else {
        if (tapped.isBefore(_start!)) {
          _end = _start;
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
    final firstDay = DateTime(_year, _month, 1);
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // Sun=0

    final List<DateTime?> days = [];
    for (int i = 0; i < startWeekday; i++) days.add(null);
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_year, _month, i));
    }

    while (days.length % 7 != 0) {
      final extra = days.length - startWeekday - daysInMonth + 1;
      days.add(DateTime(_year, _month + 1, extra));
    }
    return days;
  }

  void _prevMonth() {
    setState(() {
      if (_month == 1) { _month = 12; _year--; }
      else _month--;
    });
  }

  void _nextMonth() {
    setState(() {
      if (_month == 12) { _month = 1; _year++; }
      else _month++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildCalendarDays();
    final yearList = List.generate(30, (i) => DateTime.now().year - 10 + i);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dateDisplay("Start Date", _start),
              _dateDisplay("End Date", _end, alignRight: true),
            ],
          ),

          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _prevMonth,
                      child: const Icon(Icons.chevron_left,
                          color: Colors.white, size: 28),
                    ),

                    _styledDropdown<int>(
                      value: _month,
                      items: List.generate(12, (i) => i + 1),
                      label: (v) => _monthNames[v - 1],
                      onChanged: (v) => setState(() => _month = v),
                    ),

                    const SizedBox(width: 8),

                    // Year dropdown
                    _styledDropdown<int>(
                      value: _year,
                      items: yearList,
                      label: (v) => v.toString(),
                      onChanged: (v) => setState(() => _year = v),
                    ),

                    GestureDetector(
                      onTap: _nextMonth,
                      child: const Icon(Icons.chevron_right,
                          color: Colors.white, size: 28),
                    ),
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
                              color: Colors.white54,
                              fontSize: 13)),
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
                              ? Colors.white
                              : isR
                              ? const Color(0xFF606060)
                              : Colors.transparent,
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
                                  ? Colors.black
                                  : isCurrentMonth
                                  ? Colors.white
                                  : Colors.white24,
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
            onTap: () {
              if (_start != null && _end != null) {
                widget.onApply(_start!, _end!);
                Navigator.pop(context);
              }
            },
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: _start != null && _end != null
                    ? Colors.white
                    : const Color(0xFF474747),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  "Apply",
                  style: GoogleFonts.arimo(
                    color: _start != null && _end != null
                        ? Colors.black
                        : Colors.white54,
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

  Widget _dateDisplay(String label, DateTime? dt,
      {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.arimo(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _formatDisplay(dt),
            style: GoogleFonts.arimo(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _styledDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) label,
    required void Function(T) onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(20),
        ),
        child: DropdownButton<T>(
          value: value,
          dropdownColor: const Color(0xFF2D2D2D),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white, size: 20),
          style: GoogleFonts.arimo(color: Colors.white, fontSize: 15),
          items: items
              .map((v) => DropdownMenuItem<T>(
            value: v,
            child: Text(label(v)),
          ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
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
    if (text.isEmpty) {
      _setLbs("");
      return;
    }

    final kg = double.tryParse(text);
    if (kg == null) return;

    final lbs = kg * 2.20462;
    _setLbs(lbs.toStringAsFixed(1));
  }

  void _onLbsChanged() {
    if (_isUpdating) return;

    final text = widget.lbsController.text;
    if (text.isEmpty) {
      _setKg("");
      return;
    }

    final lbs = double.tryParse(text);
    if (lbs == null) return;

    final kg = lbs / 2.20462;
    _setKg(kg.toStringAsFixed(1));
  }

  void _setKg(String value) {
    _isUpdating = true;
    widget.kgController.text = value;
    widget.kgController.selection = TextSelection.fromPosition(
      TextPosition(offset: value.length),
    );
    _isUpdating = false;
  }

  void _setLbs(String value) {
    _isUpdating = true;
    widget.lbsController.text = value;
    widget.lbsController.selection = TextSelection.fromPosition(
      TextPosition(offset: value.length),
    );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          "Weight",
          style: GoogleFonts.arimo(
            color: Colors.white,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [

            Container(
              width: 80,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(3),
              ),
              child: TextField(
                controller: widget.kgController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "kg",
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                ),
                textAlignVertical: TextAlignVertical.center,
              ),
            ),

            const SizedBox(width: 6),

            Text(
              "KG",
              style: GoogleFonts.arimo(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),

            const SizedBox(width: 16),

            Container(
              width: 80,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(3),
              ),
              child: TextField(
                controller: widget.lbsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "lbs",
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                ),
                textAlignVertical: TextAlignVertical.center,
              ),
            ),

            const SizedBox(width: 6),

            Text(
              "LBS",
              style: GoogleFonts.arimo(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ReminderTile extends StatefulWidget {
  final ReminderEntry entry;

  const ReminderTile({
    super.key,
    required this.entry,
  });

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
    _frequency = widget.entry.frequency;
    _isRecurring = widget.entry.schedule == 'Recurring';
    _times = List.from(widget.entry.times);
    _startDate = widget.entry.startDate;
    _endDate = widget.entry.endDate;
    _nameCtrl = TextEditingController(text: widget.entry.medicineName);
    _reminderNameCtrl =
        TextEditingController(text: widget.entry.reminderName ?? '');
    _notesCtrl = TextEditingController(text: widget.entry.notes ?? '');
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

  String get _scheduleLabel {
    final times = _times.map((t) {
      final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
      final m = t.minute.toString().padLeft(2, '0');
      final p = t.period == DayPeriod.am ? 'am' : 'pm';
      return '$h:$m $p';
    }).join(', ');
    return '${_isRecurring ? _frequency : 'Once'} - $times';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  Future<void> _pickTime(int index, StateSetter sheetSetState) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index],
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
    if (picked != null) {
      sheetSetState(() => _times[index] = picked);
      setState(() {});
    }
  }

  void _pickFrequency(StateSetter sheetSetState) {
    final options = ['Daily', 'Weekly', 'Every 2 days', 'Monthly'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Frequency',
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...options.map((o) => GestureDetector(
              onTap: () {
                sheetSetState(() => _frequency = o);
                setState(() {});
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _frequency == o
                      ? const Color(0xFF00C950).withOpacity(0.15)
                      : const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _frequency == o
                          ? const Color(0xFF00C950)
                          : Colors.transparent),
                ),
                child: Center(
                  child: Text(o,
                      style: GoogleFonts.arimo(
                          color: _frequency == o
                              ? const Color(0xFF00C950)
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            )),
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

  void _openEditSheet() {
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
            decoration: const BoxDecoration(
              color: Color(0xFF212121),
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              children: [

                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Image.asset(_iconAsset, width: 20, height: 20),
                      const SizedBox(width: 8),
                      Text('Edit Reminder',
                          style: GoogleFonts.arimo(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close,
                            color: Colors.white54, size: 20),
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
                      Text('Name',
                          style: GoogleFonts.arimo(
                              color: Colors.white54, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameCtrl,
                        onChanged: (_) => sheetSetState(() {}),
                        style: GoogleFonts.arimo(
                            color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF4F4F4F),
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
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [

                            // Recurring / Once toggle
                            Center(
                              child: Container(
                                height: 26,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F0F0F),
                                  borderRadius: BorderRadius.circular(34),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _toggleOption('Recurring', _isRecurring,
                                            () => sheetSetState(
                                                () => _isRecurring = true),
                                        sheetSetState),
                                    _toggleOption('Once', !_isRecurring,
                                            () => sheetSetState(
                                                () => _isRecurring = false),
                                        sheetSetState),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Schedule row
                            _sheetInfoRow(
                              label: 'Schedule',
                              value: _isRecurring ? _frequency : 'Once',
                              onTap: _isRecurring
                                  ? () => _pickFrequency(sheetSetState)
                                  : null,
                            ),
                            _divider(),

                            // Times
                            ..._times.asMap().entries.map((e) {
                              final i = e.key;
                              final t = e.value;
                              return Column(children: [
                                _sheetInfoRow(
                                  label: i == 0 ? 'Times' : '',
                                  value: _formatTime(t),
                                  onTap: () =>
                                      _pickTime(i, sheetSetState),
                                  trailing: i > 0
                                      ? GestureDetector(
                                      onTap: () => sheetSetState(
                                              () => _times.removeAt(i)),
                                      child: const Icon(Icons.close,
                                          color: Colors.white38,
                                          size: 16))
                                      : null,
                                ),
                                _divider(),
                              ]);
                            }),

                            // Add time
                            GestureDetector(
                              onTap: () => sheetSetState(() => _times
                                  .add(const TimeOfDay(hour: 8, minute: 0))),
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 6),
                                child: Text('+ Add time',
                                    style: GoogleFonts.arimo(
                                        color: const Color(0xFF00C950),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),

                            _divider(),

                            // Start & End date
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _openDateRange(sheetSetState),
                              child: Column(children: [
                                _sheetInfoRow(
                                    label: 'Start date',
                                    value: _formatDate(_startDate),
                                    onTap: null),
                                _divider(),
                                _sheetInfoRow(
                                    label: 'End date',
                                    value: _endDate != null
                                        ? _formatDate(_endDate!)
                                        : 'Never',
                                    onTap: null),
                              ]),
                            ),

                            _divider(),

                            // Reminder name
                            _editableField(
                              label: 'Reminder name',
                              hint: 'eg. Morning meds',
                              controller: _reminderNameCtrl,
                              optional: true,
                              sheetSetState: sheetSetState,
                            ),

                            _divider(),

                            // Notes
                            _editableField(
                              label: 'Notes',
                              hint: 'eg. take after food',
                              controller: _notesCtrl,
                              optional: true,
                              sheetSetState: sheetSetState,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      MainButton(
                        text: 'Save',
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
    return GestureDetector(
      onTap: () { onTap(); setState(() {}); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF5A5A5A) : Colors.transparent,
          borderRadius: BorderRadius.circular(33),
        ),
        child: Text(label,
            style: GoogleFonts.arimo(
                color: active
                    ? const Color(0xFF00C950)
                    : Colors.white.withOpacity(0.48),
                fontSize: 12,
                fontWeight: FontWeight.w400)),
      ),
    );
  }

  Widget _sheetInfoRow({
    required String label,
    required String value,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
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
                      color: Colors.white.withOpacity(0.77),
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            const Spacer(),
            if (trailing != null) ...[trailing, const SizedBox(width: 6)],
            Text(value,
                style: GoogleFonts.arimo(
                    color: const Color(0xFF00C950),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _editableField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool optional = false,
    required StateSetter sheetSetState,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label,
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400)),
            const Spacer(),
            if (optional)
              Text('optional',
                  style: GoogleFonts.arimo(
                      color: Colors.white.withOpacity(0.49), fontSize: 14)),
          ]),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            onChanged: (_) => sheetSetState(() {}),
            style: GoogleFonts.arimo(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.arimo(
                  color: const Color(0xFFB4B4B4), fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF0C0C0C),
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

  Widget _divider() =>
      Container(height: 0.5, color: Colors.white12);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 84,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFF444444),
        shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 1, color: Colors.white.withOpacity(0.10)),
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
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _scheduleLabel,
                    style: GoogleFonts.arimo(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                // Delete
                GestureDetector(
                  onTap: _confirmDelete,
                  child: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                ),
                const SizedBox(width: 10),
                // Edit
                GestureDetector(
                  onTap: _openEditSheet,
                  child: const Icon(Icons.edit_outlined,
                      color: Colors.white54, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Reminder',
          style: GoogleFonts.arimo(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.entry.medicineName}"?',
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
              context.read<HealthCubit>().deleteReminder(widget.entry);
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: GoogleFonts.arimo(
                    color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
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
    setState(() {
      selectedUnit = unit;
    });
    widget.onUnitChanged(unit);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          'Glucose',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [

            Container(
              width: 90,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextField(
                controller: widget.controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
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
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [

                  _unitButton('mg/dl'),
                  _unitButton('mmol'),

                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _unitButton(String unit) {
    final isSelected = selectedUnit == unit;

    return GestureDetector(
      onTap: () => _switchUnit(unit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00C950)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
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
  bool _missedExpanded = false;
  bool _upcomingExpanded = false;
  bool _resolvedExpanded = false;

  List<_LogInstance> _buildInstances(BuildContext context) {
    final cubit = context.read<HealthCubit>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final instances = <_LogInstance>[];

    for (final reminder in widget.reminders) {
      if (reminder.startDate.isAfter(now)) continue;
      if (reminder.endDate != null &&
          reminder.endDate!.isBefore(today)) continue;

      for (int i = 0; i < reminder.times.length; i++) {
        final t = reminder.times[i];
        final due = DateTime(today.year, today.month, today.day, t.hour, t.minute);

        final skipped = cubit.isSkipped(reminder, i, today);
        final resolved = cubit.isResolved(reminder, i, today);

        String status;
        if (resolved) {
          status = 'resolved';
        } else if (skipped) {
          status = 'skipped';
        } else if (due.isBefore(now)) {
          status = 'missed';
        } else {
          status = 'upcoming';
        }

        instances.add(_LogInstance(
          reminder: reminder,
          timeIndex: i,
          due: due,
          status: status,
        ));
      }
    }

    final appointments = cubit.getAppointments();

    for (final appt in appointments) {
      final due = appt.appointmentDateTime;

      instances.add(_LogInstance(
        appointment: appt,
        due: due,
        status: due.isBefore(now) ? 'resolved' : 'upcoming',
      ));
    }

    instances.sort((a, b) => a.due.compareTo(b.due));
    return instances;
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  String _iconAsset(String type) {
    switch (type) {
      case 'blood_pressure': return 'assets/icons/bloodPressure.png';
      case 'meds': return 'assets/icons/capsule.png';
      case 'weight': return 'assets/icons/weight.png';
      case 'glucose': return 'assets/icons/diabetes.png';
      default: return 'assets/icons/bell.png';
    }
  }

  void _handleAddLog(BuildContext context, _LogInstance instance) {
    if (instance.reminder == null) return;

    final cubit = context.read<HealthCubit>();
    final today = DateTime.now();

    switch (instance.reminder!.type) {
      case 'blood_pressure':
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const BloodPressureScreen(),
        ));
        break;
      case 'meds':
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const MedicationLogScreen(),
        ));
        break;
      case 'weight':
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const WeightLogScreen(),
        ));
        break;
      case 'glucose':
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const GlucoseScreen(),
        ));
        break;
    }

    cubit.resolveReminderLog(
        instance.reminder!, instance.timeIndex!, today);
  }

  void _handleSkip(BuildContext context, _LogInstance instance) {
    if (instance.reminder == null) return;

    final today = DateTime.now();

    context.read<HealthCubit>().skipReminderLog(
        instance.reminder!, instance.timeIndex!, today);
  }

  @override
  Widget build(BuildContext context) {
    final instances = _buildInstances(context);

    final missed = instances.where((i) => i.status == 'missed').toList();
    final upcoming = instances.where((i) => i.status == 'upcoming').toList();
    final resolved = instances
        .where((i) => i.status == 'resolved' || i.status == 'skipped')
        .toList();

    return Column(
      children: [
        _drawer(
          label: 'Missed logs',
          count: missed.length,
          expanded: _missedExpanded,
          accentColor: Colors.redAccent,
          onTap: () => setState(() => _missedExpanded = !_missedExpanded),
          instances: missed,
          context: context,
        ),

        const SizedBox(height: 12),

        _drawer(
          label: 'Upcoming logs',
          count: upcoming.length,
          expanded: _upcomingExpanded,
          accentColor: const Color(0xFF00C950),
          onTap: () => setState(() => _upcomingExpanded = !_upcomingExpanded),
          instances: upcoming,
          context: context,
        ),

        const SizedBox(height: 12),

        _drawer(
          label: 'Resolved logs',
          count: resolved.length,
          expanded: _resolvedExpanded,
          accentColor: Colors.white38,
          onTap: () => setState(() => _resolvedExpanded = !_resolvedExpanded),
          instances: resolved,
          context: context,
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
    required BuildContext context,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(12),
            ),
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
                        color: Colors.white,
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
            children: instances.map((i) => _logTile(context, i)).toList(),
          ),
          secondChild: const SizedBox(),
        ),
      ],
    );
  }

  Widget _logTile(BuildContext context, _LogInstance instance) {
    final isAppointment = instance.appointment != null;
    final isResolved = instance.status == 'resolved';
    final isSkipped = instance.status == 'skipped';
    final isDone = isResolved || isSkipped;

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
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          isAppointment
              ? const Icon(Icons.local_hospital, color: Colors.white)
              : Image.asset(_iconAsset(instance.reminder!.type),
              width: 20, height: 20),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.arimo(
                      color: isDone ? Colors.white38 : Colors.white,
                      fontWeight: FontWeight.w600,
                    )),
                Text(_formatTime(time),
                    style: GoogleFonts.arimo(color: Colors.white38)),
              ],
            ),
          ),

          if (!isAppointment && !isDone) ...[
            GestureDetector(
              onTap: () => _handleSkip(context, instance),
              child: const Icon(Icons.close, color: Colors.white38),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _handleAddLog(context, instance),
              child: const Icon(Icons.add, color: Color(0xFF00C950)),
            ),
          ]
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