import 'package:equatable/equatable.dart';

/// Un point de la courbe d'évolution du chiffre d'affaires — total des
/// ventes pour ce jour-là.
class RevenuePoint extends Equatable {
  final DateTime date;
  final double revenue;

  const RevenuePoint({required this.date, required this.revenue});

  @override
  List<Object?> get props => [date, revenue];
}

/// Métriques agrégées du dashboard pour un routeur — calculées à partir du
/// cache local des vouchers (`vouchers`), jamais depuis le routeur en direct
/// (prix/statut/date n'existent que localement).
class DashboardMetrics extends Equatable {
  final double revenueToday;
  final double revenueWeek;
  final double revenueMonth;

  final int vouchersPending;
  final int vouchersActive;
  final int vouchersExpired;

  /// Chiffre d'affaires jour par jour sur les 30 derniers jours (le plus
  /// ancien en premier), pour la courbe de tendance.
  final List<RevenuePoint> revenueTrend;

  const DashboardMetrics({
    this.revenueToday = 0,
    this.revenueWeek = 0,
    this.revenueMonth = 0,
    this.vouchersPending = 0,
    this.vouchersActive = 0,
    this.vouchersExpired = 0,
    this.revenueTrend = const [],
  });

  int get vouchersTotal => vouchersPending + vouchersActive + vouchersExpired;

  @override
  List<Object?> get props => [
    revenueToday,
    revenueWeek,
    revenueMonth,
    vouchersPending,
    vouchersActive,
    vouchersExpired,
    revenueTrend,
  ];
}
