import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/vouchers/domain/usecases/get_vouchers_by_profile.dart';

part 'vouchers_event.dart';
part 'vouchers_state.dart';

class VouchersBloc extends Bloc<VouchersEvent, VouchersState> {
  final GetVouchersByProfile _getVouchersByProfile;

  VouchersBloc({required GetVouchersByProfile getVouchersByProfile})
      : _getVouchersByProfile = getVouchersByProfile,
        super(const VouchersInitial()) {
    on<VouchersLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(VouchersLoadRequested event, Emitter<VouchersState> emit) async {
    emit(const VouchersLoading());
    final result = await _getVouchersByProfile(event.router, event.profile);
    result.fold(
      (failure) => emit(VouchersError(failure.message)),
      (vouchers) => emit(VouchersLoaded(vouchers)),
    );
  }
}
