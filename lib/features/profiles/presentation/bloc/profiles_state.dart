part of 'profiles_bloc.dart';

sealed class ProfilesState extends Equatable {
  final List<MikroTikRouter> routers;

  const ProfilesState({this.routers = const []});

  @override
  List<Object> get props => [routers];
}

/// État initial — avant le chargement des routeurs.
final class ProfilesInitial extends ProfilesState {
  const ProfilesInitial({super.routers = const []});
}

/// Chargement des profils en cours.
final class ProfilesLoading extends ProfilesState {
  const ProfilesLoading({super.routers = const []});
}

/// Synchronisation MikroTik en cours.
final class ProfilesSyncing extends ProfilesState {
  final List<HotspotProfile> profiles;

  const ProfilesSyncing({required this.profiles, super.routers = const []});

  @override
  List<Object> get props => [profiles, routers];
}

/// Profils chargés avec succès.
final class ProfilesListLoaded extends ProfilesState {
  final List<HotspotProfile> profiles;
  final int routerId;

  const ProfilesListLoaded({
    required this.profiles,
    required this.routerId,
    super.routers = const [],
  });

  @override
  List<Object> get props => [profiles, routerId, routers];
}

/// Opération réussie (sync ou mise à jour prix) — liste mise à jour.
final class ProfilesOperationSuccess extends ProfilesState {
  final List<HotspotProfile> profiles;
  final int routerId;
  final String message;

  const ProfilesOperationSuccess({
    required this.profiles,
    required this.routerId,
    required this.message,
    super.routers = const [],
  });

  @override
  List<Object> get props => [profiles, routerId, message, routers];
}

/// Erreur sur n'importe quelle opération.
final class ProfilesError extends ProfilesState {
  final List<HotspotProfile> profiles;
  final String message;

  const ProfilesError({
    required this.profiles,
    required this.message,
    super.routers = const [],
  });

  @override
  List<Object> get props => [profiles, message, routers];
}
