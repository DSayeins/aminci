import 'package:equatable/equatable.dart';

/// Serveur hotspot MikroTik (`/ip/hotspot`) — un routeur peut en avoir
/// plusieurs. Mis en cache localement (table `hotspots`), toujours resynchronisé
/// depuis le routeur à chaque chargement (comme les routeurs/profils).
class Hotspot extends Equatable {
  /// Id local (autoincrement) — `0` tant que pas encore persisté.
  final int id;
  final int routerId;

  /// Identifiant interne MikroTik (ex: `*1`) — nécessaire pour set/remove.
  final String mikrotikId;
  final String name;
  final String interface;
  final String? addressPool;

  /// Profil hotspot par défaut de ce serveur (`/ip/hotspot/profile`).
  final String? profile;
  final bool disabled;

  const Hotspot({
    this.id = 0,
    required this.routerId,
    required this.mikrotikId,
    required this.name,
    required this.interface,
    this.addressPool,
    this.profile,
    this.disabled = false,
  });

  /// Parse une ligne JSON REST MikroTik (`/ip/hotspot/print`).
  factory Hotspot.fromRestJson(Map<String, dynamic> map, {required int routerId}) {
    return Hotspot(
      routerId: routerId,
      mikrotikId: (map['.id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      interface: (map['interface'] ?? '') as String,
      addressPool: map['address-pool'] as String?,
      profile: map['profile'] as String?,
      disabled: map['disabled'] == 'true' || map['disabled'] == true,
    );
  }

  Hotspot copyWith({
    int? id,
    int? routerId,
    String? mikrotikId,
    String? name,
    String? interface,
    String? addressPool,
    String? profile,
    bool? disabled,
  }) {
    return Hotspot(
      id: id ?? this.id,
      routerId: routerId ?? this.routerId,
      mikrotikId: mikrotikId ?? this.mikrotikId,
      name: name ?? this.name,
      interface: interface ?? this.interface,
      addressPool: addressPool ?? this.addressPool,
      profile: profile ?? this.profile,
      disabled: disabled ?? this.disabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'router_id': routerId,
      'mikrotik_id': mikrotikId,
      'name': name,
      'interface': interface,
      'address_pool': addressPool,
      'profile': profile,
      'disabled': disabled ? 1 : 0,
    };
  }

  factory Hotspot.fromMap(Map<String, dynamic> map) {
    return Hotspot(
      id: (map['id'] ?? 0) as int,
      routerId: (map['router_id'] ?? 0) as int,
      mikrotikId: (map['mikrotik_id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      interface: (map['interface'] ?? '') as String,
      addressPool: map['address_pool'] as String?,
      profile: map['profile'] as String?,
      disabled: (map['disabled'] as int? ?? 0) == 1,
    );
  }

  @override
  List<Object?> get props => [id, routerId, mikrotikId, name, interface, addressPool, profile, disabled];
}
