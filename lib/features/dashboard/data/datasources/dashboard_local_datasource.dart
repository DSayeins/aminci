import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aminci/core/error/exceptions.dart';
import 'package:aminci/core/models/dashboard_metrics.dart';

/// Nombre de jours couverts par la courbe de tendance du chiffre d'affaires.
const int _trendDays = 30;

/// Calcule les métriques du dashboard à partir du cache local des vouchers.
class DashboardLocalDatasource {
  final Database _db;

  const DashboardLocalDatasource(this._db);

  Future<DashboardMetrics> getMetrics(int routerId) async {
    try {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      // Semaine calendaire commençant le lundi.
      final startOfWeek = startOfToday.subtract(Duration(days: startOfToday.weekday - 1));
      final startOfMonth = DateTime(now.year, now.month, 1);

      final revenueToday = await _sumPriceSince(routerId, startOfToday);
      final revenueWeek = await _sumPriceSince(routerId, startOfWeek);
      final revenueMonth = await _sumPriceSince(routerId, startOfMonth);
      final revenueTrend = await _getRevenueTrend(routerId, startOfToday);

      final statusRows = await _db.rawQuery(
        'SELECT status, COUNT(*) as count FROM vouchers WHERE router_id = ? GROUP BY status',
        [routerId],
      );
      var pending = 0;
      var active = 0;
      var expired = 0;
      for (final row in statusRows) {
        final count = (row['count'] as int?) ?? 0;
        switch (row['status']) {
          case 'pending':
            pending = count;
          case 'active':
            active = count;
          case 'expired':
            expired = count;
        }
      }

      return DashboardMetrics(
        revenueToday: revenueToday,
        revenueWeek: revenueWeek,
        revenueMonth: revenueMonth,
        vouchersPending: pending,
        vouchersActive: active,
        vouchersExpired: expired,
        revenueTrend: revenueTrend,
      );
    } catch (e) {
      throw StorageException('Impossible de calculer les métriques du dashboard : $e');
    }
  }

  Future<double> _sumPriceSince(int routerId, DateTime since) async {
    final rows = await _db.rawQuery(
      'SELECT COALESCE(SUM(price), 0) as total FROM vouchers WHERE router_id = ? AND created_at >= ?',
      [routerId, since.millisecondsSinceEpoch ~/ 1000],
    );
    return ((rows.first['total'] as num?) ?? 0).toDouble();
  }

  /// Chiffre d'affaires jour par jour sur les [_trendDays] derniers jours
  /// (bornes incluses), [startOfToday] inclus, avec `0` pour les jours sans
  /// vente.
  Future<List<RevenuePoint>> _getRevenueTrend(int routerId, DateTime startOfToday) async {
    final startOfTrend = startOfToday.subtract(const Duration(days: _trendDays - 1));
    final rows = await _db.rawQuery(
      'SELECT created_at, price FROM vouchers WHERE router_id = ? AND created_at >= ?',
      [routerId, startOfTrend.millisecondsSinceEpoch ~/ 1000],
    );

    final byDay = <DateTime, double>{};
    for (final row in rows) {
      final createdAt = DateTime.fromMillisecondsSinceEpoch(((row['created_at'] as int?) ?? 0) * 1000);
      final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
      final price = ((row['price'] as num?) ?? 0).toDouble();
      byDay[day] = (byDay[day] ?? 0) + price;
    }

    return List.generate(_trendDays, (i) {
      final day = startOfTrend.add(Duration(days: i));
      return RevenuePoint(date: day, revenue: byDay[day] ?? 0);
    });
  }
}
