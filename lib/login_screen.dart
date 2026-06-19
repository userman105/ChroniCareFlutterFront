import 'package:chronic_care/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cubit/auth_cubit.dart';
import 'forgot_password_screen.dart';
import 'main.dart';
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
  bool authLocked = false;
  bool loginLoading = false;
  @override
  void initState() {
    super.initState();

    if (AppConfig.guestMode) {
      email.text = 'guest';
      password.text = 'guest';

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        context.read<AuthCubit>().login(
          email.text,
          password.text,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => loading = true);
        } else if (state is AuthNeedsVerification) {
          setState(() => loading = false);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => BlocProvider.value(
              value: context.read<AuthCubit>(),
              child: OtpDialog(
                email: state.email,
                password: password.text.trim(),
              ),
            ),
          );
        } else if (state is AuthSuccess) {
          setState(() => loading = false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RootDecider()),
          );
        } else if (state is AuthError) {
          setState(() {
            loginLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 2),
            ),
          );
          _lockAfterFailure();
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
                  isPassword: true,
                ),
                SizedBox(height: h * 0.035),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {

                    final loading = state is AuthLoading || loginLoading;


                    return MainButton(

                      text: loading
                          ? "Logging in..."
                          : authLocked
                          ? "Try again in 3s"
                          : "Login",


                      enabled: !loading,


                      onTap: () {

                        final emailText =
                        email.text.trim();

                        final passText =
                        password.text.trim();



                        setState(() {
                          loginLoading = true;
                        });


                        context.read<AuthCubit>().login(
                          emailText,
                          passText,
                        );

                      },

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
                      onTap: authLocked
                          ? null
                          : () {
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
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: authLocked
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot your password?",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _lockAfterFailure() async {

    if(authLocked) return;


    setState(() {
      authLocked = true;
    });


    await Future.delayed(
      const Duration(seconds: 3),
    );


    if(!mounted) return;


    setState(() {
      authLocked = false;
    });

  }
}