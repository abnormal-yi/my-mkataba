import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class RiderLocation {
  final double latitude;
  final double longitude;
  final double speed;
  final DateTime timestamp;

  const RiderLocation({
    required this.latitude, required this.longitude,
    this.speed = 0, required this.timestamp,
  });

  factory RiderLocation.fromJson(Map<String, dynamic> j) => RiderLocation(
    latitude: (j['latitude'] as num).toDouble(),
    longitude: (j['longitude'] as num).toDouble(),
    speed: (j['speed'] as num?)?.toDouble() ?? 0,
    timestamp: DateTime.parse(j['timestamp']),
  );

  Map<String, dynamic> toJson() => {
    'latitude': latitude, 'longitude': longitude,
    'speed': speed, 'timestamp': timestamp.toIso8601String(),
  };
}

class LocationState {
  final RiderLocation? currentLocation;
  final bool isTracking;
  final bool isLoading;
  final String? error;
  final List<RiderLocation> locationHistory;

  const LocationState({
    this.currentLocation, this.isTracking = false, this.isLoading = false,
    this.error, this.locationHistory = const [],
  });

  LocationState copyWith({
    RiderLocation? currentLocation, bool? isTracking, bool? isLoading,
    String? error, List<RiderLocation>? locationHistory,
  }) => LocationState(
    currentLocation: currentLocation ?? this.currentLocation,
    isTracking: isTracking ?? this.isTracking,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    locationHistory: locationHistory ?? this.locationHistory,
  );
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) => LocationNotifier());

class LocationNotifier extends StateNotifier<LocationState> {
  StreamSubscription<Position>? _subscription;

  LocationNotifier() : super(const LocationState());

  Future<void> startTracking() async {
    state = state.copyWith(isTracking: true, isLoading: true, error: null);
    try {
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        state = state.copyWith(isTracking: false, isLoading: false, error: 'Location permission denied');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _addPosition(position);

      _subscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(_addPosition);
      state = state.copyWith(isTracking: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isTracking: false, isLoading: false, error: e.toString());
    }
  }

  void stopTracking() {
    _subscription?.cancel();
    _subscription = null;
    state = state.copyWith(isTracking: false);
  }

  void _addPosition(Position p) {
    final loc = RiderLocation(
      latitude: p.latitude, longitude: p.longitude,
      speed: p.speed, timestamp: DateTime.now(),
    );
    final history = List<RiderLocation>.from(state.locationHistory)..add(loc);
    if (history.length > 100) history.removeAt(0);
    state = state.copyWith(currentLocation: loc, locationHistory: history);
  }

  Future<bool> _requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    return permission != LocationPermission.deniedForever;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
