// Domain entity for a Car owned by a Client.
//
// This replaces the raw `Map<String, dynamic>` returned by `AuthService.getCars`
// in the legacy implementation. Field names mirror the DB columns
// (car_type, car_model, plate_number, car_year, color) after the
// Phase 0.1 rename.
class Car {

  factory Car.fromJson(Map<String, dynamic> json) => Car(
        id: (json['id'] as String?) ?? '',
        userId: (json['user_id'] as String?) ?? '',
        carType: (json['car_type'] as String?) ?? '',
        carModel: (json['car_model'] as String?) ?? '',
        plateNumber: (json['plate_number'] as String?) ?? '',
        carYear: json['car_year']?.toString(),
        color: json['color'] as String?,
        imageUrl: json['image_url'] as String?,
      );
  const Car({
    required this.id,
    required this.userId,
    required this.carType,
    required this.carModel,
    required this.plateNumber,
    this.carYear,
    this.color,
    this.imageUrl,
  });

  /// UUID primary key (empty when the car hasn't been persisted yet).
  final String id;

  /// UUID of the owning client.
  final String userId;

  final String carType;
  final String carModel;
  final String plateNumber;
  final String? carYear;
  final String? color;

  /// Optional future-proofing; not used today but DB column reserved.
  final String? imageUrl;

  String get displayName {
    final m = carModel.trim();
    if (carType.isEmpty && m.isEmpty) return '';
    if (carType.isEmpty) return m;
    if (m.isEmpty) return carType;
    return '$carType $m';
  }

  Car copyWith({
    String? id,
    String? userId,
    String? carType,
    String? carModel,
    String? plateNumber,
    String? carYear,
    String? color,
    String? imageUrl,
  }) =>
      Car(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        carType: carType ?? this.carType,
        carModel: carModel ?? this.carModel,
        plateNumber: plateNumber ?? this.plateNumber,
        carYear: carYear ?? this.carYear,
        color: color ?? this.color,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  /// JSON shape used by `POST /cars`.  `id` is omitted on insert so the
  /// DB can generate it (`gen_random_uuid()`).
  Map<String, dynamic> toInsertJson() => {
        if (id.isNotEmpty) 'id': id,
        'user_id': userId,
        'car_type': carType,
        'car_model': carModel,
        'plate_number': plateNumber,
        if (carYear != null) 'car_year': carYear,
        if (color != null) 'color': color,
        if (imageUrl != null) 'image_url': imageUrl,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Car &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          carType == other.carType &&
          carModel == other.carModel &&
          plateNumber == other.plateNumber &&
          carYear == other.carYear &&
          color == other.color &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        carType,
        carModel,
        plateNumber,
        carYear,
        color,
        imageUrl,
      );

  @override
  String toString() =>
      'Car(id=$id, displayName=$displayName, plateNumber=$plateNumber)';
}
