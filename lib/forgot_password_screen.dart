import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cubit/auth_cubit.dart';
import 'widgets/components.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailCtrl = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => loading = true);
        } else if (state is PasswordResetOtpSent) {
          setState(() => loading = false);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => BlocProvider.value(
              value: context.read<AuthCubit>(),
              child: ResetPasswordOtpDialog(email: state.email),
            ),
          );
        } else if (state is AuthError) {
          setState(() => loading = false);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is PasswordResetSuccess) {
          setState(() => loading = false);
          // Close OTP dialog + this screen, return to login
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset successfully. Please log in.')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.textTheme.bodyLarge?.color),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: h * 0.02),

                const Center(child: ChronicLogo()),

                SizedBox(height: h * 0.04),

                Text(
                  "Reset your password",
                  style: GoogleFonts.arimo(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Enter the email associated with your account and we'll send you a code to reset your password.",
                  style: GoogleFonts.arimo(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),

                SizedBox(height: h * 0.04),

                RoundedInputBox(
                  hintTop: "Email",
                  centerPlaceholder: "Enter your email",
                  controller: emailCtrl,
                ),

                SizedBox(height: h * 0.04),

                MainButton(
                  text: loading ? "Sending..." : "Send reset code",
                  onTap: loading
                      ? null
                      : () {
                    final emailText = emailCtrl.text.trim();
                    if (emailText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Enter your email")),
                      );
                      return;
                    }
                    context.read<AuthCubit>().forgotPassword(emailText);
                  },
                ),

                SizedBox(height: h * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// OTP dialog for password reset — collects the 6-digit code and the new
/// password, then submits both to AuthCubit.resetPassword.
class ResetPasswordOtpDialog extends StatefulWidget {
  final String email;

  const ResetPasswordOtpDialog({super.key, required this.email});

  @override
  State<ResetPasswordOtpDialog> createState() =>
      _ResetPasswordOtpDialogState();
}

class _ResetPasswordOtpDialogState extends State<ResetPasswordOtpDialog> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in _otpControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  String get _otp => _otpControllers.map((c) => c.text).join();

  void _submit(BuildContext context) {
    final otp = _otp;
    final newPass = newPasswordCtrl.text;
    final confirmPass = confirmPasswordCtrl.text;

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the complete 6-digit code')),
      );
      return;
    }

    if (newPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a new password')),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    context.read<AuthCubit>().resetPassword(
      email: widget.email,
      otp: otp,
      newPassword: newPass,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Dialog(
      backgroundColor: c.bottomSheet,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_outlined,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Check your email',
                style: GoogleFonts.arimo(
                  color: c.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Enter the 6-digit code sent to\n${widget.email}\nand choose a new password',
                textAlign: TextAlign.center,
                style: GoogleFonts.arimo(color: c.subtleText, fontSize: 13),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 44,
                    height: 56,
                    child: TextField(
                      controller: _otpControllers[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.arimo(
                        color: c.primaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: c.inputFill,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: c.divider, width: 0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: c.divider, width: 0.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && i < 5) {
                          _focusNodes[i + 1].requestFocus();
                        } else if (val.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              RoundedInputBox(
                hintTop: "New Password",
                centerPlaceholder: "Enter new password",
                controller: newPasswordCtrl,
                isPassword: true,
              ),

              const SizedBox(height: 14),

              RoundedInputBox(
                hintTop: "Confirm Password",
                centerPlaceholder: "Confirm new password",
                controller: confirmPasswordCtrl,
                isPassword: true,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Reset Password',
                    style: GoogleFonts.arimo(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.arimo(color: c.subtleText, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}