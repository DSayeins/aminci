import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:aminci/features/auth/presentation/widgets/auth_form_panel.dart';
import 'package:aminci/shared/widgets/branding_panel.dart';
import 'package:aminci/features/launch/presentation/bloc/launch_bloc.dart';

/// Écran de connexion — deux panels côte à côte.
/// Délègue tout le visuel à [BrandingPanel] et [AuthFormPanel].
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.read<LaunchBloc>().add(const LaunchStarted());
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            const Expanded(child: BrandingPanel()),
            const Expanded(child: AuthFormPanel()),
          ],
        ),
      ),
    );
  }
}
