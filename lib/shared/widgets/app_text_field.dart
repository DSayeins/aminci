import 'package:flutter/material.dart';

import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';

/// Champ de texte labellisé réutilisable.
///
/// Regroupe le label, le gap et le TextField en un seul widget.
/// Supporte la visibilité toggle pour les champs mot de passe.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.focusNode,
    this.nextFocus,
    this.enabled = true,
    this.autofocus = false,
    this.obscure = false,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.fillColor = AppColors.bgPage,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final bool enabled;
  final bool autofocus;

  /// Si true, affiche un toggle visibilité (mode mot de passe).
  final bool obscure;

  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Color fillColor;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscure;
  }

  void _handleSubmitted(String value) {
    if (widget.nextFocus != null) {
      widget.nextFocus!.requestFocus();
    } else {
      widget.onSubmitted?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.gapSm),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          obscureText: _isObscured,
          textInputAction: widget.textInputAction,
          onSubmitted: _handleSubmitted,
          style: AppTypography.input.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            fillColor: widget.fillColor,
            suffixIcon: widget.obscure ? _VisibilityToggle(
              isObscured: _isObscured,
              onToggle: () => setState(() => _isObscured = !_isObscured),
            ) : null,
          ),
        ),
      ],
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.isObscured, required this.onToggle});

  final bool isObscured;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
        color: AppColors.textTertiary,
      ),
      onPressed: onToggle,
    );
  }
}
