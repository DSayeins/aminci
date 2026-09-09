import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Hachage de mots de passe — SHA-256 avec salt aléatoire 16 octets.
/// Format stocké en base : `"<salt_b64>:<sha256_hex>"`
abstract final class PasswordHasher {
  /// Génère un hash stockable pour un nouveau mot de passe.
  static String hash(String password) {
    final salt = _generateSalt();
    final digest = sha256.convert(utf8.encode('$salt:$password'));
    return '$salt:$digest';
  }

  /// Vérifie un mot de passe en clair contre un hash stocké (`hash()`).
  static bool verify(String password, String stored) {
    final sep = stored.indexOf(':');
    if (sep == -1) return false;
    final salt = stored.substring(0, sep);
    final expected = stored.substring(sep + 1);
    final digest = sha256.convert(utf8.encode('$salt:$password'));
    return digest.toString() == expected;
  }

  /// Génère un salt aléatoire sécurisé (16 octets → base64url).
  static String _generateSalt() {
    final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    return base64Url.encode(bytes);
  }
}
