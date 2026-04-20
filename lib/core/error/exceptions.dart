/// Exceptions levées dans la couche data (datasources)
/// Converties en Failures dans les repositories
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Connexion réseau impossible']);
}

class MikroTikException implements Exception {
  final String message;
  const MikroTikException([this.message = 'Erreur RouterOS API']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentification échouée']);
}

class StorageException implements Exception {
  final String message;
  const StorageException([this.message = 'Erreur base de données']);
}

class ExportException implements Exception {
  final String message;
  const ExportException([this.message = 'Export impossible']);
}
