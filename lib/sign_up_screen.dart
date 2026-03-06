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
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Column(
            children: [

              const SizedBox(height: 20),

              ChronicLogo(),

              const SizedBox(height: 40),

              /// Title
              Text(
                "Welcome to ChroniCare",
                style: GoogleFonts.bonaNova(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),


              Text(
                "Your daily health companion",
                style: GoogleFonts.bonaNova(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),


              RoundedInputBox(
                hintTop: "Full Name",
                centerPlaceholder: "Enter your name",
                controller: field1,
              ),

              const SizedBox(height: 18),

              RoundedInputBox(
                hintTop: "Email",
                centerPlaceholder: "Enter your email",
                controller: field2,
              ),

              const SizedBox(height: 18),

              RoundedInputBox(
                hintTop: "Password",
                centerPlaceholder: "••••••••",
                controller: field3,
                isPassword: true,
              ),

              const SizedBox(height: 18),

              RoundedInputBox(
                hintTop: "Repeat password",
                centerPlaceholder: "••••••••",
                controller: field4,
              ),

            const SizedBox(height: 35,),
              MainButton(
               text: "Sign up",
               onTap: (){//TODO
                 },
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: const Color(0xFF4A5565),
                      fontSize: 16,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_)=>LoginScreen()));
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: const Color(0xFF2B7FFF),
                        fontSize: 16,
                        fontFamily: 'Arimo',
                        fontWeight: FontWeight.w700,
                        height: 1.50,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}