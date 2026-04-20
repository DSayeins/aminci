import 'package:aminci/features/launch/presentation/bloc/launch_bloc.dart';
import 'package:aminci/features/profiles/presentation/screens/profiles_screen.dart';
import 'package:aminci/features/routers/presentation/screens/routers_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aminci/core/navigation/routes.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/features/app/presentation/bloc/app_bloc.dart';
import 'package:aminci/features/app/presentation/widgets/app_sidebar.dart';
import 'package:aminci/features/app/presentation/widgets/app_topbar.dart';

/// Shell principal de l'application.
///
/// Affiché uniquement quand l'utilisateur est authentifié — garanti par le flux LaunchBloc.
/// AppShell charge lui-même les données de l'utilisateur actif via AppBloc.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    debugPrint('[AppShell] initState → AppStarted dispatché');
    context.read<AppBloc>().add(const AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColorsDark.bgPage : AppColors.bgPage,
      body: BlocConsumer<AppBloc, AppState>(
        listener: (context, state) {
          if (state is AppClosed) {
            debugPrint('[AppShell] AppClosed → LaunchStarted');
            context.read<LaunchBloc>().add(const LaunchStarted());
          }
        },
        builder: (context, state) {
          debugPrint('[AppShell] AppBloc state = ${state.runtimeType}');

          if (state is! AppNavigating) {
            debugPrint('[AppShell] État non-navigating → écran vide affiché');
            return const SizedBox.shrink();
          }

          debugPrint(
            '[AppShell] currentPage = ${state.currentPage.name}, index = ${state.availablePages.indexOf(state.currentPage)}',
          );

          return Row(
            children: [
              const AppSidebar(),
              const VerticalDivider(width: 1),
              Expanded(
                child: Column(
                  children: [
                    AppTopBar(currentPage: state.currentPage),
                    Expanded(
                      child: IndexedStack(
                        index: state.availablePages.indexOf(state.currentPage),
                        children: state.availablePages.map(_buildPage).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPage(Routes page) {
    return switch (page) {
      Routes.dashboard => const Placeholder(),
      Routes.sessions => const Placeholder(),
      Routes.routers => const RoutersScreen(),
      Routes.profiles => const ProfilesScreen(),
      Routes.history => const Placeholder(),
    };
  }
}
