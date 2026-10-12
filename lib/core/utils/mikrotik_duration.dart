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

  /// Formate une durée en secondes au format MikroTik compact (ex: `1d2h30m`).
  /// Les unités nulles sont omises ; `0s` si [totalSeconds] est nul ou négatif.
  static String formatSeconds(int totalSeconds) {
    if (totalSeconds <= 0) return '0s';

    var remaining = totalSeconds;
    final weeks = remaining ~/ 604800;
    remaining %= 604800;
    final days = remaining ~/ 86400;
    remaining %= 86400;
    final hours = remaining ~/ 3600;
    remaining %= 3600;
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;

    final parts = <String>[
      if (weeks > 0) '${weeks}w',
      if (days > 0) '${days}d',
      if (hours > 0) '${hours}h',
      if (minutes > 0) '${minutes}m',
      if (seconds > 0) '${seconds}s',
    ];
    return parts.join();
  }
}
