import 'package:equatable/equatable.dart';

/// Hiérarchie des Failures Aminci
/// Toutes les erreurs métier remontent sous forme de Failure
/// Usage : Either`<Failure, T>` dans les repositories et use cases
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Erreur de connexion réseau (LAN local)
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Erreur de connexion réseau']);
}

/// Erreur d'authentification locale
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Identifiants incorrects']);
}

/// Erreur de communication avec le routeur MikroTik
class MikroTikFailure extends Failure {
  const MikroTikFailure([super.message = 'Erreur de communication MikroTik']);
}

/// Erreur de lecture/écriture base de données locale (sqflite)
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Erreur de stockage local']);
}

/// Erreur de génération ou export PDF
class ExportFailure extends Failure {
  const ExportFailure([super.message = "Erreur lors de l'export PDF"]);
}

/// Erreur de validation (données invalides)
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Données invalides']);
}

/// Erreur inattendue — attrape-tout
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Une erreur inattendue est survenue']);
}
