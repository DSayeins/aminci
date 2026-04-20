import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:aminci/core/models/voucher.dart';
import 'package:aminci/features/vouchers/domain/usecases/delete_voucher.dart';
import 'package:aminci/features/vouchers/domain/usecases/generate_vouchers.dart';
import 'package:aminci/features/vouchers/domain/usecases/get_hotspot_servers.dart';
import 'package:aminci/features/vouchers/domain/usecases/get_vouchers.dart';

part 'vouchers_event.dart';
part 'vouchers_state.dart';

class VouchersBloc extends Bloc<VouchersEvent, VouchersState> {
  final GetVouchers _getVouchers;
  final GenerateVouchers _generateVouchers;
  final DeleteVoucher _deleteVoucher;
  final GetHotspotServers _getHotspotServers;

  VouchersBloc({
    required GetVouchers getVouchers,
    required GenerateVouchers generateVouchers,
    required DeleteVoucher deleteVoucher,
    required GetHotspotServers getHotspotServers,
  })  : _getVouchers = getVouchers,
        _generateVouchers = generateVouchers,
        _deleteVoucher = deleteVoucher,
        _getHotspotServers = getHotspotServers,
        super(VouchersInitial()) {
    on<VouchersLoaded>(_onLoaded);
    on<VouchersGenerated>(_onGenerated);
    on<VoucherDeleted>(_onDeleted);
    on<VouchersHotspotServersRequested>(_onHotspotServersRequested);
  }

  // ---------------------------------------------------------------------------

  Future<void> _onLoaded(VouchersLoaded event, Emitter<VouchersState> emit) async {
    emit(VouchersLoading());
    final result = await _getVouchers(event.routerId);
    result.fold(
      (failure) => emit(VouchersError(vouchers: const [], message: failure.message)),
      (vouchers) => emit(VouchersListLoaded(vouchers: vouchers, routerId: event.routerId)),
    );
  }

  Future<void> _onGenerated(VouchersGenerated event, Emitter<VouchersState> emit) async {
    final existing = _currentVouchers();
    emit(VouchersGenerating(existing));

    final result = await _generateVouchers(
      routerId: event.routerId,
      profileName: event.profileName,
      price: event.price,
      quantity: event.quantity,
      createdBy: event.createdBy,
      comment: event.comment,
      limitUptime: event.limitUptime,
      limitBytesTotal: event.limitBytesTotal,
      server: event.server,
      usernameLength: event.usernameLength,
      lettersOnly: event.lettersOnly,
      samePassword: event.samePassword,
    );

    result.fold(
      (failure) => emit(VouchersError(vouchers: existing, message: failure.message)),
      (newVouchers) {
        final updated = [...newVouchers, ...existing];
        final count = newVouchers.length;
        emit(VouchersOperationSuccess(
          vouchers: updated,
          routerId: event.routerId,
          message: '$count voucher${count > 1 ? 's' : ''} généré${count > 1 ? 's' : ''}',
          newVouchers: newVouchers,
        ));
      },
    );
  }

  Future<void> _onDeleted(VoucherDeleted event, Emitter<VouchersState> emit) async {
    final existing = _currentVouchers();
    final routerId = _currentRouterId();

    final result = await _deleteVoucher(voucherId: event.voucherId, routerId: event.routerId);
    result.fold(
      (failure) => emit(VouchersError(vouchers: existing, message: failure.message)),
      (_) {
        final updated = existing.where((v) => v.id != event.voucherId).toList();
        emit(VouchersOperationSuccess(
          vouchers: updated,
          routerId: routerId,
          message: 'Voucher supprimé',
        ));
      },
    );
  }

  Future<void> _onHotspotServersRequested(
    VouchersHotspotServersRequested event,
    Emitter<VouchersState> emit,
  ) async {
    final result = await _getHotspotServers(event.routerId);
    result.fold(
      (_) => emit(const VouchersServersLoaded([])),
      (servers) => emit(VouchersServersLoaded(servers)),
    );
  }

  // ---------------------------------------------------------------------------

  List<Voucher> _currentVouchers() => switch (state) {
        VouchersListLoaded(:final vouchers) => vouchers,
        VouchersOperationSuccess(:final vouchers) => vouchers,
        VouchersGenerating(:final vouchers) => vouchers,
        VouchersError(:final vouchers) => vouchers,
        _ => const [],
      };

  int _currentRouterId() => switch (state) {
        VouchersListLoaded(:final routerId) => routerId,
        VouchersOperationSuccess(:final routerId) => routerId,
        _ => 0,
      };
}
