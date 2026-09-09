import 'package:flutter/material.dart';

/// Palette de couleurs Aminci
/// Organisée en 3 niveaux :
///   1. Couleurs primitives (les valeurs brutes)
///   2. Couleurs sémantiques (ce qu'elles signifient)
///   3. Couleurs de surface (backgrounds, borders)

abstract final class AppColors {
  // -------------------------------------------------------------------------
  // 1. PRIMITIVES — Ne pas utiliser directement dans les widgets
  // -------------------------------------------------------------------------

  // Vert (couleur principale)
  static const Color green50 = Color(0xFFEAF3DE);
  static const Color green100 = Color(0xFFC0DD97);
  static const Color green200 = Color(0xFF97C459);
  static const Color green400 = Color(0xFF639922);
  static const Color green600 = Color(0xFF3B6D11);
  static const Color green800 = Color(0xFF27500A);
  static const Color green900 = Color(0xFF173404);

  // Gris neutre
  static const Color gray50 = Color(0xFFF5F5F3);
  static const Color gray100 = Color(0xFFF1F0E8);
  static const Color gray200 = Color(0xFFD3D1C7);
  static const Color gray300 = Color(0xFFB4B2A9);
  static const Color gray400 = Color(0xFF888780);
  static const Color gray600 = Color(0xFF5F5E5A);
  static const Color gray800 = Color(0xFF444441);
  static const Color gray900 = Color(0xFF2C2C2A);

  // Ambre (warning)
  static const Color amber50 = Color(0xFFFAEEDA);
  static const Color amber100 = Color(0xFFFAC775);
  static const Color amber400 = Color(0xFFBA7517);
  static const Color amber800 = Color(0xFF633806);

  // Rouge (danger / erreur)
  static const Color red50 = Color(0xFFFCEBEB);
  static const Color red100 = Color(0xFFF7C1C1);
  static const Color red400 = Color(0xFFE24B4A);
  static const Color red800 = Color(0xFF791F1F);

  // Bleu (info)
  static const Color blue50 = Color(0xFFE6F1FB);
  static const Color blue100 = Color(0xFFB5D4F4);
  static const Color blue400 = Color(0xFF378ADD);
  static const Color blue800 = Color(0xFF0C447C);

  // Blanc / Noir
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // -------------------------------------------------------------------------
  // 2. COULEURS SÉMANTIQUES — À utiliser dans les widgets
  // -------------------------------------------------------------------------

  // Primaire (vert)
  static const Color primary = green600;
  static const Color primaryLight = green50;
  static const Color primaryMid = green400;
  static const Color primaryDark = green800;

  // Statut voucher
  static const Color statusActive = green600;
  static const Color statusActiveBg = green50;
  static const Color statusPending = amber400;
  static const Color statusPendingBg = amber50;
  static const Color statusExpired = gray400;
  static const Color statusExpiredBg = gray100;

  // Feedback
  static const Color success = green600;
  static const Color successBg = green50;
  static const Color warning = amber400;
  static const Color warningBg = amber50;
  static const Color error = red400;
  static const Color errorBg = red50;
  static const Color info = blue400;
  static const Color infoBg = blue50;

  // Texte
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray600;
  static const Color textTertiary = gray400;
  static const Color textDisabled = gray300;
  static const Color textOnPrimary = white;
  static const Color textSuccess = green800;
  static const Color textWarning = amber800;
  static const Color textError = red800;
  static const Color textInfo = blue800;

  // -------------------------------------------------------------------------
  // 3. SURFACES — Backgrounds et borders
  // -------------------------------------------------------------------------

  // Backgrounds
  static const Color bgPage = gray50; // canvas de l'app
  static const Color bgSurface = white; // cards, sidebar, topbar
  static const Color bgSubtle = gray100; // thead, hover rows
  static const Color bgElevated = white; // menus, popovers (symétrie avec AppColorsDark)
  static const Color bgCode = gray50; // fond des codes mono

  // Borders
  static const Color borderDefault = Color(0x26000000); // 15% noir
  static const Color borderSubtle = Color(0x15000000); // 8% noir
  static const Color borderStrong = Color(0x40000000); // 25% noir

  // Sidebar
  static const Color sidebarBg = white;
  static const Color sidebarActive = green50;
  static const Color sidebarHover = gray50;

  // Router pill (sélecteur de site)
  static const Color routerPillBg = green50;
  static const Color routerPillDot = green400;
  static const Color routerPillText = green600;

  // Logo icon background
  static const Color logoBg = green600;
}

/// Couleurs pour le thème sombre
/// Même structure qu'AppColors — les widgets utilisent AppColorsDark en dark mode
/// via ThemeExtension ou en sélectionnant la bonne classe selon le brightness

abstract final class AppColorsDark {
  // -------------------------------------------------------------------------
  // Vert — adapté pour fond sombre (plus lumineux, moins saturé)
  // -------------------------------------------------------------------------

  static const Color primary = Color(0xFF97C459); // green200 — lisible sur fond sombre
  static const Color primaryLight = Color(0xFF1E3410); // vert très sombre pour fills
  static const Color primaryMid = Color(0xFF639922); // green400
  static const Color primaryDark = Color(0xFFC0DD97); // green100 — texte clair sur vert

  // Statut voucher
  static const Color statusActive = Color(0xFF97C459);
  static const Color statusActiveBg = Color(0xFF1A2E0D);
  static const Color statusPending = Color(0xFFFAC775);
  static const Color statusPendingBg = Color(0xFF2E1E06);
  static const Color statusExpired = Color(0xFF888780);
  static const Color statusExpiredBg = Color(0xFF2A2A28);

  // Feedback
  static const Color success = Color(0xFF97C459);
  static const Color successBg = Color(0xFF1A2E0D);
  static const Color warning = Color(0xFFFAC775);
  static const Color warningBg = Color(0xFF2E1E06);
  static const Color error = Color(0xFFF09595);
  static const Color errorBg = Color(0xFF2E0F0F);
  static const Color info = Color(0xFF85B7EB);
  static const Color infoBg = Color(0xFF0D1E30);

  // Texte
  static const Color textPrimary = Color(0xFFEFEEE8); // quasi-blanc chaud
  static const Color textSecondary = Color(0xFFB4B2A9); // gray300
  static const Color textTertiary = Color(0xFF888780); // gray400
  static const Color textDisabled = Color(0xFF5F5E5A); // gray600
  static const Color textOnPrimary = Color(0xFF0F1F07); // texte foncé sur vert clair
  static const Color textSuccess = Color(0xFFC0DD97);
  static const Color textWarning = Color(0xFFFAC775);
  static const Color textError = Color(0xFFF7C1C1);
  static const Color textInfo = Color(0xFFB5D4F4);

  // -------------------------------------------------------------------------
  // SURFACES dark
  // -------------------------------------------------------------------------

  // Backgrounds — hiérarchie de profondeur
  static const Color bgPage = Color(0xFF191918); // canvas le plus profond
  static const Color bgSurface = Color(0xFF222221); // cards, sidebar, topbar
  static const Color bgSubtle = Color(0xFF2A2A28); // thead, hover rows
  static const Color bgElevated = Color(0xFF2E2E2C); // menus, popovers
  static const Color bgCode = Color(0xFF1E1E1D); // fond des codes mono

  // Borders — transparence sur fond sombre
  static const Color borderDefault = Color(0x30FFFFFF); // 19% blanc
  static const Color borderSubtle = Color(0x18FFFFFF); // 10% blanc
  static const Color borderStrong = Color(0x50FFFFFF); // 31% blanc

  // Sidebar
  static const Color sidebarBg = Color(0xFF222221);
  static const Color sidebarActive = Color(0xFF1A2E0D);
  static const Color sidebarHover = Color(0xFF2A2A28);

  // Router pill
  static const Color routerPillBg = Color(0xFF1A2E0D);
  static const Color routerPillDot = Color(0xFF97C459);
  static const Color routerPillText = Color(0xFFC0DD97);

  // Logo
  static const Color logoBg = Color(0xFF3B6D11);
}
