import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/core/env/env.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/features/auth/controllers/registration_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_button.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';

enum MapMode { selectLocation, trackTechnician, navigateToCustomer }

class MapScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> requestData;
  const MapScreen({super.key, required this.requestData});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  // ==================================================
  // CONSTANTS
  // ==================================================
  static final LatLngBounds _cairoGizaBounds = LatLngBounds.fromPoints([
    const ll.LatLng(29.1000, 30.7000), // SouthWest
    const ll.LatLng(30.5000, 32.0000), // NorthEast
  ]);
  // ==================================================
  // STATE
  // ==================================================
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

  // ==================================================
  // LIFECYCLE
  // ==================================================
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

  // ==================================================
  // INITIALIZATION
  // ==================================================
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

    if (widget.requestData['tracking'] == true) {
      _mapMode = MapMode.trackTechnician;
      final order = widget.requestData['order'] as Map<String, dynamic>?;
      if (order != null) {
        _destination = ll.LatLng(
          (order['latitude'] as num?)?.toDouble() ?? 0.0,
          (order['longitude'] as num?)?.toDouble() ?? 0.0,
        );
        final techId = order['technician_id']?.toString() ?? '';
        await _subscribeToTechnicianUpdates(techId);
        _routeRefreshTimer = Timer.periodic(
          const Duration(seconds: 12),
          (_) => _refreshRoute(
            origin: _technicianPosition,
            destination: _destination,
          ),
        );
      }
    } else if (widget.requestData['navigateCustomer'] == true) {
      _mapMode = MapMode.navigateToCustomer;
      _destination = ll.LatLng(
        (widget.requestData['latitude'] as num?)?.toDouble() ?? 0.0,
        (widget.requestData['longitude'] as num?)?.toDouble() ?? 0.0,
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
        _mapController.move(_destination ?? _userPosition!, 14.0);
      }
    }
  }

  // ==================================================
  // PERMISSIONS & LOCATION
  // ==================================================
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
    } catch (e) {
      AppSnackbar.showError(
        context,
        message: 'Unable to get current position.',
      );
      return null;
    }
  }

  bool _isInsideAllowedBounds(ll.LatLng point) {
    return _cairoGizaBounds.contains(point);
  }

  // ==================================================
  // TRACKING
  // ==================================================
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
    _positionSubscription = Geolocator.getPositionStream(
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

  // ==================================================
  // ROUTING
  // ==================================================
  Future<void> _refreshRoute({
    ll.LatLng? origin,
    ll.LatLng? destination,
  }) async {
    if (origin == null || destination == null) {
      debugPrint("[MAP ROUTE] Skipped: origin or destination is null");
      return;
    }
    final token = Env.mapboxAccessToken;
    if (token.isEmpty) {
      debugPrint("[MAP ROUTE] Skipped: Mapbox token is empty");
      return;
    }

    final lon1 = origin.longitude;
    final lat1 = origin.latitude;
    final lon2 = destination.longitude;
    final lat2 = destination.latitude;

    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/$lon1,$lat1;$lon2,$lat2';
    debugPrint("[MAP ROUTE] Request URL: $url");
    debugPrint("[MAP ROUTE] Origin: $lat1,$lon1 Destination: $lat2,$lon2");

    try {
      final resp = await Dio().get(url, queryParameters: {
        'geometries': 'polyline6',
        'overview': 'full',
        'steps': 'false',
        'access_token': token,
      });

      debugPrint("[MAP ROUTE] HTTP status: ${resp.statusCode}");
      debugPrint("[MAP ROUTE] Response body: ${resp.data}");

      final data = resp.data as Map<String, dynamic>?;
      final routes = data?['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        debugPrint("[MAP ROUTE] No routes found in response");
        return;
      }

      final route = routes[0];
      final geometry = route['geometry'] as String?;
      debugPrint("[MAP ROUTE] route['distance'] = ${route['distance']}");
      debugPrint("[MAP ROUTE] route['duration'] = ${route['duration']}");
      final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 0.0;
      final durationSeconds = (route['duration'] as num?)?.toDouble() ?? 0.0;

      debugPrint("[MAP ROUTE] distanceMeters = $distanceMeters, durationSeconds = $durationSeconds");
      final distanceKm = distanceMeters / 1000;
      final durationMin = (durationSeconds / 60).round();
      final etaText = '$durationMin min';
      debugPrint("[MAP ROUTE] computed distanceKm = $distanceKm, etaText = $etaText");
      debugPrint("[MAP ROUTE] _distanceText before setState = $_distanceText, _durationText before setState = $_durationText");

      if (geometry == null) {
        debugPrint("[MAP ROUTE] No geometry in route");
        return;
      }

      final points = _decodePolyline(geometry, 1000000);
      debugPrint("[MAP ROUTE] Decoded ${points.length} polyline points");

      if (mounted) {
        setState(() {
          _routePoints
            ..clear()
            ..addAll(points);
          _distanceText = '${distanceKm.toStringAsFixed(1)} km';
          _durationText = etaText;
        });
        debugPrint("[MAP ROUTE] _distanceText after setState = $_distanceText, _durationText after setState = $_durationText");
      }
    } catch (e) {
      debugPrint("[MAP ROUTE] Request failed: $e");
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

  void _calculateDistanceAndEta(double distanceMeters, double durationSeconds) {
    if (!mounted) return;
    final distanceKm = distanceMeters / 1000;
    final durationMin = (durationSeconds / 60).round();

    _distanceText = '${distanceKm.toStringAsFixed(1)} km';
    _durationText = '$durationMin min';
  }

  // ==================================================
  // CAMERA
  // ==================================================
  void _fitBounds() {
    if (!mounted) return;

    final rawPoints = <ll.LatLng>[
      if (_userPosition != null) _userPosition!,
      if (_technicianPosition != null) _technicianPosition!,
      if (_destination != null) _destination!,
    ].where((p) => p.latitude != 0.0 && p.longitude != 0.0).toList();

    final uniquePoints = <ll.LatLng>[];
    for (final p in rawPoints) {
      if (!uniquePoints
          .any((u) => u.latitude == p.latitude && u.longitude == p.longitude)) {
        uniquePoints.add(p);
      }
    }

    if (uniquePoints.isEmpty) return;

    if (uniquePoints.length == 1) {
      _mapController.move(uniquePoints.first, 15.0);
      return;
    }

    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(uniquePoints),
          padding: const EdgeInsets.all(60.0),
          maxZoom: 17.0,
        ),
      );
    } catch (_) {
      // Fallback in case of bounds generation exception
    }
  }

  Future<void> _goToMyLocation() async {
    if (_userPosition != null) {
      _mapController.move(_userPosition!, 15.0);
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
        _mapController.move(latLng, 15.0);
      }
    }
  }

  // ==================================================
  // HELPERS
  // ==================================================
  Future<void> _confirmLocation() async {
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
        message: "Please select a location inside Cairo or Giza.",
      );
      return;
    }

    final user = ref.read(authStateChangesProvider).valueOrNull;
    if (user == null) return;

    final car = widget.requestData['car'] as Map<String, dynamic>;
    final carId = car['id'].toString();
    final serviceType = widget.requestData['serviceType'] as String;
    final description = widget.requestData['description'] as String;
    final imageUrl = widget.requestData['imageUrl'] as String?;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(registrationControllerProvider.notifier).createOrder(
            clientId: user.id,
            carId: carId,
            serviceType: serviceType,
            description: description,
            imageUrl: imageUrl,
            latitude: _destination!.latitude,
            longitude: _destination!.longitude,
          );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppSnackbar.showError(context, message: 'Failed to create order: $e');
      }
    }
  }

  // ==================================================
  // UI & BUILD
  // ==================================================
  @override
  Widget build(BuildContext context) {
    debugPrint("[MAP ROUTE] build() _distanceText='$_distanceText' _durationText='$_durationText'");
    ref.listen<AsyncValue<RegistrationResult?>>(
      registrationControllerProvider,
      (_, state) {
        state.when(
          data: (result) {
            if (_isSubmitting && result == null) {
              setState(() => _isSubmitting = false);
              if (mounted) {
                AppSnackbar.showSuccess(
                  context,
                  message: 'Order created successfully!',
                );
                context.go(AppRoutes.orders);
              }
            }
          },
          error: (error, _) {
            setState(() => _isSubmitting = false);
            if (mounted) {
              AppSnackbar.showError(context, message: error.toString());
            }
          },
          loading: () {},
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _mapMode == MapMode.selectLocation
              ? 'Select Location'
              : 'Live Tracking',
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: AppLoader(message: 'Loading map...'))
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _destination ??
                        _userPosition ??
                        const ll.LatLng(30.0444, 31.2357),
                    initialZoom: 14.0,
                    minZoom: 9.0,
                    maxZoom: 18.0,
                    cameraConstraint: CameraConstraint.contain(
                      bounds: _cairoGizaBounds,
                    ),
                    interactionOptions: _mapMode == MapMode.selectLocation
                        ? const InteractionOptions(flags: InteractiveFlag.all)
                        : const InteractionOptions(
                            flags: InteractiveFlag.pinchZoom |
                                InteractiveFlag.drag,
                          ),
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture && _mapMode == MapMode.selectLocation) {
                        if (position.center != null) {
                          setState(() => _destination = position.center);
                        }
                      }
                    },
                    onMapReady: () {
                      setState(() => _isMapReady = true);
                      if (_destination != null || _userPosition != null) {
                        _mapController.move(
                          _destination ?? _userPosition!,
                          14.0,
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
                            color: AppColors.primary,
                            strokeWidth: 4.5,
                          ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        if (_userPosition != null &&
                            _mapMode == MapMode.navigateToCustomer)
                          Marker(
                            width: 40,
                            height: 40,
                            point: _userPosition!,
                            child: const Icon(
                              Icons.navigation,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                        if (_technicianPosition != null &&
                            _mapMode == MapMode.trackTechnician)
                          Marker(
                            width: 40,
                            height: 40,
                            point: _technicianPosition!,
                            child: const Icon(
                              Icons.engineering,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                        if (_destination != null &&
                            _mapMode != MapMode.selectLocation)
                          Marker(
                            width: 40,
                            height: 40,
                            point: _destination!,
                            child: const Icon(
                              Icons.flag,
                              color: Colors.red,
                              size: 40,
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
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Distance',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _distanceText.isNotEmpty
                                          ? _distanceText
                                          : '--',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'ETA',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _durationText.isNotEmpty
                                          ? _durationText
                                          : '--',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.my_location,
                                    color: AppColors.primary,
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
                if (_mapMode == MapMode.selectLocation)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            onPressed:
                                _isSubmitting ? null : _confirmLocation,
                            isLoading: _isSubmitting,
                            text: _isSubmitting
                                ? 'Confirming...'
                                : 'Confirm Location',
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