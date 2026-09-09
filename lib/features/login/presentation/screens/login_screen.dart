import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:aminci/features/login/presentation/bloc/login_bloc.dart';
import 'package:aminci/features/login/presentation/widgets/login_form_panel.dart';
import 'package:aminci/shared/widgets/branding_panel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginAuthenticated) context.go('/routers');
      },
      child: const Scaffold(
        body: Row(
          children: [
            Expanded(child: BrandingPanel()),
            Expanded(child: LoginFormPanel()),
          ],
        ),
      ),
    );
  }
}
