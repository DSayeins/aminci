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

  final bool https;
  final int? addressesPerMac;
  final String? idleTimeout;
  final bool invalid;
  final String? ipOfDnsName;
  final String? keepaliveTimeout;
  final String? loginTimeout;
  final String? proxyStatus;

  const Hotspot({
    this.id = 0,
    required this.routerId,
    required this.mikrotikId,
    required this.name,
    required this.interface,
    this.addressPool,
    this.profile,
    this.disabled = false,
    this.https = false,
    this.addressesPerMac,
    this.idleTimeout,
    this.invalid = false,
    this.ipOfDnsName,
    this.keepaliveTimeout,
    this.loginTimeout,
    this.proxyStatus,
  });

  static bool _asBool(dynamic value) => value == true || value == 'true';

  /// Parse une ligne JSON REST MikroTik (`/ip/hotspot/print`).
  factory Hotspot.fromRestJson(Map<String, dynamic> map, {required int routerId}) {
    return Hotspot(
      routerId: routerId,
      mikrotikId: (map['.id'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      interface: (map['interface'] ?? '') as String,
      addressPool: map['address-pool'] as String?,
      profile: map['profile'] as String?,
      disabled: _asBool(map['disabled']),
      https: _asBool(map['HTTPS']),
      addressesPerMac: int.tryParse('${map['addresses-per-mac'] ?? ''}'),
      idleTimeout: map['idle-timeout'] as String?,
      invalid: _asBool(map['invalid']),
      ipOfDnsName: map['ip-of-dns-name'] as String?,
      keepaliveTimeout: map['keepalive-timeout'] as String?,
      loginTimeout: map['login-timeout'] as String?,
      proxyStatus: map['proxy-status'] as String?,
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
    bool? https,
    int? addressesPerMac,
    String? idleTimeout,
    bool? invalid,
    String? ipOfDnsName,
    String? keepaliveTimeout,
    String? loginTimeout,
    String? proxyStatus,
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
      https: https ?? this.https,
      addressesPerMac: addressesPerMac ?? this.addressesPerMac,
      idleTimeout: idleTimeout ?? this.idleTimeout,
      invalid: invalid ?? this.invalid,
      ipOfDnsName: ipOfDnsName ?? this.ipOfDnsName,
      keepaliveTimeout: keepaliveTimeout ?? this.keepaliveTimeout,
      loginTimeout: loginTimeout ?? this.loginTimeout,
      proxyStatus: proxyStatus ?? this.proxyStatus,
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
      'https': https ? 1 : 0,
      'addresses_per_mac': addressesPerMac,
      'idle_timeout': idleTimeout,
      'invalid': invalid ? 1 : 0,
      'ip_of_dns_name': ipOfDnsName,
      'keepalive_timeout': keepaliveTimeout,
      'login_timeout': loginTimeout,
      'proxy_status': proxyStatus,
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
      https: (map['https'] as int? ?? 0) == 1,
      addressesPerMac: map['addresses_per_mac'] as int?,
      idleTimeout: map['idle_timeout'] as String?,
      invalid: (map['invalid'] as int? ?? 0) == 1,
      ipOfDnsName: map['ip_of_dns_name'] as String?,
      keepaliveTimeout: map['keepalive_timeout'] as String?,
      loginTimeout: map['login_timeout'] as String?,
      proxyStatus: map['proxy_status'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    routerId,
    mikrotikId,
    name,
    interface,
    addressPool,
    profile,
    disabled,
    https,
    addressesPerMac,
    idleTimeout,
    invalid,
    ipOfDnsName,
    keepaliveTimeout,
    loginTimeout,
    proxyStatus,
  ];
}
