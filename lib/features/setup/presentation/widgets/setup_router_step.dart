import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/shared/widgets/app_text_field.dart';

/// Étape 2 du wizard de setup — premier routeur MikroTik (obligatoire).
class SetupRouterStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ipController;
  final TextEditingController portController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final FocusNode nameFocus;
  final FocusNode ipFocus;
  final FocusNode portFocus;
  final FocusNode usernameFocus;
  final FocusNode passwordFocus;
  final bool enabled;
  final VoidCallback onSubmitted;

  const SetupRouterStep({
    super.key,
    required this.nameController,
    required this.ipController,
    required this.portController,
    required this.usernameController,
    required this.passwordController,
    required this.nameFocus,
    required this.ipFocus,
    required this.portFocus,
    required this.usernameFocus,
    required this.passwordFocus,
    required this.enabled,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Nom du site',
          controller: nameController,
          focusNode: nameFocus,
          hint: 'Cybercafé Central',
          enabled: enabled,
          autofocus: true,
          nextFocus: ipFocus,
        ),
        const SizedBox(height: AppSpacing.gapLg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: AppTextField(
                label: 'Adresse IP',
                controller: ipController,
                focusNode: ipFocus,
                hint: '192.168.1.1',
                enabled: enabled,
                nextFocus: portFocus,
              ),
            ),
            const SizedBox(width: AppSpacing.gapMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Port', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.gapSm),
                  TextField(
                    controller: portController,
                    focusNode: portFocus,
                    enabled: enabled,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => usernameFocus.requestFocus(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: AppTypography.input.copyWith(color: AppColors.textPrimary),
                    decoration: const InputDecoration(hintText: '80', fillColor: AppColors.bgPage),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.gapLg),
        AppTextField(
          label: 'Nom d\'utilisateur du routeur',
          controller: usernameController,
          focusNode: usernameFocus,
          hint: 'admin',
          enabled: enabled,
          nextFocus: passwordFocus,
        ),
        const SizedBox(height: AppSpacing.gapLg),
        AppTextField(
          label: 'Mot de passe du routeur',
          controller: passwordController,
          focusNode: passwordFocus,
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
