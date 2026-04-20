// =============================================================================
// Catégories d'erreur RouterOS (protocol spec)
// =============================================================================

/// Catégories d'erreur définies par le protocole RouterOS API.
/// Correspondent à la valeur du champ `category` dans une phrase `!trap`.
enum RouterOsTrapCategory {
  missingItem, // 0 — commande ou item introuvable
  argumentValue, // 1 — valeur d'argument invalide (ex: user déjà existant)
  interrupted, // 2 — commande interrompue (/cancel)
  scriptFailure, // 3 — erreur de script RouterOS
  generalFailure, // 4 — erreur générale
  apiFailure, // 5 — erreur liée à l'API
  ttyFailure, // 6 — erreur TTY
  returnValue, // 7 — valeur retournée par :return
  unknown, // fallback — catégorie absente ou non reconnue
}

extension RouterOsTrapCategoryX on RouterOsTrapCategory {
  /// Message lisible pour affichage dans l'UI.
  String get label {
    switch (this) {
      case RouterOsTrapCategory.missingItem:
        return 'Commande ou item introuvable';
      case RouterOsTrapCategory.argumentValue:
        return 'Valeur invalide';
      case RouterOsTrapCategory.interrupted:
        return 'Commande interrompue';
      case RouterOsTrapCategory.scriptFailure:
        return 'Erreur de script';
      case RouterOsTrapCategory.generalFailure:
        return 'Erreur générale';
      case RouterOsTrapCategory.apiFailure:
        return 'Erreur API';
      case RouterOsTrapCategory.ttyFailure:
        return 'Erreur TTY';
      case RouterOsTrapCategory.returnValue:
        return 'Valeur de retour';
      case RouterOsTrapCategory.unknown:
        return 'Erreur inconnue';
    }
  }
}
