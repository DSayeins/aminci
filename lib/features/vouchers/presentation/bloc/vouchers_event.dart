part of 'vouchers_bloc.dart';

sealed class VouchersEvent extends Equatable {
  const VouchersEvent();

  @override
  List<Object> get props => [];
}

/// Chargement des vouchers depuis le cache local pour un routeur donné.
final class VouchersLoaded extends VouchersEvent {
  final int routerId;

  const VouchersLoaded(this.routerId);

  @override
  List<Object> get props => [routerId];
}

/// Génération de nouveaux vouchers sur MikroTik.
final class VouchersGenerated extends VouchersEvent {
  final int routerId;
  final String profileName;
  final double price;
  final int quantity;
  final String createdBy;
  final String? comment;
  final String? limitUptime;
  final int limitBytesTotal;

  final String? server;
  final int usernameLength;
  final bool lettersOnly;
  final bool samePassword;

  const VouchersGenerated({
    required this.routerId,
    required this.profileName,
    required this.price,
    required this.quantity,
    required this.createdBy,
    this.comment,
    this.limitUptime,
    this.limitBytesTotal = 0,
    this.server,
    this.usernameLength = 4,
    this.lettersOnly = false,
    this.samePassword = true,
  });

  @override
  List<Object> get props => [routerId, profileName, price, quantity, createdBy, limitBytesTotal];
}

/// Chargement des serveurs hotspot disponibles sur un routeur MikroTik.
final class VouchersHotspotServersRequested extends VouchersEvent {
  final int routerId;

  const VouchersHotspotServersRequested(this.routerId);

  @override
  List<Object> get props => [routerId];
}

/// Suppression d'un voucher (local + MikroTik).
final class VoucherDeleted extends VouchersEvent {
  final int voucherId;
  final int routerId;

  const VoucherDeleted({required this.voucherId, required this.routerId});

  @override
  List<Object> get props => [voucherId, routerId];
}
