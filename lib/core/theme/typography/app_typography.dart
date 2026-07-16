import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inter typography system.
/// Japandi favors light weights and generous whitespace.
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle body;
  final TextStyle label;
  final TextStyle caption;

  const AppTypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.headline,
    required this.title,
    required this.body,
    required this.label,
    required this.caption,
  });

  factory AppTypography.inter() {
    return AppTypography(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w300,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      headline: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
      title: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      body: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      label: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.25,
      ),
      caption: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.4,
      ),
    );
  }

  @override
  AppTypography copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? headline,
    TextStyle? title,
    TextStyle? body,
    TextStyle? label,
    TextStyle? caption,
  }) {
    return AppTypography(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      headline: headline ?? this.headline,
      title: title ?? this.title,
      body: body ?? this.body,
      label: label ?? this.label,
      caption: caption ?? this.caption,
    );
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      headline: TextStyle.lerp(headline, other.headline, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}
