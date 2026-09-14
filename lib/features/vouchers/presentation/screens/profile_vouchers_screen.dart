import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/di/service_locator.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/features/vouchers/presentation/bloc/vouchers_bloc.dart';
import 'package:aminci/shared/widgets/empty_state.dart';
import 'package:aminci/shared/widgets/error_view.dart';

/// Ouvre l'écran des vouchers générés pour [profile] sur [router].
///
/// Écran secondaire (poussé au-dessus de l'écran des profils), pas de route
/// go_router dédiée — cohérent avec les dialogs de création/modification.
Future<void> showProfileVouchersScreen(BuildContext context, MikroTikRouter router, HotspotProfile profile) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => sl<VouchersBloc>()
          ..add(VouchersLoadRequested(router, profile)),
        child: ProfileVouchersScreen(router: router, profile: profile),
      ),
    ),
  );
}

class ProfileVouchersScreen extends StatelessWidget {
  final MikroTikRouter router;
  final HotspotProfile profile;

  const ProfileVouchersScreen({super.key, required this.router, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vouchers — ${profile.mikrotikName}')),
      body: BlocBuilder<VouchersBloc, VouchersState>(
        builder: (context, state) {
          if (state is VouchersLoading || state is VouchersInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VouchersError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<VouchersBloc>().add(
                    VouchersLoadRequested(router, profile),
                  ),
            );
          }

          final loaded = state as VouchersLoaded;

          if (loaded.vouchers.isEmpty) {
            return const EmptyState(
              icon: Icons.confirmation_number_outlined,
              title: 'Aucun voucher généré',
              subtitle: 'Les vouchers générés pour ce profil\napparaîtront ici.',
            );
          }

          return ListView.separated(
            padding: AppSpacing.insetPage,
            itemCount: loaded.vouchers.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.gapSm),
            itemBuilder: (context, index) {
              final voucher = loaded.vouchers[index];
              return ListTile(title: Text(voucher.code));
            },
          );
        },
      ),
    );
  }
}
