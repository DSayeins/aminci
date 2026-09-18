import 'package:equatable/equatable.dart';

import 'package:aminci/core/utils/mikrotik_duration.dart';

enum VoucherStatus { pending, active, expired }

class Voucher extends Equatable {
  final int id;
  final int routerId;
  final String code;
  final String password;
  final String profileName;
  final double price;
  final VoucherStatus status;
  final DateTime createdAt;
  final String createdBy;

  // --- Champs MikroTik synchronisés ---

  /// Identifiant interne MikroTik (ex: `*429`). Nécessaire pour set/remove.
  final String? mikrotikId;

  /// Serveur hotspot sur lequel l'utilisateur est enregistré (ex: `hotspot1`).
  final String? server;

  /// Commentaire libre (ex: référence de vente, opérateur).
  final String? comment;

  /// Quota de durée de connexion cumulée (ex: `1w1d`, `3h`). Vide = illimité.
  final String? limitUptime;

  /// Quota total de données (octets). 0 = illimité.
  final int limitBytesTotal;

  /// Durée de connexion déjà consommée depuis la dernière activation (ex: `2h30m`).
  final String? uptime;

  /// Données téléchargées (octets).
  final int bytesIn;

  /// Données envoyées (octets).
  final int bytesOut;

  /// Voucher désactivé manuellement sur MikroTik.
  final bool disabled;

  const Voucher({
    required this.id,
    required this.routerId,
    required this.code,
    required this.password,
    required this.profileName,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    this.mikrotikId,
    this.server,
    this.comment,
    this.limitUptime,
    this.limitBytesTotal = 0,
    this.uptime,
    this.bytesIn = 0,
    this.bytesOut = 0,
    this.disabled = false,
  });

  Voucher copyWith({
    int? id,
    int? routerId,
    String? code,
    String? password,
    String? profileName,
    double? price,
    VoucherStatus? status,
    DateTime? createdAt,
    String? createdBy,
    String? mikrotikId,
    String? server,
    String? comment,
    String? limitUptime,
    int? limitBytesTotal,
    String? uptime,
    int? bytesIn,
    int? bytesOut,
    bool? disabled,
  }) {
    return Voucher(
      id: id ?? this.id,
      routerId: routerId ?? this.routerId,
      code: code ?? this.code,
      password: password ?? this.password,
      profileName: profileName ?? this.profileName,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      mikrotikId: mikrotikId ?? this.mikrotikId,
      server: server ?? this.server,
      comment: comment ?? this.comment,
      limitUptime: limitUptime ?? this.limitUptime,
      limitBytesTotal: limitBytesTotal ?? this.limitBytesTotal,
      uptime: uptime ?? this.uptime,
      bytesIn: bytesIn ?? this.bytesIn,
      bytesOut: bytesOut ?? this.bytesOut,
      disabled: disabled ?? this.disabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'router_id': routerId,
      'code': code,
      'password': password,
      'profile_name': profileName,
      'price': price,
      'status': status.name,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'created_by': createdBy,
      'mikrotik_id': mikrotikId,
      'server': server,
      'comment': comment,
      'limit_uptime': limitUptime,
      'limit_bytes_total': limitBytesTotal,
      'uptime': uptime,
      'bytes_in': bytesIn,
      'bytes_out': bytesOut,
      'disabled': disabled ? 1 : 0,
    };
  }

  /// Parse une ligne JSON REST MikroTik (`/ip/hotspot/user/print`).
  ///
  /// `price`/`createdAt`/`createdBy` n'existent pas côté RouterOS — laissés à
  /// leur défaut, à préserver lors d'une resynchronisation (voir
  /// `VoucherLocalDatasource.syncFromRemote`). [profileName] est déjà résolu
  /// (le champ brut `profile` de RouterOS peut être un nom ou un identifiant
  /// interne selon l'état du profil référencé). `status` est recalculé à
  /// chaque synchronisation à partir de la consommation réelle du voucher
  /// (voir [resolveStatus]).
  factory Voucher.fromRestJson(
    Map<String, dynamic> map, {
    required int routerId,
    required String profileName,
  }) {
    final disabled = map['disabled'] == true || map['disabled'] == 'true';
    final limitUptime = map['limit-uptime'] as String?;
    final limitBytesTotal = int.tryParse('${map['limit-bytes-total'] ?? 0}') ?? 0;
    final uptime = map['uptime'] as String?;
    final bytesIn = int.tryParse('${map['bytes-in'] ?? 0}') ?? 0;
    final bytesOut = int.tryParse('${map['bytes-out'] ?? 0}') ?? 0;

    return Voucher(
      id: 0,
      routerId: routerId,
      code: (map['name'] ?? '') as String,
      password: (map['password'] ?? '') as String,
      profileName: profileName,
      price: 0,
      status: resolveStatus(
        disabled: disabled,
        uptime: uptime,
        bytesIn: bytesIn,
        bytesOut: bytesOut,
        limitUptime: limitUptime,
        limitBytesTotal: limitBytesTotal,
      ),
      createdAt: DateTime.now(),
      createdBy: '',
      mikrotikId: map['.id'] as String?,
      server: map['server'] as String?,
      comment: map['comment'] as String?,
      limitUptime: limitUptime,
      limitBytesTotal: limitBytesTotal,
      uptime: uptime,
      bytesIn: bytesIn,
      bytesOut: bytesOut,
      disabled: disabled,
    );
  }

  /// Déduit le statut d'un voucher à partir de sa consommation réelle sur le
  /// routeur : `expired` si désactivé ou si le quota (durée ou données) est
  /// atteint, `active` s'il a déjà servi à se connecter, `pending` sinon
  /// (jamais utilisé).
  static VoucherStatus resolveStatus({
    required bool disabled,
    required String? uptime,
    required int bytesIn,
    required int bytesOut,
    required String? limitUptime,
    required int limitBytesTotal,
  }) {
    if (disabled) return VoucherStatus.expired;

    final consumedSeconds = MikroTikDuration.parseSeconds(uptime);
    final consumedBytes = bytesIn + bytesOut;

    final limitSeconds = MikroTikDuration.parseSeconds(limitUptime);
    final uptimeExhausted = limitSeconds > 0 && consumedSeconds >= limitSeconds;
    final dataExhausted = limitBytesTotal > 0 && consumedBytes >= limitBytesTotal;
    if (uptimeExhausted || dataExhausted) return VoucherStatus.expired;

    if (consumedSeconds > 0 || consumedBytes > 0) return VoucherStatus.active;

    return VoucherStatus.pending;
  }

  factory Voucher.fromMap(Map<String, dynamic> map) {
    return Voucher(
      id: (map['id'] ?? 0) as int,
      routerId: (map['router_id'] ?? 0) as int,
      code: (map['code'] ?? '') as String,
      password: (map['password'] ?? '') as String,
      profileName: (map['profile_name'] ?? '') as String,
      price: (map['price'] ?? 0.0) as double,
      status: VoucherStatus.values.byName((map['status'] ?? 'pending') as String),
      createdAt: DateTime.fromMillisecondsSinceEpoch(((map['created_at'] ?? 0) as int) * 1000),
      createdBy: (map['created_by'] ?? '') as String,
      mikrotikId: map['mikrotik_id'] as String?,
      server: map['server'] as String?,
      comment: map['comment'] as String?,
      limitUptime: map['limit_uptime'] as String?,
      limitBytesTotal: (map['limit_bytes_total'] ?? 0) as int,
      uptime: map['uptime'] as String?,
      bytesIn: (map['bytes_in'] ?? 0) as int,
      bytesOut: (map['bytes_out'] ?? 0) as int,
      disabled: ((map['disabled'] ?? 0) as int) == 1,
    );
  }

  /// Formate un volume en octets — au-delà de 1000 Mo, bascule en Go.
  static String _formatBytes(int bytes) {
    if (bytes == 0) return '0';
    final mb = bytes / 1048576;
    if (mb >= 1000) return '${(bytes / 1073741824).toStringAsFixed(1)} Go';
    if (mb >= 1) return '${mb.toStringAsFixed(0)} Mo';
    return '$bytes o';
  }

  /// Quota de données formaté lisiblement (ex: `5.0 Go`, `500 Mo`).
  String get limitBytesFmt => limitBytesTotal == 0 ? 'illimité' : _formatBytes(limitBytesTotal);

  /// Données consommées formatées (download + upload).
  String get bytesTotalFmt => _formatBytes(bytesIn + bytesOut);

  @override
  List<Object?> get props => [id, routerId, code, profileName, status, createdAt];
}
