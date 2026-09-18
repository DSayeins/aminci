import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/dashboard_metrics.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardMetrics>> getMetrics(int routerId);
}
