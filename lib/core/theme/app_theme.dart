import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Point d'entrée unique du thème Aminci
/// Usage : MaterialApp(theme: AppTheme.light)

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontUI,
    textTheme: AppTypography.textTheme,
    colorScheme: _colorScheme,

    // Scaffold
    scaffoldBackgroundColor: AppColors.bgPage,

    // AppBar (non utilisé — on a notre propre Topbar)
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgSurface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTypography.topbarTitle,
    ),

    // Cards
    cardTheme: CardThemeData(
      color: AppColors.bgSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderLg,
        side: const BorderSide(color: AppColors.borderDefault, width: AppSpacing.borderThin),
      ),
      margin: EdgeInsets.zero,
    ),

    // Divider
    dividerTheme: const DividerThemeData(color: AppColors.borderDefault, thickness: AppSpacing.borderThin, space: 0),

    // ElevatedButton → bouton primaire
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, AppSpacing.buttonHeightMd),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.buttonPaddingH),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
        textStyle: AppTypography.buttonMd,
      ),
    ),

    // OutlinedButton → bouton secondaire
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.borderDefault, width: AppSpacing.borderThin),
        elevation: 0,
        minimumSize: const Size(0, AppSpacing.buttonHeightMd),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.buttonPaddingH),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
        textStyle: AppTypography.buttonMd,
      ),
    ),

    // TextButton → bouton ghost
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, AppSpacing.buttonHeightMd),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingSm),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
        textStyle: AppTypography.buttonMd,
      ),
    ),

    // InputDecoration (TextField)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.inputPaddingH,
        vertical: AppSpacing.inputPaddingV,
      ),
      hintStyle: AppTypography.inputPlaceholder.copyWith(color: AppColors.textTertiary),
      border: OutlineInputBorder(
        borderRadius: AppSpacing.borderSm,
        borderSide: const BorderSide(color: AppColors.borderDefault, width: AppSpacing.borderThin),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderSm,
        borderSide: const BorderSide(color: AppColors.borderDefault, width: AppSpacing.borderThin),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderSm,
        borderSide: const BorderSide(color: AppColors.primary, width: AppSpacing.borderDefault),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderSm,
        borderSide: const BorderSide(color: AppColors.error, width: AppSpacing.borderDefault),
      ),
    ),

    // Checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return Colors.transparent;
      }),
      side: const BorderSide(color: AppColors.borderDefault, width: AppSpacing.borderDefault),
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderXs),
    ),

    // Tooltip
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: AppColors.gray900, borderRadius: AppSpacing.borderXs),
      textStyle: AppTypography.bodySm.copyWith(color: AppColors.white),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingSm, vertical: AppSpacing.gapSm),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.gray900,
      contentTextStyle: AppTypography.bodySm.copyWith(color: AppColors.white),
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
      behavior: SnackBarBehavior.floating,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.bgSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderLg,
        side: const BorderSide(color: AppColors.borderDefault, width: AppSpacing.borderThin),
      ),
      titleTextStyle: AppTypography.pageTitle.copyWith(color: AppColors.textPrimary),
      contentTextStyle: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
    ),

    // ListTile (utilisé dans certains menus)
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.navItemPaddingH, vertical: 0),
      minLeadingWidth: AppSpacing.navIconSize,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
    ),

    // PopupMenu
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.bgSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderMd,
        side: const BorderSide(color: AppColors.borderDefault, width: AppSpacing.borderThin),
      ),
      textStyle: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
    ),
  );

  // -------------------------------------------------------------------------
  // COLOR SCHEME
  // -------------------------------------------------------------------------

  static const ColorScheme _colorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.gray400,
    onSecondary: AppColors.white,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.bgSurface,
    onSurface: AppColors.textPrimary,
    outline: AppColors.borderDefault,
  );
}

// =============================================================================
// THÈME SOMBRE
// =============================================================================

abstract final class AppThemeDark {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontUI,
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColorsDark.textPrimary,
      displayColor: AppColorsDark.textPrimary,
    ),
    colorScheme: _colorSchemeDark,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColorsDark.bgPage,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsDark.bgSurface,
      foregroundColor: AppColorsDark.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTypography.topbarTitle.copyWith(color: AppColorsDark.textPrimary),
    ),

    cardTheme: CardThemeData(
      color: AppColorsDark.bgSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderLg,
        side: BorderSide(color: AppColorsDark.borderDefault, width: AppSpacing.borderThin),
      ),
      margin: EdgeInsets.zero,
    ),

    dividerTheme: DividerThemeData(color: AppColorsDark.borderDefault, thickness: AppSpacing.borderThin, space: 0),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsDark.primary,
        foregroundColor: AppColorsDark.textOnPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, AppSpacing.buttonHeightMd),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.buttonPaddingH),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
        textStyle: AppTypography.buttonMd,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorsDark.textSecondary,
        side: BorderSide(color: AppColorsDark.borderDefault, width: AppSpacing.borderThin),
        elevation: 0,
        minimumSize: const Size(0, AppSpacing.buttonHeightMd),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.buttonPaddingH),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
        textStyle: AppTypography.buttonMd,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColorsDark.primary,
        minimumSize: const Size(0, AppSpacing.buttonHeightMd),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingSm),
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
        textStyle: AppTypography.buttonMd,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsDark.bgSubtle,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.inputPaddingH,
        vertical: AppSpacing.inputPaddingV,
      ),
      hintStyle: AppTypography.inputPlaceholder.copyWith(color: AppColorsDark.textTertiary),
      border: OutlineInputBorder(
        borderRadius: AppSpacing.borderSm,
        borderSide: BorderSide(color: AppColorsDark.borderDefault, width: AppSpacing.borderThin),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderSm,
        borderSide: BorderSide(color: AppColorsDark.borderDefault, width: AppSpacing.borderThin),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderSm,
        borderSide: BorderSide(color: AppColorsDark.primary, width: AppSpacing.borderDefault),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderSm,
        borderSide: BorderSide(color: AppColorsDark.error, width: AppSpacing.borderDefault),
      ),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColorsDark.primary;
        return Colors.transparent;
      }),
      side: BorderSide(color: AppColorsDark.borderDefault, width: AppSpacing.borderDefault),
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderXs),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColorsDark.bgElevated,
        borderRadius: AppSpacing.borderXs,
        border: Border.all(color: AppColorsDark.borderDefault, width: AppSpacing.borderThin),
      ),
      textStyle: AppTypography.bodySm.copyWith(color: AppColorsDark.textPrimary),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingSm, vertical: AppSpacing.gapSm),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColorsDark.bgElevated,
      contentTextStyle: AppTypography.bodySm.copyWith(color: AppColorsDark.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
      behavior: SnackBarBehavior.floating,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColorsDark.bgSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderLg,
        side: BorderSide(color: AppColorsDark.borderDefault, width: AppSpacing.borderThin),
      ),
      titleTextStyle: AppTypography.pageTitle.copyWith(color: AppColorsDark.textPrimary),
      contentTextStyle: AppTypography.bodyMd.copyWith(color: AppColorsDark.textSecondary),
    ),

    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.navItemPaddingH, vertical: 0),
      minLeadingWidth: AppSpacing.navIconSize,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: AppColorsDark.bgElevated,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderMd,
        side: BorderSide(color: AppColorsDark.borderDefault, width: AppSpacing.borderThin),
      ),
      textStyle: AppTypography.bodySm.copyWith(color: AppColorsDark.textPrimary),
    ),
  );

  static const ColorScheme _colorSchemeDark = ColorScheme.dark(
    primary: AppColorsDark.primary,
    onPrimary: AppColorsDark.textOnPrimary,
    primaryContainer: AppColorsDark.primaryLight,
    onPrimaryContainer: AppColorsDark.primaryDark,
    secondary: AppColorsDark.textTertiary,
    onSecondary: AppColorsDark.bgPage,
    error: AppColorsDark.error,
    onError: AppColorsDark.errorBg,
    surface: AppColorsDark.bgSurface,
    onSurface: AppColorsDark.textPrimary,
    outline: AppColorsDark.borderDefault,
  );
}
