import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/theme_cubit.dart';
import '../cubit/locale_cubit.dart';
import '../core/lang/lang_strings.dart';
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

  Color _primary(BuildContext context) => Theme.of(context).primaryColor;
  Color _text(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
  Color _subtext(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54;
  Color _card(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF343434) : const Color(0xFFF5F5F5);
  Color _field(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : const Color(0xFFE0E0E0);
  Color _dialogBg(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF212121) : Colors.white;

  void _showLogoutDialog(String lang) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _dialogBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, color: Color(0xFFFF3030), size: 48),
              const SizedBox(height: 16),
              Text(
                AppStrings.get('logout', lang),
                style: GoogleFonts.arimo(color: _text(context), fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _isGuest
                    ? AppStrings.get('exit_guest', lang)
                    : AppStrings.get('logout_confirm', lang),
                textAlign: TextAlign.center,
                style: GoogleFonts.arimo(color: _subtext(context), fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(color: _field(context), borderRadius: BorderRadius.circular(22)),
                        child: Center(
                          child: Text(AppStrings.get('cancel', lang),
                              style: GoogleFonts.arimo(color: _text(context), fontSize: 15, fontWeight: FontWeight.w600)),
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
                        decoration: BoxDecoration(color: const Color(0xFFFF3030), borderRadius: BorderRadius.circular(22)),
                        child: Center(
                          child: Text(AppStrings.get('logout', lang),
                              style: GoogleFonts.arimo(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
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
      builder: (_) => Center(child: CircularProgressIndicator(color: _primary(context))),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignUpScreen()), (r) => false);
  }

  Future<void> _handleRegularLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator(color: _primary(context))),
    );
    await context.read<AuthCubit>().logout();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignUpScreen()), (r) => false);
  }

  void _pickBirthday(String lang) {
    if (_isGuest) { _showGuestMessage(lang); return; }
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
              color: _dialogBg(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _text(context).withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(AppStrings.get('birthday', lang),
                  style: GoogleFonts.arimo(color: _text(context), fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              Row(children: [
                _dateField('MM', mmCtrl, 2),
                _slash(),
                _dateField('DD', ddCtrl, 2),
                _slash(),
                _dateField('YYYY', yyCtrl, 4),
              ]),
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
                  decoration: BoxDecoration(color: _primary(context), borderRadius: BorderRadius.circular(22)),
                  child: Center(child: Text(AppStrings.get('save', lang),
                      style: GoogleFonts.arimo(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
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
        style: GoogleFonts.arimo(color: _text(context), fontSize: 22, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          counterText: '',
          hintText: hint,
          hintStyle: GoogleFonts.arimo(color: _text(context).withOpacity(0.3), fontSize: 22),
          filled: true,
          fillColor: _field(context),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _slash() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Text('/', style: GoogleFonts.arimo(color: _text(context).withOpacity(0.5), fontSize: 24, fontWeight: FontWeight.w300)),
  );

  void _pickGender(String lang) {
    if (_isGuest) { _showGuestMessage(lang); return; }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: _dialogBg(context), borderRadius: const BorderRadius.vertical(top: Radius.circular(22))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _text(context).withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(AppStrings.get('gender', lang),
                style: GoogleFonts.arimo(color: _text(context), fontSize: 18, fontWeight: FontWeight.w600)),
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
                  color: _gender == g ? _primary(context).withOpacity(0.15) : _field(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _gender == g ? _primary(context) : Colors.transparent),
                ),
                child: Center(
                  child: Text(g,
                      style: GoogleFonts.arimo(
                          color: _gender == g ? _primary(context) : _text(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _editName(String lang) {
    if (_isGuest) { _showGuestMessage(lang); return; }
    final ctrl = TextEditingController(text: _name);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: _dialogBg(context), borderRadius: const BorderRadius.vertical(top: Radius.circular(22))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _text(context).withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(AppStrings.get('name', lang),
                  style: GoogleFonts.arimo(color: _text(context), fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                style: GoogleFonts.arimo(color: _text(context), fontSize: 16),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _field(context),
                  hintText: AppStrings.get('enter_name', lang),
                  hintStyle: GoogleFonts.arimo(color: _text(context).withOpacity(0.3)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
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
                  width: double.infinity, height: 44,
                  decoration: BoxDecoration(color: _primary(context), borderRadius: BorderRadius.circular(22)),
                  child: Center(child: Text(AppStrings.get('save', lang),
                      style: GoogleFonts.arimo(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickLanguage(String currentLang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: _dialogBg(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: _text(context).withOpacity(0.2), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(AppStrings.get('language', currentLang),
                style: GoogleFonts.arimo(color: _text(context), fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...[
              ('en', AppStrings.get('english', currentLang)),
              ('ar', AppStrings.get('arabic', currentLang)),
            ].map(((String, String) entry) {
              final (code, label) = entry;
              final isSelected = currentLang == code;
              return GestureDetector(
                onTap: () async {
                  context.read<LocaleCubit>().changeLang(code);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('lang', code);
                  if (mounted) Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? _primary(context).withOpacity(0.12) : _field(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isSelected ? _primary(context) : Colors.transparent,
                        width: 1.5),
                  ),
                  child: Row(
                    children: [
                      // Radio indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isSelected ? _primary(context) : _text(context).withOpacity(0.35),
                              width: 2),
                          color: isSelected ? _primary(context) : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Center(child: Icon(Icons.circle, size: 8, color: Colors.white))
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Text(label,
                          style: GoogleFonts.arimo(
                              color: isSelected ? _primary(context) : _text(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showGuestMessage(String lang) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppStrings.get('guest_cannot_edit', lang), style: GoogleFonts.arimo()),
      backgroundColor: _field(context),
      duration: const Duration(seconds: 2),
    ));
  }

  Widget _settingsRow({
    required String label,
    required String value,
    VoidCallback? onTap,
    bool isDestructive = false,
    bool showChevron = true,
    Widget? trailing,
    BuildContext? ctx,
  }) {
    final c = ctx ?? context;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 0.5, color: _text(c).withOpacity(0.1)))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.arimo(
                          color: isDestructive ? const Color(0xFFFF3030) : _text(c),
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  if (value.isNotEmpty)
                    Text(value,
                        style: GoogleFonts.arimo(
                            color: _text(c).withOpacity(0.48), fontSize: 15, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (showChevron && trailing == null)
              Icon(Icons.chevron_right, color: _primary(c), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String lang) {
    return Container(
      width: double.infinity,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5, color: _text(context).withOpacity(0.1)))),
      child: Row(
        children: [
          Expanded(child: Text(title,
              style: GoogleFonts.arimo(color: _text(context), fontSize: 20, fontWeight: FontWeight.w500))),
          if (_isGuest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange)),
              child: Text(AppStrings.get('guest_mode', lang),
                  style: GoogleFonts.arimo(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, String lang) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: _card(context), borderRadius: BorderRadius.circular(13)),
      child: Column(children: [_sectionHeader(title, lang), ...children]),
    );
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: _primary(context))));
    }

    return BlocBuilder<LocaleCubit, String>(
      builder: (context, lang) {
        final isArabic = lang == 'ar';
        final isLightMode = context.watch<ThemeCubit>().state == ThemeMode.light;

        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 46,
                    color: _field(context),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Align(
                      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(AppStrings.get('profile_and_settings', lang),
                          style: GoogleFonts.arimo(
                              color: _text(context), fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSection(
                            AppStrings.get('profile_settings', lang),
                            [
                              _settingsRow(label: AppStrings.get('name', lang), value: _name, onTap: () => _editName(lang)),
                              _settingsRow(label: AppStrings.get('birthday', lang), value: _birthday, onTap: () => _pickBirthday(lang)),
                              _settingsRow(label: AppStrings.get('gender', lang), value: _gender, onTap: () => _pickGender(lang)),
                            ],
                            lang,
                          ),
                          const SizedBox(height: 16),

                          // Account section
                          _buildSection(
                            AppStrings.get('account_settings', lang),
                            [
                              _settingsRow(label: AppStrings.get('email', lang), value: _email, onTap: () {}),
                              if (!_isGuest)
                                _settingsRow(label: AppStrings.get('password', lang), value: '', onTap: () {}),

                              _settingsRow(
                                label: AppStrings.get('notifications', lang),
                                value: _notificationsOn
                                    ? AppStrings.get('on', lang)
                                    : AppStrings.get('off', lang),
                                showChevron: false,
                                trailing: Switch(
                                  value: _notificationsOn,
                                  activeColor: _primary(context),
                                  onChanged: (v) => setState(() => _notificationsOn = v),
                                ),
                              ),

                              _settingsRow(
                                label: AppStrings.get('light_mode', lang),
                                value: isLightMode
                                    ? AppStrings.get('on', lang)
                                    : AppStrings.get('off', lang),
                                showChevron: false,
                                trailing: Switch(
                                  value: isLightMode,
                                  activeColor: _primary(context),
                                  onChanged: (v) => context.read<ThemeCubit>().toggleTheme(v),
                                ),
                              ),

                              _settingsRow(
                                label: AppStrings.get('language', lang),
                                value: lang == 'ar'
                                    ? AppStrings.get('arabic', lang)
                                    : AppStrings.get('english', lang),
                                onTap: () => _pickLanguage(lang),
                              ),

                              _settingsRow(
                                label: AppStrings.get('logout', lang),
                                value: '',
                                isDestructive: true,
                                showChevron: false,
                                onTap: () => _showLogoutDialog(lang),
                              ),

                              if (!_isGuest)
                                _settingsRow(
                                  label: AppStrings.get('delete_account', lang),
                                  value: '',
                                  isDestructive: true,
                                  showChevron: false,
                                  onTap: () {},
                                ),
                            ],
                            lang,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}