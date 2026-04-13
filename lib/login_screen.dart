import 'package:chronic_care/choose_your_condition.dart';
import 'package:chronic_care/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/components.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Column(
            children: [

              SizedBox(height: h * 0.025),

              const ChronicLogo(),

              SizedBox(height: h * 0.04),

              Text(
                "Welcome to ChroniCare",
                style: GoogleFonts.bonaNova(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFE4E4E4),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                "Your daily health companion",
                style: GoogleFonts.bonaNova(
                  fontSize: 15,
                  color: const Color(0xFFE4E4E4),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: h * 0.04),

              RoundedInputBox(
                hintTop: "Email",
                centerPlaceholder: "Enter your email",
                controller: email,
              ),

              const SizedBox(height: 14),

              RoundedInputBox(
                hintTop: "Password",
                centerPlaceholder: "Enter your password",
                controller: password,
              ),

              SizedBox(height: h * 0.035),

              MainButton(
                text: "Login",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChooseYourCondition()),
                  );
                },
              ),

              SizedBox(height: h * 0.035),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account yet?",
                    style: TextStyle(
                      color: Color(0xFFE4E4E4),
                      fontSize: 15,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SignUpScreen())),
                    child: const Text(
                      ' Sign up',
                      style: TextStyle(
                        color: Color(0xFF2B7FFF),
                        fontSize: 15,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: h * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}