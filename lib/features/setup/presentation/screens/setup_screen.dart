import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/di/service_locator.dart';
import 'package:aminci/features/launch/presentation/bloc/launch_bloc.dart';
import 'package:aminci/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:aminci/features/setup/presentation/widgets/setup_form_panel.dart';
import 'package:aminci/shared/widgets/branding_panel.dart';

/// Écran de configuration initiale — affiché uniquement au premier lancement.
///
/// Crée le premier compte administrateur.
/// Sur [SetupSuccess], redéclenche [LaunchStarted] pour repasser par le flux normal.
class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SetupBloc>(),
      child: BlocListener<SetupBloc, SetupState>(
        listener: (context, state) {
          if (state is SetupSuccess) {
            context.read<LaunchBloc>().add(const LaunchStarted());
          }
        },
        child: Scaffold(
          body: Row(
            children: [
              const Expanded(child: BrandingPanel()),
              const Expanded(child: SetupFormPanel()),
            ],
          ),
        ),
      ),
    );
  }
}
