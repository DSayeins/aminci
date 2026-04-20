// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

enum UserRole { admin, operator }

class User extends Equatable {
  final int id;
  final String username;
  final UserRole role;

  const User({required this.id, required this.username, required this.role});

  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object> get props => [id, username, role];

  User copyWith({int? id, String? username, UserRole? role}) {
    return User(id: id ?? this.id, username: username ?? this.username, role: role ?? this.role);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'username': username, 'role': role.name};
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: (map['id'] ?? 0) as int,
      username: (map['username'] ?? '') as String,
      role: UserRole.values.firstWhere((r) => r.name == map['role']),
    );
  }
}
