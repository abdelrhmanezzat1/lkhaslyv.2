// Domain entity for a service Order, shared between the Client and Technician
// flows.
//
// It exposes the lifecycle that the existing services already encode:
//   pending -> accepted -> on_the_way -> arrived -> working ->
//   finished -> completed -> paid
//
// Status values intentionally mirror the existing DB `status` strings so we
// don't break the schema until the technician-side refactor (Phase 2) lands.
class Order {

  factory Order.fromJson(Map<String, dynamic> json) {
    final carInfoRaw = json['car_info'];
    final carInfo = carInfoRaw is Map<String, dynamic>
        ? Map<String, dynamic>.from(carInfoRaw)
        : null;
    return Order(
      id: (json['id'] as String?) ?? '',
      clientId: (json['customer_id'] as String?) ?? '',
      carId: (json['car_id'] as String?) ?? '',
      serviceType: (json['service_type'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      latitude: _parseDouble(json['latitude']) ?? 0,
      longitude: _parseDouble(json['longitude']) ?? 0,
      imageUrl: json['image_url'] as String?,
      status: OrderStatusX.parse(json['status'] as String?),
      paymentStatus:
          PaymentStatusX.parse(json['payment_status'] as String?),
      paymentMethod:
          PaymentMethodX.parse(json['payment_method'] as String?),
      technicianId: json['technician_id'] as String?,
      technicianName: json['technician_name'] as String?,
      carInfo: carInfo,
      createdAt:
          _parseDate(json['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      acceptedAt: _parseDate(json['accepted_at']),
      drivingAt: _parseDate(json['driving_at']),
      arrivedAt: _parseDate(json['arrived_at']),
      workingAt: _parseDate(json['working_at']),
      finishedAt: _parseDate(json['finished_at']),
      completedAt: _parseDate(json['completed_at']),
      notes: json['notes'] as String?,
      totalAmount: _parseDouble(json['total_amount']),
    );
  }
  const Order({
    required this.id,
    required this.clientId,
    required this.carId,
    required this.serviceType,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    this.technicianId,
    this.technicianName,
    this.imageUrl,
    this.acceptedAt,
    this.drivingAt,
    this.arrivedAt,
    this.workingAt,
    this.finishedAt,
    this.completedAt,
    this.notes,
    this.totalAmount,
    this.paymentMethod,
    this.carInfo,
  });

  final String id;
  final String clientId;
  final String carId;
  final String serviceType;
  final String description;
  final double latitude;
  final double longitude;

  final String? imageUrl;

  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final PaymentMethod? paymentMethod;

  final String? technicianId;
  final String? technicianName;

  /// Optional embedded car snapshot — populated via the Supabase
  /// `car_info:cars(*)` join used in `AuthService.getOrders`.
  final Map<String, dynamic>? carInfo;

  // ── Timestamps ──────────────────────────────────────────────────────────
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? drivingAt;
  final DateTime? arrivedAt;
  final DateTime? workingAt;
  final DateTime? finishedAt;
  final DateTime? completedAt;

  final String? notes;
  final double? totalAmount;

  bool get hasTechnician =>
      technicianId != null && technicianId!.isNotEmpty;

  Order copyWith({
    String? technicianId,
    String? technicianName,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    String? notes,
    double? totalAmount,
    DateTime? acceptedAt,
    DateTime? drivingAt,
    DateTime? arrivedAt,
    DateTime? workingAt,
    DateTime? finishedAt,
    DateTime? completedAt,
  }) =>
      Order(
        id: id,
        clientId: clientId,
        carId: carId,
        serviceType: serviceType,
        description: description,
        latitude: latitude,
        longitude: longitude,
        imageUrl: imageUrl,
        status: status ?? this.status,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        technicianId: technicianId ?? this.technicianId,
        technicianName: technicianName ?? this.technicianName,
        carInfo: carInfo,
        createdAt: createdAt,
        acceptedAt: acceptedAt ?? this.acceptedAt,
        drivingAt: drivingAt ?? this.drivingAt,
        arrivedAt: arrivedAt ?? this.arrivedAt,
        workingAt: workingAt ?? this.workingAt,
        finishedAt: finishedAt ?? this.finishedAt,
        completedAt: completedAt ?? this.completedAt,
        notes: notes ?? this.notes,
        totalAmount: totalAmount ?? this.totalAmount,
      );

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static double? _parseDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  @override
  String toString() =>
      'Order(id=$id, serviceType=$serviceType, status=${status.name})';
}

// ─────────────────────────────────────────────────────────────────────────────
// Order enums
// ─────────────────────────────────────────────────────────────────────────────

enum OrderStatus {
  pending,
  accepted,
  onTheWay,
  arrived,
  working,
  finished,
  completed,
  paid,
  cancelled,
  unknown,
}

extension OrderStatusX on OrderStatus {
  /// Wire format used by the existing DB schema.
  String get dbValue {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.onTheWay:
        return 'on_the_way';
      case OrderStatus.arrived:
        return 'arrived';
      case OrderStatus.working:
        return 'working';
      case OrderStatus.finished:
        return 'finished';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.paid:
        return 'paid';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.unknown:
        return '';
    }
  }

  String get name => dbValue;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.onTheWay:
        return 'On the way';
      case OrderStatus.arrived:
        return 'Arrived';
      case OrderStatus.working:
        return 'Working';
      case OrderStatus.finished:
        return 'Finished';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.paid:
        return 'Paid';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.unknown:
        return 'Unknown';
    }
  }

  static OrderStatus parse(String? raw) {
    switch (raw) {
      case 'pending':
        return OrderStatus.pending;
      case 'accepted':
        return OrderStatus.accepted;
      case 'on_the_way':
        return OrderStatus.onTheWay;
      case 'arrived':
        return OrderStatus.arrived;
      case 'working':
        return OrderStatus.working;
      case 'finished':
        return OrderStatus.finished;
      case 'completed':
        return OrderStatus.completed;
      case 'paid':
        return OrderStatus.paid;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.unknown;
    }
  }
}

enum PaymentStatus { pending, paid, refunded, unknown }

extension PaymentStatusX on PaymentStatus {
  String get dbValue {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.refunded:
        return 'refunded';
      case PaymentStatus.unknown:
        return '';
    }
  }

  String get name => dbValue;

  static PaymentStatus parse(String? raw) {
    switch (raw) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.unknown;
    }
  }
}

enum PaymentMethod { cash, card, wallet, unknown }

extension PaymentMethodX on PaymentMethod {
  String get dbValue {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.wallet:
        return 'wallet';
      case PaymentMethod.unknown:
        return '';
    }
  }

  String get name => dbValue;

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.unknown:
        return '';
    }
  }

  static PaymentMethod? parse(String? raw) {
    switch (raw) {
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      case 'wallet':
        return PaymentMethod.wallet;
      case null:
      case '':
        return null;
      default:
        return PaymentMethod.unknown;
    }
  }
}
