import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/components.dart';
import 'today_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';
import 'reminder_screen.dart';

class MainContainer extends StatefulWidget {
  final List<HealthTile> tiles;

  const MainContainer({super.key, required this.tiles});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  void changePage(int index) {
    setState(() => currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness:     isDark ? Brightness.dark  : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [

              Container(
                width: 412,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: context.colors.divider, // adaptive
                    ),
                  ),
                ),
              ),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) =>
                      setState(() => currentIndex = index),
                  children: [
                    TodayScreen(tiles: widget.tiles),
                    InsightsScreen(tiles: widget.tiles),
                    const RemindersScreen(),
                    const ProfileScreen(),
                  ],
                ),
              ),

            ],
          ),
        ),

        bottomNavigationBar: BottomNavigationBarCustom(
          currentIndex: currentIndex,
          onTabSelected: (index) {
            setState(() => currentIndex = index);
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          onTileSelected: (selectedTile) {
            setState(() {
              final exists = widget.tiles.any((t) => t.labelKey == selectedTile.labelKey);

              if (!exists) {
                widget.tiles.add(HealthTile(
                  icon:     selectedTile.icon,
                  labelKey: selectedTile.labelKey, // Required parameter
                  selected: false,
                ));
              }
            });
          },
        ),
      ),
    );
  }
}