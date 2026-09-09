import 'package:dartz/dartz.dart';

import 'package:aminci/core/error/exceptions.dart' hide MikroTikException;
import 'package:aminci/core/error/failures.dart';
import 'package:aminci/core/mikrotik/mikrotik_exception.dart';

/// Convertit les exceptions de la couche data en [Failure] du domain layer.
///
/// Centralise la logique dupliquée dans chaque repository
/// (`on XxxException catch (e) { return Left(XxxFailure(e.message)); }`).
///
/// Usage direct :
/// ```dart
/// } on StorageException catch (e) {
///   return Left(ErrorMapper.map(e));
/// }
/// ```
///
/// Usage recommandé — [ErrorMapper.guard] enveloppe l'appel entier :
/// ```dart
/// Future<Either<Failure, List<MikroTikRouter>>> getRouters() {
///   return ErrorMapper.guard(() => _local.getRouters());
/// }
/// ```
class ErrorMapper {
  const ErrorMapper._();

  /// Exécute [action] et convertit toute exception levée en [Failure].
  /// Retourne `Right(résultat)` en cas de succès.
  static Future<Either<Failure, T>> guard<T>(
    Future<T> Function() action, {
    String? fallbackMessage,
  }) async {
    try {
      return Right(await action());
    } catch (e) {
      return Left(map(e, fallbackMessage: fallbackMessage));
    }
  }

  /// Convertit une exception déjà catchée en [Failure] typée.
  static Failure map(Object error, {String? fallbackMessage}) {
    switch (error) {
      case StorageException e:
        return StorageFailure(e.message);
      case NetworkException e:
        return NetworkFailure(e.message);
      case AuthException e:
        return AuthFailure(e.message);
      case ExportException e:
        return ExportFailure(e.message);
      case MikroTikException e:
        // 401 côté RouterOS = identifiants invalides plutôt qu'un défaut réseau
        if (e.statusCode == 401) return AuthFailure(e.message);
        return MikroTikFailure(e.message);
      case Failure f:
        // Déjà mappé (ex. relayé depuis un autre Either) — on le laisse passer
        return f;
      default:
        return UnexpectedFailure(fallbackMessage ?? 'Une erreur inattendue est survenue : $error');
    }
  }
}
