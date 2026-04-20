import 'package:flutter/material.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_typography.dart';

/// Helper pour afficher des snackbars cohérents dans toute l'application.
abstract final class AppSnackbar {
  static void success(BuildContext context, String message) {
    _show(context, message: message, color: AppColors.success);
  }

  static void error(BuildContext context, String message) {
    _show(context, message: message, color: AppColors.error);
  }

  static void _show(BuildContext context, {required String message, required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.bodySm.copyWith(color: AppColors.textOnPrimary)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
