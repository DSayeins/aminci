# Refonte du design system Aminci — Spec

**Date** : 2026-09-08
**Statut** : en attente de revue utilisateur
**Périmètre** : `lib/core/theme/` (4 fichiers) + `pubspec.yaml` (déclarations de polices) + `.claude/CLAUDE.md` (doc de référence)

---

## 1. Contexte et objectif

Un audit de conformité au design system (§12 de `.claude/CLAUDE.md`) et une relecture ligne à ligne de `app_colors.dart`, `app_spacing.dart`, `app_typography.dart` et `app_theme.dart` ont révélé plusieurs incohérences structurelles, sans qu'aucune ne casse visuellement l'app aujourd'hui :

1. **Police mal déclarée** — `pubspec.yaml` définit une famille `Inter` dont les fichiers pointent en réalité vers `JetBrainsMono-Regular.ttf` / `JetBrainsMono-Medium.ttf` (copier-coller raté). Aucune famille `JetBrainsMono` n'est correctement déclarée, alors qu'`AppTypography.fontMono` y fait référence — le texte mono risque de retomber sur une police système.
2. **Doc vs code** — `.claude/CLAUDE.md` mandate la police **Inter** pour l'UI, mais le code utilise **Sora** partout (`AppTypography.fontUI = 'Sora'`), et aucun fichier `.ttf` Inter n'existe dans `assets/fonts/`.
3. **Duplication de constantes** — `AppSpacing.buttonIconSize` (14) et `AppSpacing.navIconSize` (16) redéfinissent des valeurs déjà nommées (`iconSm`, `iconMd`) au lieu d'y faire référence.
4. **Violations de la grille 4px** — `buttonHeightSm` (30), `buttonHeightLg` (42), `navItemHeight` (34) et `routerPillDotSize` (7) ne sont pas des multiples de 4, alors que le fichier annonce explicitement une grille 4px.
5. **Asymétrie light/dark** — `AppColorsDark.bgElevated` existe (menus, popovers) mais `AppColors` (light) n'a pas d'équivalent ; le thème clair réutilise `bgSurface` partout.
6. **Commentaire obsolète** — `AppSpacing.cardPaddingV` référence un ajustement dense qui existe déjà sous forme de token dédié (`cardPaddingDense`).
7. **Violation ponctuelle du design system dans un widget** — `app_sidebar.dart:224` utilise `TextStyle(color: AppColors.error)` inline au lieu de `AppTypography.xxx.copyWith(...)`.

**Objectif** : corriger ces incohérences sans casser les ~25 fichiers de widgets qui consomment déjà `AppColors`/`AppSpacing`/`AppTypography`, et aligner la documentation du projet sur la réalité du code plutôt que l'inverse.

---

## 2. Décisions validées avec l'utilisateur

| Sujet | Décision |
|---|---|
| Police UI | **Garder Sora.** Corriger `.claude/CLAUDE.md` pour documenter Sora au lieu d'Inter (le code ne change pas de police). |
| Police mono mal déclarée | Corriger le bug `pubspec.yaml` : renommer le bloc `family: Inter` (qui pointe vers les fichiers JetBrains Mono) en `family: JetBrainsMono`. Pas de nouveau fichier de police à ajouter. |
| Couleur primaire | **Garder le vert** — pas de changement de teinte. |
| Style général | **Sobre / utilitaire** — le style actuel (densité d'info, arrondis modérés) correspond déjà à cette direction ; validé, pas de changement d'échelle visuelle. |
| Border radius | **Garder l'échelle actuelle** (4/6/8/10/12px, pill) — cohérente avec le style sobre/utilitaire. |
| Stratégie d'implémentation | **Approche A — refactor en place.** On garde les 4 fichiers et tous les noms de tokens publics existants ; on ne corrige que les bugs et incohérences listés ci-dessus. Aucun fichier widget consommateur n'a besoin d'être modifié, sauf le point 7 (violation ponctuelle). |

**Hors scope (accepté comme compromis de l'approche A)** : le chevauchement de nommage entre `AppSpacing.borderXs/Sm/Md/Lg/Xl/Full` (des `BorderRadius`) et `AppSpacing.borderThin/Default/Thick` (des largeurs `double`) n'est **pas renommé** — un renommage propre (ex. séparer en `AppRadius`/`AppBorderWidth`) toucherait les ~25 fichiers consommateurs pour un gain cosmétique, ce qui contredit le choix de l'approche A. Documenté ici comme dette technique connue, pas comme oubli.

---

## 3. Changements détaillés par fichier

### 3.1 `pubspec.yaml`
- Renommer le bloc de police `family: Inter` en `family: JetBrainsMono` (les assets pointés restent `JetBrainsMono-Regular.ttf` / `JetBrainsMono-Medium.ttf` — inchangés, seul le nom de famille était faux).
- Le bloc `family: Sora` reste inchangé.

### 3.2 `lib/core/theme/app_typography.dart`
- Aucun changement de `fontUI` (reste `'Sora'`).
- `fontMono` reste `'JetBrainsMono'` — devient maintenant correct une fois le pubspec corrigé.
- Mettre à jour le commentaire d'en-tête (lignes 3-27) : remplacer les références à "Inter" par "Sora", et corriger l'exemple YAML pour refléter le vrai contenu de `pubspec.yaml` (bloc `JetBrainsMono` au lieu de `Inter`).
- Aucun changement aux styles (`pageTitle`, `bodyMd`, etc.) — l'échelle typographique elle-même n'est pas remise en cause.

### 3.3 `lib/core/theme/app_spacing.dart`
- `buttonIconSize` : `14` → référence `iconSm` (valeur inchangée, juste dédupliquée)
- `navIconSize` : `16` → référence `iconMd` (valeur inchangée, juste dédupliquée)
- `buttonHeightSm` : `30` → `32` (multiple de 4)
- `buttonHeightLg` : `42` → `44` (multiple de 4)
- `navItemHeight` : `34` → `32` (multiple de 4, aligné sur `buttonHeightSm`)
- `routerPillDotSize` : `7` → `8` (multiple de 4)
- Commentaire de `cardPaddingV` (ligne 76) : supprimer la mention "(ajuster à x3 pour dense)" puisque `cardPaddingDense` couvre déjà ce cas explicitement.

**Note de risque** : les 4 changements de dimensions (30→32, 42→44, 34→32, 7→8) modifient visuellement de 1-2px des boutons, lignes de nav et le point du sélecteur de routeur. Écart minime, mais à vérifier visuellement après implémentation (`flutter run -d windows`).

### 3.4 `lib/core/theme/app_colors.dart`
- Ajouter `AppColors.bgElevated` (light) — valeur proposée : `white` (identique à `bgSurface`, puisque le light theme n'a pas de hiérarchie de profondeur aussi marquée que le dark ; le token existe pour la symétrie d'API, pas pour un changement visuel immédiat).
- Aucun autre changement de palette.

### 3.5 `lib/core/theme/app_theme.dart`
- `popupMenuTheme.color` dans `AppTheme.light` : `AppColors.bgSurface` → `AppColors.bgElevated` (symétrie avec `AppThemeDark` qui utilise déjà `AppColorsDark.bgElevated` à la ligne 411). Aucun changement visuel puisque `bgElevated == bgSurface` en light.
- Aucun autre changement.

### 3.6 `.claude/CLAUDE.md`
- §2 (tableau stack) : `Inter` → `Sora` là où la police UI est mentionnée.
- §12.3 (Typographie) : remplacer les mentions "Inter" par "Sora" dans les exemples et règles (ex. "JetBrains Mono pour les codes" reste inchangé, seule la police UI de référence change).

### 3.7 `lib/features/app/presentation/widgets/app_sidebar.dart`
- Ligne 224 : `TextStyle(color: AppColors.error)` → `AppTypography.bodyMd.copyWith(color: AppColors.error)` (aligné sur le style utilisé pour le texte de confirmation juste au-dessus, ligne 218).

---

## 4. Ce qui ne change PAS

- Aucun nom de token public existant n'est renommé ou supprimé (zéro breaking change pour les ~25 fichiers consommateurs).
- Aucune valeur de couleur sémantique ou primitive existante n'est modifiée.
- Aucun changement à l'échelle typographique (tailles, poids, letter-spacing).
- Aucun changement à l'échelle de padding/gap (`paddingXs`→`paddingXl`, `gapXs`→`gapXl`).
- Aucun changement au border radius.

---

## 5. Tests / vérification

Pas de tests automatisés existants pour le thème (projet Flutter Windows, pas de tests écrits — cf. `CLAUDE.md`). Vérification :

1. `flutter analyze` — doit rester à 0 issue après chaque fichier modifié.
2. `flutter run -d windows` — vérification visuelle manuelle des écrans qui utilisent les dimensions modifiées : sidebar (nav items, sélecteur de routeur), boutons (tous formulaires/dialogs), et le dialog de déconnexion (`app_sidebar.dart`).
3. Vérifier que le texte en `AppTypography.techData`/`voucherCode` (JetBrains Mono) s'affiche bien avec la police mono après correction du `pubspec.yaml` — actuellement il est possible qu'elle retombe déjà sur une police système par un mécanisme de fallback, donc comparer avant/après.

---

## 6. Ordre d'implémentation recommandé

1. `pubspec.yaml` (fix police mono) — indépendant, à faire en premier, `flutter pub get` après.
2. `app_typography.dart` (commentaire seulement)
3. `app_spacing.dart` (dédup icônes + grille 4px + commentaire)
4. `app_colors.dart` (ajout `bgElevated` light)
5. `app_theme.dart` (usage de `bgElevated` dans `popupMenuTheme`)
6. `app_sidebar.dart` (fix `TextStyle` inline)
7. `.claude/CLAUDE.md` (doc Sora)
8. Vérification finale : `flutter analyze` + `flutter run -d windows`
