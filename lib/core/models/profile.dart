import 'package:equatable/equatable.dart';

class HotspotProfile extends Equatable {
  final int id;
  final int routerId;

  /// Identifiant interne MikroTik (ex: `*1`) — nécessaire pour set/remove.
  final String? mikrotikId;
  final String mikrotikName;
  final String? addressPool;
  final String? rateLimit;

  /// Durée max de session (ex: `1h`, `30m`). Vide = illimité.
  final String? sessionTimeout;

  /// Durée d'inactivité avant déconnexion (ex: `5m`, `none`).
  final String? idleTimeout;

  /// Délai keepalive avant déconnexion (ex: `2m`).
  final String? keepaliveTimeout;

  /// Mémorisation MAC pour reconnexion automatique.
  final bool addMacCookie;

  /// Durée de validité du cookie MAC (ex: `3d`).
  final String? macCookieTimeout;

  final int sharedUsers;

  /// Prix local — non présent sur MikroTik.
  final double price;

  /// Date de fin de validité du profil (locale, non présente sur MikroTik).
  /// Null = pas de limite de validité.
  final DateTime? expiresAt;

  const HotspotProfile({
    required this.id,
    required this.routerId,
    this.mikrotikId,
    required this.mikrotikName,
    this.addressPool,
    this.rateLimit,
    this.sessionTimeout,
    this.idleTimeout,
    this.keepaliveTimeout,
    this.addMacCookie = true,
    this.macCookieTimeout,
    required this.sharedUsers,
    required this.price,
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  HotspotProfile copyWith({
    int? id,
    int? routerId,
    String? mikrotikId,
    String? mikrotikName,
    String? addressPool,
    String? rateLimit,
    String? sessionTimeout,
    String? idleTimeout,
    String? keepaliveTimeout,
    bool? addMacCookie,
    String? macCookieTimeout,
    int? sharedUsers,
    double? price,
    DateTime? expiresAt,
  }) {
    return HotspotProfile(
      id: id ?? this.id,
      routerId: routerId ?? this.routerId,
      mikrotikId: mikrotikId ?? this.mikrotikId,
      mikrotikName: mikrotikName ?? this.mikrotikName,
      addressPool: addressPool ?? this.addressPool,
      rateLimit: rateLimit ?? this.rateLimit,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      idleTimeout: idleTimeout ?? this.idleTimeout,
      keepaliveTimeout: keepaliveTimeout ?? this.keepaliveTimeout,
      addMacCookie: addMacCookie ?? this.addMacCookie,
      macCookieTimeout: macCookieTimeout ?? this.macCookieTimeout,
      sharedUsers: sharedUsers ?? this.sharedUsers,
      price: price ?? this.price,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'router_id': routerId,
      'mikrotik_id': mikrotikId,
      'mikrotik_name': mikrotikName,
      'address_pool': addressPool,
      'rate_limit': rateLimit,
      'session_timeout': sessionTimeout,
      'idle_timeout': idleTimeout,
      'keepalive_timeout': keepaliveTimeout,
      'add_mac_cookie': addMacCookie ? 1 : 0,
      'mac_cookie_timeout': macCookieTimeout,
      'shared_users': sharedUsers,
      'price': price,
      'expires_at': expiresAt != null ? expiresAt!.millisecondsSinceEpoch ~/ 1000 : null,
    };
  }

  factory HotspotProfile.fromMap(Map<String, dynamic> map) {
    final expiresAtRaw = map['expires_at'] as int?;
    return HotspotProfile(
      id: (map['id'] ?? 0) as int,
      routerId: (map['router_id'] ?? 0) as int,
      mikrotikId: map['mikrotik_id'] as String?,
      mikrotikName: (map['mikrotik_name'] ?? '') as String,
      addressPool: map['address_pool'] as String?,
      rateLimit: map['rate_limit'] as String?,
      sessionTimeout: map['session_timeout'] as String?,
      idleTimeout: map['idle_timeout'] as String?,
      keepaliveTimeout: map['keepalive_timeout'] as String?,
      addMacCookie: ((map['add_mac_cookie'] ?? 1) as int) == 1,
      macCookieTimeout: map['mac_cookie_timeout'] as String?,
      sharedUsers: (map['shared_users'] ?? 1) as int,
      price: (map['price'] ?? 0.0) as double,
      expiresAt: expiresAtRaw != null
          ? DateTime.fromMillisecondsSinceEpoch(expiresAtRaw * 1000)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, routerId, mikrotikName, sharedUsers, price];
}
