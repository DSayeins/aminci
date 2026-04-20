import 'package:flutter/material.dart';

/// Typographie Aminci
/// Polices : Inter (UI) + JetBrains Mono (codes techniques)
///
/// Déclaration dans pubspec.yaml :
/// ```yaml
/// fonts:
///   - family: Sora
///     fonts:
///       - asset: assets/fonts/Sora-Regular.ttf
///         weight: 400
///       - asset: assets/fonts/Sora-Medium.ttf
///         weight: 500
///       - asset: assets/fonts/Sora-SemiBold.ttf
///         weight: 600
///   - family: JetBrainsMono
///     fonts:
///       - asset: assets/fonts/JetBrainsMono-Regular.ttf
///         weight: 400
///       - asset: assets/fonts/JetBrainsMono-Medium.ttf
///         weight: 500
/// ```
///
/// Téléchargement :
///   Inter        → https://fonts.google.com/specimen/Inter
///   JetBrains Mono → https://www.jetbrains.com/lp/mono/

abstract final class AppTypography {
  // -------------------------------------------------------------------------
  // FONT FAMILIES
  // -------------------------------------------------------------------------

  static const String fontUI = 'Sora';
  static const String fontMono = 'JetBrainsMono';

  // -------------------------------------------------------------------------
  // FONT WEIGHTS
  // -------------------------------------------------------------------------

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;

  // -------------------------------------------------------------------------
  // ÉCHELLE TYPOGRAPHIQUE — Interface (Inter)
  // -------------------------------------------------------------------------

  // Titres de page
  static const TextStyle pageTitleLg = TextStyle(
    fontFamily: fontUI,
    fontSize: 20,
    fontWeight: semiBold,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontUI,
    fontSize: 16,
    fontWeight: semiBold,
    letterSpacing: -0.2,
    height: 1.4,
  );

  // Titres de section / card
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: fontUI,
    fontSize: 13,
    fontWeight: medium,
    letterSpacing: 0,
    height: 1.4,
  );

  // Corps de texte
  static const TextStyle bodyMd = TextStyle(fontFamily: fontUI, fontSize: 13, fontWeight: regular, height: 1.6);

  static const TextStyle bodySm = TextStyle(fontFamily: fontUI, fontSize: 12, fontWeight: regular, height: 1.5);

  // Labels
  static const TextStyle labelMd = TextStyle(fontFamily: fontUI, fontSize: 12, fontWeight: medium, height: 1.4);

  static const TextStyle labelSm = TextStyle(
    fontFamily: fontUI,
    fontSize: 11,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // Labels de section nav (uppercase)
  static const TextStyle navSectionLabel = TextStyle(
    fontFamily: fontUI,
    fontSize: 10,
    fontWeight: medium,
    letterSpacing: 0.6,
    height: 1.4,
  );

  // Item de navigation
  static const TextStyle navItem = TextStyle(fontFamily: fontUI, fontSize: 13, fontWeight: regular, height: 1.4);

  static const TextStyle navItemActive = TextStyle(fontFamily: fontUI, fontSize: 13, fontWeight: medium, height: 1.4);

  // Boutons
  static const TextStyle buttonMd = TextStyle(
    fontFamily: fontUI,
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1,
  );

  static const TextStyle buttonSm = TextStyle(
    fontFamily: fontUI,
    fontSize: 11,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1,
  );

  // Stat cards
  static const TextStyle statValue = TextStyle(
    fontFamily: fontUI,
    fontSize: 22,
    fontWeight: semiBold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle statLabel = TextStyle(fontFamily: fontUI, fontSize: 11, fontWeight: regular, height: 1.4);

  static const TextStyle statSub = TextStyle(fontFamily: fontUI, fontSize: 10, fontWeight: regular, height: 1.4);

  // Tableau
  static const TextStyle tableHeader = TextStyle(
    fontFamily: fontUI,
    fontSize: 11,
    fontWeight: medium,
    letterSpacing: 0.4,
    height: 1.4,
  );

  static const TextStyle tableCell = TextStyle(fontFamily: fontUI, fontSize: 12, fontWeight: regular, height: 1.4);

  // Badge / pill
  static const TextStyle badge = TextStyle(
    fontFamily: fontUI,
    fontSize: 10,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1,
  );

  // Topbar
  static const TextStyle topbarTitle = TextStyle(fontFamily: fontUI, fontSize: 15, fontWeight: medium, height: 1.3);

  // Input
  static const TextStyle input = TextStyle(fontFamily: fontUI, fontSize: 13, fontWeight: regular, height: 1.4);

  static const TextStyle inputPlaceholder = TextStyle(
    fontFamily: fontUI,
    fontSize: 13,
    fontWeight: regular,
    height: 1.4,
  );

  // Logo
  static const TextStyle logoText = TextStyle(
    fontFamily: fontUI,
    fontSize: 16,
    fontWeight: semiBold,
    letterSpacing: -0.2,
    height: 1.2,
  );

  static const TextStyle logoSub = TextStyle(fontFamily: fontUI, fontSize: 11, fontWeight: regular, height: 1.4);

  // User info (sidebar footer)
  static const TextStyle userName = TextStyle(fontFamily: fontUI, fontSize: 12, fontWeight: medium, height: 1.3);

  static const TextStyle userRole = TextStyle(fontFamily: fontUI, fontSize: 10, fontWeight: regular, height: 1.4);

  // -------------------------------------------------------------------------
  // ÉCHELLE TYPOGRAPHIQUE — Monospace (JetBrains Mono)
  // -------------------------------------------------------------------------

  // Code voucher dans le tableau (AM-4F2K9)
  static const TextStyle voucherCode = TextStyle(
    fontFamily: fontMono,
    fontSize: 12,
    fontWeight: medium,
    letterSpacing: 0.3,
    height: 1.4,
  );

  // Données techniques (IP, port, MAC)
  static const TextStyle techData = TextStyle(
    fontFamily: fontMono,
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: 0.2,
    height: 1.4,
  );

  // Code voucher en grand (écran d'impression / ticket)
  static const TextStyle voucherCodeLg = TextStyle(
    fontFamily: fontMono,
    fontSize: 18,
    fontWeight: medium,
    letterSpacing: 1.5,
    height: 1.3,
  );

  // Code voucher XL (ticket imprimé)
  static const TextStyle voucherCodeXl = TextStyle(
    fontFamily: fontMono,
    fontSize: 24,
    fontWeight: semiBold,
    letterSpacing: 2.0,
    height: 1.2,
  );

  // -------------------------------------------------------------------------
  // TEXT THEME Flutter (pour ThemeData)
  // -------------------------------------------------------------------------

  static TextTheme get textTheme => const TextTheme(
    displayLarge: pageTitleLg,
    titleLarge: pageTitle,
    titleMedium: sectionTitle,
    bodyLarge: bodyMd,
    bodyMedium: bodySm,
    labelLarge: labelMd,
    labelMedium: labelSm,
    labelSmall: navSectionLabel,
  );
}
