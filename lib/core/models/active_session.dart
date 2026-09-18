import 'package:equatable/equatable.dart';

import 'package:aminci/core/utils/byte_formatter.dart';

/// Connexion hotspot active en direct (`/ip/hotspot/active`) — distinct des
/// comptes vouchers (`/ip/hotspot/user`) : ne représente que les sessions
/// actuellement connectées, jamais persisté en local (donnée live).
class ActiveSession extends Equatable {
  /// Identifiant interne MikroTik (ex: `*1`) — nécessaire pour déconnecter.
  final String mikrotikId;

  /// Code voucher (nom du compte hotspot) de la session.
  final String code;

  final String? address;
  final String? macAddress;
  final String? server;

  /// Durée de la session en cours (ex: `5m30s`).
  final String? uptime;

  final int bytesIn;
  final int bytesOut;

  const ActiveSession({
    required this.mikrotikId,
    required this.code,
    this.address,
    this.macAddress,
    this.server,
    this.uptime,
    this.bytesIn = 0,
    this.bytesOut = 0,
  });

  /// Données consommées formatées (download + upload) pour cette session.
  String get bytesTotalFmt => ByteFormatter.format(bytesIn + bytesOut);

  /// Parse une ligne JSON REST MikroTik (`/ip/hotspot/active/print`).
  factory ActiveSession.fromRestJson(Map<String, dynamic> map) {
    return ActiveSession(
      mikrotikId: (map['.id'] ?? '') as String,
      code: (map['user'] ?? '') as String,
      address: map['address'] as String?,
      macAddress: map['mac-address'] as String?,
      server: map['server'] as String?,
      uptime: map['uptime'] as String?,
      bytesIn: int.tryParse('${map['bytes-in'] ?? 0}') ?? 0,
      bytesOut: int.tryParse('${map['bytes-out'] ?? 0}') ?? 0,
    );
  }

  @override
  List<Object?> get props => [mikrotikId, code, address, macAddress, uptime, bytesIn, bytesOut];
}
