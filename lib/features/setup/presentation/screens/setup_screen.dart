import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:aminci/features/setup/presentation/bloc/setup_bloc.dart';
import 'package:aminci/features/setup/presentation/widgets/setup_form_panel.dart';
import 'package:aminci/features/setup/presentation/widgets/setup_welcome_panel.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SetupBloc, SetupState>(
      listener: (context, state) {
        if (state is SetupSuccess) context.go('/login');
      },
      child: const Scaffold(
        body: Row(
          children: [
            Expanded(child: SetupWelcomePanel()),
            Expanded(child: SetupFormPanel()),
          ],
        ),
      ),
    );
  }
}
