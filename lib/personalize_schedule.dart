import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/components.dart';
import 'main_activity/today_screen.dart';
import 'main_activity/main_container.dart';

class PersonalizeSchedule extends StatefulWidget {
  const PersonalizeSchedule({super.key});

  @override
  State<PersonalizeSchedule> createState() => _PersonalizeScheduleState();
}

class _PersonalizeScheduleState extends State<PersonalizeSchedule> {
  final Set<int> selectedIndexes = {};

  final List<Map<String, String>> buttons = [
    {'icon': 'assets/icons/bloodPressure.png', 'label': 'Blood Pressure'},
    {'icon': 'assets/icons/capsule.png', 'label': 'Meds'},
    {'icon': 'assets/icons/healthcare.png', 'label': 'Symptoms'},
    {'icon': 'assets/icons/cutlery.png', 'label': 'Food'},
    {'icon': 'assets/icons/weight.png', 'label': 'Weight'},
    {'icon': 'assets/icons/diabetes.png', 'label': 'Glucose'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              SizedBox(
                width: 352,
                child: Text(
                  'Select what you want us to help you with',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.arimo(
                    color: Color(0xFFFFFFFF),
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 40),

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
                  mainAxisAlignment: MainAxisAlignment.center, // <-- centers the grid vertically
                  children: [
                    GridView.builder(
                      itemCount: buttons.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true, // <-- important! makes GridView take only needed height
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 181 / 52,
                      ),
                      itemBuilder: (context, index) {
                        final button = buttons[index];
                        return ConditionGridButton(
                          iconAsset: button['icon']!,
                          label: button['label']!,
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
                text: "Proceed",
                enabled: selectedIndexes.isNotEmpty,
                onTap: () {


                  final selectedTiles =
                  selectedIndexes.map((i) => allTiles[i]).toList();

                  Navigator.pop(context, selectedTiles);
                  if (selectedIndexes.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>
                    MainContainer(tiles: selectedTiles))
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}