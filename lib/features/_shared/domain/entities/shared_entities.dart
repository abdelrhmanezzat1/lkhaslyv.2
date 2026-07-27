/// Public barrel for cross-feature domain entities.
///
/// Import this from any feature that needs the shared [UserProfile],
/// [Car] or [Order] entities without taking an internal dependency on
/// individual files.
library;

import 'package:flutter_application_1/features/_shared/domain/entities/shared_entities.dart' show Car, Order, UserProfile;

export 'car.dart';
export 'order.dart';
export 'user_profile.dart';
