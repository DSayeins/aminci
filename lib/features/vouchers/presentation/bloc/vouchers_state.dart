part of 'vouchers_bloc.dart';

sealed class VouchersState extends Equatable {
  const VouchersState();

  @override
  List<Object> get props => [];
}

final class VouchersInitial extends VouchersState {
  const VouchersInitial();
}

final class VouchersLoading extends VouchersState {
  const VouchersLoading();
}

final class VouchersLoaded extends VouchersState {
  final List<Voucher> vouchers;
  final bool isBusy;

  const VouchersLoaded(this.vouchers, {this.isBusy = false});

  @override
  List<Object> get props => [vouchers, isBusy];
}

final class VouchersError extends VouchersState {
  final String message;
  final List<Voucher> vouchers;

  const VouchersError(this.message, {this.vouchers = const []});

  @override
  List<Object> get props => [message, vouchers];
}
