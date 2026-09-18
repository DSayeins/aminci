import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/error_mapper.dart';
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/dashboard_metrics.dart';
import 'package:aminci/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:aminci/features/dashboard/domain/repository/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDatasource _local;

  const DashboardRepositoryImpl(this._local);

  @override
  Future<Either<Failure, DashboardMetrics>> getMetrics(int routerId) {
    return ErrorMapper.guard(
      () => _local.getMetrics(routerId),
      fallbackMessage: 'Impossible de charger les métriques du dashboard',
    );
  }
}
