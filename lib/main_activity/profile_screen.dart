import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'ZizO El Maestro';
  String _birthday = '04 / 14 / 2002';
  String _gender = 'Male';
  final String _email = 'example@mail.com';
  bool _notificationsOn = true;

  void _pickBirthday() {
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
              // Handle
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

              // MM / DD / YY fields
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

              // Save button
              GestureDetector(
                onTap: () {
                  final mm = mmCtrl.text.padLeft(2, '0');
                  final dd = ddCtrl.text.padLeft(2, '0');
                  final yy = yyCtrl.text;
                  if (mm.isNotEmpty && dd.isNotEmpty && yy.isNotEmpty) {
                    setState(() => _birthday = '$mm / $dd / $yy');
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
              onTap: () {
                setState(() => _gender = g);
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
                onTap: () {
                  if (ctrl.text.trim().isNotEmpty) {
                    setState(() => _name = ctrl.text.trim());
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
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
            style: GoogleFonts.arimo(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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