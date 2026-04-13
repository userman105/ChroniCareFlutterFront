import 'package:chronic_care/login_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/components.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final TextEditingController field1 = TextEditingController();
  final TextEditingController field2 = TextEditingController();
  final TextEditingController field3 = TextEditingController();
  final TextEditingController field4 = TextEditingController();

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
                hintTop: "Full Name",
                centerPlaceholder: "Enter your name",
                controller: field1,
              ),

              const SizedBox(height: 14),

              RoundedInputBox(
                hintTop: "Email",
                centerPlaceholder: "Enter your email",
                controller: field2,
              ),

              const SizedBox(height: 14),

              RoundedInputBox(
                hintTop: "Password",
                centerPlaceholder: "••••••••",
                controller: field3,
                isPassword: true,
              ),

              const SizedBox(height: 14),

              RoundedInputBox(
                hintTop: "Repeat password",
                centerPlaceholder: "••••••••",
                controller: field4,
              ),

              SizedBox(height: h * 0.035),

              MainButton(
                text: "Sign up",
                onTap: () {
                  // TODO
                },
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Color(0xFFE4E4E4),
                      fontSize: 15,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => LoginScreen())),
                    child: const Text(
                      'Login',
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