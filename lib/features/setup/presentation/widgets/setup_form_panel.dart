import 'package:aminci/core/enum/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aminci/core/models/preference.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/user.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:aminci/features/setup/presentation/widgets/setup_admin_step.dart';
import 'package:aminci/features/setup/presentation/widgets/setup_preferences_step.dart';
import 'package:aminci/features/setup/presentation/widgets/setup_router_step.dart';

const _stepCount = 3;

class SetupFormPanel extends StatefulWidget {
  const SetupFormPanel({super.key});

  @override
  State<SetupFormPanel> createState() => _SetupFormPanelState();
}

class _SetupFormPanelState extends State<SetupFormPanel> {
  // Étape 1 — compte admin
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  // Étape 2 — premier routeur
  final _routerNameController = TextEditingController();
  final _routerIpController = TextEditingController();
  final _routerPortController = TextEditingController(text: MikroTikRouter.defaultRestPort.toString());
  final _routerUsernameController = TextEditingController(text: 'admin');
  final _routerPasswordController = TextEditingController();
  final _routerNameFocus = FocusNode();
  final _routerIpFocus = FocusNode();
  final _routerPortFocus = FocusNode();
  final _routerUsernameFocus = FocusNode();
  final _routerPasswordFocus = FocusNode();

  // Étape 3 — préférences
  final _currencyController = TextEditingController(text: 'FCFA');
  String _dateFormat = 'dd/MM/yyyy';
  AppThemeMode _themeMode = AppThemeMode.system;

  String? _validationError;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _routerNameController.dispose();
    _routerIpController.dispose();
    _routerPortController.dispose();
    _routerUsernameController.dispose();
    _routerPasswordController.dispose();
    _routerNameFocus.dispose();
    _routerIpFocus.dispose();
    _routerPortFocus.dispose();
    _routerUsernameFocus.dispose();
    _routerPasswordFocus.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  /// Valide l'étape [step] — retourne un message d'erreur, ou `null` si valide.
  String? _validateStep(int step) {
    switch (step) {
      case 0:
        if (_nameController.text.trim().isEmpty) return 'Le nom est requis';
        if (_usernameController.text.trim().isEmpty) return 'Le nom d\'utilisateur est requis';
        if (_passwordController.text.isEmpty) return 'Le mot de passe est requis';
        if (_passwordController.text != _confirmController.text) {
          return 'Les mots de passe ne correspondent pas';
        }
        return null;
      case 1:
        if (_routerNameController.text.trim().isEmpty) return 'Le nom du routeur est requis';
        if (_routerIpController.text.trim().isEmpty) return 'L\'adresse IP du routeur est requise';
        final port = int.tryParse(_routerPortController.text.trim());
        if (port == null || port <= 0) return 'Port du routeur invalide';
        if (_routerUsernameController.text.trim().isEmpty) {
          return 'Le nom d\'utilisateur du routeur est requis';
        }
        if (_routerPasswordController.text.isEmpty) return 'Le mot de passe du routeur est requis';
        return null;
      default:
        return null;
    }
  }

  void _goToStep(int step) {
    setState(() => _validationError = null);
    context.read<SetupBloc>().add(SetupStepChanged(step));
  }

  void _onNext(int currentStep) {
    final error = _validateStep(currentStep);
    if (error != null) {
      setState(() => _validationError = error);
      return;
    }
    if (currentStep < _stepCount - 1) {
      _goToStep(currentStep + 1);
    } else {
      _submit();
    }
  }

  void _submit() {
    final user = User(
      id: 0,
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      role: UserRole.admin,
    );
    final router = MikroTikRouter(
      id: 0,
      name: _routerNameController.text.trim(),
      ip: _routerIpController.text.trim(),
      port: int.parse(_routerPortController.text.trim()),
      username: _routerUsernameController.text.trim(),
      password: _routerPasswordController.text,
    );
    final preference = Preference(
      themeMode: _themeMode,
      currency: _currencyController.text.trim().isEmpty ? 'FCFA' : _currencyController.text.trim(),
      dateFormat: _dateFormat,
    );

    context.read<SetupBloc>().add(SetupSubmitted(user: user, router: router, preference: preference));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgSurface,
      padding: AppSpacing.insetPage,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: SingleChildScrollView(
            child: BlocBuilder<SetupBloc, SetupState>(
              builder: (context, state) {
                final currentStep = state.currentStep;
                final isLoading = state is SetupLoading;
                final blocError = state is SetupError ? state.message : null;
                final error = blocError ?? _validationError;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _stepTitle(currentStep),
                      style: AppTypography.pageTitleLg.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.gapSm),
                    Text(
                      _stepSubtitle(currentStep),
                      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.gapXl),

                    switch (currentStep) {
                      1 => SetupRouterStep(
                        nameController: _routerNameController,
                        ipController: _routerIpController,
                        portController: _routerPortController,
                        usernameController: _routerUsernameController,
                        passwordController: _routerPasswordController,
                        nameFocus: _routerNameFocus,
                        ipFocus: _routerIpFocus,
                        portFocus: _routerPortFocus,
                        usernameFocus: _routerUsernameFocus,
                        passwordFocus: _routerPasswordFocus,
                        enabled: !isLoading,
                        onSubmitted: () => _onNext(currentStep),
                      ),
                      2 => SetupPreferencesStep(
                        currencyController: _currencyController,
                        dateFormat: _dateFormat,
                        themeMode: _themeMode,
                        enabled: !isLoading,
                        onDateFormatChanged: (v) => setState(() => _dateFormat = v),
                        onThemeModeChanged: (v) => setState(() => _themeMode = v),
                      ),
                      _ => SetupAdminStep(
                        nameController: _nameController,
                        usernameController: _usernameController,
                        passwordController: _passwordController,
                        confirmController: _confirmController,
                        usernameFocus: _usernameFocus,
                        passwordFocus: _passwordFocus,
                        confirmFocus: _confirmFocus,
                        enabled: !isLoading,
                        onSubmitted: () => _onNext(currentStep),
                      ),
                    },

                    // Erreur
                    if (error != null) ...[
                      const SizedBox(height: AppSpacing.gapMd),
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
                        child: Text(error, style: AppTypography.bodySm.copyWith(color: AppColors.textError)),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.gapXl),

                    Row(
                      children: [
                        if (currentStep > 0) ...[
                          Expanded(
                            child: SizedBox(
                              height: AppSpacing.buttonHeightLg,
                              child: OutlinedButton(
                                onPressed: isLoading ? null : () => _goToStep(currentStep - 1),
                                child: const Text('Précédent'),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.gapMd),
                        ],
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: AppSpacing.buttonHeightLg,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : () => _onNext(currentStep),
                              child: isLoading
                                  ? SizedBox(
                                      width: AppSpacing.iconMd,
                                      height: AppSpacing.iconMd,
                                      child: CircularProgressIndicator(
                                        strokeWidth: AppSpacing.borderDefault,
                                        color: AppColors.textOnPrimary,
                                      ),
                                    )
                                  : Text(currentStep < _stepCount - 1 ? 'Suivant' : 'Créer le compte'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _stepTitle(int step) {
    switch (step) {
      case 1:
        return 'Ajouter votre premier routeur';
      case 2:
        return 'Choisir vos préférences';
      default:
        return 'Créer le compte administrateur';
    }
  }

  String _stepSubtitle(int step) {
    switch (step) {
      case 1:
        return 'Ce routeur MikroTik sera utilisé pour générer vos premiers vouchers.';
      case 2:
        return 'Ces réglages peuvent être modifiés plus tard.';
      default:
        return 'Premier lancement — ce compte aura accès complet à l\'application.';
    }
  }
}
