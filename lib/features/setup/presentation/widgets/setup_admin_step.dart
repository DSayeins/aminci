import 'package:flutter/material.dart';

import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/shared/widgets/app_text_field.dart';

/// Étape 1 du wizard de setup — création du compte administrateur.
class SetupAdminStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final FocusNode usernameFocus;
  final FocusNode passwordFocus;
  final FocusNode confirmFocus;
  final bool enabled;
  final VoidCallback onSubmitted;

  const SetupAdminStep({
    super.key,
    required this.nameController,
    required this.usernameController,
    required this.passwordController,
    required this.confirmController,
    required this.usernameFocus,
    required this.passwordFocus,
    required this.confirmFocus,
    required this.enabled,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Nom complet',
          controller: nameController,
          hint: 'Jean Dupont',
          enabled: enabled,
          autofocus: true,
          nextFocus: usernameFocus,
        ),
        const SizedBox(height: AppSpacing.gapLg),
        AppTextField(
          label: 'Nom d\'utilisateur',
          controller: usernameController,
          focusNode: usernameFocus,
          hint: 'admin',
          enabled: enabled,
          nextFocus: passwordFocus,
        ),
        const SizedBox(height: AppSpacing.gapLg),
        AppTextField(
          label: 'Mot de passe',
          controller: passwordController,
          focusNode: passwordFocus,
          hint: '••••••••',
          enabled: enabled,
          obscure: true,
          nextFocus: confirmFocus,
        ),
        const SizedBox(height: AppSpacing.gapLg),
        AppTextField(
          label: 'Confirmer le mot de passe',
          controller: confirmController,
          focusNode: confirmFocus,
          hint: '••••••••',
          enabled: enabled,
          obscure: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmitted(),
        ),
      ],
    );
  }
}
