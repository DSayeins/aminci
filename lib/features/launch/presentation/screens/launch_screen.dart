import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/app/presentation/screens/app_shell.dart';
import 'package:aminci/features/auth/presentation/screens/auth_screen.dart';
import 'package:aminci/features/launch/presentation/bloc/launch_bloc.dart';
import 'package:aminci/features/setup/presentation/screens/setup_screen.dart';
import 'package:aminci/shared/widgets/error_view.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LaunchBloc>().add(const LaunchStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LaunchBloc, LaunchState>(
      builder: (context, state) {
        return switch (state) {
          LaunchInitial() => const _SplashView(),
          LaunchFirstTime() => const SetupScreen(),
          LaunchAuthenticated() => const AppShell(),
          LaunchUnauthenticated() => const AuthScreen(),
          LaunchError(:final message) => ErrorView(
            message: message,
            onRetry: () => context.read<LaunchBloc>().add(const LaunchStarted()),
          ),
        };
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Vue splash
// -----------------------------------------------------------------------------

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpacing.x16,
              height: AppSpacing.x16,
              decoration: BoxDecoration(color: AppColors.logoBg, borderRadius: AppSpacing.borderLg),
              child: const Icon(Icons.wifi_tethering_rounded, color: AppColors.textOnPrimary, size: AppSpacing.iconXl),
            ),
            SizedBox(height: AppSpacing.gapLg),
            Text('Aminci', style: AppTypography.logoText.copyWith(color: AppColors.textPrimary)),
            SizedBox(height: AppSpacing.gapSm),
            Text('Gestion de vouchers MikroTik', style: AppTypography.logoSub.copyWith(color: AppColors.textSecondary)),
            SizedBox(height: AppSpacing.gapXl),
            SizedBox(
              width: AppSpacing.x12,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.bgSubtle,
                color: AppColors.primary,
                minHeight: AppSpacing.borderDefault,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
