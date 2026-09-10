# Contribuer à Aminci

## Mise en place

```bash
flutter pub get
flutter run -d windows
```

Avant de proposer une contribution :

```bash
flutter analyze   # doit rester à 0 issue
flutter test      # pas de tests écrits pour l'instant, mais la commande doit passer
```

---

## Branches

`master` est la branche par défaut — on n'y commit jamais directement.

Toute contribution part d'une branche dédiée :

```bash
git checkout -b <type>/<sujet-court>
```

Exemples : `feat/generation-vouchers`, `fix/session-restore`, `refactor/hotspot-cache`.

---

## Commits

Format [Conventional Commits](https://www.conventionalcommits.org/), en français dans le corps du message :

```
<type>(<scope>): <résumé bref>

- détail 1
- détail 2
```

Types utilisés dans ce projet : `feat`, `fix`, `refactor`, `docs`, `chore`.
Le scope est en général le nom de la feature (`feat(routers): ...`, `fix(setup): ...`).

Voir l'historique (`git log --oneline`) pour des exemples réels.

---

## Architecture — à respecter

Aminci suit une architecture **feature-first Clean Architecture**. Le détail complet (flux de démarrage, conventions DI, migrations DB, gestion d'erreurs) est dans [`CLAUDE.md`](CLAUDE.md) — le lire avant de toucher au code si ce n'est pas déjà fait.

Points non négociables :

- Chaque feature garde ses couches `data/` / `domain/` / `presentation/` séparées. `domain` ne dépend ni de Flutter, ni de sqflite, ni d'une autre feature.
- La coordination entre features passe par un événement dispatché sur le BLoC d'une autre feature (ex. `LoginBloc.add(LoginSessionRestored(...))`), jamais par un import direct de son `domain`/`data`.
- Tout retour d'erreur de repository est un `Either<Failure, T>` (`dartz`). Préférer `ErrorMapper.guard(() => ...)` à un try/catch manuel.
- Toute nouvelle feature ajoute son module DI (`lib/core/di/modules/<feature>_module.dart`) et l'enregistre dans `service_locator.dart`.
- Tout nouveau BLoC doit être ajouté au `MultiBlocProvider` de `lib/main.dart`, sinon `context.read<>()`/`context.watch<>()` lève une exception au premier appel.
- Aucune valeur hex, `Colors.xxx` ou `TextStyle`/padding/`BorderRadius` inline dans les widgets — toujours `AppColors` / `AppSpacing` / `AppTypography` (`lib/core/theme/`).
- Un composant visuel distinct va dans son propre fichier — pas d'écran monolithique qui mélange plusieurs responsabilités.

### Migrations de base de données

Pour ajouter une colonne ou une table :
1. Bumper `_dbVersion` dans `lib/core/database/database_helper.dart`
2. Ajouter un bloc `if (oldVersion < N)` dans `_onUpgrade`
3. Mettre à jour `_onCreate` pour que les nouvelles installations aient le même schéma

---

## Avant d'ouvrir une pull request

- [ ] `flutter analyze` ne remonte rien
- [ ] Testé manuellement sur `flutter run -d windows`
- [ ] `CLAUDE.md` mis à jour si un pattern d'architecture a changé
- [ ] Pas de credentials, token ou chemin local dans le diff
