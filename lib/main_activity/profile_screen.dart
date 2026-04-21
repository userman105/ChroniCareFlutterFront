import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/theme_cubit.dart';
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
  bool _isLightMode = false;

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
      _isLightMode = prefs.getBool('is_light_mode') ?? false;
      final birthday = prefs.getString('birthday');
      final dob = prefs.getString('dob');
      if (birthday != null && birthday.isNotEmpty) {
        _birthday = birthday;
      } else if (dob != null && dob.isNotEmpty) {
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
      final parts = dob.split('-');
      if (parts.length == 3) return '${parts[1]} / ${parts[2]} / ${parts[0]}';
    } catch (_) {}
    return dob;
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _name);
    await prefs.setString('gender', _gender);
    await prefs.setString('birthday', _birthday);
  }

  // --- Helper to get theme colors easily ---
  Color _getPrimaryColor(BuildContext context) => Theme.of(context).primaryColor;
  Color _getTextColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
  Color _getSubtextColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54;
  Color _getCardColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF343434) : const Color(0xFFF5F5F5);
  Color _getFieldColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : const Color(0xFFE0E0E0);
  Color _getDialogBg(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF212121) : Colors.white;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _getDialogBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, color: Color(0xFFFF3030), size: 48),
              const SizedBox(height: 16),
              Text(
                'Logout',
                style: GoogleFonts.arimo(
                  color: _getTextColor(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isGuest ? 'Exit guest mode?' : 'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: GoogleFonts.arimo(color: _getSubtextColor(context), fontSize: 14),
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
                          color: _getFieldColor(context),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.arimo(
                              color: _getTextColor(context),
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
                        Navigator.pop(context);
                        _isGuest ? _handleGuestLogout() : _handleRegularLogout();
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
                            style: GoogleFonts.arimo(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator(color: _getPrimaryColor(context))),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const SignUpScreen()), (route) => false);
  }

  Future<void> _handleRegularLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator(color: _getPrimaryColor(context))),
    );
    await context.read<AuthCubit>().logout();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const SignUpScreen()), (route) => false);
  }

  void _pickBirthday() {
    if (_isGuest) { _showGuestModeMessage(); return; }
    final parts = _birthday.replaceAll(' ', '').split('/');
    final mmCtrl = TextEditingController(text: parts.isNotEmpty ? parts[0] : '');
    final ddCtrl = TextEditingController(text: parts.length > 1 ? parts[1] : '');
    final yyCtrl = TextEditingController(text: parts.length > 2 ? parts[2] : '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _getDialogBg(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _getTextColor(context).withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Birthday', style: GoogleFonts.arimo(color: _getTextColor(context), fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              Row(children: [_dateField('MM', mmCtrl, 2), _slash(), _dateField('DD', ddCtrl, 2), _slash(), _dateField('YYYY', yyCtrl, 4)]),
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
                  width: double.infinity, height: 44,
                  decoration: BoxDecoration(color: _getPrimaryColor(context), borderRadius: BorderRadius.circular(22)),
                  child: Center(child: Text('Save', style: GoogleFonts.arimo(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField(String hint, TextEditingController ctrl, int maxLen) {
    return Expanded(
      child: TextField(
        controller: ctrl,
        maxLength: maxLen,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        style: GoogleFonts.arimo(color: _getTextColor(context), fontSize: 22, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          counterText: '',
          hintText: hint,
          hintStyle: GoogleFonts.arimo(color: _getTextColor(context).withOpacity(0.3), fontSize: 22),
          filled: true,
          fillColor: _getFieldColor(context),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _slash() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text('/', style: GoogleFonts.arimo(color: _getTextColor(context).withOpacity(0.5), fontSize: 24, fontWeight: FontWeight.w300)),
    );
  }

  void _pickGender() {
    if (_isGuest) { _showGuestModeMessage(); return; }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: _getDialogBg(context), borderRadius: const BorderRadius.vertical(top: Radius.circular(22))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _getTextColor(context).withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Gender', style: GoogleFonts.arimo(color: _getTextColor(context), fontSize: 18, fontWeight: FontWeight.w600)),
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
                  color: _gender == g ? _getPrimaryColor(context).withOpacity(0.15) : _getFieldColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _gender == g ? _getPrimaryColor(context) : Colors.transparent),
                ),
                child: Center(
                  child: Text(g, style: GoogleFonts.arimo(color: _gender == g ? _getPrimaryColor(context) : _getTextColor(context), fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _editName() {
    if (_isGuest) { _showGuestModeMessage(); return; }
    final ctrl = TextEditingController(text: _name);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: _getDialogBg(context), borderRadius: const BorderRadius.vertical(top: Radius.circular(22))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _getTextColor(context).withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Name', style: GoogleFonts.arimo(color: _getTextColor(context), fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                style: GoogleFonts.arimo(color: _getTextColor(context), fontSize: 16),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _getFieldColor(context),
                  hintText: 'Enter your name',
                  hintStyle: GoogleFonts.arimo(color: _getTextColor(context).withOpacity(0.3)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  if (ctrl.text.trim().isNotEmpty) { setState(() => _name = ctrl.text.trim()); await _saveToPrefs(); }
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity, height: 44,
                  decoration: BoxDecoration(color: _getPrimaryColor(context), borderRadius: BorderRadius.circular(22)),
                  child: Center(child: Text('Save', style: GoogleFonts.arimo(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGuestModeMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Guest users cannot edit profile information', style: GoogleFonts.arimo()),
        backgroundColor: _getFieldColor(context),
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
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: _getTextColor(context).withOpacity(0.1)))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.arimo(color: isDestructive ? const Color(0xFFFF3030) : _getTextColor(context), fontSize: 16, fontWeight: FontWeight.w500)),
                  if (value.isNotEmpty)
                    Text(value, style: GoogleFonts.arimo(color: _getTextColor(context).withOpacity(0.48), fontSize: 15, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (showChevron && trailing == null) Icon(Icons.chevron_right, color: _getPrimaryColor(context), size: 22),
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
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.5, color: _getTextColor(context).withOpacity(0.1)))),
      child: Row(
        children: [
          Expanded(child: Text(title, style: GoogleFonts.arimo(color: _getTextColor(context), fontSize: 20, fontWeight: FontWeight.w500))),
          if (_isGuest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange)),
              child: Text('Guest Mode', style: GoogleFonts.arimo(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: _getPrimaryColor(context))));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity, height: 46,
              color: _getFieldColor(context),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Profile & Settings', style: GoogleFonts.arimo(color: _getTextColor(context), fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSection('Profile Settings', [
                      _settingsRow(label: 'Name', value: _name, onTap: _editName),
                      _settingsRow(label: 'Birthday', value: _birthday, onTap: _pickBirthday),
                      _settingsRow(label: 'Gender', value: _gender, onTap: _pickGender),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection('Account Settings', [
                      _settingsRow(label: 'Email', value: _email, onTap: () {}),
                      if (!_isGuest) _settingsRow(label: 'Password', value: '', onTap: () {}),
                      _settingsRow(
                        label: 'Notifications',
                        value: _notificationsOn ? 'On' : 'Off',
                        showChevron: false,
                        trailing: Switch(
                          value: _notificationsOn,
                          activeColor: _getPrimaryColor(context),
                          onChanged: (v) => setState(() => _notificationsOn = v),
                        ),
                      ),
                      _settingsRow(
                        label: 'Light Mode',
                        value: _isLightMode ? 'On' : 'Off',
                        showChevron: false,
                        trailing: Switch(
                          value: _isLightMode,
                          activeColor: _getPrimaryColor(context),
                          onChanged: (v) {
                            setState(() => _isLightMode = v);
                            context.read<ThemeCubit>().toggleTheme(v);
                          },
                        ),
                      ),
                      _settingsRow(label: 'Logout', value: '', isDestructive: true, showChevron: false, onTap: _showLogoutDialog),
                      if (!_isGuest) _settingsRow(label: 'Delete Account', value: '', isDestructive: true, showChevron: false, onTap: () {}),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: _getCardColor(context), borderRadius: BorderRadius.circular(13)),
      child: Column(children: [_sectionHeader(title), ...children]),
    );
  }
}