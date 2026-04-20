part of 'profiles_bloc.dart';

sealed class ProfilesEvent extends Equatable {
  const ProfilesEvent();

  @override
  List<Object> get props => [];
}

/// Initialisation de l'écran — charge la liste des routeurs disponibles.
final class ProfilesStarted extends ProfilesEvent {
  const ProfilesStarted();
}

/// Chargement des profils depuis le cache local pour un routeur donné.
final class ProfilesLoaded extends ProfilesEvent {
  final int routerId;

  const ProfilesLoaded(this.routerId);

  @override
  List<Object> get props => [routerId];
}

/// Synchronisation des profils depuis MikroTik.
final class ProfilesSynced extends ProfilesEvent {
  final int routerId;

  const ProfilesSynced(this.routerId);

  @override
  List<Object> get props => [routerId];
}

/// Création d'un nouveau profil hotspot sur MikroTik.
final class ProfileCreated extends ProfilesEvent {
  final int routerId;
  final String name;
  final String addressPool;
  final String? rateLimit;
  final String? sessionTimeout;
  final String? idleTimeout;
  final String? keepaliveTimeout;
  final bool addMacCookie;
  final String? macCookieTimeout;
  final int sharedUsers;

  final DateTime? expiresAt;

  const ProfileCreated({
    required this.routerId,
    required this.name,
    required this.addressPool,
    this.rateLimit,
    this.sessionTimeout,
    this.idleTimeout,
    this.keepaliveTimeout,
    this.addMacCookie = true,
    this.macCookieTimeout,
    this.sharedUsers = 1,
    this.expiresAt,
  });

  @override
  List<Object> get props => [routerId, name, addressPool, rateLimit ?? '', sessionTimeout ?? '', sharedUsers];
}

/// Modification d'un profil hotspot existant sur MikroTik.
final class ProfileUpdated extends ProfilesEvent {
  final int profileId;
  final int routerId;
  final String name;
  final String addressPool;
  final String? rateLimit;
  final String? sessionTimeout;
  final String? idleTimeout;
  final String? keepaliveTimeout;
  final bool addMacCookie;
  final String? macCookieTimeout;
  final int sharedUsers;

  final DateTime? expiresAt;

  const ProfileUpdated({
    required this.profileId,
    required this.routerId,
    required this.name,
    required this.addressPool,
    this.rateLimit,
    this.sessionTimeout,
    this.idleTimeout,
    this.keepaliveTimeout,
    this.addMacCookie = true,
    this.macCookieTimeout,
    required this.sharedUsers,
    this.expiresAt,
  });

  @override
  List<Object> get props => [profileId, routerId, name, addressPool, rateLimit ?? '', sessionTimeout ?? '', sharedUsers];
}

/// Suppression d'un profil hotspot sur MikroTik et du cache local.
final class ProfileDeleted extends ProfilesEvent {
  final int profileId;
  final int routerId;

  const ProfileDeleted({required this.profileId, required this.routerId});

  @override
  List<Object> get props => [profileId, routerId];
}

/// Mise à jour du prix local d'un profil.
final class ProfilePriceUpdated extends ProfilesEvent {
  final int profileId;
  final double price;

  const ProfilePriceUpdated({required this.profileId, required this.price});

  @override
  List<Object> get props => [profileId, price];
}
