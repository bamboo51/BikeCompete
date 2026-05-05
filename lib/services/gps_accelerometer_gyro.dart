import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/tracking_model.dart';

/// A single point-in-time reading from all sensors.
class SensorSnapshot {
  final GpsData? gps;
  final Vector3Data accelerometer;
  final Vector3Data gyroscope;
  final DateTime timestamp;

  const SensorSnapshot({
    this.gps,
    required this.accelerometer,
    required this.gyroscope,
    required this.timestamp,
  });

  bool get hasGps => gps != null;

  /// Convert to a [TrackingRequest] ready to send to the backend.
  /// Only call this when [hasGps] is true.
  TrackingRequest toTrackingRequest(String rideId) {
    assert(hasGps, 'Cannot build TrackingRequest without GPS data');
    return TrackingRequest(
      rideId: rideId,
      timestamp: timestamp,
      gps: gps!,
      accelerometer: accelerometer,
      gyroscope: gyroscope,
    );
  }
}

/// Singleton service that reads GPS, accelerometer, and gyroscope and
/// exposes a combined stream of [SensorSnapshot]s.
///
/// Usage:
///   await SensorService.instance.start();
///   SensorService.instance.snapshots.listen((snap) { ... });
///   SensorService.instance.stop();
class SensorService {
  SensorService._();
  static final SensorService instance = SensorService._();

  final _controller = StreamController<SensorSnapshot>.broadcast();

  Vector3Data _latestAccel = const Vector3Data(x: 0, y: 0, z: 0);
  Vector3Data _latestGyro = const Vector3Data(x: 0, y: 0, z: 0);
  GpsData? _latestGps;
  SensorSnapshot? _latestSnapshot;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<Position>? _gpsSub;

  /// The combined stream — emits every time a new GPS position arrives,
  /// carrying the latest accelerometer and gyroscope readings.
  Stream<SensorSnapshot> get snapshots => _controller.stream;

  /// The last emitted snapshot, or null before the first GPS fix.
  SensorSnapshot? get latest => _latestSnapshot;

  bool get isRunning => _accelSub != null;

  /// Request location permission from the OS.
  /// Returns true if permission was granted.
  Future<bool> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Start all sensors. Safe to call multiple times (no-op if already running).
  Future<void> start() async {
    if (isRunning) return;

    _accelSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.normalInterval,
    ).listen((event) {
      _latestAccel = Vector3Data(x: event.x, y: event.y, z: event.z);
    });

    _gyroSub = gyroscopeEventStream(
      samplingPeriod: SensorInterval.normalInterval,
    ).listen((event) {
      _latestGyro = Vector3Data(x: event.x, y: event.y, z: event.z);
    });

    final hasGps = await requestPermission();
    if (hasGps) {
      _gpsSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // emit every 5 metres
        ),
      ).listen(_onPosition);
    }
  }

  /// Stop all sensors and clear subscriptions.
  void stop() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _gpsSub?.cancel();
    _accelSub = null;
    _gyroSub = null;
    _gpsSub = null;
  }

  /// Release resources entirely. Do not use the service after calling this.
  void dispose() {
    stop();
    _controller.close();
  }

  void _onPosition(Position pos) {
    _latestGps = GpsData(
      latitude: pos.latitude,
      longitude: pos.longitude,
      speed: pos.speed,
      accuracy: pos.accuracy,
    );
    _emit();
  }

  void _emit() {
    final snapshot = SensorSnapshot(
      gps: _latestGps,
      accelerometer: _latestAccel,
      gyroscope: _latestGyro,
      timestamp: DateTime.now().toUtc(),
    );
    _latestSnapshot = snapshot;
    if (!_controller.isClosed) _controller.add(snapshot);
  }
}
