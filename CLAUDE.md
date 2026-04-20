# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> Full architecture rules, design system constraints, and MikroTik API reference are in [`.claude/CLAUDE.md`](.claude/CLAUDE.md). Read it before making any changes.

---

## Commands

```bash
# Run on Windows desktop
flutter run -d windows

# Build release
flutter build windows

# Analyze (lint)
flutter analyze

# Run tests (no tests written yet)
flutter test
```

---

## App startup flow

```
main() → setupServiceLocator() → LaunchScreen
  → LaunchBloc checks first launch & active session
  → SetupScreen (first launch, create admin)   OR
  → AuthScreen (login)                          OR
  → AppBloc (authenticated) → AppShell
       ├── AppSidebar  (navigation tabs)
       ├── IndexedStack (pages kept in memory)
       └── NavigationBloc filters pages by role
```

`AppShell` provides `VouchersBloc` to the tree — dialogs opened from `ProfilesScreen` use `context.read<VouchersBloc>()` without needing their own `BlocProvider`.

---

## Dependency injection

All registrations are in [`lib/core/di/service_locator.dart`](lib/core/di/service_locator.dart).

Pattern for a new feature:
1. Register repository as `registerLazySingleton`
2. Register each use case as `registerFactory`
3. Register BLoC as `registerFactory` (injecting use cases via `sl()`)

When adding a use case, always register it in `service_locator.dart` or it won't be available via `sl<>()`.

Every BLoC must also be added to the `MultiBlocProvider` in [`lib/main.dart`](lib/main.dart) to be accessible anywhere in the widget tree via `context.read<>()` / `context.watch<>()`. A BLoC registered only in `service_locator.dart` but absent from `main.dart` will throw at runtime.

---

## Database migrations

`DatabaseHelper` is in [`lib/core/database/database_helper.dart`](lib/core/database/database_helper.dart). Current version: **5**.

To add columns:
1. Bump `_dbVersion`
2. Add a `case N:` block in `_onUpgrade` with `ALTER TABLE ... ADD COLUMN ...`
3. Update the `CREATE TABLE` statement in `_onCreate` to include the new columns

---

## MikroTik clients

Two transports share the same `MikroTikService` façade ([`lib/core/mikrotik/mikrotik_service.dart`](lib/core/mikrotik/mikrotik_service.dart)):

- **REST** (`MikroTikRestClient`) — used for all current features (RouterOS v7+, HTTP port 80)
- **TCP** (`RouterOsClient`) — legacy v6 client, port 8728, not yet wired into the service factory

`MikroTikService.fromRouter(router)` creates a per-router instance. Never share instances across routeurs.

---

## Key patterns in use

**Fetching MikroTik data from a dialog** — use `sl<UseCase>()` directly in `initState`, store result in local state with `setState`. No BLoC needed for one-shot lookups (e.g. `GetAddressPools`, `GetHotspotServers`).

**Either error propagation** — every repository method returns `Either<Failure, T>`. BLoCs fold the result and emit typed error states; widgets react via `BlocListener`.

**Datasource split in profiles** — `ProfileLocalDatasource` (SQLite) and `ProfileRemoteDatasource` (MikroTik) have separate impl classes. `ProfilesRepositoryImpl` coordinates them.
