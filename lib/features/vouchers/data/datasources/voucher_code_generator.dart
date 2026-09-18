import 'dart:math';

/// Génère des codes/mots de passe de voucher aléatoires (convention observée
/// sur le routeur : nom alphanumérique, mot de passe numérique).
class VoucherCodeGenerator {
  static final Random _random = Random.secure();

  /// Alphabet du code voucher — lettres + chiffres, sans caractères ambigus
  /// à la lecture/saisie (`0`/`o`, `1`/`l`/`i`). 31 caractères ⁴ ≈ 923 500
  /// combinaisons possibles (contre ~457 000 avec des lettres seules), pour
  /// limiter le risque de collision avec un compte déjà existant sur le
  /// routeur.
  static const String _codeAlphabet = 'abcdefghjkmnpqrstuvwxyz23456789';

  static String code() => List.generate(4, (_) => _codeAlphabet[_random.nextInt(_codeAlphabet.length)]).join();

  static String password() => List.generate(4, (_) => _random.nextInt(10)).join();
}
