import 'package:equatable/equatable.dart';

/// Serveur hotspot MikroTik (`/ip/hotspot`) — un routeur peut en avoir
/// plusieurs. Donnée live, jamais mise en cache localement (comme les
/// sessions actives) : toujours interrogée en direct sur le routeur.
class Hotspot extends Equatable {
  /// Identifiant interne MikroTik (ex: `*1`) — nécessaire pour set/remove.
  final String mikrotikId;
  final String name;
  final String interface;
  final String? addressPool;

  /// Profil hotspot par défaut de ce serveur (`/ip/hotspot/profile`).
  final String? profile;
  final bool disabled;

  const Hotspot({
    required this.mikrotikId,
    required this.name,
    required this.interface,
    this.addressPool,
    this.profile,
    this.disabled = false,
  });

  factory Hotspot.fromMap(Map<String, dynamic> map) {
    return Hotspot(
      mikrotikId: (map['.id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      interface: (map['interface'] ?? '') as String,
      addressPool: map['address-pool'] as String?,
      profile: map['profile'] as String?,
      disabled: map['disabled'] == 'true' || map['disabled'] == true,
    );
  }

  @override
  List<Object?> get props => [mikrotikId, name, interface, addressPool, profile, disabled];
}
