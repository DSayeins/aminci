import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:aminci/core/models/dashboard_metrics.dart';
import 'package:aminci/core/theme/app_colors.dart';
import 'package:aminci/core/theme/app_spacing.dart';
import 'package:aminci/core/theme/app_typography.dart';
import 'package:aminci/core/utils/currency_formatter.dart';

/// Courbe d'évolution du chiffre d'affaires sur les 30 derniers jours.
class RevenueTrendChart extends StatelessWidget {
  final List<RevenuePoint> points;

  const RevenueTrendChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.insetCard,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppSpacing.borderLg,
        border: Border.all(color: AppColors.borderDefault, width: AppSpacing.borderThin),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chiffre d\'affaires — 30 derniers jours',
            style: AppTypography.sectionTitle.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.gapLg),
          Expanded(child: points.isEmpty ? const SizedBox.shrink() : _Chart(points: points)),
        ],
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  final List<RevenuePoint> points;

  const _Chart({required this.points});

  @override
  Widget build(BuildContext context) {
    final maxRevenue = points.map((p) => p.revenue).fold<double>(0, (max, v) => v > max ? v : max);
    // Évite un graphe plat (maxY == 0) quand il n'y a encore aucune vente.
    final maxY = maxRevenue <= 0 ? 1.0 : maxRevenue * 1.2;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: AppColors.borderDefault, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxY / 4,
              getTitlesWidget: (value, meta) => Text(
                CurrencyFormatter.format(value, currency: ''),
                style: AppTypography.statSub.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (points.length / 5).ceilToDouble().clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.gapXs),
                  child: Text(
                    DateFormat('d/MM').format(points[index].date),
                    style: AppTypography.statSub.copyWith(color: AppColors.textTertiary),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((spot) {
              final point = points[spot.x.toInt()];
              return LineTooltipItem(
                '${DateFormat('d/MM').format(point.date)}\n${CurrencyFormatter.format(point.revenue)}',
                AppTypography.bodySm.copyWith(color: AppColors.textOnPrimary),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].revenue)],
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }
}
