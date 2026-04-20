import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/profile.dart';
import 'package:aminci/features/profiles/domain/repository/profiles_repository.dart';
import 'package:dartz/dartz.dart';

class UpdatePrice {
  final ProfilesRepository _repository;

  UpdatePrice(this._repository);

  Future<Either<Failure, HotspotProfile>> call({required int profileId, required double price}) async =>
      _repository.updatePrice(profileId: profileId, price: price);
}
