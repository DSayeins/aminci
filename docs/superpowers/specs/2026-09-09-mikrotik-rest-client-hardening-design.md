# Renforcement du client REST MikroTik — Spec

**Date** : 2026-09-09
**Statut** : en attente de revue utilisateur
**Périmètre** : `lib/core/mikrotik/mikrotik_rest_client.dart` uniquement (aucun changement de schéma DB, de modèle `MikroTikRouter`, ni d'UI dans cette spec)
**Source** : [doc REST API RouterOS officielle](https://help.mikrotik.com/docs/spaces/ROS/pages/47579162/REST+API)

---

## 1. Contexte

`MikroTikRestClient` couvre aujourd'hui GET/PUT/PATCH/DELETE en HTTP simple, avec un timeout fixe de 10s. La doc officielle RouterOS révèle trois écarts :

1. **POST** est le verbe universel de la REST API — il donne accès à des commandes que GET/PUT/PATCH/DELETE ne couvrent pas (ex. `/system/reboot`, `/tool/ping`, tout endpoint non-CRUD). Le client actuel n'a aucun moyen de les appeler.
2. RouterOS tolère jusqu'à **60 secondes** pour l'exécution d'une commande côté serveur avant de renvoyer une erreur 400 ; le client coupe déjà à 10s côté `receiveTimeout`, donc une commande légitimement lente (ex. scan Wi-Fi, `/tool/ping count=20`) peut échouer côté client alors que RouterOS l'aurait terminée.
3. La doc recommande **HTTPS en production**, HTTP n'étant toléré que pour les tests. Le client construit son `baseUrl` en HTTP en dur.

## 2. Décisions

| Sujet | Décision |
|---|---|
| POST | Ajouter `Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body])` sur `MikroTikRestClient`, même pattern try/catch que les autres méthodes. Pas de nouveau use case ajouté dans cette spec — seulement la capacité du client ; l'usage concret (ex. reboot routeur) sera une feature séparée si besoin. |
| Timeout | Séparer les deux timeouts Dio : `connectTimeout` reste à **10s** (établir la connexion TCP doit rester rapide — un routeur injoignable ne doit pas bloquer l'UI 60s), `receiveTimeout` passe à **60s** (aligné sur la limite serveur RouterOS, pour laisser le temps aux commandes lentes de répondre). |
| HTTPS | Ajouter un paramètre optionnel `useSsl` au constructeur (`bool useSsl = false`) qui bascule le `baseUrl` en `https://`. **Valeur par défaut `false`** — aucun comportement existant ne change tant que l'appelant ne passe pas explicitly `useSsl: true`. |
| Certificats HTTPS | RouterOS utilise typiquement un certificat auto-signé en LAN. Avec `useSsl: true`, le client doit accepter ces certificats (sinon toute connexion HTTPS échoue par défaut). Voir §4 pour la mise en œuvre et le compromis de sécurité — **à valider explicitement**, car c'est la décision la plus sensible de cette spec. |
| Câblage routeur → `useSsl` | **Hors scope.** Faire du HTTPS un choix persistant par routeur nécessiterait une colonne DB (migration, bump `_dbVersion`) + un champ dans `add_router_dialog.dart`/`routers_repository_impl.dart`. Cette spec livre seulement la capacité au niveau du client ; le câblage complet est une spec séparée si le besoin se confirme. |

## 3. Changements dans `mikrotik_rest_client.dart`

### 3.1 Constructeur
```dart
MikroTikRestClient({
  required String ip,
  required int port,
  required String username,
  required String password,
  bool useSsl = false,
}) : _dio = Dio(
        BaseOptions(
          baseUrl: '${useSsl ? 'https' : 'http'}://$ip:$port/rest',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 60),
          headers: { ... }, // inchangé
        ),
      ) {
  if (useSsl) {
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true; // cert auto-signé LAN — voir §4
      return client;
    };
  }
}
```

### 3.2 Nouvelle méthode `post`
```dart
Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) async {
  try {
    final response = await _dio.post<dynamic>(path, data: body);
    return (response.data as Map<String, dynamic>?) ?? {};
  } on DioException catch (e) {
    throw _toMikroTikException(e);
  }
}
```
Même comportement d'erreur que `put`/`patch` — réutilise `_toMikroTikException`.

## 4. Compromis de sécurité — certificats auto-signés

`badCertificateCallback: (cert, host, port) => true` **désactive la validation du certificat** pour toutes les requêtes HTTPS de ce client, pas seulement pour un hôte précis. C'est nécessaire parce que RouterOS génère un certificat auto-signé par défaut (pas d'autorité de confiance) et que ce projet n'a pas d'infrastructure PKI interne.

**Risque accepté** : sur un LAN local (contexte du projet, §8 de `.claude/CLAUDE.md`), le risque de MITM est faible (nécessite un accès physique/déjà compromis au réseau local). C'est cohérent avec la tolérance HTTP déjà en place aujourd'hui (§2/§5 de `.claude/CLAUDE.md` : "pas de problème de certificat en LAN").

**Alternative plus stricte (non retenue par défaut)** : épingler le certificat exact du routeur (certificate pinning) — rejeté ici car ça demanderait de stocker/gérer une empreinte de certificat par routeur, complexité disproportionnée pour un déploiement LAN mono-tenant.

## 5. Ce qui ne change PAS

- `get`, `put`, `patch`, `delete` : signature et comportement inchangés.
- `connect()` : toujours `GET /system/identity`, inchangé.
- Aucun appelant existant (`RoutersRepositoryImpl.testConnection`) n'est impacté — `useSsl` par défaut à `false` reproduit le comportement actuel à l'identique.
- Pas de nouvelle colonne DB, pas de nouveau champ UI.

## 6. Tests / vérification

Pas de tests automatisés existants sur ce client. Vérification :
1. `flutter analyze` sur le fichier modifié.
2. Vérification manuelle : `testConnection` sur un routeur réel doit continuer à fonctionner sans changement (HTTP, timeout 10s de connexion inchangé).
3. Si un routeur avec HTTPS/`www-ssl` actif est disponible pour test manuel, valider `useSsl: true` retourne bien une réponse au lieu d'un `HandshakeException`.

## 7. Ordre d'implémentation

1. Timeout (`receiveTimeout` → 60s) — changement isolé, aucun risque.
2. Méthode `post()` — additive, aucun risque.
3. Paramètre `useSsl` + gestion du certificat — additif avec défaut `false`, aucun risque pour les appelants existants.
4. `flutter analyze` final.
