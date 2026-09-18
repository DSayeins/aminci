/// Utilitaires pour les durées au format MikroTik (`limit-uptime`, `uptime`).
abstract final class MikroTikDuration {
  static final RegExp _pattern = RegExp(r'(\d+)(w|d|h|m|s)');

  /// Parse une durée MikroTik (ex: `1w2d3h4m5s`, `45m`, `0s`) en secondes.
  /// Retourne 0 si [value] est nul, vide, ou ne correspond à aucun format connu.
  static int parseSeconds(String? value) {
    if (value == null || value.isEmpty) return 0;

    var totalSeconds = 0;
    for (final match in _pattern.allMatches(value)) {
      final amount = int.parse(match.group(1)!);
      switch (match.group(2)) {
        case 'w':
          totalSeconds += amount * 604800;
        case 'd':
          totalSeconds += amount * 86400;
        case 'h':
          totalSeconds += amount * 3600;
        case 'm':
          totalSeconds += amount * 60;
        case 's':
          totalSeconds += amount;
      }
    }
    return totalSeconds;
  }
}
