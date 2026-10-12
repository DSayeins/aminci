import 'package:equatable/equatable.dart';

import 'package:aminci/core/models/active_session.dart';

sealed class ProfileFilter extends Equatable {
  const ProfileFilter();

  @override
  List<Object?> get props => [];
}

final class AllProfiles extends ProfileFilter {
  const AllProfiles();
}

final class UnknownProfile extends ProfileFilter {
  const UnknownProfile();
}

final class NamedProfile extends ProfileFilter {
  final String name;

  const NamedProfile(this.name);

  @override
  List<Object?> get props => [name];
}

List<ActiveSession> filterSessions(List<ActiveSession> sessions, ProfileFilter filter) {
  return switch (filter) {
    AllProfiles() => sessions,
    UnknownProfile() => sessions.where((s) => s.profileName == null).toList(),
    NamedProfile(:final name) => sessions.where((s) => s.profileName == name).toList(),
  };
}

/// Puces proposées : Tous, les profils présents (triés), puis Inconnu s'il y a
/// des sessions sans profil. Le profil [selected] reste proposé même quand plus
/// aucune session ne l'utilise, pour ne pas faire disparaître le filtre actif
/// au rafraîchissement suivant.
List<ProfileFilter> profileFilterOptions(List<ActiveSession> sessions, ProfileFilter selected) {
  final names = {
    for (final s in sessions)
      if (s.profileName != null) s.profileName!,
    if (selected is NamedProfile) selected.name,
  }.toList()
    ..sort();
  final hasUnknown = sessions.any((s) => s.profileName == null);

  return [
    const AllProfiles(),
    for (final name in names) NamedProfile(name),
    if (hasUnknown) const UnknownProfile(),
  ];
}
