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
  → LaunchBloc.add(LaunchStarted) → Initialize usecase
     → LaunchFirstTime        → /setup   (no admin account yet)
     → LaunchAuthenticated(user) → dispatches LoginSessionRestored(user)
                                    to LoginBloc, then → /dashboard
     → LaunchUnauthenticated  → /login
```

`LaunchAuthenticated` carries the resumed `User` (read from the `active_session` +
`users` join). `LaunchScreen` must feed that user into `LoginBloc` via
`LoginSessionRestored` **before** navigating — `AppShell` and the rest of the
authenticated UI read the current user from `LoginBloc`'s state
(`LoginAuthenticated`), never by querying the database themselves. Skipping the
`LoginSessionRestored` dispatch bounces the user straight back to `/login` even
with a valid session.

Routing is declarative `go_router` (`lib/core/router/app_router.dart`); pages
under `/dashboard`, `/sessions`, `/profiles`, `/history` live inside a
`ShellRoute` wrapping `AppShell` (sidebar + topbar + page content).

---

## Feature-first Clean Architecture

Each feature under `lib/features/<name>/` has `data/`, `domain/`, `presentation/`
layers (repository interface + impl, use cases, BLoC). `domain` never imports
Flutter, sqflite, or another feature — cross-feature coordination happens by one
feature's presentation layer dispatching an event on another feature's BLoC
(e.g. `LaunchScreen` → `LoginBloc.add(LoginSessionRestored(...))`), not by
importing the other feature's domain/data layers directly.

**Exception:** `lib/features/app/` (the authenticated shell — `app_shell.dart`,
`app_sidebar.dart`, `app_topbar.dart`) is presentation-only, no `domain`/`data`.
It reads the active user from `LoginBloc` and dispatches logout via `LogoutBloc`
directly; there is no `AppRepository`/`AppBloc`.

Shared models live in `lib/core/models/` (`User`, `MikroTikRouter`,
`HotspotProfile`, `Voucher`, `Preference`, `AppState`) with `toMap()`/`fromMap()`
for sqflite rows — `toMap()` never includes `id` (autoincrement columns) and
`User.toMap()` never includes `password` (hashing happens in the usecase layer;
datasources that need to persist a hashed password must add it to the map
explicitly before inserting). Shared enums live in `lib/core/enum/`
(`UserRole`, `RouterOsVersion`).

---

## Dependency injection

Registrations are split into per-feature modules under
[`lib/core/di/modules/`](lib/core/di/modules/), each wired into
[`lib/core/di/service_locator.dart`](lib/core/di/service_locator.dart).

Pattern for a new feature module:
1. Register the datasource as `registerLazySingleton`
2. Register the repository as `registerLazySingleton<XRepository>`
3. Register each use case as `registerFactory`
4. Register the BLoC as `registerFactory` (injecting use cases via `sl()`)
5. Call `register<X>Module(sl)` from `setupServiceLocator()`

**`Database` is injected directly, not `DatabaseHelper`.** `core_module.dart`
registers it with `registerSingletonAsync<Database>`, and
`setupServiceLocator()` awaits `sl.isReady<Database>()` right after
`registerCoreModule` before registering anything else. Every datasource takes a
`Database` constructor param and calls `_db.query(...)` /
`_db.insert(...)` / `_db.transaction(...)` directly — no
`await _db.database` indirection.

Every BLoC must also be added to the `MultiBlocProvider` in
[`lib/main.dart`](lib/main.dart) to be reachable via `context.read<>()` /
`context.watch<>()`. A BLoC registered only in `service_locator.dart` but
absent from `main.dart` throws `ProviderNotFoundException` at first use.

---

## Database migrations

`DatabaseHelper` is in
[`lib/core/database/database_helper.dart`](lib/core/database/database_helper.dart).
Current version: **11**.

To add columns or tables:
1. Bump `_dbVersion`
2. Add an `if (oldVersion < N)` block in `_onUpgrade` with the `ALTER
   TABLE`/`CREATE TABLE` statements
3. Update `_onCreate` to match (fresh installs skip `_onUpgrade` entirely)

Single-row config tables (`active_session`, `app_state`, `preferences`) use
`id INTEGER PRIMARY KEY CHECK(id = 1)` and are seeded with one row at creation
time.

---

## MikroTik client

`MikroTikRestClient` ([`lib/core/mikrotik/mikrotik_rest_client.dart`](lib/core/mikrotik/mikrotik_rest_client.dart))
is a thin Dio wrapper over the RouterOS v7+ REST API (`http://{ip}:{port}/rest`,
Basic Auth). GET/PUT/PATCH/DELETE map to RouterOS list/create/modify/remove;
errors are translated to `MikroTikException` (`core/mikrotik/mikrotik_exception.dart`).
A router is validated by `GET /system/identity` on `connect()`. Each
`MikroTikRouter` gets its own client instance — never share one across routers.

---

## Error handling

Every repository method returns `Either<Failure, T>` (`dartz`). Datasources
throw typed `Exception`s (`core/error/exceptions.dart`:
`StorageException`, `NetworkException`, `MikroTikException`, `AuthException`,
`ExportException`); repositories catch and map them to `Failure`
(`core/error/failures.dart`).

Prefer `ErrorMapper.guard(() => ...)` (`core/error/error_mapper.dart`) over a
manual try/catch in repository implementations — it runs the action and maps
any thrown exception to the right `Failure` in one call, falling back to
`UnexpectedFailure` for anything unrecognized.

---

## Shared utilities

- `PasswordHasher` (`core/utils/password_hasher.dart`) — SHA-256 + random
  salt, format `"<salt_b64>:<sha256_hex>"`. Hash in the usecase layer (e.g.
  `CreateSetup`), never in a datasource — datasources persist an
  already-hashed `user.password` as-is.
- `CurrencyFormatter` (`core/utils/currency_formatter.dart`) — thousands
  grouping via `intl`'s `NumberFormat.currency`, defaults to `FCFA`.
