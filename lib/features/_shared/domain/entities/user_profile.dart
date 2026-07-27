// Domain entity for a user profile.
//
// This is the single typed representation of a "user" across all features.
// It replaces the raw `Map<String, dynamic>` that used to leak out of
// `AuthService` and `AuthRepository` once the data layer returned a profile.
//
// Mapping rules:
//   ─ JSON `role`     -> [UserProfile.role]
//   ─ JSON `user_type`-> [UserProfile.userType] (legacy column kept for
//      backward compatibility during the migration in Phase 0.1).
//   ─ `first_name` + `last_name` -> [UserProfile.firstName]/[lastName].
//     A pre-computed `fullName` is exposed for callers that don't need
//     the split.
class UserProfile {

  /// Builds an entity from a raw Supabase row.
  ///
  /// Tolerates the legacy duplicate columns (`role` and `user_type`) that
  /// were observed in `auth_service.dart` during the Phase 0.1 migration.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['id'] as String?) ?? '',
      firstName: (json['first_name'] as String?) ?? '',
      lastName: (json['last_name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      role: UserRoleX.parse(
        (json['role'] as String?) ?? (json['user_type'] as String?),
      ),
      userType: (json['user_type'] as String?) ??
          (json['role'] as String?) ??
          'client',
      currentLat: (json['current_lat'] as num?)?.toDouble(),
      currentLng: (json['current_lng'] as num?)?.toDouble(),
    );
  }
  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone = '',
    this.role = UserRole.client,
    this.userType = 'client',
    this.currentLat,
    this.currentLng,
  });

  /// Unique Supabase user uuid.
  final String id;

  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  /// Coarse role (used by the router redirect).
  final UserRole role;

  /// Free-form `user_type` metadata field as stored on the auth user.
  /// Kept for backward-compat with downstream Supabase queries.
  final String userType;

  /// Optional live technician location (only present for technicians).
  final double? currentLat;
  final double? currentLng;

  String get fullName {
    final first = firstName.trim();
    final last = lastName.trim();
    if (first.isEmpty && last.isEmpty) return '';
    if (first.isEmpty) return last;
    if (last.isEmpty) return first;
    return '$first $last';
  }

  bool get isTechnician => role == UserRole.technician;

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    UserRole? role,
    String? userType,
    double? currentLat,
    double? currentLng,
  }) {
    return UserProfile(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      userType: userType ?? this.userType,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'role': role.name,
        'user_type': userType,
        if (currentLat != null) 'current_lat': currentLat,
        if (currentLng != null) 'current_lng': currentLng,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          email == other.email &&
          phone == other.phone &&
          role == other.role &&
          userType == other.userType &&
          currentLat == other.currentLat &&
          currentLng == other.currentLng;

  @override
  int get hashCode => Object.hash(
        id,
        firstName,
        lastName,
        email,
        phone,
        role,
        userType,
        currentLat,
        currentLng,
      );

  @override
  String toString() =>
      'UserProfile(id=$id, fullName=$fullName, role=${role.name})';
}

enum UserRole { client, technician }

extension UserRoleX on UserRole {
  String get name {
    switch (this) {
      case UserRole.client:
        return 'client';
      case UserRole.technician:
        return 'technician';
    }
  }

  static UserRole parse(String? raw) {
    if (raw == null) return UserRole.client;
    return raw.toLowerCase() == 'technician'
        ? UserRole.technician
        : UserRole.client;
  }
}
