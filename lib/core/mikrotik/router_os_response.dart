import 'package:aminci/core/mikrotik/router_os_trap_category.dart';

/// Réponse brute du protocole RouterOS API.
///
/// Le routeur émet des phrases (sentences) composées de mots.
/// Chaque phrase commence par un mot-type :
///   - `!re`    → une ligne de données (attributs clé=valeur)
///   - `!done`  → fin de la commande, succès
///   - `!trap`  → erreur applicative MikroTik
///   - `!fatal` → erreur fatale, connexion fermée
sealed class RouterOsResponse {
  const RouterOsResponse();
}

// =============================================================================
// Types de réponse
// =============================================================================

/// Une ligne de résultat — contient les attributs de la réponse.
///
/// Exemple : `{'.id': '*1', 'name': 'AM-4F2K9', 'profile': 'basic'}`
final class RouterOsReply extends RouterOsResponse {
  /// Attributs de la ligne, sans le préfixe `=`.
  /// Clé : nom de l'attribut (ex: `name`), valeur : valeur brute.
  final Map<String, String> attributes;

  const RouterOsReply(this.attributes);

  /// Raccourci pour lire un attribut, retourne `null` si absent.
  String? operator [](String key) => attributes[key];

  /// Copie immuable des attributs — utile pour la sérialisation.
  Map<String, String> toMap() => Map.unmodifiable(attributes);

  @override
  String toString() => 'RouterOsReply($attributes)';
}

/// Fin de commande — succès.
/// Peut contenir des attributs supplémentaires (ex: `ret` dans le login v6).
final class RouterOsDone extends RouterOsResponse {
  final Map<String, String> attributes;

  const RouterOsDone([this.attributes = const {}]);

  String? operator [](String key) => attributes[key];

  @override
  String toString() => 'RouterOsDone($attributes)';
}

/// Erreur applicative retournée par le routeur.
///
/// Exemple : tentative de créer un utilisateur déjà existant.
final class RouterOsTrap extends RouterOsResponse {
  final String message;
  final RouterOsTrapCategory category;

  const RouterOsTrap({required this.message, this.category = RouterOsTrapCategory.unknown});

  /// Construit un [RouterOsTrap] depuis les attributs bruts d'une phrase.
  factory RouterOsTrap.fromAttributes(Map<String, String> attrs) {
    final catIndex = int.tryParse(attrs['category'] ?? '');
    final category = (catIndex != null && catIndex >= 0 && catIndex < RouterOsTrapCategory.values.length - 1)
        ? RouterOsTrapCategory.values[catIndex]
        : RouterOsTrapCategory.unknown;

    return RouterOsTrap(message: attrs['message'] ?? 'Erreur MikroTik inconnue', category: category);
  }

  @override
  String toString() => 'RouterOsTrap(message: $message, category: $category)';
}

/// Erreur fatale — le routeur ferme la connexion immédiatement.
final class RouterOsFatal extends RouterOsResponse {
  final String message;

  const RouterOsFatal(this.message);

  @override
  String toString() => 'RouterOsFatal($message)';
}

// =============================================================================
// Extension utilitaire sur List<RouterOsResponse>
// =============================================================================

extension RouterOsResponseListX on List<RouterOsResponse> {
  /// `true` si la liste contient un `!trap` ou un `!fatal`.
  bool get hasError => any((r) => r is RouterOsTrap || r is RouterOsFatal);

  /// `true` si la commande s'est terminée avec `!done` sans erreur.
  bool get isSuccess => !hasError && any((r) => r is RouterOsDone);

  /// Premier `!trap` trouvé, ou `null`.
  RouterOsTrap? get trap => whereType<RouterOsTrap>().firstOrNull;

  /// Premier `!fatal` trouvé, ou `null`.
  RouterOsFatal? get fatal => whereType<RouterOsFatal>().firstOrNull;

  /// Toutes les lignes de données `!re`.
  List<RouterOsReply> get replies => whereType<RouterOsReply>().toList();

  /// Le `!done` de fin de commande, ou `null`.
  RouterOsDone? get done => whereType<RouterOsDone>().firstOrNull;

  /// Message d'erreur consolidé (trap ou fatal), ou `null` si succès.
  String? get errorMessage => trap?.message ?? fatal?.message;

  /// Lève une [Exception] si la réponse contient une erreur.
  /// Usage : `result.throwIfError()` dans les repositories.
  void throwIfError() {
    if (trap != null) throw Exception(trap!.message);
    if (fatal != null) throw Exception(fatal!.message);
  }
}
