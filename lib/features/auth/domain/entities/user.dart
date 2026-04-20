import 'package:equatable/equatable.dart';

enum UserRole { admin, operator }

/// Entité utilisateur local — couche domain.
/// Ne dépend d'aucun framework ni base de données.
class User extends Equatable {
  final int id;
  final String username;
  final UserRole role;

  const User({
    required this.id,
    required this.username,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object> get props => [id, username, role];
}
