import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/utils/currency_formatter.dart';
import 'package:aminci/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:aminci/features/dashboard/presentation/widgets/revenue_trend_chart.dart';
import 'package:aminci/features/dashboard/presentation/widgets/voucher_status_breakdown.dart';
import 'package:aminci/features/routers/presentation/bloc/routers_bloc.dart';
import 'package:aminci/shared/widgets/empty_state.dart';
import 'package:aminci/shared/widgets/error_view.dart';
import 'package:aminci/shared/widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  MikroTikRouter? _router;

  @override
  void initState() {
    super.initState();
    final state = context.read<RoutersBloc>().state;
    _router = state is RoutersLoaded ? state.selectedRouter : null;
    _load();
  }

  void _load() {
    final router = _router;
    if (router != null) context.read<DashboardBloc>().add(DashboardLoadRequested(router));
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
        subtitle: 'Choisissez un routeur pour voir le dashboard.',
      );
    }

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading || state is DashboardInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DashboardError) {
          return ErrorView(message: state.message, onRetry: _load);
        }

        final loaded = state as DashboardLoaded;
        final metrics = loaded.metrics;

        return SingleChildScrollView(
          padding: AppSpacing.insetPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.payments_rounded,
                      value: CurrencyFormatter.format(metrics.revenueToday),
                      label: 'Chiffre d\'affaires — aujourd\'hui',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapMd),
                  Expanded(
                    child: StatCard(
                      icon: Icons.calendar_view_week_rounded,
                      value: CurrencyFormatter.format(metrics.revenueWeek),
                      label: 'Chiffre d\'affaires — cette semaine',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapMd),
                  Expanded(
                    child: StatCard(
                      icon: Icons.calendar_month_rounded,
                      value: CurrencyFormatter.format(metrics.revenueMonth),
                      label: 'Chiffre d\'affaires — ce mois',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.gapMd),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.confirmation_number_rounded,
                      value: '${metrics.vouchersTotal}',
                      label: 'Vouchers générés',
                      accentColor: AppColors.statusPending,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapMd),
                  Expanded(
                    child: StatCard(
                      icon: Icons.sensors_rounded,
                      value: '${loaded.activeSessionsCount}',
                      label: 'Sessions actives',
                      accentColor: AppColors.statusActive,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.gapLg),
              RevenueTrendChart(points: metrics.revenueTrend),
              const SizedBox(height: AppSpacing.gapLg),
              VoucherStatusBreakdown(metrics: metrics),
            ],
          ),
        );
      },
    );
  }
}
