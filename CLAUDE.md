# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project overview

**Visit Proof** is a Flutter app for managing field-service visits: clients (with sites and equipment), technicians, services/categories, visits (scheduling, assignment, status workflow, history), and invoices/payments. It targets Saudi Arabia (currency `SAR`, Saudi city list in `lib/core/utils/general_dummy_data.dart`).

One app serves two roles, chosen on the first screen and switchable from either app's drawer:
- **Admin** — no account; the full admin app (`MainMenuScr`).
- **Technician** — signs in with the email/password the admin set on the technician; sees only their own visits (`TechHomeScr`) and moves them forward (start trip → start work → complete) with their live GPS location and camera proof photos.

**There is no backend yet.** Every `*RemoteDataSource` is a local prototype that persists JSON in `SharedPreferences` and simulates latency with `Future.delayed(AppLatency.local)` (`core/network/app_latency.dart`, 60 ms; use it for any new data source). The layering is built so a real API can replace the data sources later without touching domain/presentation code.

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

Features: `website` (sales website + design studio, presentation only; web builds only), `visits` (home list), `add_visit`, `visit_detail`, `clients`, `technicians`, `services`, `invoices`, `dispatch`, `dashboard`, `main_menu` (admin shell), `auth` (role selection, technician sign in, session), `technician_home` (presentation only; reuses `VisitsBloc`).

Notes:
- `invoices` uses `data/data_sources/` (plural, underscore) — keep it as-is.
- `visit_detail` has no models of its own; it reuses models from `visits`, `invoices`, `technicians`, `services` (see its `data/models/README.md`). All its use cases + parameter classes live in one file: `domain/usecases/visit_detail_actions_uc.dart`.
- Models are shared across features by import (e.g. `VisitDetailModel` lives in `features/visits/data/models/visit_detail_models/`).

### Core (`lib/core/`)
- `session/app_session.dart` — `AppSession.current` (`ValueNotifier<AppSessionModel?>`: role + technician id/name/email), `isAdmin` / `isTechnician` / `technicianId`, and `AppSession.actor` (who to credit in history). Only the `auth` data source writes it; it is restored in `main()` via `RestoreSessionUc` before `runApp`.
- `local/local_photos.dart` — copies camera photos into the app documents folder (`visit_photos/<visitId>/`) and cleans them up.
- `utils/general_functions.dart/g_fun_location.dart` (`GFunLocation.current()` live GPS, rejects mock locations, throws `GFunLocationException` with an issue) and `g_fun_photo.dart` (`GFunPhoto.takePhoto()`, camera only).
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
- Performance: `AppTheme.palette`, `materialTheme` and the base Google Font styles in `AppTheme.font` are cached (rebuilt only when mode/brand/language change); `MyApp._rebuildAll` runs at most once per frame. Keep long lists lazy (`ListView.builder`/`.separated`).
- `AppToasts` — `showMessage` (SnackBar via global navigator key), `showBottomSheet`, `showDeleteConfirmation`. Data sources call `AppToasts.showMessage` on success.

### App / navigation
- `lib/app/app.dart` — `App.navigatorKey`, `App.lang = 'en'`, `App.currency = 'SAR'`.
- `lib/main.dart` — `MaterialApp` with named `routes`; `'/'` is `AppGateScr`, which follows `AppSession.current` and shows `RoleSelectScr`, `MainMenuScr` or `TechHomeScr`. Switching role or logging out only changes the session, then pops to the first route (`AuthWidgetAccountActions.backToHome()`). Each screen has `static const route = '/<ScreenName>'`.
- Route arguments use a small `<Screen>Argu` class defined at the bottom of the screen file with `toArgu()` → `Map<String, dynamic>` and `fromJson(map)`; screens read `ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?`.
- Screens return results via `Navigator.pop(context, value)`; callers `await Navigator.pushNamed(...)` and refresh if truthy.
- `AddServiceScr` is opened as a bottom sheet via `AddServiceScr.show(context, ...)`, not a route.
- `ClientsScr`, `TechniciansScr`, `ServicesScr`, `InvoicesScr` exist but there is currently no navigation into them from the home screen (and `TechniciansScr`/`ServicesScr`/`InvoicesScr` are not in `routes`).
- `flutter_riverpod`'s `ProviderScope` wraps the app but Riverpod is not used anywhere; state management is BLoC.

## Website (web build)

`flutter build web` / `flutter run -d chrome` shows the sales website, not the bare app (`DemoMode.isOn` = `kIsWeb && !CUSTOMER_APP`). Guide for the owner: `docs/Website_Guide_AR.md`.
- **Test data on every start** (`DemoMode.testData`, all builds except `CUSTOMER_APP`): `main()` wipes SharedPreferences (keeping the app's language/dark choices; the website always opens Arabic and light). The website runs `DemoSeed.runScenario()` (the sample company with only finished past visits) and starts as the admin; other test builds run `DemoSeed.run()` (`core/demo/demo_seed.dart`): 8 technicians, 24 clients, 12 services, ~200 visits from 30 days ago to 14 days ahead in every status, invoices paid/partly paid/pending field collection/unpaid with a consistent ledger (see `test/demo_seed_test.dart`). Its texts follow the start-up language. Demo technician `ahmed@demo.com` / `123456`.
- `MyApp` → `WebsiteApp` opens on `WebsiteStudioScr`: the real `VisitProofApp` (`lib/app/visit_proof_app.dart`; full screen on a phone, in a phone frame on a computer, with an overridden `MediaQuery`) plus `StudioWidgetDock` (the scenario's next step and inline design tools: no sheets, the app stays visible). The details page `WebsiteScr` and `WebsiteRequestScr` open on top. Links: `?demo=technician`, `?request`, `?site`, `?privacy`, `?terms` (`WebsiteLegalScr`).
- **Scenario** (`presentation/studio_scenario.dart`): `StudioStep`s (Wizpoo's intro, the help flag and the palette → create visit → dispatch → technician: trip, work, complete, collect → back to admin: proof, invoice, confirm the payment → offer), ticked off by polling the app's own `visits` (ids not starting with `demo-`) and `AppSession`, so a step is done only when it is really done in the app.
- The app runs in its own `Navigator` inside the website's, so its dialogs and date/time pickers pass `useRootNavigator: false`; otherwise they open over the whole website instead of inside the phone.
- **Wizpoo** (`widgets/studio_widget_bot.dart`) sits in its bubble (so it covers nothing), flies briefly to each new control, and rings the next control, found by its on-screen label in the current route (`_Cue`; `stay` keeps it beside a small control at the top). On a screen the step is not played on (`StudioScenario.offPath`) it points at the back arrow. If a screen's label changes, update its cue. `DemoMode.prefillNewVisit` fills the add-visit form.
- In test builds "Switch to technician" signs in directly (`DemoSeed.technicianToTry()`); `CUSTOMER_APP` builds still ask for the technician's sign-in.
- **The visitor's design** lives only in the open page (`StudioDesign`). The tools wait for the palette in the top bar (Wizpoo's `themeTip` step points at it). Leaving deletes it, so `_askToLeave` confirms on the browser's back button (which steps back inside the app first) and a `beforeunload` guard (`PwaBridge.setLeaveGuard`) covers closing or reloading the tab, in the browser's own wording.
- **Studio "Request a copy" (طلب نسخة) opens the request form** while `WebsiteStudioScr.requestInstallsApp` is false; true installs the designed app as a PWA (see the note at the top of `main.dart`). `StudioInstall` (`widgets/studio_widget_install.dart`) keeps the page's manifest in step with the design (blob manifest + PNG data-URL icons drawn in Dart) so the tap can call the browser's captured install prompt; otherwise it opens the app's link in a new tab with steps (iPhone: Share → Add to Home Screen). `core/pwa/app_install.dart`: the design is base64url JSON in the link's # part (`#app=<design>~/<route>` via `_InstalledUrlStrategy` in `pwa_bridge_web.dart`; never in the query, since a logo makes it longer than GitHub Pages accepts — 414; logo shrunk to 192 px); a page opened with it is `DemoMode.installedApp`: only `VisitProofApp`, that brand, light/dark fixed (switch hidden in `GWidgetAppSettings`), sample company seeded once then kept, own SharedPreferences prefix (`vp_app_<hash>.`), `GWidgetInstallBanner` when opened in a tab. JS side: `window.wizpoPwa` in `web/index.html` (via `core/pwa/pwa_bridge*.dart`, stub off the web).
- Requests: `WebsiteRequestModel` (`features/website/data/models/`: contact, design, `requestedChanges`, offer) → `WebsiteRequestRemoteDataSource.submitRequest` — a stub until a backend exists (send `toJson()` there).
- `configs/app_offer.dart` — the single plan's prices/limits (first month free, then 56 SAR every 6 months; `AppOffer.summary`; `AppOffer.whatsappNumber`, international digits, empty hides the WhatsApp buttons: the number beside "Request a copy" on a computer, `WebsiteWhatsappButton` floating on a phone and the details page); the website reads every number from here, except the static text in `web/index.html`. Changes to a customer's version are free within a limit, then paid features.
- `configs/app_brand.dart` — `AppBrand.current`: any color per `AppBrandColor` slot (primary, secondary, background, card, text, success, warning, danger; background/card/text change light mode only), Arabic/English Google Font, `fontScale`, app name, icon key, logo bytes. Applied in `AppTheme.palette` / `activeFontFamily` / `activeFontScale` (`onPrimary` is picked for contrast); `MyApp` rebuilds on change. `AppBrand.fromEnvironment()` reads a `BRAND` JSON dart-define for a customer build. The studio uses `flutter_colorpicker`. `GWidgetBrandMark` shows logo/icon.
- `DemoMode.simulateOnSite` makes the field-proof panel use the visit's site location instead of GPS (test builds only).
- Fonts: the Arabic weights of Cairo and IBM Plex Sans Arabic are bundled in `assets/google_fonts/` (google_fonts finds them by file name) and `main()` waits for them behind the loading screen in `web/index.html`, so Arabic never paints as empty boxes. A visitor's other font still comes from Google Fonts.
- Web-safe photos: `LocalPhotos` keeps the picker path on web; show local photos with `GWidgetLocalImage` (never `Image.file`).
- Hosting: `.github/workflows/deploy-web.yml` builds the web app on every push to `main` (with `--base-href /<repo>/`) and publishes it to GitHub Pages (`https://zeyadkhaled12.github.io/visit_proof/`), plus a `CUSTOMER_APP=true` build at `.../visit_proof/app/` to install and test the bare app as a PWA (manifest renamed to "Visit Proof" in the workflow). Pages source must be set to "GitHub Actions". Keep asset/link paths relative so they work under that sub-path.
- `--dart-define=CUSTOMER_APP=true` builds a customer's app: no website, no reset, real GPS. All data is still device-local; a shared backend is needed before real customers.
- The website is branded **Wizpo** (a marketplace of small business apps; Visit Proof is the first, more "coming soon"). Its own fixed theme is `WebTheme` (`features/website/presentation/website_theme.dart`, Wizpo palette: ink `#15182D`, purple `#4B315F`, gold `#D6AC58`, green `#1E5045`, wine `#6B2B3A`, parchment `#F4EAD6`; always light, Inter / IBM Plex Sans Arabic). Brand name, tagline, tab title and the `WizpoMark` painter are in `widgets/website_widget_brand.dart`; the logo/icon SVG originals are in `web/brand/` (favicon and PWA icons are rendered from them). Website widgets use `WebTheme`, never `AppTheme`, so the visitor's colors, dark mode, fonts and text size only restyle the app in the phone frame. Exceptions: studio controls that read/change the app's design and the brand preview on the request page.
- Arabic translations are formal Arabic (فصحى); keep new entries formal.

## Local storage (current "backend")

SharedPreferences `StringList` keys, each item a `jsonEncode(model.toJson())`:
`clients`, `technicians`, `services`, `categories`, `visits`, `invoices`, `invoice_payments` (the payment ledger). The session is a JSON `String` under `session`. Visit photos are files on disk; `VisitDetailModel.photos` stores their paths.

Clearing app data resets everything (there is a commented `LocalPref.sharedPreferences.clear()` in `main()`).

## Business rules (enforced in data sources)

Most real logic lives in `visit_detail_remote_data_source.dart`, `invoices_remote_data_source.dart` and `add_visit_remote_data_source.dart`. Validation failures throw `ServerException` via a `_fail(message)` helper. Read the relevant file before changing behavior. Key points:

- **Visit ⇄ invoice is one-to-one.** Creating a visit creates its invoice; visit and invoice are written together (invoice first, then visit, with best-effort rollback).
- Writes are serialised with a static `_queue`/`_locked` helper; keep using it for multi-key writes.
- Money is validated/handled in **cents** (`_cents`) to avoid float errors.
- **VAT**: `CompanySettings.vatNumber` (admin menu; empty = not registered). New invoices of a registered company add 15% on top of the price; issued ones show a QR code (`GFunVatQr`). The website's sample company is registered.
- Visit status (`VisitStatus`: draft, scheduled, assigned, onWay, inProgress, completed, cancel) follows an explicit transition map in `changeVisitStatus`. Assigned and later states require a technician; scheduled must have none; technicians are assigned/unassigned only via the dedicated actions, not via status change or edit. Some transitions need a reason of ≥ 8 characters.
- Every visit change appends to `history` (`VisitHistoryModel`, actor defaults to a local admin).
- Payment statuses: unpaid, pending, partiallyPaid, paid, cancelled, refunded. `pending` = a field collection is waiting for the admin.
- **Field collection**: completing a visit auto-issues its untouched draft invoice (`_invoiceForStatus`). The technician can then record a payment on their own inProgress/completed visit (`VisitRules.canCollectPayment`) with a fresh location + at least one receipt photo (`PhotoKind.receipt`, also added to `visit.photos`). It is saved as a `PaymentEntryStatus.pending` ledger entry and adds to `invoice.pendingAmount`, not `paidAmount`. The admin confirms/rejects it (`reviewPayment`, reject needs a reason ≥ 8) from the invoice screen or the `Collections` menu tab. Ledger invariants checked in `_change`: confirmed entries sum = `paidAmount`, pending entries sum = `pendingAmount`; collectible = remaining − pending. All other invoice actions are admin-only.
- **Roles** (`VisitRules` reads `AppSession`): admin-only actions (assign/unassign, reschedule, edit info/service/site, delete, invoices) return false for technicians and the data source refuses them (`adminOnly: true` / `_requireAdmin()`). A technician only gets `technicianNextStatuses` (assigned→onWay→inProgress→completed) and notes, on visits assigned to them; the visits list is filtered to their own visits in `VisitsRemoteDataSource`.
- **Field proof**: every technician action must carry a fresh live location (`VisitRules.maxLocationAge`), which the technician cannot edit, agrees once per device to share (`LocationConsent`, can be withdrawn) and which is logged on the history entry (`location`, `distanceFromSite`). Starting work requires being within `VisitRules.maxStartDistanceMeters` (200 m) when the site has coordinates; without coordinates the location is only logged. Required before/after photos (`requireBefore/AfterWorkPhotos`) are enforced at inProgress/completed; notes may carry photos too.
- Technician emails are unique (they are the sign-in name).

## Conventions

- **Every user-visible text goes through `.tr` / `.trArgs` and needs an entry in `lib/configs/app_translations.dart`** (no duplicate keys, or the const map breaks the build). Seeded data shown to the user (city and default category names) is shown with `.tr` too; user-typed names are left as typed. History descriptions are stored in the language active when they were written.

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
