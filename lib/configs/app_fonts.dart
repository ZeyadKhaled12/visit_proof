import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts extends TextStyle {
  AppFonts({
    super.fontSize,
    super.color,
    super.fontWeight,
    super.fontStyle,
    super.letterSpacing,
    super.wordSpacing,
    super.height,
    super.decoration,
    super.foreground,
    super.background,
    super.shadows,
    super.fontFeatures,
  }) : super(
          fontFamily: GoogleFonts.manrope(fontWeight: fontWeight).fontFamily,
        );
}
