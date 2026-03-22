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
    setState(() {
      currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),

      child: Scaffold(
        backgroundColor: const Color(0xFF111111),

        body: SafeArea(
          child: Column(
            children: [

              TodayDateBar(
                calendarIconAsset: 'assets/icons/calendar.png',
              ),

              const SizedBox(height: 10),

              Container(
                width: 412,
                decoration: const ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ),
              ),


              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [

                    TodayScreen(tiles: widget.tiles),
                    const InsightsScreen(),
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
            setState(() {
              currentIndex = index;
            });

            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          onTileSelected: (selectedTile) {
            setState(() {

              final exists = widget.tiles.any(
                    (t) => t.label == selectedTile.label,
              );

              if (!exists) {
                widget.tiles.add(
                  HealthTile(
                    icon: selectedTile.icon,
                    label: selectedTile.label,
                    selected: false,
                  ),
                );
              }

            });
          },
        ),
      ),
    );
  }
}