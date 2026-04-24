import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/components.dart';
import 'main_activity/main_container.dart';
import 'cubit/health_cubit.dart';
import 'core/lang/lang_strings.dart';
import 'cubit/locale_cubit.dart';

class PersonalizeSchedule extends StatefulWidget {
  const PersonalizeSchedule({super.key});

  @override
  State<PersonalizeSchedule> createState() => _PersonalizeScheduleState();
}

class _PersonalizeScheduleState extends State<PersonalizeSchedule> {
  final Set<int> selectedIndexes = {};

  final List<Map<String, String>> buttons = [
    {'icon': 'assets/icons/bloodPressure.png', 'key': 'blood_pressure'},
    {'icon': 'assets/icons/capsule.png',       'key': 'meds'},
    {'icon': 'assets/icons/healthcare.png',    'key': 'symptoms'},
    {'icon': 'assets/icons/cutlery.png',       'key': 'food'},
    {'icon': 'assets/icons/weight.png',        'key': 'weight'},
    {'icon': 'assets/icons/diabetes.png',      'key': 'glucose'},
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasTiles = context.read<HealthCubit>().hasTiles();

      if (hasTiles) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainContainer()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleCubit>().state;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [

              SizedBox(
                width: 352,
                child: Text(
                  AppStrings.get('personalize_title', lang),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.arimo(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// GRID
              Container(
                width: 412,
                height: 282,
                padding: const EdgeInsets.all(8),
                decoration: ShapeDecoration(
                  color: const Color(0xFF272727),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GridView.builder(
                      itemCount: buttons.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 181 / 52,
                      ),
                      itemBuilder: (context, index) {
                        final button = buttons[index];

                        return ConditionGridButton(
                          iconAsset: button['icon']!,
                          label: AppStrings.get(button['key']!, lang),
                          selected: selectedIndexes.contains(index),
                          onTap: () {
                            setState(() {
                              if (selectedIndexes.contains(index)) {
                                selectedIndexes.remove(index);
                              } else {
                                selectedIndexes.add(index);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              MainButton(
                text: AppStrings.get('proceed', lang),
                enabled: selectedIndexes.isNotEmpty,
                onTap: () {
                  final cubit = context.read<HealthCubit>();

                  for (final i in selectedIndexes) {
                    cubit.addTile(buttons[i]['key']!);
                  }
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainContainer(),
                    ),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}