import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/features/active_sessions/presentation/active_session_filter.dart';
import 'package:aminci/features/active_sessions/presentation/bloc/active_sessions_bloc.dart';
import 'package:aminci/features/active_sessions/presentation/widgets/active_session_filter_bar.dart';
import 'package:aminci/features/active_sessions/presentation/widgets/active_session_tile.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';
import 'package:aminci/shared/widgets/empty_state.dart';
import 'package:aminci/shared/widgets/error_view.dart';

class ActiveSessionsScreen extends StatefulWidget {
  const ActiveSessionsScreen({super.key});

  @override
  State<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends State<ActiveSessionsScreen> {
  MikroTikRouter? _router;
  // Capturé dans initState plutôt que relu dans dispose() : si cet écran est
  // démonté en même temps que ses ancêtres (ex. déconnexion qui remplace tout
  // le ShellRoute), l'élément n'est plus assez stable en dispose() pour
  // remonter vers le Provider — voir "Looking up a deactivated widget's
  // ancestor is unsafe".
  late final ActiveSessionsBloc _activeSessionsBloc;
  ProfileFilter _profileFilter = const AllProfiles();

  @override
  void initState() {
    super.initState();
    _activeSessionsBloc = context.read<ActiveSessionsBloc>();
    final state = context.read<RoutersBloc>().state;
    _router = state is RoutersLoaded ? state.selectedRouter : null;
    _load();
  }

  void _load() {
    final router = _router;
    if (router != null) _activeSessionsBloc.add(ActiveSessionsLoadRequested(router));
  }

  @override
  void dispose() {
    // Le bloc est partagé (registré globalement) — on arrête explicitement
    // le rafraîchissement automatique en quittant l'écran pour ne pas
    // continuer à interroger le routeur en arrière-plan.
    _activeSessionsBloc.add(const ActiveSessionsStopped());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = _router;
    if (router == null) {
      // AppShell garantit normalement un routeur sélectionné avant d'atteindre
      // cette page — filet de sécurité si jamais ce n'est pas le cas.
      return const EmptyState(
        icon: Icons.router_rounded,
        title: 'Aucun routeur sélectionné',
        subtitle: 'Choisissez un routeur pour voir ses sessions actives.',
      );
    }

    return BlocBuilder<ActiveSessionsBloc, ActiveSessionsState>(
      builder: (context, state) {
        if (state is ActiveSessionsLoading || state is ActiveSessionsInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ActiveSessionsError) {
          return ErrorView(message: state.message, onRetry: _load);
        }

        final loaded = state as ActiveSessionsLoaded;

        if (loaded.sessions.isEmpty) {
          return const EmptyState(
            icon: Icons.sensors_off_rounded,
            title: 'Aucune session active',
            subtitle: 'Personne n\'est actuellement connecté au hotspot.',
          );
        }

        final filtered = filterSessions(loaded.sessions, _profileFilter);

        return Column(
          children: [
            ActiveSessionFilterBar(
              options: profileFilterOptions(loaded.sessions, _profileFilter),
              selected: _profileFilter,
              onChanged: (filter) => setState(() => _profileFilter = filter),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyState(
                      icon: Icons.filter_alt_off_rounded,
                      title: 'Aucune session pour ce profil',
                      subtitle: 'Personne n\'est connecté avec ce profil en ce moment.',
                    )
                  : ListView.separated(
                      padding: AppSpacing.insetPage,
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.gapSm),
                      itemBuilder: (context, index) {
                        final session = filtered[index];
                        return ActiveSessionTile(
                          session: session,
                          isBusy: loaded.isBusy,
                          onDisconnect: () => context.read<ActiveSessionsBloc>().add(
                                ActiveSessionsDisconnectRequested(router, session),
                              ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
