# CarServices - Database Compatibility Fix

## Task Progress

- [x] Analyze all car-related files
- [ ] Fix `auth_service.dart` - database column names (owner_id→user_id, brand→car_type, model→car_model, year→car_year)
- [ ] Fix `auth_repository.dart` - parameter names (brand→carType, model→carModel, year→carYear)
- [ ] Fix `auth_repository_impl.dart` - parameter names (brand→carType, model→carModel, year→carYear)
- [ ] Fix `registration_controller.dart` - parameter names (brand→carType, model→carModel, year→carYear)
- [ ] Fix `add_car_screen.dart` - UI variable names, labels, and parameter passing
- [ ] Fix `service_request_screen.dart` - car field access (brand→car_type, model→car_model)
- [ ] Run `flutter analyze` and fix errors
- [ ] Verify no other features were modified

---

# Architectural Riverpod Migration

## Phase 4 — Riverpod controllers + screen migration

- [x] **Phase 4.1** — Per-feature Riverpod controllers (`CarsController`, `OrdersController`, `ProfileController`) replacing direct `auth_service` access. Generated parts via `build_runner` (`.g.dart`).
- [x] **Phase 4.1b** — Analyzer clean on new controllers + tests green.
- [x] **Phase 4.2a** — `lib/features/home/presentation/orders_screen.dart` converted from `ConsumerStatefulWidget` (with `_orders`/`_isLoading` local state + per-order Supabase realtime subscription) to pure `ConsumerWidget` reading `AsyncValue<List<Order>>` from `clientOrdersForUserProvider`. Bonus cleanup: dead `auth_repository.dart` import removed from `lib/features/auth/controllers/auth_controller.dart`; `() => authRepository.signOut()` lambda replaced with tearoff. **Verifier:** `flutter analyze lib/features/home/presentation/orders_screen.dart` → `No issues found!` ✅
- [ ] **Phase 4.2b** — `lib/features/home/presentation/payment_screen.dart` → `OrdersController.payOrder` (delegates to existing `payOrderUseCaseProvider`).
- [ ] **Phase 4.2c** — `lib/features/home/presentation/service_request_screen.dart` → `carsForUserProvider` + `OrdersController.createOrder`.
- [ ] **Phase 4.2d** — `lib/features/auth/presentation/login/add_car_screen.dart` → `CarsController.saveCar`.
- [ ] **Phase 4.2e** — Verify `lib/features/auth/presentation/login/register_screen.dart` uses `RegisterUserUseCase` provider only.
- [ ] **Phase 4.2f** — Trim dead `registration_controller` imports from `lib/features/home/presentation/technician_home_screen.dart` and `lib/features/home/presentation/map_screen.dart`.
- [ ] **Phase 4.3** — Move `add_car_screen.dart` to `lib/features/cars/presentation/`.
- [ ] **Phase 4.4** — Move `service_request_screen.dart`, `payment_screen.dart`, `orders_screen.dart` to `lib/features/orders/presentation/`.
- [ ] **Phase 4.5** — Normalise route names + replace raw `extra` `Map<String,dynamic>` with typed extras.

## Phase 5 — UI design-system hardening

- [ ] Phase 5.1 — Rename `theme.dart` barrel to `app_design_system.dart`.
- [ ] Phase 5.2 — Delete `lakhsly_button.dart`, `lakhsly_card.dart`, `lakhsly_text_field.dart` after migration.
- [ ] Phase 5.3 — Standardise widget param order, `const` constructors, `semanticLabel`/`testID`.
- [ ] Phase 5.4 — Light/dark parity audit on `AppColors`.

## Phase 6 — Backbone consolidation

- [ ] Phase 6.1 — Single source of auth-state (drop redundant Supabase listener from `main.dart`).
- [ ] Phase 6.2 — Centralise Supabase error → `AppException` mapping.
- [ ] Phase 6.3 — Wrap `NotificationService` init inside auth controller (post profile load).
- [ ] Phase 6.4 — Verify `DioClient` is injected; remove unused deps if necessary.
- [ ] Phase 6.5 — Standardise structured logging contract in repositories.

## Phase 7 — Test coverage

- [ ] Phase 7.1 — Provider-level tests for every controller (`ProviderContainer`).
- [ ] Phase 7.2 — Mock repository tests for `AuthRepository`, `OrdersRepository`.
- [ ] Phase 7.3 — Golden tests for top 5 design-system widgets.
- [ ] Phase 7.4 — Integration test for auth happy-path (onboarding → register → add car → request service).