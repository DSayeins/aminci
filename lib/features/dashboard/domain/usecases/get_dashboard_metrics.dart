import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/dashboard_metrics.dart';
import 'package:aminci/features/dashboard/domain/repository/dashboard_repository.dart';

class GetDashboardMetrics {
  final DashboardRepository _repository;
  const GetDashboardMetrics(this._repository);

  Future<Either<Failure, DashboardMetrics>> call(int routerId) => _repository.getMetrics(routerId);
}
