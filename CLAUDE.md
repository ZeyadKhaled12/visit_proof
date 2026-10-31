# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project overview

**Visit Proof** is a Flutter app for managing field-service visits: clients (with sites and equipment), technicians, services/categories, visits (scheduling, assignment, status workflow, history), and invoices/payments. It targets Saudi Arabia (currency `SAR`, Saudi city list in `lib/core/utils/general_dummy_data.dart`).

**There is no backend yet.** Every `*RemoteDataSource` is a local prototype that persists JSON in `SharedPreferences` and simulates latency with `Future.delayed`. The layering is built so a real API can replace the data sources later without touching domain/presentation code.

- Flutter 3.27.x, Dart SDK `^3.6.2`
- Package name: `visit_proof` (use `package:visit_proof/...` imports)

## Commands

```bash
flutter pub get
flutter run                 # main target is Android/iOS
flutter analyze             # lints from flutter_lints; slow on this machine (~5 min); baseline 2026-10-31: 33 issues, mostly info-level
flutter test                # test/widget_test.dart is still the default counter template and will fail
```

## Architecture

Clean Architecture + BLoC + GetIt, one folder per feature under `lib/features/<feature>/`:

```
data/
  datasource/<feature>_remote_data_source.dart   # abstract Base…RemoteDataSource + impl (SharedPreferences today)
  models/                                         # hand-written Equatable models: fromJson/toJson/copyWith
  repository/<feature>_repo.dart                  # implements Base…Repo; catches ServerException -> Left(ServerFailure.openFun(...))
domain/
  repository/base_<feature>_repo.dart             # abstract, returns Future<Either<Failure, T>>
  usecases/<action>_uc.dart                       # one class per action + its <Action>Parameters class
presentation/
  controller/<feature>_bloc.dart (+ _event, _state as `part` files)
  screens/<name>_scr.dart                         # BlocProvider(create: sl<Bloc>()..add(...)) + BlocBuilder/BlocConsumer
  widgets/<screen>_widgets/<screen>_body.dart, <screen>_widget_<part>.dart
```

Features: `visits` (home list), `add_visit`, `visit_detail`, `clients`, `technicians`, `services`, `invoices`.

Notes:
- `invoices` uses `data/data_sources/` (plural, underscore) — keep it as-is.
- `visit_detail` has no models of its own; it reuses models from `visits`, `invoices`, `technicians`, `services` (see its `data/models/README.md`). All its use cases + parameter classes live in one file: `domain/usecases/visit_detail_actions_uc.dart`.
- Models are shared across features by import (e.g. `VisitDetailModel` lives in `features/visits/data/models/visit_detail_models/`).

### Core (`lib/core/`)
- `services/services_locator.dart` — GetIt `sl`. Blocs = `registerFactory`; use cases, repos, data sources = `registerLazySingleton` (repos/data sources registered against their `Base…` type). **Every new bloc/use case/repo/data source must be registered here.**
- `usecase/base_use_case.dart` — `BaseUseCase<T, Params>` with `call(params)` returning `Future<Either<Failure, T>>`; `NoParameters` for parameterless calls.
- `network/error/` — data sources wrap bodies in `HandleLogicErrors(fun: ...).checkLogicErrors()`, which rethrows `ServerException` and converts anything else to a generic message. `ServerFailure.openFun(...)` shows an error toast automatically, so blocs don't show errors themselves.
- `local/local_pref.dart` — static `LocalPref.sharedPreferences`, initialised in `main()`.
- `utils/enums.dart` — `RequestState { loading, loaded, error }`. Bloc state keeps **one `RequestState` per operation** (e.g. `addClientRequestState`), defaulting to `loaded`.
- `utils/enums/*_enum.dart` — domain enums with a `…Switch` helper class mapping enum ⇄ int id ⇄ color ⇄ label (`switchID`, `switchEnum`, `getColor`, `getText`). Models store the **int id** in JSON. `invoice_status_enum.dart` is fully commented out; invoices use `PaymentStatus`.
- `utils/general_widgets/g_widget_*.dart` — shared widgets (buttons, text fields, app bars, bottom sheets, dropdowns, map/location picker, phone field, search, loading). Reuse these before writing new ones.
- `utils/general_functions.dart/` (yes, a folder named `.dart`) — `GFunToken.generateRandomId()` (UUID v4, used for all ids), date picker, url launcher, validators.
- `utils/general_models/` — `GModelCatg` (id/name/description), `GModelSite`, `GModelEquipment`.

### Configs (`lib/configs/`)
- `AppTheme` (`configs/app_theme.dart`) — the only theme file: light and dark palettes (`AppTheme.light` / `AppTheme.dark`), Google font family, text size tokens (`AppTheme.textBody`, …) and `fontScale`. Use `AppTheme.<color>` for colors, `AppTheme.font(...)` for text styles and size tokens for `fontSize`; never hard-code colors or sizes. Colors are runtime getters (dark mode), so they can't be used inside `const` expressions. `surface` = backgrounds, `onPrimary` = text/icons on brand colors.
- `AppToasts` — `showMessage` (SnackBar via global navigator key), `showBottomSheet`, `showDeleteConfirmation`. Data sources call `AppToasts.showMessage` on success.

### App / navigation
- `lib/app/app.dart` — `App.navigatorKey`, `App.lang = 'en'`, `App.currency = 'SAR'`.
- `lib/main.dart` — `MaterialApp` with named `routes`; `'/'` is `VisitsScr`. Each screen has `static const route = '/<ScreenName>'`.
- Route arguments use a small `<Screen>Argu` class defined at the bottom of the screen file with `toArgu()` → `Map<String, dynamic>` and `fromJson(map)`; screens read `ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?`.
- Screens return results via `Navigator.pop(context, value)`; callers `await Navigator.pushNamed(...)` and refresh if truthy.
- `AddServiceScr` is opened as a bottom sheet via `AddServiceScr.show(context, ...)`, not a route.
- `ClientsScr`, `TechniciansScr`, `ServicesScr`, `InvoicesScr` exist but there is currently no navigation into them from the home screen (and `TechniciansScr`/`ServicesScr`/`InvoicesScr` are not in `routes`).
- `flutter_riverpod`'s `ProviderScope` wraps the app but Riverpod is not used anywhere; state management is BLoC.

## Local storage (current "backend")

SharedPreferences `StringList` keys, each item a `jsonEncode(model.toJson())`:
`clients`, `technicians`, `services`, `categories`, `visits`, `invoices`.

Clearing app data resets everything (there is a commented `LocalPref.sharedPreferences.clear()` in `main()`).

## Business rules (enforced in data sources)

Most real logic lives in `visit_detail_remote_data_source.dart`, `invoices_remote_data_source.dart` and `add_visit_remote_data_source.dart`. Validation failures throw `ServerException` via a `_fail(message)` helper. Read the relevant file before changing behavior. Key points:

- **Visit ⇄ invoice is one-to-one.** Creating a visit creates its invoice; visit and invoice are written together (invoice first, then visit, with best-effort rollback).
- Writes are serialised with a static `_queue`/`_locked` helper; keep using it for multi-key writes.
- Money is validated/handled in **cents** (`_cents`) to avoid float errors.
- Visit status (`VisitStatus`: draft, scheduled, assigned, onWay, inProgress, completed, cancel) follows an explicit transition map in `changeVisitStatus`. Assigned and later states require a technician; scheduled must have none; technicians are assigned/unassigned only via the dedicated actions, not via status change or edit. Some transitions need a reason of ≥ 8 characters.
- Every visit change appends to `history` (`VisitHistoryModel`, actor defaults to a local admin).
- Payment statuses: unpaid, pending, partiallyPaid, paid, cancelled, refunded.

## Conventions

- File/class naming: screens `*_scr.dart` / `*Scr`, use cases `*_uc.dart` / `*Uc`, general items `g_widget_*`, `g_fun_*`, `g_model_*` / `GWidget…`, `GFun…`, `GModel…`.
- Each use case has a matching `<Action>Parameters` class in the same file; events wrap the parameters (`AddClientEvent(addClientParameters: ...)`).
- State classes are Equatable with hand-written `copyWith` and full `props`.
- Models are Equatable, all-nullable fields, hand-written `fromJson`/`toJson`/`copyWith` (no code generation).
- Match existing spelling of identifiers even where misspelled (e.g. `laoding`, `raduis`, `successfuly`) unless doing a deliberate rename across all usages.
- UI text is English for now; city data has Arabic `description`.

## Adding a new feature/action (checklist)

1. Add method to `Base<Feature>RemoteDataSource` + implementation (wrap in `HandleLogicErrors`).
2. Add method to `Base<Feature>Repo` + `<Feature>Repo` (try/catch → `Left(ServerFailure.openFun(...))`).
3. Create `<action>_uc.dart` with use case + `Parameters` class.
4. Add event, `RequestState` field (+ `copyWith`, `props`), and handler in the bloc.
5. Register the use case in `services_locator.dart` and add it to the bloc's `sl()` constructor list.
6. For a new screen: add `static const route`, register it in `main.dart` `routes`, add an `Argu` class if it needs arguments.

## Open TODOs (from `main.dart`)

1. Full-screen view for pictures.
2. Multiple locations per client in client detail.
3. Fix start time handling in both update-visit and create-visit.
