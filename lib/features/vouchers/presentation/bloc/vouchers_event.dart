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
