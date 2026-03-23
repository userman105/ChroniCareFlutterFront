import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../cubit/health_cubit.dart';
import '../main_activity/blood_log/blood_log_screen.dart';
import '../main_activity/today_screen.dart';
import '../main_activity/weight_log/weight_log_screen.dart';
///***
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
/// addEntrySlider
/// addEntryPopup
/// BloodPressureInputs
/// DateRangePickerWidget
/// WeightInputs
///
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
      decoration: InputDecoration(
        labelText: hintTop,
        labelStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 14,
        ),
        hintText: centerPlaceholder,
        hintStyle: const TextStyle(
          color: Color(0xFF4A5565),
        ),

        alignLabelWithHint: true,
        floatingLabelAlignment: FloatingLabelAlignment.start,

        filled: true,
        fillColor: Colors.transparent,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFFFFFFFF),
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFFFFFFFF),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFFFFFFFF),
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
                            // TODO
                              break;

                            case "Symptoms":
                            // TODO
                              break;

                            case "Food":
                            // TODO
                              break;

                            case "Weight":
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_)=>WeightLogScreen()));
                              break;

                            case "Glucose":
                            // TODO
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
      height: 380,
      decoration: const BoxDecoration(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(21),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                //TODO
              },
            ),

            const SizedBox(height: 12),

            optionTile(
              title: "Schedule a reminder",
              description:
              "Add medications and reminders for measurements, activities, symptoms and appointments.",
              icon: "assets/icons/bellCalendar.png",
              onTap: (){
                //TODO
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
          ],
        ),
      ),
    );
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
              height: 27,
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 7),
                ),
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
              height: 27,
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 7),
                ),
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
          height: 27,
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
              contentPadding: EdgeInsets.symmetric(horizontal: 7),
            ),
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
              height: 27,
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 7),
                ),
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
              height: 27,
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 7),
                ),
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