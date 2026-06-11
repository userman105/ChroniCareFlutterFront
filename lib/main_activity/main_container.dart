import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/lang/lang_strings.dart';
import '../cubit/health_cubit.dart';
import '../cubit/locale_cubit.dart';
import '../services/connectivity_service.dart';
import '../widgets/components.dart';
import 'today_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';
import 'reminder_screen.dart';
import '../services/sync_service.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  @override
  void initState() {
    super.initState();
    ConnectivityService().startPolling();
  }

  @override
  void dispose() {
    ConnectivityService().stopPolling();
    super.dispose();
  }

  Future<bool> _onWillPop(String lang) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get('exit_title', lang)),
        content: Text(AppStrings.get('exit_message', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppStrings.get('cancel', lang)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              AppStrings.get('exit_confirm', lang),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final lang = context.watch<LocaleCubit>().state;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onWillPop(lang);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: context.colors.divider,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      StreamBuilder<SyncStatus>(
                        stream: SyncService().syncStatus,
                        builder: (ctx, snap) {
                          final status = snap.data ?? SyncStatus.idle;
                          switch (status) {
                            case SyncStatus.pendingItems:
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cloud_upload, size: 16, color: Colors.orange),
                                    SizedBox(width: 4),
                                    Text('Pending Sync'),
                                  ],
                                ),
                              );
                            case SyncStatus.syncing:
                              return const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            default:
                              return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
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
              context.read<HealthCubit>().addTile(selectedTile.labelKey);
            },
          ),
        ),
      ),
    );
  }
}