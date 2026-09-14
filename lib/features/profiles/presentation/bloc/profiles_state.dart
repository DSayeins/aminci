part of 'profiles_bloc.dart';

sealed class ProfilesState extends Equatable {
  const ProfilesState();

  @override
  List<Object> get props => [];
}

final class ProfilesInitial extends ProfilesState {
  const ProfilesInitial();
}

final class ProfilesLoading extends ProfilesState {
  const ProfilesLoading();
}

/// Liste chargée. [isBusy] indique qu'une opération (ajout) est en cours.
final class ProfilesLoaded extends ProfilesState {
  final List<HotspotProfile> profiles;
  final bool isBusy;

  const ProfilesLoaded(this.profiles, {this.isBusy = false});

  ProfilesLoaded copyWith({List<HotspotProfile>? profiles, bool? isBusy}) {
    return ProfilesLoaded(profiles ?? this.profiles, isBusy: isBusy ?? this.isBusy);
  }

  @override
  List<Object> get props => [profiles, isBusy];
}

final class ProfilesError extends ProfilesState {
  final String message;
  final List<HotspotProfile> profiles;

  const ProfilesError(this.message, {this.profiles = const []});

  @override
  List<Object> get props => [message, profiles];
}
