part of 'vouchers_bloc.dart';

sealed class VouchersState extends Equatable {
  const VouchersState();

  @override
  List<Object> get props => [];
}

/// État initial.
final class VouchersInitial extends VouchersState {}

/// Chargement local en cours.
final class VouchersLoading extends VouchersState {}

/// Génération MikroTik en cours — conserve la liste actuelle à l'écran.
final class VouchersGenerating extends VouchersState {
  final List<Voucher> vouchers;

  const VouchersGenerating(this.vouchers);

  @override
  List<Object> get props => [vouchers];
}

/// Vouchers chargés avec succès.
final class VouchersListLoaded extends VouchersState {
  final List<Voucher> vouchers;
  final int routerId;

  const VouchersListLoaded({required this.vouchers, required this.routerId});

  @override
  List<Object> get props => [vouchers, routerId];
}

/// Opération réussie (génération ou suppression).
final class VouchersOperationSuccess extends VouchersState {
  final List<Voucher> vouchers;
  final int routerId;
  final String message;

  /// Vouchers fraîchement générés — permet à l'UI de les mettre en avant.
  final List<Voucher> newVouchers;

  const VouchersOperationSuccess({
    required this.vouchers,
    required this.routerId,
    required this.message,
    this.newVouchers = const [],
  });

  @override
  List<Object> get props => [vouchers, routerId, message, newVouchers];
}

/// Serveurs hotspot chargés depuis MikroTik.
final class VouchersServersLoaded extends VouchersState {
  final List<String> servers;

  const VouchersServersLoaded(this.servers);

  @override
  List<Object> get props => [servers];
}

/// Erreur sur n'importe quelle opération.
final class VouchersError extends VouchersState {
  final List<Voucher> vouchers;
  final String message;

  const VouchersError({required this.vouchers, required this.message});

  @override
  List<Object> get props => [vouchers, message];
}
