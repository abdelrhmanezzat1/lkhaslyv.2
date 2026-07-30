### 📋 **The "Discovery Checklist" (Paste answers here)**

#### 1. **Project Meta**
*   **Repo Link?** `https://github.com/abdelrhmanezzat1/lkhaslyv.2` (origin)
*   **Flutter Version:** **Flutter 3.44.4** (stable) / Dart 3.12.2 / DevTools 2.57.0. SDK constraint in `pubspec.yaml`: `sdk: ^3.12.2`.
*   **State Management:** **Riverpod** (`flutter_riverpod: ^2.5.1` + `riverpod_annotation: ^2.3.5` + `riverpod_generator: ^2.4.0`). Also uses `get_it: ^7.7.0` for service-location DI (`setupServiceLocator()`).
*   **Architecture:** **Feature-First + Clean-ish layered**. Each feature (`auth`, `cars`, `orders`, `profile`, `technician`, `home`, `onboarding`, `splash`, `settings`) is split into `controllers` / `data` (services + repository impls) / `domain` (entities, repositories, use cases) / `presentation`. Shared code lives under `lib/features/_shared` and `lib/shared/widgets`. Routing via `go_router: ^14.0.0` with a Riverpod-provided `GoRouter` + auth-state redirect.
*   **Backend:** **Supabase** (`supabase_flutter: ^2.5.8`) — Auth, Postgres tables (`profiles`, `orders`, `cars`), and realtime streams (`profiles` stream for technician location). **Firebase Cloud Messaging** (`firebase_messaging: ^15.1.3` + `firebase_core: ^3.6.0`) for push notifications, with role-based topic subscription. **Mapbox** Directions API + tiles for routing/maps (`mapbox_maps_flutter` + `flutter_map: ^7.0.2`). HTTP via `dio: ^5.4.3+1`.

---

#### 2. **Current Progress % (Be honest)**

> This is an **on-demand roadside assistance / mobile mechanic** app (not a ride-hailing app). Mapping the checklist to the actual domain: Passenger → **Customer/Client**, Driver → **Technician**, Ride → **Service Order**.

| Module | Status (Not Started / UI Only / Logic Done / Tested / **Done**) | Notes |
| :--- | :--- | :--- |
| **Auth (Email/Password + Reset)** | **Logic Done / Tested** | `SupabaseAuthService` (signIn/signUp/resetPassword/signOut/updateUser) + `AuthRepositoryImpl` + `AuthController` (Riverpod). Email/password only — **no Phone/OTP or Social**. Auto-bootstraps `profiles` row on sign-in. Tests in `test/features/auth/`. |
| **Customer: Home & Search** | **Logic Done** | `HomeScreen`, `HomeGreetingBar`, service-type entry → `ServiceRequestScreen`. No global "search" — service selection drives the flow. |
| **Customer: Map & Place Picker** | **Logic Done** | `MapScreen` (flutter_map + Mapbox tiles). Modes: `selectLocation`, `trackTechnician`, `navigateToCustomer`. Geolocator permissions, Cairo/Giza bounds, polyline route decoding, ETA/distance card. Confirms pickup → creates order. |
| **Customer: Service Request Flow** | **Logic Done** | `ServiceRequestScreen` → car select + description + image (`image_picker`) → `MapScreen` confirm → `OrdersController.createOrder` → `SupabaseOrdersService.createOrder` (status `pending`). |
| **Customer: Orders & Tracking** | **Logic Done** | `OrdersScreen`, `OrderTrackingScreen`, `OrderCompletionScreen`, `OrderRatingScreen`. `getClientOrders` query with joined `car_info`. |
| **Customer: Payment** | **Logic Done** | `PaymentScreen` + `PayOrderUseCase` → `SupabaseOrdersService.payOrder` (sets `status=paid`, `payment_status=paid`, method). **Mock/no real gateway** — DB flags only. Tests in `test/features/orders/pay_order_use_case_test.dart`. |
| **Customer: Cars Management** | **Logic Done** | `AddCarScreen`, `CarsController`, `SupabaseCarsService` (CRUD on `cars` table). |
| **Customer: Profile** | **Logic Done** | `ProfileScreen`, `ProfileController`, `SupabaseProfileService`, `ProfileRepositoryImpl`. |
| **Technician: App Entry / Shift Toggle** | **UI Only / Partial** | `TechnicianHomeScreen`, `TechnicianController`, `TechnicianRepositoryImpl.toggleOnline()` is **in-memory only** (`_isOnline` flag) — **not persisted to DB**. `loadTechnicianProfile` reads `is_online` from `profiles` but toggle doesn't write back. |
| **Technician: Request Handling (Accept/Reject)** | **Logic Done / Tested** | `IncomingRequestsScreen`, `RequestsController`, `AcceptOrderUseCase` → `SupabaseOrdersService.acceptOrder` (status `accepted`, sets `technician_id/name`, `accepted_at`). `rejectRequest` sets `rejected`. Tests in `test/features/orders/accept_order_use_case_test.dart`. |
| **Technician: Job Lifecycle (Driving/Arrived/Working/Finished)** | **Logic Done (local) / Partial (realtime)** | `JobController`, `AcceptedRequestScreen`, `AcceptedRequestDetailScreen`, `LiveStatusScreen`, `FinishJobScreen`. `TechnicianRepositoryImpl.updateRequestStatus` updates local lists + writes `orders.status` + timestamp columns (`driving_at`, `arrived_at`, `working_at`, `finished_at`). **Caveat:** pending/accepted lists are **in-memory** in the repo — not subscribed from DB realtime; `getPendingOrders` exists in the orders service but technician repo keeps local state. |
| **Technician: Live Location Update** | **Logic Done** | `TechnicianLocationRepositoryImpl` writes `current_lat/current_lng` to `profiles`. `MapScreen` subscribes via Supabase realtime stream on `profiles`. |
| **Technician: Completed Jobs** | **Logic Done** | `CompletedJobsScreen`, `completeOrderAfterPayment` → status `completed`. |
| **Onboarding / Splash** | **Done** | `SplashScreen` (auth-state redirect), `OnboardingScreen` (flag persisted via `StorageService`). |
| **Push Notifications** | **Logic Done** | `NotificationService` (FCM + `flutter_local_notifications`), role-based topic subscription on auth state change. Background handler stubbed. |
| **Routing / Auth Guard** | **Done** | `app_router.dart` — Riverpod `GoRouter`, refreshListenable on auth stream, role-based redirect (`technician` → `technicianHome`, else `home`). |
| **Theming / Design System** | **Done** | `lib/core/theme/*` (colors, spacing, radius, shadows, motion, typography, dimensions) + `lib/shared/widgets/*` (cards, surfaces, shimmer, dropdown, dialogs, etc.). Inter font. |
| **CI/CD** | **Partial** | `.github/workflows/build-ios.yml` exists. No Android/web CI workflows seen. |
| **Tests** | **Partial** | Unit tests for use cases (`register_user`, `accept_order`, `pay_order`) + entity mappers + auth repo. **No widget/integration tests** beyond default `widget_test.dart`. |

---

#### 3. **Notable Risks / Gaps**
1.  **Technician online/offline toggle is not persisted** — `TechnicianRepositoryImpl.toggleOnline()` only flips an in-memory `_isOnline` flag; DB `profiles.is_online` is never updated.
2.  **Technician request lists are in-memory** — `TechnicianRepositoryImpl` keeps `_pendingRequests`/`_acceptedRequests`/`_activeRequests`/`_completedRequests` as local lists and only mutates them on explicit calls. There's **no Supabase realtime subscription** feeding incoming orders to the technician; `getPendingOrders()` exists in `SupabaseOrdersService` but the technician repo doesn't subscribe to it. Incoming requests likely rely on polling or push notifications + manual refresh.
3.  **No real payment gateway** — `payOrder` only flips DB flags (`payment_status=paid`). No Stripe/Paymob/Stripe SDK or transaction verification.
4.  **No Phone/OTP or Social auth** — email/password only.
5.  **Crash reporting stubbed** — `main.dart` has TODOs for Firebase Crashlytics / Sentry; `PlatformDispatcher.instance.onError` only `debugPrint`s.
6.  **`mapbox_maps_flutter: any`** — unversioned dependency; risk of breaking on pub resolution.
7.  **Background FCM handler commented out** in `main.dart` (`FirebaseMessaging.onBackgroundMessage(...)` is disabled).
8.  **Test coverage** is unit-only (use cases, mappers, auth repo); no widget or integration tests for screens/flows.