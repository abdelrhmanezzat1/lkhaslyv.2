import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/env/env.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/car.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/order.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/features/orders/controllers/orders_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/widgets/custom_app_bar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:supabase_flutter/supabase_flutter.dart';

enum MapMode { selectLocation, trackTechnician, navigateToCustomer }

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key, required this.args});
  final MapScreenArgs args;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  static final LatLngBounds _cairoGizaBounds = LatLngBounds.fromPoints([
    const ll.LatLng(29.1000, 30.7000),
    const ll.LatLng(30.5000, 32),
  ]);

  final MapController _mapController = MapController();
  StreamSubscription? _profileSubscription;
  StreamSubscription? _positionSubscription;
  Timer? _routeRefreshTimer;

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isMapReady = false;
  MapMode _mapMode = MapMode.selectLocation;

  ll.LatLng? _userPosition;
  ll.LatLng? _technicianPosition;
  ll.LatLng? _destination;

  final List<ll.LatLng> _routePoints = [];
  String _distanceText = '';
  String _durationText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initialize();
      }
    });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _positionSubscription?.cancel();
    _routeRefreshTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final permissionGranted = await _ensureLocationPermission();
    if (!permissionGranted) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final position = await _getCurrentPosition();
    if (position == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (!mounted) return;
    _userPosition = ll.LatLng(position.latitude, position.longitude);

    if (widget.args.tracking == true) {
      _mapMode = MapMode.trackTechnician;
      final order = widget.args.order;
      if (order != null) {
        _destination = ll.LatLng(order.latitude, order.longitude);
        final techId = order.technicianId ?? '';
        await _subscribeToTechnicianUpdates(techId);
        _routeRefreshTimer = Timer.periodic(
          const Duration(seconds: 12),
          (_) => _refreshRoute(
            origin: _technicianPosition,
            destination: _destination,
          ),
        );
      }
    } else if (widget.args.navigateCustomer == true) {
      _mapMode = MapMode.navigateToCustomer;
      _destination = ll.LatLng(
        (widget.args.latitude as num?)?.toDouble() ?? 0.0,
        (widget.args.longitude as num?)?.toDouble() ?? 0.0,
      );
      await _subscribeToUserPosition();
      _routeRefreshTimer = Timer.periodic(
        const Duration(seconds: 12),
        (_) => _refreshRoute(origin: _userPosition, destination: _destination),
      );
    } else {
      _mapMode = MapMode.selectLocation;
      _destination = _userPosition;
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (_isMapReady) {
        _mapController.move(_destination ?? _userPosition!, 14);
      }
    }
  }

  Future<bool> _ensureLocationPermission() async {
    if (!mounted) return false;

    if (!await Geolocator.isLocationServiceEnabled()) {
      if (!mounted) return false;
      AppSnackbar.showError(
        context,
        message: 'Location services are disabled. Please enable GPS.',
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return false;
        AppSnackbar.showError(
          context,
          message: 'Location permission is required to continue.',
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return false;
      AppSnackbar.showError(
        context,
        message:
            'Location permission is permanently denied. Enable it in app settings.',
      );
      return false;
    }

    return true;
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          message: 'Unable to get current position.',
        );
      }
      return null;
    }
  }

  bool _isInsideAllowedBounds(ll.LatLng point) {
    return _cairoGizaBounds.contains(point);
  }

  Future<void> _subscribeToTechnicianUpdates(String technicianId) async {
    await _profileSubscription?.cancel();
    if (technicianId.isEmpty) return;

    final supabase = Supabase.instance.client;
    _profileSubscription = supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', technicianId)
        .listen((updates) {
          if (!mounted || updates.isEmpty) return;
          final profile = updates.first;
          final lat = (profile['current_lat'] as num?)?.toDouble();
          final lng = (profile['current_lng'] as num?)?.toDouble();
          if (lat == null || lng == null) return;

          setState(() {
            _technicianPosition = ll.LatLng(lat, lng);
          });

          _refreshRoute(origin: _technicianPosition, destination: _destination);
          _fitBounds();
        });
  }

  Future<void> _subscribeToUserPosition() async {
    await _positionSubscription?.cancel();
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((position) {
          if (!mounted) return;
          setState(() {
            _userPosition = ll.LatLng(position.latitude, position.longitude);
          });
          _refreshRoute(origin: _userPosition, destination: _destination);
        });
  }

  Future<void> _refreshRoute({
    ll.LatLng? origin,
    ll.LatLng? destination,
  }) async {
    if (origin == null || destination == null) return;
    final token = Env.mapboxAccessToken;
    if (token.isEmpty) return;

    final lon1 = origin.longitude;
    final lat1 = origin.latitude;
    final lon2 = destination.longitude;
    final lat2 = destination.latitude;

    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/$lon1,$lat1;$lon2,$lat2';

    try {
      final resp = await Dio().get(
        url,
        queryParameters: {
          'geometries': 'polyline6',
          'overview': 'full',
          'steps': 'false',
          'access_token': token,
        },
      );

      final data = resp.data as Map<String, dynamic>?;
      final routes = data?['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) return;

      final route = routes[0] as Map<String, dynamic>;
      final geometry = route['geometry'] as String?;
      final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 0.0;
      final durationSeconds = (route['duration'] as num?)?.toDouble() ?? 0.0;

      final distanceKm = distanceMeters / 1000;
      final durationMin = (durationSeconds / 60).round();
      final etaText = '$durationMin min';

      if (geometry == null) return;

      final points = _decodePolyline(geometry, 1000000);

      if (mounted) {
        setState(() {
          _routePoints
            ..clear()
            ..addAll(points);
          _distanceText = '${distanceKm.toStringAsFixed(1)} km';
          _durationText = etaText;
        });
      }
    } catch (_) {
      // Network error or route failure — silently retry on next interval
    }
  }

  List<ll.LatLng> _decodePolyline(String encoded, int precision) {
    final List<ll.LatLng> coords = [];
    int index = 0;
    int lat = 0;
    int lng = 0;
    final len = encoded.length;

    while (index < len) {
      int result = 0;
      int shift = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      result = 0;
      shift = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      final double latitude = lat / precision;
      final double longitude = lng / precision;
      coords.add(ll.LatLng(latitude, longitude));
    }

    return coords;
  }

  void _fitBounds() {
    if (!mounted) return;

    final rawPoints =
        <ll.LatLng?>[_userPosition, _technicianPosition, _destination]
            .whereType<ll.LatLng>()
            .where((p) => p.latitude != 0.0 && p.longitude != 0.0)
            .toList();

    final uniquePoints = <ll.LatLng>[];
    for (final p in rawPoints) {
      if (!uniquePoints.any(
        (u) => u.latitude == p.latitude && u.longitude == p.longitude,
      )) {
        uniquePoints.add(p);
      }
    }

    if (uniquePoints.isEmpty) return;

    if (uniquePoints.length == 1) {
      _mapController.move(uniquePoints.first, 15);
      return;
    }

    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(uniquePoints),
          padding: const EdgeInsets.all(60),
          maxZoom: 17,
        ),
      );
    } catch (_) {
      // Fallback in case of bounds generation exception
    }
  }

  Future<void> _goToMyLocation() async {
    if (_userPosition != null) {
      _mapController.move(_userPosition!, 15);
      if (_mapMode == MapMode.selectLocation) {
        setState(() => _destination = _userPosition);
      }
    } else {
      final position = await _getCurrentPosition();
      if (position != null && mounted) {
        final latLng = ll.LatLng(position.latitude, position.longitude);
        setState(() {
          _userPosition = latLng;
          if (_mapMode == MapMode.selectLocation) {
            _destination = latLng;
          }
        });
        _mapController.move(latLng, 15);
      }
    }
  }

  Future<void> _confirmLocation() async {
    if (_isSubmitting) return;
    if (_destination == null) {
      AppSnackbar.showError(
        context,
        message: 'Please choose a pickup location.',
      );
      return;
    }

    if (!_isInsideAllowedBounds(_destination!)) {
      AppSnackbar.showError(
        context,
        message: 'Please select a location inside Cairo or Giza.',
      );
      return;
    }

    final user = ref.read(authStateChangesProvider).valueOrNull;
    if (user == null) return;

    final car = widget.args.car;
    final serviceType = widget.args.serviceType;
    final description = widget.args.description;
    final imageUrl = widget.args.imageUrl;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(ordersControllerProvider.notifier).createOrder(
            clientId: user.id,
            carId: car.id,
            serviceType: serviceType,
            description: description,
            imageUrl: imageUrl,
            latitude: _destination!.latitude,
            longitude: _destination!.longitude,
          );
      if (mounted) {
        AppSnackbar.showSuccess(
          context,
          message: 'Order created successfully!',
        );
        context.go(AppRoutes.orders);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, message: 'Failed to create order: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: Text(
          _mapMode == MapMode.selectLocation
              ? 'Select Location'
              : 'Live Tracking',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const AppLoader(message: 'Loading map...'),
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        _destination ??
                        _userPosition ??
                        const ll.LatLng(30.0444, 31.2357),
                    initialZoom: 14,
                    minZoom: 9,
                    maxZoom: 18,
                    cameraConstraint: CameraConstraint.contain(
                      bounds: _cairoGizaBounds,
                    ),
                    interactionOptions: _mapMode == MapMode.selectLocation
                        ? const InteractionOptions(flags: InteractiveFlag.all)
                        : const InteractionOptions(
                            flags:
                                InteractiveFlag.pinchZoom |
                                InteractiveFlag.drag,
                          ),
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture && _mapMode == MapMode.selectLocation) {
                        setState(() => _destination = position.center);
                      }
                    },
                    onMapReady: () {
                      setState(() => _isMapReady = true);
                      if (_destination != null || _userPosition != null) {
                        _mapController.move(
                          _destination ?? _userPosition!,
                          14,
                        );
                      } else {
                        _goToMyLocation();
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}@2x?access_token=${Env.mapboxAccessToken}',
                      tileProvider: NetworkTileProvider(),
                      userAgentPackageName: 'com.example.flutter_application_1',
                      maxZoom: 18,
                      maxNativeZoom: 18,
                    ),
                    PolylineLayer(
                      polylines: [
                        if (_routePoints.isNotEmpty)
                          Polyline(
                            points: _routePoints,
                            color: colorScheme.primary,
                            strokeWidth: 4.5,
                          ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        if (_userPosition != null &&
                            _mapMode == MapMode.navigateToCustomer)
                          Marker(
                            width: 48,
                            height: 48,
                            point: _userPosition!,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.navigation_rounded,
                                color: colorScheme.onPrimary,
                                size: 24,
                              ),
                            ),
                          ),
                        if (_technicianPosition != null &&
                            _mapMode == MapMode.trackTechnician)
                          Marker(
                            width: 48,
                            height: 48,
                            point: _technicianPosition!,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.engineering_rounded,
                                color: colorScheme.onPrimary,
                                size: 24,
                              ),
                            ),
                          ),
                        if (_destination != null &&
                            _mapMode != MapMode.selectLocation)
                          Marker(
                            width: 48,
                            height: 48,
                            point: _destination!,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.flag_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (_mapMode == MapMode.selectLocation)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: Colors.red,
                        size: 44,
                      ),
                    ),
                  ),
                // Premium Info Card
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, -30 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _InfoColumn(
                                    label: 'Distance',
                                    value: _distanceText.isNotEmpty
                                        ? _distanceText
                                        : '--',
                                    icon: Icons.straighten_rounded,
                                    iconColor: colorScheme.primary,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                Expanded(
                                  child: _InfoColumn(
                                    label: 'ETA',
                                    value: _durationText.isNotEmpty
                                        ? _durationText
                                        : '--',
                                    icon: Icons.access_time_rounded,
                                    iconColor: Colors.orange,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.my_location_rounded,
                                      color: colorScheme.primary,
                                    ),
                                    onPressed: _goToMyLocation,
                                    tooltip: 'My Location',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_mapMode == MapMode.selectLocation)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : _confirmLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                elevation: 8,
                                shadowColor: colorScheme.primary.withValues(
                                  alpha: 0.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          size: 22,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Confirm Location',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}

/// Typed arguments for MapScreen
class MapScreenArgs {
  const MapScreenArgs({
    required this.car,
    required this.serviceType,
    required this.description,
    this.imageUrl,
    this.tracking = false,
    this.navigateCustomer = false,
    this.order,
    this.latitude,
    this.longitude,
  });

  final Car car;
  final String serviceType;
  final String description;
  final String? imageUrl;

  // For tracking/navigation modes
  final bool tracking;
  final bool navigateCustomer;
  final Order? order;
  final double? latitude;
  final double? longitude;
}
