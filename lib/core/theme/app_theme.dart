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

    // Icônes
    iconTheme: const IconThemeData(color: AppColors.textSecondary, size: AppSpacing.iconMd),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        highlightColor: AppColors.bgSubtle,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
      ),
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
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderSm,
        borderSide: const BorderSide(color: AppColors.error, width: AppSpacing.borderThick),
      ),
      errorStyle: AppTypography.bodySm.copyWith(color: AppColors.textError),
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

    // Progress indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.bgSubtle,
    ),

    // Scrollbar (Windows desktop)
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return AppColors.borderStrong;
        return AppColors.borderDefault;
      }),
      thickness: WidgetStateProperty.all(AppSpacing.borderThick),
      radius: const Radius.circular(AppSpacing.radiusFull),
      thumbVisibility: WidgetStateProperty.all(false),
      trackVisibility: WidgetStateProperty.all(false),
    ),

    // DataTable (tableaux de vouchers, profils, routeurs)
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(AppColors.bgSubtle),
      headingTextStyle: AppTypography.tableHeader.copyWith(color: AppColors.textSecondary),
      dataTextStyle: AppTypography.tableCell.copyWith(color: AppColors.textPrimary),
      dataRowMinHeight: AppSpacing.buttonHeightLg,
      dataRowMaxHeight: AppSpacing.buttonHeightLg + AppSpacing.x2,
      dividerThickness: AppSpacing.borderThin,
      columnSpacing: AppSpacing.x4,
      horizontalMargin: AppSpacing.x4,
    ),

    // Tooltip
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: AppColors.textPrimary, borderRadius: AppSpacing.borderXs),
      textStyle: AppTypography.bodySm.copyWith(color: AppColors.textOnPrimary),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingSm, vertical: AppSpacing.gapSm),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTypography.bodySm.copyWith(color: AppColors.textOnPrimary),
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
      color: AppColors.bgElevated,
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
    onSecondary: AppColors.textOnPrimary,
    error: AppColors.error,
    onError: AppColors.textOnPrimary,
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

    iconTheme: IconThemeData(color: AppColorsDark.textSecondary, size: AppSpacing.iconMd),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColorsDark.textSecondary,
        highlightColor: AppColorsDark.bgSubtle,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
      ),
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
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderSm,
        borderSide: BorderSide(color: AppColorsDark.error, width: AppSpacing.borderThick),
      ),
      errorStyle: AppTypography.bodySm.copyWith(color: AppColorsDark.textError),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColorsDark.primary;
        return Colors.transparent;
      }),
      side: BorderSide(color: AppColorsDark.borderDefault, width: AppSpacing.borderDefault),
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderXs),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColorsDark.primary,
      linearTrackColor: AppColorsDark.bgSubtle,
    ),

    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return AppColorsDark.borderStrong;
        return AppColorsDark.borderDefault;
      }),
      thickness: WidgetStateProperty.all(AppSpacing.borderThick),
      radius: const Radius.circular(AppSpacing.radiusFull),
      thumbVisibility: WidgetStateProperty.all(false),
      trackVisibility: WidgetStateProperty.all(false),
    ),

    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(AppColorsDark.bgSubtle),
      headingTextStyle: AppTypography.tableHeader.copyWith(color: AppColorsDark.textSecondary),
      dataTextStyle: AppTypography.tableCell.copyWith(color: AppColorsDark.textPrimary),
      dataRowMinHeight: AppSpacing.buttonHeightLg,
      dataRowMaxHeight: AppSpacing.buttonHeightLg + AppSpacing.x2,
      dividerThickness: AppSpacing.borderThin,
      columnSpacing: AppSpacing.x4,
      horizontalMargin: AppSpacing.x4,
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
