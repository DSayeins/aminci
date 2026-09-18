import 'package:equatable/equatable.dart';

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

  const DashboardMetrics({
    this.revenueToday = 0,
    this.revenueWeek = 0,
    this.revenueMonth = 0,
    this.vouchersPending = 0,
    this.vouchersActive = 0,
    this.vouchersExpired = 0,
  });

  int get vouchersTotal => vouchersPending + vouchersActive + vouchersExpired;

  @override
  List<Object?> get props => [revenueToday, revenueWeek, revenueMonth, vouchersPending, vouchersActive, vouchersExpired];
}
