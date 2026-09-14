part of 'profiles_bloc.dart';

sealed class ProfilesEvent extends Equatable {
  const ProfilesEvent();

  @override
  List<Object> get props => [];
}

/// Charge les profils du routeur [router] (déclenché à l'entrée sur l'écran).
final class ProfilesLoadRequested extends ProfilesEvent {
  final MikroTikRouter router;

  const ProfilesLoadRequested(this.router);

  @override
  List<Object> get props => [router];
}

/// Crée [profile] sur le routeur [router].
final class ProfileCreateRequested extends ProfilesEvent {
  final MikroTikRouter router;
  final HotspotProfile profile;

  const ProfileCreateRequested(this.router, this.profile);

  @override
  List<Object> get props => [router, profile];
}

/// Modifie [profile] sur le routeur [router].
final class ProfileUpdateRequested extends ProfilesEvent {
  final MikroTikRouter router;
  final HotspotProfile profile;

  const ProfileUpdateRequested(this.router, this.profile);

  @override
  List<Object> get props => [router, profile];
}

/// Supprime [profile] sur le routeur [router].
final class ProfileDeleteRequested extends ProfilesEvent {
  final MikroTikRouter router;
  final HotspotProfile profile;

  const ProfileDeleteRequested(this.router, this.profile);

  @override
  List<Object> get props => [router, profile];
}
