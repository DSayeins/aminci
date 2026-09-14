import 'package:get_it/get_it.dart';

import 'package:aminci/features/vouchers/data/datasources/voucher_local_datasource.dart';
import 'package:aminci/features/vouchers/data/datasources/voucher_remote_datasource.dart';
import 'package:aminci/features/vouchers/data/repositories/vouchers_repository_impl.dart';
import 'package:aminci/features/vouchers/domain/repository/vouchers_repository.dart';
import 'package:aminci/features/vouchers/domain/usecases/get_vouchers_by_profile.dart';
import 'package:aminci/features/vouchers/presentation/bloc/vouchers_bloc.dart';

void registerVouchersModule(GetIt sl) {
  sl.registerLazySingleton(() => const VoucherRemoteDatasource());
  sl.registerLazySingleton(() => VoucherLocalDatasource(sl()));
  sl.registerLazySingleton<VouchersRepository>(() => VouchersRepositoryImpl(sl(), sl()));

  sl.registerFactory(() => GetVouchersByProfile(sl()));

  sl.registerFactory(() => VouchersBloc(getVouchersByProfile: sl()));
}
