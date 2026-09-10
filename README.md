# Aminci

> **Aminci** signifie « simplifier » en haoussa (Niger).

Application desktop Windows de gestion et génération de tickets d'accès MikroTik (hotspot vouchers), conçue pour les opérateurs réseau en Afrique de l'Ouest.

---

## Aperçu

Aminci vise à permettre à des administrateurs et opérateurs réseau de :

- Gérer plusieurs routeurs MikroTik sur des sites différents (multi-site)
- Gérer plusieurs hotspots par routeur
- Générer des vouchers hotspot et les imprimer en PDF
- Synchroniser et configurer les profils d'accès (débit, durée, quota)
- Surveiller les sessions hotspot actives en temps réel
- Consulter l'historique des tickets générés

L'application fonctionne **entièrement en réseau local** — aucune connexion Internet n'est requise. Elle communique avec les routeurs MikroTik via la **REST API de RouterOS v7+** (`http://{ip}:{port}/rest`).

**État actuel** : authentification, gestion des routeurs et des hotspots sont fonctionnels. Profils, vouchers, sessions actives et historique sont encore à construire (voir [Roadmap](#roadmap)).

---

## Stack technique

| Rôle | Technologie |
|---|---|
| Framework | Flutter (Windows desktop) |
| Langage | Dart |
| State management | BLoC / Cubit |
| Injection de dépendances | get_it |
| Navigation | go_router (déclaratif) |
| Base de données locale | sqflite (via sqflite_common_ffi) |
| Communication MikroTik | REST API (RouterOS v7+) via Dio |
| Export PDF | pdf + printing |
| UI | Flutter Desktop — police Sora (UI) + JetBrains Mono (codes) |

---

## Architecture

Aminci suit une architecture **Feature-first Clean Architecture**.

```
lib/
├── core/
│   ├── database/     ← DatabaseHelper (sqflite_common_ffi), migrations
│   ├── di/           ← Service locator (get_it), un module par feature
│   ├── enum/         ← UserRole, RouterOsVersion
│   ├── error/        ← Failures, Exceptions, Either, ErrorMapper
│   ├── mikrotik/     ← Client REST RouterOS (MikroTikRestClient)
│   ├── models/       ← Modèles partagés (User, MikroTikRouter, Hotspot,
│   │                    HotspotProfile, Voucher, Preference, AppState)
│   ├── router/       ← go_router (app_router.dart), enum Routes
│   ├── theme/        ← AppColors, AppSpacing, AppTypography, AppTheme
│   └── utils/        ← PasswordHasher, CurrencyFormatter
│
├── features/
│   ├── launch/    ← Écran de démarrage, détection premier lancement / session active
│   ├── setup/     ← Wizard 3 étapes : compte admin, premier routeur, préférences
│   ├── login/     ← Authentification locale
│   ├── logout/    ← Déconnexion (ferme la session active)
│   ├── routers/   ← CRUD routeurs MikroTik + test de connexion
│   ├── hotspot/   ← Liste des hotspots d'un routeur (un routeur peut en avoir plusieurs)
│   └── app/       ← Shell de l'app connectée (sidebar, topbar) — presentation seule
│
└── shared/
    └── widgets/   ← EmptyState, ErrorView, AppSnackbar, SplashView, BrandingPanel, AppTextField
```

Chaque feature suit le même découpage interne (sauf `app/`, presentation-only par choix — voir `CLAUDE.md`) :

```
feature/
├── data/           ← Repository impl, datasources (sqflite, MikroTik)
├── domain/         ← Repository abstract, use cases (sans dépendance Flutter)
└── presentation/   ← BLoC, écrans, widgets
```

Détails à jour dans [`CLAUDE.md`](CLAUDE.md) (flux de démarrage, conventions DI, migrations DB, gestion d'erreurs).

---

## Fonctionnalités

### Authentification & premier lancement
- Wizard de setup en 3 étapes au premier lancement : compte administrateur, premier routeur, préférences (devise, format de date, thème)
- Connexion locale (sqflite), hash SHA-256 + salt
- Session persistée entre redémarrages — restaurée automatiquement sans repasser par l'écran de connexion

### Routeurs
- Ajout, sélection et suppression de routeurs MikroTik
- Validation de connexion via `GET /system/identity`
- Support RouterOS v7+ (REST, port 80)

### Hotspots
- Liste des serveurs hotspot d'un routeur (`/ip/hotspot/print`) — un routeur peut en avoir plusieurs
- Mise en cache locale, resynchronisée à chaque chargement
- Sélection du hotspot actif avant d'accéder au reste de l'app

---

## Roadmap

Pas encore implémenté (routes présentes mais vides — `Placeholder()`) :

- **Profils** — synchronisation des profils hotspot MikroTik (débit, durée, quota, prix)
- **Vouchers** — génération par lot, impression PDF, historique
- **Sessions actives** — surveillance en temps réel, déconnexion manuelle

---

## Prérequis

- Windows 10 / 11 (64 bits)
- Flutter SDK ≥ 3.11
- Dart SDK ≥ 3.11
- Un ou plusieurs routeurs MikroTik RouterOS v7+ avec l'API REST activée

### Activer l'API REST sur MikroTik (RouterOS v7+)

```
/ip service set www disabled=no port=80
```

---

## Installation

```bash
# Cloner le dépôt
git clone <url-du-repo>
cd aminci

# Installer les dépendances
flutter pub get

# Lancer en mode debug
flutter run -d windows

# Compiler en release
flutter build windows --release
```

L'exécutable est généré dans `build/windows/x64/runner/Release/`.

Voir [`CONTRIBUTING.md`](CONTRIBUTING.md) pour les conventions de contribution.

---

## Base de données

La base SQLite est stockée dans `%APPDATA%\Aminci\aminci.db`.

Pour réinitialiser l'application en développement (ex: après un changement de schéma non migré proprement) : supprimer ce fichier.

---

## Système de design

Le thème Aminci est défini dans `lib/core/theme/` :

| Fichier | Rôle |
|---|---|
| `app_colors.dart` | Palette light + dark (primitives + sémantiques) |
| `app_spacing.dart` | Grille 4px — espacements, dimensions, border radius |
| `app_typography.dart` | Styles Sora (UI) + JetBrains Mono (codes, données techniques) |
| `app_theme.dart` | `ThemeData` Flutter assemblé (`AppTheme.light` / `AppThemeDark.dark`) |

**Règle absolue** : ne jamais utiliser de valeurs hex, de `Colors.xxx` ou de `TextStyle` inline dans les widgets. Toujours passer par `AppColors`, `AppSpacing` et `AppTypography`.

---

## Contexte d'utilisation

- Réseau local (LAN) — aucun accès Internet requis
- Déploiement sur PC de bureau ou laptop Windows
- Opérateurs potentiellement peu techniques — l'UI privilégie la clarté et la rapidité
- Tickets imprimés sur petits formats papier
- Adapté aux contraintes terrain d'Afrique de l'Ouest (Niger)

---

## Licence

Distribué sous licence MIT — voir [`LICENSE`](LICENSE).
