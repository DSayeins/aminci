part of 'vouchers_bloc.dart';

sealed class VouchersEvent extends Equatable {
  const VouchersEvent();

  @override
  List<Object> get props => [];
}

/// Charge les vouchers du profil [profile] sur le routeur [router].
final class VouchersLoadRequested extends VouchersEvent {
  final MikroTikRouter router;
  final HotspotProfile profile;

  const VouchersLoadRequested(this.router, this.profile);

  @override
  List<Object> get props => [router, profile];
}

/// Supprime [vouchers] sur le routeur [router].
final class VouchersDeleteRequested extends VouchersEvent {
  final MikroTikRouter router;
  final List<Voucher> vouchers;

  const VouchersDeleteRequested(this.router, this.vouchers);

  @override
  List<Object> get props => [router, vouchers];
}

/// Ajoute des vouchers déjà générés (et persistés) à la liste en cours —
/// la génération elle-même est appelée directement depuis le dialog (comme
/// `GetAddressPools` pour les profils), cet event ne fait que rafraîchir
/// l'écran sans nouvel appel réseau.
final class VouchersGenerated extends VouchersEvent {
  final List<Voucher> vouchers;

  const VouchersGenerated(this.vouchers);

  @override
  List<Object> get props => [vouchers];
}
