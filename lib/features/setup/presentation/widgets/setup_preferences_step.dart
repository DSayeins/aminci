import 'package:flutter/material.dart';

import 'package:aminci/core/models/preference.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/shared/widgets/app_text_field.dart';

const _dateFormats = ['dd/MM/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd'];

/// Étape 3 du wizard de setup — préférences UI initiales (facultatives, valeurs
/// par défaut sensées).
class SetupPreferencesStep extends StatelessWidget {
  final TextEditingController currencyController;
  final String dateFormat;
  final AppThemeMode themeMode;
  final bool enabled;
  final ValueChanged<String> onDateFormatChanged;
  final ValueChanged<AppThemeMode> onThemeModeChanged;

  const SetupPreferencesStep({
    super.key,
    required this.currencyController,
    required this.dateFormat,
    required this.themeMode,
    required this.enabled,
    required this.onDateFormatChanged,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Devise des tickets',
          controller: currencyController,
          hint: 'FCFA',
          enabled: enabled,
          autofocus: true,
        ),
        const SizedBox(height: AppSpacing.gapLg),

        Text('Format de date', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.gapSm),
        Wrap(
          spacing: AppSpacing.gapSm,
          children: _dateFormats.map((format) {
            final selected = format == dateFormat;
            return ChoiceChip(
              label: Text(format),
              selected: selected,
              onSelected: enabled ? (_) => onDateFormatChanged(format) : null,
              selectedColor: AppColors.primaryLight,
              labelStyle: AppTypography.labelMd.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.borderDefault,
                width: selected ? AppSpacing.borderDefault : AppSpacing.borderThin,
              ),
              backgroundColor: AppColors.bgSurface,
              shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.gapLg),

        Text('Thème', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.gapSm),
        Wrap(
          spacing: AppSpacing.gapSm,
          children: AppThemeMode.values.map((mode) {
            final selected = mode == themeMode;
            return ChoiceChip(
              label: Text(_themeModeLabel(mode)),
              selected: selected,
              onSelected: enabled ? (_) => onThemeModeChanged(mode) : null,
              selectedColor: AppColors.primaryLight,
              labelStyle: AppTypography.labelMd.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: selected ? AppColors.primary : AppColors.borderDefault,
                width: selected ? AppSpacing.borderDefault : AppSpacing.borderThin,
              ),
              backgroundColor: AppColors.bgSurface,
              shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderSm),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _themeModeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Clair';
      case AppThemeMode.dark:
        return 'Sombre';
      case AppThemeMode.system:
        return 'Système';
    }
  }
}
