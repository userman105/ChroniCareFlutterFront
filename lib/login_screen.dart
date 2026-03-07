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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Column(
              children: [

              const SizedBox(height: 20),

              ChronicLogo(),

              const SizedBox(height: 40),

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
                  hintTop: "Email",
                  centerPlaceholder: "Enter your email",
                  controller: email,
                ),

                const SizedBox(height: 18),

                RoundedInputBox(
                  hintTop: "Password",
                  centerPlaceholder: "Enter your password",
                  controller: password,
                ),

                const SizedBox(height: 35),
                
                MainButton(text: "Login",
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>ChooseYourCondition()));
                   },),

                const SizedBox(height: 35),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account yet?",
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
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>SignUpScreen()));
                      },
                      child: Text(
                        'Sign up',
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
              
            ]),
      )

     ),
      
    );
  }
}
