import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/auth/presentation/bloc/auth_bloc.dart';

/// Panel droit de l'écran de connexion — formulaire d'identification.
class AuthFormPanel extends StatefulWidget {
  const AuthFormPanel({super.key});

  @override
  State<AuthFormPanel> createState() => _AuthFormPanelState();
}

class _AuthFormPanelState extends State<AuthFormPanel> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) return;
    context.read<AuthBloc>().add(AuthLoginRequested(username: username, password: password));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgSurface,
      padding: AppSpacing.insetPage,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Connexion', style: AppTypography.pageTitleLg.copyWith(color: AppColors.textPrimary)),
                  SizedBox(height: AppSpacing.gapSm),
                  Text(
                    'Entrez vos identifiants pour accéder à l\'application.',
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: AppSpacing.gapXl),

                  // Champ username
                  Text('Nom d\'utilisateur', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                  SizedBox(height: AppSpacing.gapSm),
                  TextField(
                    controller: _usernameController,
                    enabled: !isLoading,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                    style: AppTypography.input.copyWith(color: AppColors.textPrimary),
                    decoration: const InputDecoration(hintText: 'admin'),
                  ),
                  SizedBox(height: AppSpacing.gapLg),

                  // Champ password
                  Text('Mot de passe', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                  SizedBox(height: AppSpacing.gapSm),
                  TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    enabled: !isLoading,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    style: AppTypography.input.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          size: AppSpacing.iconMd,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),

                  // Message d'erreur
                  if (state is AuthError) ...[
                    SizedBox(height: AppSpacing.gapMd),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingSm, vertical: AppSpacing.gapSm),
                      decoration: BoxDecoration(
                        color: AppColors.errorBg,
                        borderRadius: AppSpacing.borderSm,
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: AppSpacing.borderThin),
                      ),
                      child: Text(state.message, style: AppTypography.bodySm.copyWith(color: AppColors.textError)),
                    ),
                  ],

                  SizedBox(height: AppSpacing.gapXl),

                  // Bouton connexion
                  SizedBox(
                    height: AppSpacing.buttonHeightLg,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      child: isLoading
                          ? SizedBox(
                              width: AppSpacing.iconMd,
                              height: AppSpacing.iconMd,
                              child: CircularProgressIndicator(
                                strokeWidth: AppSpacing.borderDefault,
                                color: AppColors.textOnPrimary,
                              ),
                            )
                          : const Text('Se connecter'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
