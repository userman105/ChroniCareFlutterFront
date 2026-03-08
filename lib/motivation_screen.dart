import 'package:chronic_care/personalize_schedule.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/components.dart';

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Image.asset(
                "assets/logos/launcherIcon.png",
                height: 128,
                width: 128,
              ),

              const SizedBox(height: 16),

              Text(
                'We know that living with a chronic disease is uncomfortable',
                textAlign: TextAlign.center,
                style: GoogleFonts.arimo(
                  color: const Color(0xFF1E2939),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),

              const SizedBox(height: 20),

              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "But don't worry, ",
                      style: GoogleFonts.arimo(
                        color: const Color(0xFF364153),
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        height: 1.40,
                      ),
                    ),
                    TextSpan(
                      text: "we got you\n",
                      style: GoogleFonts.arimo(
                        color: const Color(0xFF364153),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.40,
                      ),
                    ),
                    TextSpan(
                      text:
                      "We help you live a happy life with diabetes",
                      style: GoogleFonts.arimo(
                        color: const Color(0xFF364153),
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        height: 1.40,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              ConditionButton(
                iconAsset: "assets/icons/eatRight.png",
                title: "Eat the right food",
                description: "",
                width: 380,
                height: 95,
                selected: false,
                enabled: true,
                onTap: () {},
              ),

              const SizedBox(height: 12),

              ConditionButton(
                iconAsset: "assets/icons/neverForgetMed.png",
                title: "Never forget your medicine",
                description: "",
                width: 380,
                height: 95,
                selected: false,
                enabled: true,
                onTap: () {},
              ),

              const SizedBox(height: 12),

              ConditionButton(
                iconAsset: "assets/icons/chart.png",
                title: "Follow up with routine tests",
                description: "",
                width: 380,
                height: 95,
                selected: false,
                enabled: true,
                onTap: () {},
              ),

              const SizedBox(height: 30,),

              MainButton(
                text: "Let's get started",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder:
                  (_)=>PersonalizeSchedule()));},
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}