/// A class that holds the route paths for the application.
/// This prevents using hardcoded strings and provides a single source of truth for all routes.
library;
import 'package:flutter_application_1/features/_shared/domain/entities/order.dart';
import 'package:flutter_application_1/features/home/presentation/map_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String addCar = '/add-car';
  static const String editCar = '/edit-car';
  static const String myCars = '/my-cars';
  static const String map = '/map';
  static const String serviceRequest = '/service-request';
  static const String orders = '/orders';
  static const String payment = '/payment';
  static const String technicianHome = '/technician-home';
  static const String incomingRequests = '/technician/incoming';
  static const String acceptedRequests = '/technician/accepted';
  static const String liveStatus = '/technician/live-status';
  static const String finishJob = '/technician/finish-job';
  static const String completedJobs = '/technician/completed';

  // Order tracking and completion routes - consistent plurals
  static const String orderTracking = '/orders/:orderId/tracking';
  static const String orderCompletion = '/orders/:orderId/completion';
  static const String orderRating = '/orders/:orderId/rating';

  // Technician accepted request detail route - singular for detail
  static const String acceptedRequestDetail = '/technician/accepted/:orderId/detail';

  // Typed extra object keys for routes (public constants for type-safe navigation)
  static const String paymentExtraKey = 'payment_extra';
  static const String mapExtraKey = 'map_extra';
  static const String serviceRequestExtraKey = 'service_request_extra';
  static const String liveStatusExtraKey = 'live_status_extra';
  static const String finishJobExtraKey = 'finish_job_extra';
}

/// Typed extra objects for type-safe route navigation
class PaymentExtra {
  const PaymentExtra(this.order);
  final Order order;
}

class MapExtra {
  const MapExtra(this.args);
  final MapScreenArgs args;
}

class ServiceRequestExtra {
  const ServiceRequestExtra(this.serviceType);
  final String serviceType;
}

class LiveStatusExtra {
  const LiveStatusExtra(this.requestId);
  final String requestId;
}

class FinishJobExtra {
  const FinishJobExtra(this.requestId);
  final String requestId;
}
