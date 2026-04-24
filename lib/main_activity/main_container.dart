import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/health_cubit.dart';
import '../widgets/components.dart';
import 'today_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';
import 'reminder_screen.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
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
                      color: context.colors.divider,
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
                  children: const [
                    TodayScreen(),
                    InsightsScreen(),
                    RemindersScreen(),
                    ProfileScreen(),
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
            context
                .read<HealthCubit>()
                .addTile(selectedTile.labelKey);
          },
        ),
      ),
    );
  }
}