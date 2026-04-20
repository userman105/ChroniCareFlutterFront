import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cubit/auth_cubit.dart';
import '../sign_up_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _birthday = '';
  String _gender = '';
  String _email = '';
  bool _isGuest = false;
  bool _notificationsOn = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _name = prefs.getString('name') ?? 'User';
      _email = prefs.getString('email') ?? 'example@mail.com';
      _gender = prefs.getString('gender') ?? 'Male';

      // Check both 'birthday' and 'dob' keys
      final birthday = prefs.getString('birthday');
      final dob = prefs.getString('dob');

      if (birthday != null && birthday.isNotEmpty) {
        _birthday = birthday;
      } else if (dob != null && dob.isNotEmpty) {
        // Convert YYYY-MM-DD to MM / DD / YYYY format
        _birthday = _formatDob(dob);
      } else {
        _birthday = '-- / -- / ----';
      }

      _isGuest = prefs.getBool('is_guest') ?? false;
      _isLoading = false;
    });
  }

  String _formatDob(String dob) {
    try {
      // dob is in YYYY-MM-DD format
      final parts = dob.split('-');
      if (parts.length == 3) {
        return '${parts[1]} / ${parts[2]} / ${parts[0]}';
      }
    } catch (_) {}
    return dob;
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _name);
    await prefs.setString('gender', _gender);
    await prefs.setString('birthday', _birthday);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF212121),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout,
                color: Color(0xFFFF3030),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Logout',
                style: GoogleFonts.arimo(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isGuest
                    ? 'Exit guest mode?'
                    : 'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: GoogleFonts.arimo(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D2D),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.arimo(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context); // Close dialog

                        if (_isGuest) {
                          _handleGuestLogout();
                        } else {
                          _handleRegularLogout();
                        }
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3030),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Text(
                            'Logout',
                            style: GoogleFonts.arimo(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGuestLogout() async {
    // Show brief loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00C950),
        ),
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Close loading

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
          (route) => false,
    );
  }

  Future<void> _handleRegularLogout() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00C950),
        ),
      ),
    );

    await context.read<AuthCubit>().logout();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
          (route) => false,
    );
  }

  void _pickBirthday() {
    if (_isGuest) {
      _showGuestModeMessage();
      return;
    }

    final parts = _birthday.replaceAll(' ', '').split('/');
    final mmCtrl = TextEditingController(text: parts.isNotEmpty ? parts[0] : '');
    final ddCtrl = TextEditingController(text: parts.length > 1 ? parts[1] : '');
    final yyCtrl = TextEditingController(text: parts.length > 2 ? parts[2] : '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF212121),
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text('Birthday',
                  style: GoogleFonts.arimo(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),

              const SizedBox(height: 20),

              Row(
                children: [
                  _dateField('MM', mmCtrl, 2),
                  _slash(),
                  _dateField('DD', ddCtrl, 2),
                  _slash(),
                  _dateField('YYYY', yyCtrl, 4),
                ],
              ),

              const SizedBox(height: 28),

              GestureDetector(
                onTap: () async {
                  final mm = mmCtrl.text.padLeft(2, '0');
                  final dd = ddCtrl.text.padLeft(2, '0');
                  final yy = yyCtrl.text;
                  if (mm.isNotEmpty && dd.isNotEmpty && yy.isNotEmpty) {
                    setState(() => _birthday = '$mm / $dd / $yy');
                    await _saveToPrefs();
                  }
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C950),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text('Save',
                        style: GoogleFonts.arimo(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField(
      String hint, TextEditingController ctrl, int maxLen) {
    return Expanded(
      child: TextField(
        controller: ctrl,
        maxLength: maxLen,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: GoogleFonts.arimo(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          counterText: '',
          hintText: hint,
          hintStyle: GoogleFonts.arimo(color: Colors.white38, fontSize: 22),
          filled: true,
          fillColor: const Color(0xFF2D2D2D),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _slash() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text('/',
          style: GoogleFonts.arimo(
              color: Colors.white54,
              fontSize: 24,
              fontWeight: FontWeight.w300)),
    );
  }

  void _pickGender() {
    // Disable editing for guest users
    if (_isGuest) {
      _showGuestModeMessage();
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF212121),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Gender',
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...['Male', 'Female', 'Other'].map((g) => GestureDetector(
              onTap: () async {
                setState(() => _gender = g);
                await _saveToPrefs();
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _gender == g
                      ? const Color(0xFF00C950).withOpacity(0.15)
                      : const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _gender == g
                        ? const Color(0xFF00C950)
                        : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Text(g,
                      style: GoogleFonts.arimo(
                          color: _gender == g
                              ? const Color(0xFF00C950)
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _editName() {
    // Disable editing for guest users
    if (_isGuest) {
      _showGuestModeMessage();
      return;
    }

    final ctrl = TextEditingController(text: _name);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF212121),
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Name',
                  style: GoogleFonts.arimo(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                style: GoogleFonts.arimo(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF2D2D2D),
                  hintText: 'Enter your name',
                  hintStyle: GoogleFonts.arimo(color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  if (ctrl.text.trim().isNotEmpty) {
                    setState(() => _name = ctrl.text.trim());
                    await _saveToPrefs();
                  }
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C950),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text('Save',
                        style: GoogleFonts.arimo(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showGuestModeMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Guest users cannot edit profile information',
          style: GoogleFonts.arimo(),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _settingsRow({
    required String label,
    required String value,
    VoidCallback? onTap,
    bool isDestructive = false,
    bool showChevron = true,
    Widget? trailing,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: const ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 0.5, color: Colors.white24),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.arimo(
                          color: isDestructive
                              ? const Color(0xFFFF3030)
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  if (value.isNotEmpty)
                    Text(value,
                        style: GoogleFonts.arimo(
                            color: Colors.white.withOpacity(0.48),
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (showChevron && trailing == null)
              const Icon(Icons.chevron_right,
                  color: Color(0xFF00C950), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      width: double.infinity,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.5, color: Colors.white24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: GoogleFonts.arimo(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500)),
          ),
          if (_isGuest)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange,
                  width: 1,
                ),
              ),
              child: Text(
                'Guest Mode',
                style: GoogleFonts.arimo(
                  fontSize: 11,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF111111),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00C950)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 46,
              color: const Color(0xFF2D2D2D),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile & Settings',
                  style: GoogleFonts.arimo(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.01),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF343434),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Column(
                        children: [
                          _sectionHeader('Profile Settings'),
                          _settingsRow(
                            label: 'Name',
                            value: _name,
                            onTap: _editName,
                          ),
                          _settingsRow(
                            label: 'Birthday',
                            value: _birthday,
                            onTap: _pickBirthday,
                          ),
                          _settingsRow(
                            label: 'Gender',
                            value: _gender,
                            onTap: _pickGender,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF343434),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Column(
                        children: [
                          _sectionHeader('Account Settings'),
                          _settingsRow(
                            label: 'Email',
                            value: _email,
                            onTap: () {},
                          ),
                          if (!_isGuest)
                            _settingsRow(
                              label: 'Password',
                              value: '',
                              onTap: () {},
                            ),
                          _settingsRow(
                            label: 'Notifications',
                            value: _notificationsOn ? 'On' : 'Off',
                            showChevron: false,
                            trailing: Switch(
                              value: _notificationsOn,
                              activeThumbColor: const Color(0xFF00C950),
                              onChanged: (v) =>
                                  setState(() => _notificationsOn = v),
                            ),
                          ),
                          _settingsRow(
                            label: 'Logout',
                            value: '',
                            isDestructive: true,
                            showChevron: false,
                            onTap: _showLogoutDialog,
                          ),
                          if (!_isGuest)
                            _settingsRow(
                              label: 'Delete Account',
                              value: '',
                              isDestructive: true,
                              showChevron: false,
                              onTap: () {},
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}