import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/core/models/profile.dart';
import 'package:aminci/core/models/router.dart';
import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/vouchers/domain/usecases/delete_vouchers.dart';
import 'package:aminci/features/vouchers/domain/usecases/get_vouchers_by_profile.dart';

part 'vouchers_event.dart';
part 'vouchers_state.dart';

class VouchersBloc extends Bloc<VouchersEvent, VouchersState> {
  final GetVouchersByProfile _getVouchersByProfile;
  final DeleteVouchers _deleteVouchers;

  VouchersBloc({
    required GetVouchersByProfile getVouchersByProfile,
    required DeleteVouchers deleteVouchers,
  })  : _getVouchersByProfile = getVouchersByProfile,
        _deleteVouchers = deleteVouchers,
        super(const VouchersInitial()) {
    on<VouchersLoadRequested>(_onLoadRequested);
    on<VouchersDeleteRequested>(_onDeleteRequested);
    on<VouchersGenerated>(_onGenerated);
  }

  Future<void> _onLoadRequested(VouchersLoadRequested event, Emitter<VouchersState> emit) async {
    emit(const VouchersLoading());
    final result = await _getVouchersByProfile(event.router, event.profile);
    result.fold(
      (failure) => emit(VouchersError(failure.message)),
      (vouchers) => emit(VouchersLoaded(vouchers)),
    );
  }

  Future<void> _onDeleteRequested(VouchersDeleteRequested event, Emitter<VouchersState> emit) async {
    final current = state is VouchersLoaded ? (state as VouchersLoaded).vouchers : <Voucher>[];
    emit(VouchersLoaded(current, isBusy: true));

    final result = await _deleteVouchers(event.router, event.vouchers);
    final deletedIds = event.vouchers.map((v) => v.id).toSet();
    result.fold(
      (failure) => emit(VouchersError(failure.message, vouchers: current)),
      (_) => emit(VouchersLoaded(current.where((v) => !deletedIds.contains(v.id)).toList())),
    );
  }

  void _onGenerated(VouchersGenerated event, Emitter<VouchersState> emit) {
    final current = state is VouchersLoaded ? (state as VouchersLoaded).vouchers : <Voucher>[];
    emit(VouchersLoaded([...event.vouchers, ...current]));
  }
}
