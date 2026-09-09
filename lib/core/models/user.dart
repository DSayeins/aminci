// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:aminci/core/enum/user_role.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String username;
  final String password;
  final UserRole role;

  const User({required this.id, this.name = '', required this.username, this.password = '', required this.role});

  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object> get props => [id, name, username, role];

  User copyWith({int? id, String? name, String? username, String? password, UserRole? role}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'name': name, 'username': username, 'role': role.name};
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: (map['id'] ?? 0) as int,
      name: (map['name'] ?? '') as String,
      username: (map['username'] ?? '') as String,
      role: UserRole.values.firstWhere((r) => r.name == map['role']),
    );
  }
}
