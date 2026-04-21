import 'package:chronic_care/choose_your_condition.dart';
import 'package:chronic_care/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cubit/auth_cubit.dart';
import 'widgets/components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => loading = true);
        }

        if (state is AuthSuccess) {
          setState(() => loading = false);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ChooseYourCondition(),
            ),
          );
        }

        if (state is AuthError) {
          setState(() => loading = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },

      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,

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
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  "Your daily health companion",
                  style: GoogleFonts.bonaNova(
                    fontSize: 15,
                    color: theme.textTheme.bodyMedium?.color,
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
                  text: loading ? "Logging in..." : "Login",
                  onTap: loading
                      ? null
                      : () {
                    final emailText = email.text.trim();
                    final passText = password.text.trim();

                    if (emailText.isEmpty || passText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Enter email and password"),
                        ),
                      );
                      return;
                    }

                    context.read<AuthCubit>().login(
                      emailText,
                      passText,
                    );
                  },
                ),

                SizedBox(height: h * 0.035),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account yet?",
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        " Sign up",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 15,
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
      ),
    );
  }
}