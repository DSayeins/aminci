import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/setup/presentation/bloc/setup_bloc.dart';

/// Libellés des étapes du wizard de setup — l'index correspond à [SetupState.currentStep].
const _stepLabels = ['Créer le compte administrateur', 'Ajouter votre premier routeur', 'Choisir vos préférences'];

class SetupWelcomePanel extends StatelessWidget {
  const SetupWelcomePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final currentStep = context.watch<SetupBloc>().state.currentStep;

    return Stack(
      children: [
        // Fond dégradé
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
            ),
          ),
        ),

        // Cercles décoratifs
        const Positioned(top: -60, right: -50, child: _Circle(220, 0.07)),
        const Positioned(bottom: -80, left: -50, child: _Circle(260, 0.05)),
        const Positioned(top: 160, left: -40, child: _Circle(120, 0.04)),

        // Contenu
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingXl,
            vertical: AppSpacing.paddingLg,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              _Logo(),
              const SizedBox(height: AppSpacing.gapXl),

              // Badge premier lancement
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x3,
                  vertical: AppSpacing.x1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.borderFull,
                  border: Border.all(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.25),
                    width: AppSpacing.borderThin,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fiber_new_rounded,
                      size: AppSpacing.iconSm,
                      color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: AppSpacing.gapXs),
                    Text(
                      'Premier lancement',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.gapMd),

              // Titre de bienvenue
              Text(
                'Bienvenue\nsur Aminci',
                style: AppTypography.statValue.copyWith(
                  color: AppColors.textOnPrimary,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: AppSpacing.gapSm),
              Text(
                'Configurez votre compte administrateur\npour commencer à gérer vos vouchers.',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: AppSpacing.gapXl),
              _Separator(),
              const SizedBox(height: AppSpacing.gapXl),

              // Étapes
              Text(
                'Configuration initiale',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.gapMd),
              for (var i = 0; i < _stepLabels.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.gapSm),
                _Step(
                  number: '${i + 1}',
                  label: _stepLabels[i],
                  status: i < currentStep
                      ? _StepStatus.completed
                      : i == currentStep
                      ? _StepStatus.active
                      : _StepStatus.upcoming,
                ),
              ],
            ],
          ),
        ),

        // Badge version
        const Positioned(
          bottom: AppSpacing.gapLg,
          right: AppSpacing.gapLg,
          child: _VersionBadge(),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Logo
// -----------------------------------------------------------------------------

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.x16 + AppSpacing.x3,
      height: AppSpacing.x16 + AppSpacing.x3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: AppSpacing.x16 + AppSpacing.x3,
            height: AppSpacing.x16 + AppSpacing.x3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                width: AppSpacing.borderThick,
              ),
            ),
          ),
          Container(
            width: AppSpacing.x16,
            height: AppSpacing.x16,
            decoration: const BoxDecoration(
              color: AppColors.textOnPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_tethering_rounded,
              color: AppColors.primary,
              size: AppSpacing.iconXl,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Étape de configuration
// -----------------------------------------------------------------------------

enum _StepStatus { completed, active, upcoming }

const _stepAnimDuration = Duration(milliseconds: 280);
const _stepAnimCurve = Curves.easeOutCubic;

class _Step extends StatelessWidget {
  final String number;
  final String label;
  final _StepStatus status;

  const _Step({required this.number, required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == _StepStatus.completed;
    final isActive = status == _StepStatus.active;
    // Complétée : grisée (faible opacité), ni active ni neutre.
    final dotAlpha = isCompleted ? 0.15 : (isActive ? 0.2 : 0.0);
    final borderAlpha = isCompleted ? 0.15 : (isActive ? 0.4 : 0.2);
    final numberAlpha = isCompleted ? 0.35 : (isActive ? 1.0 : 0.4);
    final labelAlpha = isCompleted ? 0.35 : (isActive ? 0.9 : 0.4);

    return Row(
      children: [
        AnimatedContainer(
          duration: _stepAnimDuration,
          curve: _stepAnimCurve,
          width: AppSpacing.x6,
          height: AppSpacing.x6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotAlpha > 0 ? AppColors.textOnPrimary.withValues(alpha: dotAlpha) : Colors.transparent,
            border: Border.all(
              color: AppColors.textOnPrimary.withValues(alpha: borderAlpha),
              width: AppSpacing.borderThin,
            ),
          ),
          // Une étape active reçoit un léger halo pour se détacher du reste.
          foregroundDecoration: isActive
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.15),
                    width: AppSpacing.borderThick,
                  ),
                )
              : null,
          child: Center(
            child: AnimatedSwitcher(
              duration: _stepAnimDuration,
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: isCompleted
                  ? Icon(
                      Icons.check_rounded,
                      key: const ValueKey('check'),
                      size: AppSpacing.iconXs,
                      color: AppColors.textOnPrimary.withValues(alpha: numberAlpha),
                    )
                  : Text(
                      number,
                      key: ValueKey(number),
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: numberAlpha),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.gapMd),
        Expanded(
          child: AnimatedDefaultTextStyle(
            duration: _stepAnimDuration,
            curve: _stepAnimCurve,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: labelAlpha),
              decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
              decorationColor: AppColors.textOnPrimary.withValues(alpha: labelAlpha),
            ),
            child: Text(label),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Séparateur
// -----------------------------------------------------------------------------

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.x8,
      height: AppSpacing.borderThick,
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withValues(alpha: 0.35),
        borderRadius: AppSpacing.borderFull,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Badge version
// -----------------------------------------------------------------------------

class _VersionBadge extends StatelessWidget {
  const _VersionBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: AppSpacing.x1,
      ),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderFull,
        border: Border.all(
          color: AppColors.textOnPrimary.withValues(alpha: 0.15),
          width: AppSpacing.borderThin,
        ),
      ),
      child: Text(
        'v1.0',
        style: AppTypography.labelSm.copyWith(
          color: AppColors.textOnPrimary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Cercle décoratif
// -----------------------------------------------------------------------------

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;

  const _Circle(this.size, this.opacity);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textOnPrimary.withValues(alpha: opacity),
      ),
    );
  }
}
