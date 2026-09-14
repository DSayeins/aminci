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

  const VouchersLoaded(this.vouchers);

  @override
  List<Object> get props => [vouchers];
}

final class VouchersError extends VouchersState {
  final String message;

  const VouchersError(this.message);

  @override
  List<Object> get props => [message];
}
