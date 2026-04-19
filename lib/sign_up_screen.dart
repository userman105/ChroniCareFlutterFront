import 'dart:async';
import 'package:chronic_care/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/components.dart';
import 'cubit/auth_cubit.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  String? _selectedGender;
  bool _loadingShown = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final fullName = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;
    final dob = _dobCtrl.text.trim();

    if (fullName.isEmpty || email.isEmpty || pass.isEmpty ||
        confirm.isEmpty || dob.isEmpty || _selectedGender == null) {
      _snack(context, 'Please fill all fields');
      return;
    }

    if (pass != confirm) {
      _snack(context, 'Passwords do not match');
      return;
    }

    final names = fullName.split(' ');
    final firstName = names.first;
    final lastName =
    names.length > 1 ? names.sublist(1).join(' ') : '';

    context.read<AuthCubit>().register(
      fullName: fullName,
      email: email,
      password: pass,
      gender: _selectedGender!,
      dateOfBirth: dob,
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00C950),
            surface: Color(0xFF2D2D2D),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dobCtrl.text =
      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;


    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (state is AuthLoading && !_loadingShown) {
          _loadingShown = true;
          _showLoading(context);

          Future.delayed(const Duration(seconds: 8), () {
            if (!mounted) return;
            if (_loadingShown) {
              Navigator.of(context, rootNavigator: true).pop();
              _loadingShown = false;
              _snack(context, 'Request timed out');
            }
          });
        }

        if (state is! AuthLoading && _loadingShown) {
          Navigator.of(context, rootNavigator: true).pop();
          _loadingShown = false;
        }

        if (state is AuthOtpSent) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              final cubit = context.read<AuthCubit>();

              return BlocProvider.value(
                value: cubit,
                child: OtpDialog(email: state.email),
              );
            },
          );
        }

        if (state is AuthError) {
          _snack(context, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          body: SafeArea(
            child: AbsorbPointer(
              absorbing: state is AuthLoading,
              child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SizedBox(height: h * 0.03),

                      Center(child: const ChronicLogo()),
                      SizedBox(height: h * 0.03),
                      Center(
                        child: Text(
                          'Create Account',
                          style: GoogleFonts.arimo(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE4E4E4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'Your daily health companion',
                          style: GoogleFonts.arimo(
                            fontSize: 14,
                            color: Colors.white38,
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.04),

                      _label('Full Name'),
                      const SizedBox(height: 6),
                      _field(
                        controller: _nameCtrl,
                        hint: 'Enter your full name',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 14),

                      _label('Email'),
                      const SizedBox(height: 6),
                      _field(
                        controller: _emailCtrl,
                        hint: 'Enter your email',
                        icon: Icons.email_outlined,
                        keyboard: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 14),

                      _label('Password'),
                      const SizedBox(height: 6),
                      _field(
                        controller: _passCtrl,
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        obscure: true,
                      ),

                      const SizedBox(height: 14),

                      _label('Confirm Password'),
                      const SizedBox(height: 6),
                      _field(
                        controller: _confirmCtrl,
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        obscure: true,
                      ),

                      const SizedBox(height: 14),

                      _label('Gender'),
                      const SizedBox(height: 6),
                      _genderSelector(),

                      const SizedBox(height: 14),

                      _label('Date of Birth'),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickDob,
                        child: AbsorbPointer(
                          child: _field(
                            controller: _dobCtrl,
                            hint: 'YYYY-MM-DD',
                            icon: Icons.cake_outlined,
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.04),

                      MainButton(
                        text: 'Sign Up',
                        onTap: () => _submit(context),
                        enabled: true,
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.arimo(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => LoginScreen()),
                              ),
                              child: Text(
                                'Login',
                                style: GoogleFonts.arimo(
                                  color: const Color(0xFF2B7FFF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: h * 0.03),
                    ],
                  ),
                ),
              ),
            ),
          );
        },

    );}

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
            color: Color(0xFF00C950)),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.arimo(
      color: Colors.white70,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: GoogleFonts.arimo(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.arimo(
            color: Colors.white24, fontSize: 15),
        prefixIcon: Icon(icon, color: Colors.white24, size: 18),
        filled: true,
        fillColor: const Color(0xFF242424),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Colors.white12, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Colors.white12, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFF00C950), width: 1),
        ),
      ),
    );
  }

  Widget _genderSelector() {
    return Row(
      children: ['Male', 'Female'].map((g) {
        final active = _selectedGender == g.toLowerCase();
        return Expanded(
          child: GestureDetector(
            onTap: () =>
                setState(() => _selectedGender = g.toLowerCase()),
            child: Container(
              margin: EdgeInsets.only(
                  right: g == 'Male' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF00C950).withOpacity(0.15)
                    : const Color(0xFF242424),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active
                      ? const Color(0xFF00C950)
                      : Colors.white12,
                  width: active ? 1 : 0.5,
                ),
              ),
              child: Center(
                child: Text(
                  g,
                  style: GoogleFonts.arimo(
                    color: active
                        ? const Color(0xFF00C950)
                        : Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class OtpDialog extends StatefulWidget {
  final String email;

  const OtpDialog({super.key, required this.email});

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  int _seconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startTimer() {
    _seconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _verify(BuildContext context) {
    final otp = _otp;

    print("VERIFY CLICKED: $otp"); // DEBUG

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the complete 6-digit code')),
      );
      return;
    }

    final cubit = context.read<AuthCubit>();

    print("CALLING VERIFY OTP");

    cubit.verifyOtp(email: widget.email, otp: otp);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account activated')),
            );
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => LoginScreen()));
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)));
          } else if (state is AuthOtpSent) {
            _startTimer();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C950).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined,
                    color: Color(0xFF00C950), size: 26),
              ),

              const SizedBox(height: 16),

              Text('Check your email',
                  style: GoogleFonts.arimo(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),

              const SizedBox(height: 6),

              Text(
                'We sent a 6-digit code to\n${widget.email}',
                textAlign: TextAlign.center,
                style: GoogleFonts.arimo(
                    color: Colors.white38, fontSize: 13),
              ),

              const SizedBox(height: 28),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 42,
                    height: 50,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      style: GoogleFonts.arimo(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFF2A2A2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Colors.white12, width: 0.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Colors.white12, width: 0.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF00C950), width: 1.5),
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

              const SizedBox(height: 28),

              // Verify button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _verify(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C950),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Verify',
                      style: GoogleFonts.arimo(
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ),
              ),

              const SizedBox(height: 16),

              // Resend
              _seconds > 0
                  ? Text(
                'Resend code in ${_seconds}s',
                style: GoogleFonts.arimo(
                    color: Colors.white38, fontSize: 13),
              )
                  : GestureDetector(
                onTap: () => context
                    .read<AuthCubit>()
                    .resendOtp(widget.email),
                child: Text(
                  'Resend code',
                  style: GoogleFonts.arimo(
                    color: const Color(0xFF2B7FFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}