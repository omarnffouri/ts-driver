# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`ts_driver` — Flutter mobile app for transport/logistics drivers (shipments, inspections, chat/calling, documents, settlements, leave management). Targets Android (minSdk 26) and iOS. Package: `com.transport_system.ts_driver`.

## Commands

Use the Bash tool with `flutter`/`dart` directly — **do not** use the MCP `dart` tools (`analyze_files`, `dart_fix`, `run_tests`, etc.).

```bash
flutter pub get                  # install deps
flutter run --flavor dev --no-enable-impeller # run debug (both platforms take --flavor dev|staging|prod)
flutter analyze                  # lint / static analysis (flutter_lints + lint)
dart fix --apply                 # auto-fix lints
flutter test                     # run tests (NOTE: no test/ dir exists yet)
flutter test path/to/foo_test.dart           # run a single test file
flutter test --name "substring of test name" # run a single test by name

# Code generation (flutter_gen for assets, build_runner)
dart run build_runner build --delete-conflicting-outputs

flutter build apk --release --flavor prod       # release Android build
flutter build appbundle --release --flavor prod # release Android bundle
flutter build ios --release                     # release iOS build (no flavors yet; defaults to prod config)
dart run flutter_flavorizr -f            # regenerate flavor config from flavorizr.yaml (see Environment & API)
flutter pub run flutter_launcher_icons   # regenerate launcher icons (from assets/images/ts.png)
dart run flutter_native_splash:create    # regenerate native launch splash (see UI & theming)
```

## Architecture

GetX (state, DI-via-bindings, routing) layered over Clean Architecture, with `get_it` as the primary service locator. Each feature lives under `lib/app/modules/<feature>/` split into three layers:

- **`data/`** — `datasources/` (remote via `DioClient`, local via `GetStorage`/`sqflite`), `models/` (extend entities, add `fromJson`/`toJson`), `repositories/` (impl).
- **`domain/`** — `entities/` (Equatable), `repositories/` (abstract interfaces, prefixed `I*`), `usecases/` (extend `BaseUseCase`), `params/`.
- **`presentation/`** — GetX `bindings/` (register controllers via `Get.put`/`Get.lazyPut`), `controllers/` (extend `GetxController`, reactive `.obs`), `views/`.

Module presentation shape varies by age. Older modules (`map`, `profile`, `forward_message`, `main_screen`) are flat (`bindings/`, `controllers/`, `views/` directly). The refactored `shipments` module is the reference for new single-screen work: `presentation/{bindings,controllers,views}` with nothing else at the top level, and UI grouped under `views/` into `tabs/` (per-tab body widgets fed to the controller), `widgets/` (reusable leaves), `bottom_sheets/`, and `dialogs/`. The `inspections` module is the reference for a feature with **multiple sub-screens that share presentation code**: full `data/`+`domain/`+`presentation/` layering, the sub-screens under `presentation/{trailer_inspection,truck_inspection}/{bindings,controllers,views}`, and code shared between them placed directly under `presentation/` in category folders — `widgets/` (leaves), `components/` (composites), `bottom_sheets/`. A shared model/value-object goes in `domain/entities/` only when it is framework-agnostic (e.g. `tire`, `tire_layout`, `inspection_damage`, `inspection_enums` — no JSON, no Flutter/GetX); a view-model that needs `Rx` or carries UI strings stays in `presentation/`. Some module folders are misspelled (`annoucments`, `presintation` typo in `forms`) — match the existing spelling when importing, don't "fix" paths casually.

`lib/app/core/` holds cross-cutting code: `data/connection/` (Dio, env, network info), `data/error/` (failures, exceptions, handlers), `services/` (DI, Firebase options, `ThemeService`), `gen/` (flutter_gen assets), `helpers/`, `utils/`, `widgets/`, `transitions/`. The active theme lives at `lib/app/theme/` (see UI & theming). App-wide GetX controllers live in `lib/app/controllers/` (`auth_controller`, `call_events_controller`, `location_controller`).

### Critical conventions

- **`Either` is reversed from the dartz norm.** `BaseUseCase<Type, Params>` returns `Future<Either<Type, Failure>>` — **`Left` = success value, `Right` = `Failure`**. Repositories, datasources, and `DioClient.makeRequest` all follow this. When you `.fold()`, the first callback is success and the second is the error.
- **Register everything in DI.** New datasources/repositories/usecases must be wired in `lib/app/core/services/injection_service.dart` (`initDataSources` / `initRepositories` / `initUsecases`). Resolve with the global `sl<T>()`. `init()` runs all phases at app start from `main.dart`.
- **Resolve cross-screen controllers, don't reconstruct them.** Controllers a binding already registers (e.g. `ShipmentsController` via `MainScreenBinding`'s `lazyPut`) must be reached with `Get.find<T>()` — calling `Get.put(T())` to *get* a live controller silently builds a second instance and re-runs `onInit` (duplicate network calls, lost reactive state). Guard with `if (Get.isRegistered<T>())` when the controller may not be alive yet (the idiom used throughout the codebase).
- **New screens need a route.** Add the page + binding to `lib/app/routes/app_pages.dart` and the name to `lib/app/routes/app_routes.dart`; navigate with `Get.toNamed(Routes.X)`.
- **Auth token** is read by `AppInterceptors` (in `dio_client.dart`) from `CommonVariables.settings.read(TOKEN)` (GetStorage). Login/registration/`getStates` paths are excluded from the `Authorization` header. There is no token-refresh logic (stubbed TODO).
- **Repositories check connectivity first** via `INetworkInfo` and fall back to local cache or return an `OfflineFailure`/`EmptyCacheFailure`. Many wrap calls in `executeAndHandleError(...)` from `core/helpers/functions.dart`.

### Presentation patterns

- **Per-status visuals live on the status enum, not the widget.** Status-driven styling is centralized as an extension on the enum (e.g. `TripTypeStyle on TripType` in `core/enum/trip_type.dart`), exposing a single accent plus derived getters (`accentColor`, `railColor`, `pillTextColor`, `pillLabel`, `statusIcon`, `cardFill`, `cardBorderColor`, `rowOpacity`, `railDashed`). Widgets read these; don't re-derive per-status colors or `isDark ? …` branches inline. A reusable `StatusPill(tripType, shipment)` (`views/widgets/`) renders the badge from those getters.
- **Controllers hold state + business logic; views own UI.** Async controller methods return a result the view reacts to rather than driving presentation themselves — e.g. `completeShipment(...) → Future<bool>`, after which the caller (the upload-BOL sheet) closes the sheet and shows `showTripCompletedDialog(...)` (`views/dialogs/`). Validation surfaces as reactive `Rxn*` fields (`bolNumberError`, `bolFilesError`) the view consumes. Don't build dialog/widget trees inside controllers.

### Shared widgets & helpers — reuse before rolling your own

Canonical building blocks live in `core/`; prefer them over hand-rolling:

- **Text:** `AppText` (`core/widgets/app_text.dart`) — Poppins, applies `.sp` to `size` internally and ellipsizes. Use it for styled text instead of raw `Text`; drop to raw `Text`/`Text.rich` only for what it can't express (`letterSpacing`, mixed inline styles).
- **Buttons / header:** `AppButton` (`core/widgets/app_botton.dart` — note the misspelling) with `isLoading`/`radius`/`bgColor`/`width`; `AppBackButton` (`core/widgets/app_back_button.dart`) is the standard header back button (circular tap ripple; `onTap` defaults to `Get.back`) — use it instead of a bare `GestureDetector`+`Icon`; `AppRedHeader` (`core/widgets/app_red_header.dart`) for the brand gradient header. Screen pattern is `AppRedHeader > SafeArea > Scaffold` (the outer header paints the status-bar inset) **plus** an inner `AppRedHeader` app-bar row — keep both.
- **Bottom sheets:** `showAppBottomSheet<T>({required child})` (`core/utils/widget_utils.dart`) supplies the surface (`context.sheetColor`), rounded top, `SafeArea`, and the `SheetDragHandle` — pass only content; don't call `showModalBottomSheet` directly.
- **Files:** `FileViewer` (PDF/image viewer); in `core/utils/functions.dart`, `saveFile(...)` downloads via the system dialog and `shareRemoteFile({url, subject})` does download-to-temp → share sheet → cleanup.
- **Snackbars:** `CommonWidgets.showSnackBar(...)` (`core/widgets/common_widget.dart`). Spacing helpers `addVerticalSpace`/`addHorizontalSpace` coexist with raw `SizedBox` — both are accepted.

**`pull_to_refresh` gotcha:** `SmartRefresher` only drives overscroll when its child is a `ScrollView` **directly** (`ListView`/`GridView`/`CustomScrollView`). Wrapping the child (e.g. `SingleChildScrollView`, `AnimationLimiter`) silently disables pull-to-refresh — put such wrappers *above* the refresher.

### Environment & API

Environment is derived from the build flavor (`appFlavor`): `Environment.current` in `lib/app/core/data/connection/environments.dart` maps `dev`/`staging`/`prod` to the API host, producing `https://<host>/api/v2/` in `api_constants.dart`. **Switching environments = `flutter run --flavor dev|staging|prod`** — never a code edit. A null flavor (tests, unflavored builds) resolves to production. Each flavor is also its own Firebase project/app: `android/app/src/<flavor>/google-services.json` and `ios/config/firebase/<flavor>/GoogleService-Info.plist` (copied into the bundle by the "Copy GoogleService-Info.plist" build phase, since native `FirebaseApp.configure()` reads it) natively, and `lib/app/core/services/firebase/firebase_options_<flavor>.dart` (FlutterFire-generated, switched by `default_firebase_options.dart`) on the Dart side. On iOS each flavor is an Xcode scheme (`dev`/`staging`/`prod`) with `<Mode>-<flavor>` build configurations backed by `ios/Flutter/<Mode>-<flavor>.xcconfig`; the plain `Runner` scheme still builds production. dev/staging application ids are suffixed so they install alongside production. All endpoint paths are string constants in `api_constants.dart`.

**staging currently borrows dev's app identity.** Because the backend only has push registered for the dev Firebase project, the staging flavor ships dev's application id / bundle id (`.dev`) and dev's Firebase config — its **API host stays `staging.ts-portal.com`**, only the Firebase/FCM/APNs identity is dev's. So: dev and staging are one installed app and replace each other on device; `MyDetails.isStaging` (derived from `serverUrl`) still reports staging. The repoint lives in `flavorizr.yaml` + `android/app/flavorizr.gradle` (applicationId), the two `*-staging)` script-phase arms in `ios/Runner.xcodeproj/project.pbxproj`, `android/app/src/staging/google-services.json` (a copy of dev's), and the `Environment.staging` arm of `default_firebase_options.dart`. The real staging config is preserved unused at `android/app/src/staging/google-services.staging-project.json`, `ios/config/firebase/staging/`, and `firebase_options_staging.dart` — restore those four points together to undo it.

Flavor config is **generated by `flutter_flavorizr`** from `flavorizr.yaml` (`dart run flutter_flavorizr -f`). It owns `android/app/flavorizr.gradle` (applied from `build.gradle` between `BEGIN/END flavorDimensions` magic comments — never remove them or hand-add `flavorDimensions` elsewhere), `lib/flavors.dart` (`F` — display-only; `main.dart` sets `F.appFlavor` from `appFlavor`; env/Firebase switching must stay on the SDK `appFlavor` constant because the background FCM isolate never runs `main()`), the manifest `android:label`, and `.vscode/launch.json`. The `instructions` list in `flavorizr.yaml` is pinned to a brownfield-safe set — **never add `flutter:main`/`flutter:app`/`flutter:pages`** (they overwrite `lib/main.dart` with a template app). After regenerating: keep `app_name` out of `strings.xml` (per-flavor resValue provides it) and verify the `F.appFlavor` line in `main.dart` survived. iOS flavorization (`ios:*` instructions) is deliberately not run yet — see flavorizr.yaml header.

For local UI work without a backend, the `kUseShipmentSeed` flag (`shipments/data/shipment_seed.dart`, default `false`) makes the shipments controller serve canned `ShipmentSeed` data instead of hitting the API — flip it to iterate on the shipments tabs offline, but don't commit it `true`.

### Realtime, Firebase & notifications

- **Chat realtime** uses Pusher Channels (`dart_pusher_channels`) via `PusherManager` (`chat_detail/presentation/controllers/pusher_manager.dart`), configured from a server-fetched `RealtimeConfiguration` (`get_realtime_configuration_usecase`). `PusherManager` is a lazy singleton in DI and owns its own lifecycle — `sl<PusherManager>().start()` (re)connects idempotently on config-version change. Post-login realtime setup is centralized in `AuthController.setupRealtimeServices()` (fetch config → `start()`).
- **Firebase**: Core, Messaging (FCM + `flutter_local_notifications`), Crashlytics (errors routed in `main.dart`'s `runZonedGuarded`), Firestore, Auth, Realtime Database, Remote Config. Background FCM handler is a top-level `@pragma('vm:entry-point')` function. `DefaultFirebaseOptions` lives in `lib/app/core/services/firebase/default_firebase_options.dart` (per-flavor options in sibling `firebase_options_<flavor>.dart` files).
- **Calling** uses Agora (token + call events fetched from the API); native call UI lives in `lib/app/native_calling/`.

### App entry & startup sequence

`main.dart` runs `di.init()` + Firebase + `ThemeService` before `runApp`; splash (`INITIAL` route) auto-logs-in via `getProfile`, then routes to `MAIN_SCREEN` (drivers) or `LOGIN`. The login/splash → home path is deliberately decoupled from navigation for speed — don't re-block it:

- **Realtime is fire-and-forget.** `AuthController.setupRealtimeServices()` is *not* awaited before navigating; chat subscriptions await `authController.realtimeReady` instead (see `ConversationsController`).
- **Home's first load is deferred** until the entrance transition finishes — `HomeController.onInit` awaits `MainScreenController.entered`, which `MainScreenView`'s route-reveal gate completes when the `CircularRevealTransition` ends.
- **Splash prewarms** the applicant state (`HomePrewarm`) during its minimum-display window so the reveal opens onto populated content.

### Local packages

Three packages are vendored as path dependencies and may be edited directly: `chewie_local/`, `simple_image_cropper/`, `google_directions_api/`.

### UI & theming

`flutter_screenutil` with design size `375x812` (use `.w`/`.h`/`.sp`/`.r`). Font is Poppins, referenced via `FontFamily.poppins` (`core/gen/fonts.gen.dart`) — don't hardcode the `'Poppins'` string. Assets are typed via flutter_gen — import `package:ts_driver/app/core/gen/assets.gen.dart` and use the generated accessors (e.g. `Assets.svg.home`) rather than raw string paths. SVGs/images/sounds/json/lottie under `assets/`.

Theming lives in `lib/app/theme/` (token-based, mid-migration). `AppColors` (`app_colors.dart`) holds semantic tokens — brightness-agnostic ones (`primary`, `error`) plus `light*`/`dark*` pairs (`lightCard`/`darkCard`, …); `AppTheme.light()`/`AppTheme.dark()` (`app_theme.dart`) build the `ThemeData`. **Never branch on brightness by hand** (`isDark ? x : y`) at call sites — that ternary belongs only in `ContextColorExtensions` (`theme_extensions.dart`). Call sites use `context.panelColor`, `context.primaryTextColor`, `context.cardColor`, `context.dividerColor`, `context.hintColor`, `context.isDark`, etc. Dark mode is owned by `ThemeService` (`core/services/theme_service.dart`, a `GetxService` persisting the choice); `main.dart` wires `themeMode: Get.find<ThemeService>().mode`. Legacy top-level constants (`kMainColor`, `kTextColor`, `AppColorsLight`/`AppColorsDark`) still exist in `app_colors.dart` and are being migrated onto tokens — prefer `AppColors`/`context.*` in new code.

**Material 3 gotchas** — `useMaterial3` is left unset, so the app runs on **M3 by default**. (1) `Card` paints `colorScheme.surface` (+ an elevation tint), **not** `ThemeData.cardColor`; both themes set `CardThemeData(color: AppColors.lightCard/darkCard, surfaceTintColor: Colors.transparent)` to pin cards to the token so they match `context.cardColor` — don't repaint a card's surface with `context.cardColor` inside a `Card`, let it inherit. (2) Theme switching re-resolves `context.*` on rebuild, but **`const`-baked colors freeze** — drop `const` on any node whose color must flip between light/dark.

Custom route entrance animations (e.g. the main-screen circular reveal) are GetX `CustomTransition`s in `lib/app/core/transitions/`, attached via `GetPage.customTransition` with `transition` left unset.

**The launch splash is two separate phases — don't confuse them.** (1) The *native* splash (the frame the OS shows before Flutter starts) is generated by `flutter_native_splash` from the `flutter_native_splash:` block in `pubspec.yaml` — white background + red logo, sources `assets/images/splash_logo.png` (legacy/iOS) and `splash_logo_android12.png` (the Android 12+ circular icon). It writes the native files (`android/app/src/main/res/**` `launch_background.xml` / `values*/styles.xml` / `drawable*`, iOS `LaunchScreen` / `Info.plist`); **regenerate with `dart run flutter_native_splash:create` rather than hand-editing those — they get overwritten.** (2) The *Flutter* splash that follows is `SplashView` (the `INITIAL` route): always brand red with a white logo, and it runs the auto-login/prewarm — unrelated to the native config. App icons are likewise generated (`flutter_launcher_icons` from `assets/images/ts.png`), not hand-edited in the native mipmaps.

## Native calling layer (Android & iOS)

Calling (Agora RTC + CallKit/Telecom + a dedicated native Pusher client) is implemented **natively on both platforms**, not in Dart. The Flutter side only sends commands and listens for events. The two native trees deliberately **mirror each other** — `android/app/src/main/kotlin/com/transport_system/ts_driver/` and `ios/Runner/` have parallel folders (`agora/`↔`Agora/`, `telecom/`↔`Callkit/`, `pusher/`↔`Pusher/`, `data_providers/`+`database/`↔`MyDetails`+`Database/`, `native_calling_plugin/`↔`Callkit/Channels/`). **A change to call behavior almost always has to be made twice, once per platform, and the two are expected to stay behaviorally identical** — when editing one, find and update its counterpart.

### Flutter ⇄ native bridge

Two channel pairs, same channel names on both platforms (Dart side under `lib/app/native_calling/`):

- **`native_calling_method_channel`** (Dart → native): `place_call`, `open_native_call_ui`, `end_call`, `can_start_call`, `get_current_call`. Handlers: `native_calling_plugin/NativeCallingMethodChannel.kt` / `Callkit/Channels/NativeCallingMethodChannel.swift`.
- **`native_calling_event_channel`** (native → Dart): emits `{event, data}` where `event` is one of `callReceived`/`callPlaced`/`callTime`/`callEnded`/`callDeclined`/`callNoAnswer`/`callUserBusy`/`callFailed` (`NativeCallingEvents`). Consumed app-wide by `CallEventsController` (`lib/app/controllers/`).

Channels are registered at engine startup: Android `MainActivity.configureFlutterEngine` (adds `NativeCallingPlugin`, registers the Telecom `PhoneAccount`, boots native Pusher + call-channel events, ensures notification channels); iOS `AppDelegate.didFinishLaunchingWithOptions` (`PushKitManager.registerForVoipPushes`, channel registration, `PusherManager.shared.initializePusher`).

### Incoming-call path is native-first (Dart may be dead)

Push lands directly in native code with **no running Flutter engine**:
- **Android:** FCM **data** message with `notification_type == "call"` → `FirebaseMessagingService.onMessageReceived` → `CallManager.reportIncommingCall` → Telecom `ConnectionService` → `CallConnection.onShowIncomingCallUi` (rings via `CallNotificationService`, schedules a 30s timeout broadcast, calls `AgoraManager.reportIncomingCall`).
- **iOS:** VoIP push → `PushKitManager.didReceiveIncomingPushWith` → CallKit `CallManager.reportIncomingCall`.

Because of this, **anything the call path needs must be available without Dart** — hence the mirrored-prefs mechanism below. Android call lifecycle (timeout/decline/end) is driven by `broadcast_receiver/CallBroadcastReceiver` actions; the call UI is a native `CallActivity` + `fragments/` (Android) vs SwiftUI under `Agora/View/` (iOS).

### `MyDetails` — native's view of the session (mirrored SharedPreferences)

Native never shares Dart objects. `data_providers/MyDetails.kt` / `MyDetails.swift` read `flutter.*`-prefixed keys out of Flutter's `FlutterSharedPreferences` (Android) / `UserDefaults` (iOS) store that **Dart's `SharedPrefrencesHelper` writes** (`storeMyDetails` / `storeRealtimeConfig`): `token`, `serverUrl`, realtime `key`/`host`/`port`/`authUrl`, agora `app_id`, and `config_version`. All native REST/Pusher code builds its base URL + bearer auth from `MyDetails`; `MyDetails.isProduction/isStaging/isDevelopment` is derived from a `serverUrl` substring. **The Dart writer's keys/types and the native readers + native `storeRealtimeConfig` writers must stay byte-compatible** (note: a Dart `int` is stored as `Long` on Android) — they only match by hand-maintained convention, so change `SharedPrefrencesHelper` and *both* `MyDetails` files together.

### AgoraManager + the rotated-app-id self-heal

`agora/AgoraManager.kt` / `Agora/AgoraManager.swift` are singletons owning the `RtcEngine` and call state. App-id resolution: **server-synced value (`MyDetails.agoraAppId`) → hardcoded per-env fallback**. The engine is destroyed+recreated when the app_id changes (Android: guard inside `initializeAgora`; iOS: explicit `recreateEngineIfNeeded()`). Both the accept and place paths funnel through one shared helper — Android `syncTokenAndJoin(...)`, iOS `syncRecreateTokenThenJoin(...)` — which **(1)** refreshes realtime config, **(2)** mints the Agora token (`AgoraTokenApi`, `POST chat/agora/token`), **(3)** joins. Route any new call entry point through that helper instead of re-pasting the sequence.

`RealtimeConfigApi` (`agora/apis/RealtimeConfigApi.kt` / `Agora/Apis/Apis/RealtimeConfigApi.swift`) does the refresh: `GET drivers/realtime-configuration`, compare `config_version` to the stored one, and **only on mismatch** rewrite the mirrored prefs (so a rotated Agora app_id is fresh before join). It intentionally runs on every call setup and gates token/join — the design goal is "always a fresh app_id before connecting," so don't make it fire-and-forget or throttle it without explicit direction.

### Native REST + Pusher conventions

- **REST** is thin per-call API objects, not a shared client. Android uses **Retrofit** (`network/ApiInterface` + `RetrofitClient`; Gson; callbacks deliver on the main thread; typed response models in `network/models/`). iOS inlines `URLSession` per file under `Agora/Apis/Apis/` (no shared request builder; note Android models a typed `RealtimeConfigResponse` while iOS hand-parses JSON — a known divergence). Endpoints: `chat/agora/token`, `chat/agora/call`, `chat/agora/startCallRecording`, `drivers/realtime-configuration`. `serverUrl` already ends in `/api/v2/`.
- **Native Pusher is separate from the Dart Pusher.** `pusher/` (Android: `pusher/manager/PusherManager` + `CallChannel` + `call_channel/events/*`; iOS: `Pusher/`) is a distinct client for **call signaling** (client-events `client-call-accepted`, ringing/declined/no-answer/busy), configured from the same mirrored realtime prefs. The Dart `PusherManager` (`chat_detail/...`) handles chat/presence — don't conflate them.

### iOS Xcode project registration

iOS uses **explicit file references** (no synchronized groups). Any new `.swift` file must be added to `ios/Runner.xcodeproj/project.pbxproj` in four places — `PBXBuildFile`, `PBXFileReference`, the parent `PBXGroup` `children`, and the `PBXSourcesBuildPhase` — or it silently won't compile.

## Coding notes specific to this repo

- **Comment sparingly.** No section banners, no doc comments restating the obvious, no narrating what the code already says. A comment earns its place only by explaining a non-obvious *why*. Prefer self-explanatory names over comments.
- The app is in active refactoring (module restructuring + a token-based theme / dark-mode migration). Commits follow conventional-commit style (`feat:`, `fix:`, `refactor:`).
- `library_private_types_in_public_api` is silenced in `analysis_options.yaml`; otherwise `flutter_lints` defaults apply.
- `built_value` is pinned to `8.6.0` via `dependency_overrides` — don't bump it casually.
- `dart run build_runner build` currently crashes while serializing its cache (`built_value` in `build_runner_core`, "wrote 0 outputs") **but still writes the generated `*.gen.dart` outputs**. When regenerating, run `dart run build_runner clean` first, ignore the trailing serialization error, and verify with `flutter analyze`.
