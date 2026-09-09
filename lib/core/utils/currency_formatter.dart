import 'package:intl/intl.dart';

/// Formatage des montants pour l'affichage et les tickets imprimés.
abstract final class CurrencyFormatter {
  /// Formate un montant avec séparateur de milliers et devise en suffixe.
  /// Ex. `format(1500)` → `"1 500 FCFA"`.
  static String format(num amount, {String currency = 'FCFA'}) {
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: currency, decimalDigits: 0);
    return formatter.format(amount).trim();
  }
}
