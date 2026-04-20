import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/setup/presentation/bloc/setup_bloc.dart';

/// Panel droit de l'écran de configuration initiale — création du compte admin.
class SetupFormPanel extends StatefulWidget {
  const SetupFormPanel({super.key});

  @override
  State<SetupFormPanel> createState() => _SetupFormPanelState();
}

class _SetupFormPanelState extends State<SetupFormPanel> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (username.isEmpty || password.isEmpty || confirm.isEmpty) return;
    if (password != confirm) return;

    context.read<SetupBloc>().add(
          SetupAdminSubmitted(username: username, password: password),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgSurface,
      padding: AppSpacing.insetPage,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: BlocBuilder<SetupBloc, SetupState>(
            builder: (context, state) {
              final isLoading = state is SetupLoading;
              final passwordMismatch = _confirmController.text.isNotEmpty &&
                  _passwordController.text != _confirmController.text;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Créer le compte administrateur',
                    style: AppTypography.pageTitleLg.copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: AppSpacing.gapSm),
                  Text(
                    'Ce compte sera le premier administrateur de l\'application.',
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: AppSpacing.gapXl),

                  // Nom d'utilisateur
                  Text(
                    'Nom d\'utilisateur',
                    style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
                  ),
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

                  // Mot de passe
                  Text(
                    'Mot de passe',
                    style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: AppSpacing.gapSm),
                  TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    enabled: !isLoading,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _confirmFocus.requestFocus(),
                    onChanged: (_) => setState(() {}),
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
                  SizedBox(height: AppSpacing.gapLg),

                  // Confirmation mot de passe
                  Text(
                    'Confirmer le mot de passe',
                    style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: AppSpacing.gapSm),
                  TextField(
                    controller: _confirmController,
                    focusNode: _confirmFocus,
                    enabled: !isLoading,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    onChanged: (_) => setState(() {}),
                    style: AppTypography.input.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          size: AppSpacing.iconMd,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),

                  // Erreur mots de passe non identiques
                  if (passwordMismatch) ...[
                    SizedBox(height: AppSpacing.gapSm),
                    Text(
                      'Les mots de passe ne correspondent pas.',
                      style: AppTypography.bodySm.copyWith(color: AppColors.textError),
                    ),
                  ],

                  // Erreur BLoC
                  if (state is SetupError) ...[
                    SizedBox(height: AppSpacing.gapMd),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.paddingSm,
                        vertical: AppSpacing.gapSm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorBg,
                        borderRadius: AppSpacing.borderSm,
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                          width: AppSpacing.borderThin,
                        ),
                      ),
                      child: Text(
                        state.message,
                        style: AppTypography.bodySm.copyWith(color: AppColors.textError),
                      ),
                    ),
                  ],

                  SizedBox(height: AppSpacing.gapXl),

                  // Bouton
                  SizedBox(
                    height: AppSpacing.buttonHeightLg,
                    child: ElevatedButton(
                      onPressed: isLoading || passwordMismatch ? null : _submit,
                      child: isLoading
                          ? SizedBox(
                              width: AppSpacing.iconMd,
                              height: AppSpacing.iconMd,
                              child: CircularProgressIndicator(
                                strokeWidth: AppSpacing.borderDefault,
                                color: AppColors.textOnPrimary,
                              ),
                            )
                          : const Text('Créer le compte'),
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
