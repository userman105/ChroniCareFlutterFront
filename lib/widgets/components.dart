import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoundedInputBox extends StatelessWidget {
  final String hintTop;
  final String centerPlaceholder;
  final TextEditingController controller;
  final bool isPassword;

  const RoundedInputBox({
    super.key,
    required this.hintTop,
    required this.centerPlaceholder,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        labelText: hintTop,
        labelStyle: const TextStyle(
          color: Color(0xFF364153),
          fontSize: 14,
        ),
        hintText: centerPlaceholder,
        hintStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
        ),

        alignLabelWithHint: true,
        floatingLabelAlignment: FloatingLabelAlignment.start,

        filled: true,
        fillColor: Colors.transparent,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
      ),
    );
  }
}

class MainButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const MainButton({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 364.69,
        height: 55.97,
        decoration: ShapeDecoration(
          color: const Color(0xFF05DF72),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style:  GoogleFonts.arimo(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700, // Bold
          ),
        ),
      ),
    );
  }
}

class ChronicLogo extends StatelessWidget {
  final double logoHeight;

  const ChronicLogo({
    super.key,
    this.logoHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [

        Row(
          children: [

            Expanded(
              child: Transform.rotate(
                angle: -2.25 * math.pi / 180,
                child: Container(
                  height: 8,
                  width: MediaQuery.of(context).size.width * 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFF05DF72),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Transform.rotate(
                angle: 2.25 * math.pi / 180,
                child: Container(
                  height: 8,
                  width: MediaQuery.of(context).size.width * 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFF05DF72),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),

        Image.asset(
          "assets/logos/chronicareLogo.png",
          height: logoHeight,
        ),
      ],
    );
  }
}