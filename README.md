# Aminci

> **Aminci** signifie « simplifier » en haoussa (Niger).

Application desktop Windows de gestion et génération de tickets d'accès MikroTik (hotspot vouchers), conçue pour les opérateurs réseau en Afrique de l'Ouest.

---

## Aperçu

Aminci permet à des administrateurs et opérateurs réseau de :

- Générer des vouchers hotspot MikroTik et les imprimer en PDF
- Gérer plusieurs routeurs sur des sites différents (multi-site)
- Synchroniser et configurer les profils d'accès (débit, durée, quota)
- Surveiller les sessions hotspot actives en temps réel
- Consulter l'historique de tous les tickets générés

L'application fonctionne **entièrement en réseau local** — aucune connexion Internet n'est requise. Elle communique directement avec les routeurs MikroTik via le protocole **RouterOS API (TCP port 8728)**.

---

## Stack technique

| Rôle | Technologie |
|---|---|
| Framework | Flutter (Windows desktop) |
| Langage | Dart |
| State management | BLoC / Cubit |
| Injection de dépendances | get_it |
| Navigation | NavigationBloc + IndexedStack |
| Base de données locale | sqflite (via sqflite_common_ffi) |
| Communication MikroTik | RouterOS API TCP via `dart:io` |
| Export PDF | pdf + printing |
| UI | Flutter Desktop — thème light / dark |

---

## Architecture

Aminci suit une architecture **Feature-first Clean Architecture** avec séparation stricte des couches.

```
lib/
├── core/
│   ├── database/        ← DatabaseHelper (sqflite_common_ffi)
│   ├── di/              ← Service locator (get_it)
│   ├── error/           ← Failures, Exceptions, Either
│   ├── mikrotik/        ← Client RouterOS API (TCP)
│   ├── models/          ← Modèles partagés (User, Router, Profile, Voucher)
│   ├── navigation/      ← Routes enum, NavigationBloc
│   └── theme/           ← AppColors, AppSpacing, AppTypography, ThemeCubit
│
├── features/
│   ├── app/             ← AppShell, AppBloc, AppSidebar, AppTopBar
│   ├── auth/            ← Login local, gestion des rôles
│   ├── launch/          ← Écran de démarrage, vérification de session
│   ├── setup/           ← Création du premier compte administrateur
│   ├── routers/         ← CRUD routeurs + test de connexion
│   ├── profiles/        ← Synchronisation des profils MikroTik
│   ├── vouchers/        ← Génération, impression et suppression de vouchers
│   ├── sessions/        ← Sessions hotspot actives (temps réel)
│   └── export/          ← Impression PDF / export fichier
│
└── shared/
    └── widgets/         ← EmptyState, AppSnackbar, BrandingPanel
```

Chaque feature suit le même découpage interne :

```
feature/
├── data/           ← Repository impl, sources de données (sqflite, MikroTik)
├── domain/         ← Repository abstract, use cases (sans dépendances Flutter)
└── presentation/   ← BLoC, écrans, widgets
```

---

## Fonctionnalités

### Routeurs
- Ajout, modification et suppression de routeurs MikroTik
- Test de connexion RouterOS API en un clic
- Stockage des credentials en local (sqflite)

### Profils
- Synchronisation des profils hotspot depuis le routeur MikroTik
- Affichage du débit (`rate-limit`), de la durée (`session-timeout`) et des connexions simultanées
- Configuration du prix de vente par profil

### Vouchers
- Génération de 1 à 50 vouchers par lot
- Codes au format `AM-XXXXX` (alphabet sans caractères ambigus)
- Impression automatique en PDF après génération — 3 tickets par ligne sur A4
- Chaque ticket contient : code, mot de passe, profil, débit, durée, site, prix, date
- Suppression locale et sur le routeur MikroTik

### Authentification
- Authentification locale (sqflite) avec hash SHA-256 + salt
- Deux rôles : **Administrateur** (accès complet) et **Opérateur** (vouchers uniquement)
- Session persistée entre les redémarrages

---

## Prérequis

- Windows 10 / 11 (64 bits)
- Flutter SDK ≥ 3.11
- Dart SDK ≥ 3.11
- Un ou plusieurs routeurs MikroTik avec l'API activée (port 8728)

### Activer l'API RouterOS sur MikroTik

```
/ip service set api disabled=no port=8728
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

---

## Base de données

La base SQLite est stockée dans `%APPDATA%\Aminci\aminci.db`.

Pour réinitialiser l'application (ex: changer le schéma en développement) :

```
%APPDATA%\Aminci\aminci.db  ← supprimer ce fichier
```

---

## Système de design

Le thème Aminci est défini dans `lib/core/theme/` :

| Fichier | Rôle |
|---|---|
| `app_colors.dart` | Palette light + dark (primitives + sémantiques) |
| `app_spacing.dart` | Grille 4px — espacements, dimensions, border radius |
| `app_typography.dart` | Styles Inter (UI) + JetBrains Mono (codes, données techniques) |
| `app_theme.dart` | ThemeData Flutter assemblé (light + dark) |
| `theme_cubit.dart` | Toggle light / dark piloté par BLoC |

**Règle absolue** : ne jamais utiliser de valeurs hex, de `Colors.xxx` ou de `TextStyle` inline dans les widgets. Toujours passer par `AppColors`, `AppSpacing` et `AppTypography`.

---

## Contexte d'utilisation

- Réseau local (LAN) — aucun accès Internet requis
- Déploiement sur PC de bureau ou laptop Windows
- Opérateurs potentiellement peu techniques — l'UI privilégie la clarté et la rapidité
- Tickets imprimés sur petits formats papier (format A4, 3 par ligne)
- Adapté aux contraintes terrain d'Afrique de l'Ouest (Niger)

---

## Licence

Projet privé — tous droits réservés.
