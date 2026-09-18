/// Formatage de volumes de données pour l'affichage.
abstract final class ByteFormatter {
  /// Formate un volume en octets — au-delà de 1000 Mo, bascule en Go.
  /// Ex. `format(0)` → `"0"`, `format(500*1048576)` → `"500 Mo"`,
  /// `format(5*1073741824)` → `"5.0 Go"`.
  static String format(int bytes) {
    if (bytes == 0) return '0';
    final mb = bytes / 1048576;
    if (mb >= 1000) return '${(bytes / 1073741824).toStringAsFixed(1)} Go';
    if (mb >= 1) return '${mb.toStringAsFixed(0)} Mo';
    return '$bytes o';
  }
}
