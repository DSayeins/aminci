import 'dart:math';

/// Génère des codes/mots de passe de voucher aléatoires (convention observée
/// sur le routeur : nom en lettres minuscules, mot de passe numérique).
class VoucherCodeGenerator {
  static final Random _random = Random.secure();
  static const String _letters = 'abcdefghijklmnopqrstuvwxyz';

  static String code() => List.generate(4, (_) => _letters[_random.nextInt(_letters.length)]).join();

  static String password() => List.generate(4, (_) => _random.nextInt(10)).join();
}
