import 'package:flutter/material.dart';

/// Système d'espacement Aminci
/// Basé sur une grille de 4px
/// Utiliser uniquement ces constantes — ne jamais hardcoder des valeurs

abstract final class AppSpacing {
  // -------------------------------------------------------------------------
  // ÉCHELLE DE BASE (multiples de 4px)
  // -------------------------------------------------------------------------

  static const double x0 = 0;
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;
  static const double x12 = 48;
  static const double x16 = 64;

  // -------------------------------------------------------------------------
  // ESPACEMENTS SÉMANTIQUES
  // -------------------------------------------------------------------------

  // Interne aux composants (padding)
  static const double paddingXs = x2; //  8px — badges, chips
  static const double paddingSm = x3; // 12px — boutons compacts
  static const double paddingMd = x4; // 16px — cards, inputs
  static const double paddingLg = x6; // 24px — sections de page
  static const double paddingXl = x8; // 32px — zones larges

  // Entre composants (gap)
  static const double gapXs = x1; //  4px — entre icône et label
  static const double gapSm = x2; //  8px — entre éléments proches
  static const double gapMd = x3; // 12px — entre cards dans une grille
  static const double gapLg = x4; // 16px — entre sections
  static const double gapXl = x6; // 24px — entre blocs majeurs

  // -------------------------------------------------------------------------
  // LAYOUT — DIMENSIONS FIXES
  // -------------------------------------------------------------------------

  // Sidebar
  static const double sidebarWidth = 220;
  static const double sidebarLogoHeight = 64;
  static const double sidebarFooterHeight = 56;

  // Topbar
  static const double topbarHeight = 52;

  // Nav items
  static const double navItemHeight = 34;
  static const double navItemPaddingH = x3; // 12px horizontal
  static const double navItemPaddingV = x2; //  8px vertical
  static const double navIconSize = 16;
  static const double navSectionLabelPadV = x2; //  8px

  // Boutons
  static const double buttonHeightSm = 30;
  static const double buttonHeightMd = 36;
  static const double buttonHeightLg = 42;
  static const double buttonPaddingH = x4; // 16px
  static const double buttonIconSize = 14;
  static const double buttonIconGap = x2; //  8px

  // Inputs
  static const double inputHeight = 36;
  static const double inputPaddingH = x3; // 12px
  static const double inputPaddingV = x2; //  8px

  // Cards / surfaces
  static const double cardPaddingH = x4; // 16px
  static const double cardPaddingV = x4; // 16px (ajuster à x3 pour dense)
  static const double cardPaddingDense = x3; // 12px — mode dense (ex: stats)

  // Tableau
  static const double tableCellPaddingH = x4; // 16px
  static const double tableCellPaddingV = x3; // 12px — body rows
  static const double tableHeadPaddingV = x2; // 8px  — header

  // Dialogs
  static const double dialogWidth = 400;

  // Stats row
  static const double statCardHeight = 80;

  // Avatar / Logo
  static const double avatarSm = 28;
  static const double avatarMd = 36;
  static const double avatarLg = 44;
  static const double logoIconSize = 28;

  // Router pill
  static const double routerPillDotSize = 7;
  static const double routerPillHeight = 32;

  // -------------------------------------------------------------------------
  // BORDER RADIUS
  // -------------------------------------------------------------------------

  static const double radiusXs = 4;
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 10;
  static const double radiusXl = 12;
  static const double radiusFull = 999; // pill / cercle

  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(radiusFull));

  // -------------------------------------------------------------------------
  // BORDER WIDTH
  // -------------------------------------------------------------------------

  static const double borderThin = 0.5;
  static const double borderDefault = 1.0;
  static const double borderThick = 2.0; // réservé aux éléments focus/accent

  // -------------------------------------------------------------------------
  // TAILLES D'ICÔNES
  // -------------------------------------------------------------------------

  static const double iconXs = 12;
  static const double iconSm = 14;
  static const double iconMd = 16;
  static const double iconLg = 20;
  static const double iconXl = 24;

  // -------------------------------------------------------------------------
  // HELPERS — EdgeInsets prêts à l'emploi
  // -------------------------------------------------------------------------

  static const EdgeInsets insetXs = EdgeInsets.all(x1);
  static const EdgeInsets insetSm = EdgeInsets.all(x2);
  static const EdgeInsets insetMd = EdgeInsets.all(x4);
  static const EdgeInsets insetLg = EdgeInsets.all(x6);

  static const EdgeInsets insetCardDense = EdgeInsets.symmetric(horizontal: cardPaddingH, vertical: cardPaddingDense);
  static const EdgeInsets insetCard = EdgeInsets.symmetric(horizontal: cardPaddingH, vertical: cardPaddingV);
  static const EdgeInsets insetPage = EdgeInsets.symmetric(horizontal: paddingLg, vertical: paddingMd);
  static const EdgeInsets insetTableCell = EdgeInsets.symmetric(
    horizontal: tableCellPaddingH,
    vertical: tableCellPaddingV,
  );
}
