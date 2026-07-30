import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/storage/storage_keys.dart';
import 'package:flutter_application_1/core/storage/storage_service.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/car.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/order.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/features/auth/presentation/login/forgot_password_screen.dart';
import 'package:flutter_application_1/features/auth/presentation/login/login_screen.dart';
import 'package:flutter_application_1/features/auth/presentation/login/register_screen.dart';
import 'package:flutter_application_1/features/cars/presentation/add_car_screen.dart';
import 'package:flutter_application_1/features/home/presentation/home_screen.dart';
import 'package:flutter_application_1/features/home/presentation/map_screen.dart' as map_screen;
import 'package:flutter_application_1/features/home/presentation/profile_screen.dart';
import 'package:flutter_application_1/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter_application_1/features/orders/presentation/order_completion_screen.dart';
import 'package:flutter_application_1/features/orders/presentation/order_rating_screen.dart';
import 'package:flutter_application_1/features/orders/presentation/order_tracking_screen.dart';
import 'package:flutter_application_1/features/orders/presentation/orders_screen.dart';
import 'package:flutter_application_1/features/orders/presentation/payment_screen.dart';
import 'package:flutter_application_1/features/orders/presentation/service_request_screen.dart';
import 'package:flutter_application_1/features/splash/presentation/splash_screen.dart';
import 'package:flutter_application_1/features/technician/presentation/accepted_request_detail_screen.dart';
import 'package:flutter_application_1/features/technician/presentation/accepted_request_screen.dart';
import 'package:flutter_application_1/features/technician/presentation/completed_jobs_screen.dart';
import 'package:flutter_application_1/features/technician/presentation/finish_job_screen.dart';
import 'package:flutter_application_1/features/technician/presentation/incoming_requests_screen.dart';
import 'package:flutter_application_1/features/technician/presentation/live_status_screen.dart';
import 'package:flutter_application_1/features/technician/presentation/technician_home_screen.dart'
    as technician;
import 'package:flutter_application_1/shared/widgets/error_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

// Helper class to listen to a stream and notify listeners on new events.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final authStateController = StreamController<void>.broadcast();
  ref.listen(authStateChangesProvider, (_, _) {
    authStateController.add(null);
  });

  final listenable = GoRouterRefreshStream(authStateController.stream);
  ref.onDispose(listenable.dispose);
  ref.onDispose(authStateController.close);

  return GoRouter(
    refreshListenable: listenable,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.addCar,
        builder: (context, state) => const AddCarScreen(),
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) {
          final extra = state.extra is PaymentExtra
              ? state.extra as PaymentExtra
              : (state.extra is Order
                  ? PaymentExtra(state.extra as Order)
                  : null);
          if (extra == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid payment data.')),
            );
          }
          return PaymentScreen(order: extra.order);
        },
      ),
      GoRoute(
        path: AppRoutes.map,
        builder: (context, state) {
          map_screen.MapScreenArgs? args;
          if (state.extra is MapExtra) {
            args = (state.extra as MapExtra).args;
          } else if (state.extra is Map<String, Object?>) {
            final raw = state.extra as Map<String, Object?>;
            const dummyCar = Car(
              id: '',
              userId: '',
              carType: '',
              carModel: '',
              plateNumber: '',
            );
            args = map_screen.MapScreenArgs(
              car: raw['order'] is Order
                  ? const Car(
                      id: '',
                      userId: '',
                      carType: '',
                      carModel: '',
                      plateNumber: '',
                    )
                  : dummyCar,
              serviceType: raw['serviceType'] as String? ?? '',
              description: raw['description'] as String? ?? '',
              tracking: raw['tracking'] as bool? ?? false,
              navigateCustomer: raw['navigateCustomer'] as bool? ?? false,
              order: raw['order'] as Order?,
              latitude: (raw['latitude'] as num?)?.toDouble(),
              longitude: (raw['longitude'] as num?)?.toDouble(),
            );
          }
          if (args == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid map data.')),
            );
          }
          return map_screen.MapScreen(args: args);
        },
      ),
      GoRoute(
        path: AppRoutes.serviceRequest,
        builder: (context, state) {
          final extra = state.extra is ServiceRequestExtra
              ? state.extra as ServiceRequestExtra
              : (state.extra is String
                  ? ServiceRequestExtra(state.extra as String)
                  : null);
          if (extra == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid service request data.')),
            );
          }
          return ServiceRequestScreen(serviceType: extra.serviceType);
        },
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => const OrdersScreen(),
      ),
      // Order tracking route
      GoRoute(
        path: AppRoutes.orderTracking,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderTrackingScreen(orderId: orderId);
        },
      ),
      // Order completion route
      GoRoute(
        path: AppRoutes.orderCompletion,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderCompletionScreen(orderId: orderId);
        },
      ),
      // Order rating route
      GoRoute(
        path: AppRoutes.orderRating,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderRatingScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: AppRoutes.technicianHome,
        builder: (context, state) => const technician.TechnicianHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.incomingRequests,
        builder: (context, state) => const IncomingRequestsScreen(),
      ),
      GoRoute(
        path: AppRoutes.acceptedRequests,
        builder: (context, state) => const AcceptedRequestsScreen(),
      ),
      // Technician accepted request detail route - singular for detail
      GoRoute(
        path: AppRoutes.acceptedRequestDetail,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return AcceptedRequestDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: AppRoutes.liveStatus,
        builder: (context, state) {
          final extra = state.extra is LiveStatusExtra
              ? state.extra as LiveStatusExtra
              : (state.extra is String
                  ? LiveStatusExtra(state.extra as String)
                  : null);
          if (extra == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid live status data.')),
            );
          }
          return LiveStatusScreen(requestId: extra.requestId);
        },
      ),
      GoRoute(
        path: AppRoutes.finishJob,
        builder: (context, state) {
          final extra = state.extra is FinishJobExtra
              ? state.extra as FinishJobExtra
              : (state.extra is String
                  ? FinishJobExtra(state.extra as String)
                  : null);
          if (extra == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid finish job data.')),
            );
          }
          return FinishJobScreen(requestId: extra.requestId);
        },
      ),
      GoRoute(
        path: AppRoutes.completedJobs,
        builder: (context, state) => const CompletedJobsScreen(),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);

      if (authState.isLoading || authState.hasError) {
        return null;
      }

      final isLoggedIn = authState.valueOrNull != null;
      final hasSeenOnboarding =
          StorageService.getBool(StorageKeys.hasSeenOnboarding) ?? false;

      final publicRoutes = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      ];

      final isAtPublicRoute = publicRoutes.contains(state.matchedLocation);
      final isAtAuthFlow = [
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      ].contains(state.matchedLocation);

      if (state.matchedLocation == AppRoutes.splash) {
        if (isLoggedIn) {
          final user = authState.valueOrNull;
          if (user != null) {
            final userType =
                user.userMetadata?['user_type'] as String? ?? 'client';
            if (userType == 'technician') return AppRoutes.technicianHome;
          }
          return AppRoutes.home;
        }
        if (!hasSeenOnboarding) return AppRoutes.onboarding;
        return AppRoutes.login;
      }

      if (isLoggedIn &&
          (isAtAuthFlow || state.matchedLocation == AppRoutes.onboarding)) {
        final user = authState.valueOrNull;
        if (user != null) {
          final userType =
              user.userMetadata?['user_type'] as String? ?? 'client';
          if (userType == 'technician') return AppRoutes.technicianHome;
        }
        return AppRoutes.home;
      }

      if (!isLoggedIn && !isAtPublicRoute) {
        return AppRoutes.login;
      }

      return null;
    },
  );
}
