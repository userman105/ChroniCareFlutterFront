import 'package:chronic_care/motivation_screen.dart';
import 'package:flutter/material.dart';
import 'widgets/components.dart';
import 'package:google_fonts/google_fonts.dart';

class ChooseYourCondition extends StatefulWidget {
  const ChooseYourCondition({super.key});

  @override
  State<ChooseYourCondition> createState() => _ChooseYourConditionState();
}

class _ChooseYourConditionState extends State<ChooseYourCondition> {

  int selectedCondition = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [

              const SizedBox(height: 20),

              Column(
                children: [
                  Text(
                    'Choose Your Condition',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.arimo(
                      color: const Color(0xFFE4E4E4),
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Select the condition you'd like to manage",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.arimo(
                      color: const Color(0xFFE4E4E4),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              ConditionButton(
                iconAsset: "assets/icons/diabetesIcon.png",
                title: "Diabetes",
                description: "Manage blood sugar levels",
                enabled: true,
                selected: selectedCondition == 0,
                onTap: () {
                  setState(() {
                    selectedCondition = 0;
                  });
                },
              ),

              const SizedBox(height: 20),

              ConditionButton(
                iconAsset: "assets/icons/asthma.png",
                title: "Asthma",
                description: "Track breathing and avoid triggers",
                enabled: true,
                selected: selectedCondition == 1,
                onTap: () {
                  setState(() {
                    selectedCondition = 1;
                  });
                },
              ),

              const SizedBox(height: 20),

              ConditionButton(
                iconAsset: "assets/icons/hypertensionIcon.png",
                title: "Hypertension",
                description: "Monitor blood pressure and heart health",
                enabled: true,
                selected: selectedCondition == 2,
                onTap: () {
                  setState(() {
                    selectedCondition = 2;
                  });
                },
              ),
            
              const SizedBox(height: 80,),

              MainButton(
                text: "Continue",
                enabled: selectedCondition != -1,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>MotivationScreen()));
                },
              )



            ],
          ),
        ),
      ),
    );
  }
}