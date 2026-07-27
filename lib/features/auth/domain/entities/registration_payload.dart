// Phase 3.4 typed payload for the `register` use-case.
//
// Before this refactor, `RegistrationController.register` took 6 named
// strings individually (`firstName`, `lastName`, `email`, `password`,
// `phone`, `userType`). That made the controller signature long and
// made the orchestration hard to test.
//
// Bundling the inputs into a single value object lets the use-case have
// one parameter, and lets future call-sites (e.g. an admin import-script)
// pass the same payload without copy-pasting six args.

/// Fields required to create a new auth user + matching `profiles` row.
class RegistrationPayload {
  const RegistrationPayload({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.userType,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;

  /// One of `'client'` | `'technician'`. Kept as a string so it can be
  /// stored verbatim in `auth.users.user_metadata.user_type`. The
  /// controller still owns the `isTechnician` flag derivation —
  /// `RegistrationPayload` should stay free of any business logic.
  final String userType;

  String get fullName => '$firstName $lastName';

  /// Extra fields that go into `auth.users.user_metadata` at signup time.
  ///
  /// Kept here (on the payload) so the use-case can build the metadata
  /// from a single source instead of having the controller hand-roll the
  /// map.
  Map<String, dynamic> get metadata => <String, dynamic>{
        'full_name': fullName,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'user_type': userType,
      };
}
