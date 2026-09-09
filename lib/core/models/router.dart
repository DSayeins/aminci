import 'package:aminci/core/enum/router_os_version.dart';
import 'package:equatable/equatable.dart';

class MikroTikRouter extends Equatable {
  final int id;
  final String name;
  final String ip;
  final int port;
  final String username;
  final String password;
  final RouterOsVersion rosVersion;

  const MikroTikRouter({
    required this.id,
    required this.name,
    required this.ip,
    required this.port,
    required this.username,
    required this.password,
    this.rosVersion = RouterOsVersion.v7,
  });

  /// Port par défaut pour RouterOS API TCP (v6).
  static const int defaultPort = 8728;

  /// Port par défaut pour la REST API HTTP (v7+).
  static const int defaultRestPort = 80;

  MikroTikRouter copyWith({
    int? id,
    String? name,
    String? ip,
    int? port,
    String? username,
    String? password,
    RouterOsVersion? rosVersion,
  }) {
    return MikroTikRouter(
      id: id ?? this.id,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      rosVersion: rosVersion ?? this.rosVersion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ip': ip,
      'port': port,
      'username': username,
      'password': password,
      'ros_version': rosVersion.name,
    };
  }

  factory MikroTikRouter.fromMap(Map<String, dynamic> map) {
    return MikroTikRouter(
      id: (map['id'] ?? 0) as int,
      name: (map['name'] ?? '') as String,
      ip: (map['ip'] ?? '') as String,
      port: (map['port'] ?? defaultPort) as int,
      username: (map['username'] ?? '') as String,
      password: (map['password'] ?? '') as String,
      rosVersion: RouterOsVersion.values.byName((map['ros_version'] ?? 'v7') as String),
    );
  }

  @override
  List<Object> get props => [id, name, ip, port, username, rosVersion];
}
