import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aminci/features/launch/presentation/bloc/launch_bloc.dart';
import 'package:aminci/features/login/presentation/bloc/login_bloc.dart';
import 'package:aminci/shared/widgets/error_view.dart';
import 'package:aminci/shared/widgets/splash_view.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LaunchBloc>().add(const LaunchStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LaunchBloc, LaunchState>(
      listener: (context, state) {
        if (state is LaunchFirstTime) context.go('/setup');
        if (state is LaunchAuthenticated) {
          // Réhydrate LoginBloc — la session vient d'être restaurée depuis la
          // DB, pas d'un login fraîchement effectué dans cette session app.
          context.read<LoginBloc>().add(LoginSessionRestored(state.user));
          context.go('/dashboard');
        }
        if (state is LaunchUnauthenticated) context.go('/login');
      },
      child: BlocBuilder<LaunchBloc, LaunchState>(
        builder: (context, state) {
          if (state is LaunchError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<LaunchBloc>().add(const LaunchStarted()),
            );
          }
          return const SplashView();
        },
      ),
    );
  }
}
