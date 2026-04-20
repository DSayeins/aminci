import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/navigation/routes.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/core/theme/theme_cubit.dart';
import 'package:aminci/features/app/presentation/bloc/app_bloc.dart';

class AppTopBar extends StatelessWidget {
  final Routes currentPage;

  const AppTopBar({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColorsDark.bgSurface : AppColors.bgSurface;
    final borderColor = isDark ? AppColorsDark.borderDefault : AppColors.borderDefault;
    final textPrimary = isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColorsDark.textTertiary : AppColors.textTertiary;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;
    final primaryLight = isDark ? AppColorsDark.primaryLight : AppColors.primaryLight;

    return Container(
      height: AppSpacing.topbarHeight,
      color: bgColor,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingLg),
              child: Row(
                children: [
                  // Titre de la page
                  Icon(currentPage.icon, size: AppSpacing.iconLg, color: textSecondary),
                  SizedBox(width: AppSpacing.gapSm),
                  Text(
                    currentPage.label,
                    style: AppTypography.topbarTitle.copyWith(color: textPrimary),
                  ),

                  const Spacer(),

                  // Theme switcher
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, mode) {
                      final dark = mode == ThemeMode.dark;
                      return GestureDetector(
                        onTap: () => context.read<ThemeCubit>().toggle(),
                        child: Container(
                          width: AppSpacing.x12,
                          height: AppSpacing.x6,
                          decoration: BoxDecoration(
                            color: dark ? primaryColor : AppColors.bgPage,
                            borderRadius: AppSpacing.borderFull,
                            border: Border.all(color: borderColor, width: AppSpacing.borderThin),
                          ),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              // Icônes fixes
                              Positioned(
                                left: AppSpacing.x1 + 2,
                                child: Icon(
                                  Icons.wb_sunny_rounded,
                                  size: AppSpacing.iconSm,
                                  color: dark ? textTertiary : primaryColor,
                                ),
                              ),
                              Positioned(
                                right: AppSpacing.x1 + 2,
                                child: Icon(
                                  Icons.nightlight_round,
                                  size: AppSpacing.iconSm,
                                  color: dark ? primaryLight : textTertiary,
                                ),
                              ),
                              // Thumb animé
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                left: dark ? AppSpacing.x6 : AppSpacing.x1,
                                child: Container(
                                  width: AppSpacing.x5,
                                  height: AppSpacing.x5,
                                  decoration: BoxDecoration(
                                    color: dark ? primaryColor : AppColors.bgSurface,
                                    borderRadius: AppSpacing.borderFull,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    dark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                                    size: AppSpacing.iconXs,
                                    color: dark ? AppColors.textOnPrimary : primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: AppSpacing.gapLg),

                  // Nom d'utilisateur
                  BlocBuilder<AppBloc, AppState>(
                    builder: (context, state) {
                      if (state is! AppNavigating) return const SizedBox.shrink();
                      final user = state.user;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: AppSpacing.avatarSm,
                            height: AppSpacing.avatarSm,
                            decoration: BoxDecoration(
                              color: primaryLight,
                              borderRadius: AppSpacing.borderFull,
                            ),
                            child: Center(
                              child: Text(
                                user.username[0].toUpperCase(),
                                style: AppTypography.labelMd.copyWith(color: primaryColor),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.gapSm),
                          Text(
                            user.username,
                            style: AppTypography.labelMd.copyWith(color: textPrimary),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: borderColor),
        ],
      ),
    );
  }
}
