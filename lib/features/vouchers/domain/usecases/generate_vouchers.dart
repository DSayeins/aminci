import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/vouchers/domain/repository/vouchers_repository.dart';

class GenerateVouchers {
  final VouchersRepository _repository;

  GenerateVouchers(this._repository);

  Future<Either<Failure, List<Voucher>>> call({
    required int routerId,
    required String profileName,
    required double price,
    required int quantity,
    required String createdBy,
    String? comment,
    String? limitUptime,
    int limitBytesTotal = 0,
    String? server,
    int usernameLength = 4,
    bool lettersOnly = false,
    bool samePassword = true,
  }) =>
      _repository.generateVouchers(
        routerId: routerId,
        profileName: profileName,
        price: price,
        quantity: quantity,
        createdBy: createdBy,
        comment: comment,
        limitUptime: limitUptime,
        limitBytesTotal: limitBytesTotal,
        server: server,
        usernameLength: usernameLength,
        lettersOnly: lettersOnly,
        samePassword: samePassword,
      );
}
