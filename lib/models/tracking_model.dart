import 'json_helpers.dart';

class TrackingRequest {
  final String rideId;
  final DateTime timestamp;
  final GpsData gps;
  final Vector3Data accelerometer;
  final Vector3Data gyroscope;

  const TrackingRequest({
    required this.rideId,
    required this.timestamp,
    required this.gps,
    required this.accelerometer,
    required this.gyroscope,
  });

  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'timestamp': dateTimeToJson(timestamp),
      'gps': gps.toJson(),
      'accelerometer': accelerometer.toJson(),
      'gyroscope': gyroscope.toJson(),
    };
  }
}

class GpsData {
  final double latitude;
  final double longitude;
  final double speed;
  final double accuracy;

  const GpsData({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.accuracy,
  });

  factory GpsData.fromJson(Map<String, dynamic> json) {
    return GpsData(
      latitude: jsonDouble(json, 'latitude'),
      longitude: jsonDouble(json, 'longitude'),
      speed: jsonDouble(json, 'speed'),
      accuracy: jsonDouble(json, 'accuracy'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'accuracy': accuracy,
    };
  }
}

class Vector3Data {
  final double x;
  final double y;
  final double z;

  const Vector3Data({required this.x, required this.y, required this.z});

  factory Vector3Data.fromJson(Map<String, dynamic> json) {
    return Vector3Data(
      x: jsonDouble(json, 'x'),
      y: jsonDouble(json, 'y'),
      z: jsonDouble(json, 'z'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, 'z': z};
  }
}

class TrackingResponse {
  final bool success;
  final String trackingId;
  final DateTime receivedAt;

  const TrackingResponse({
    required this.success,
    required this.trackingId,
    required this.receivedAt,
  });

  factory TrackingResponse.fromJson(Map<String, dynamic> json) {
    return TrackingResponse(
      success: jsonBool(json, 'success'),
      trackingId: jsonString(json, 'trackingId'),
      receivedAt: jsonDateTime(json, 'receivedAt'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'trackingId': trackingId,
      'receivedAt': dateTimeToJson(receivedAt),
    };
  }
}

class DebugTrackingResponse {
  final int count;
  final List<TrackingDebugRecord> data;

  const DebugTrackingResponse({required this.count, required this.data});

  factory DebugTrackingResponse.fromJson(Map<String, dynamic> json) {
    return DebugTrackingResponse(
      count: jsonInt(json, 'count'),
      data: jsonList(json, 'data')
          .map(
            (item) =>
                TrackingDebugRecord.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'data': data.map((record) => record.toJson()).toList(),
    };
  }
}

class TrackingDebugRecord {
  final String trackingId;
  final String rideId;
  final DateTime timestamp;
  final GpsData gps;
  final Vector3Data accelerometer;
  final Vector3Data gyroscope;
  final DateTime receivedAt;

  const TrackingDebugRecord({
    required this.trackingId,
    required this.rideId,
    required this.timestamp,
    required this.gps,
    required this.accelerometer,
    required this.gyroscope,
    required this.receivedAt,
  });

  factory TrackingDebugRecord.fromJson(Map<String, dynamic> json) {
    return TrackingDebugRecord(
      trackingId: jsonString(json, 'trackingId'),
      rideId: jsonString(json, 'rideId'),
      timestamp: jsonDateTime(json, 'timestamp'),
      gps: GpsData.fromJson(jsonObject(json, 'gps')),
      accelerometer: Vector3Data.fromJson(jsonObject(json, 'accelerometer')),
      gyroscope: Vector3Data.fromJson(jsonObject(json, 'gyroscope')),
      receivedAt: jsonDateTime(json, 'receivedAt'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackingId': trackingId,
      'rideId': rideId,
      'timestamp': dateTimeToJson(timestamp),
      'gps': gps.toJson(),
      'accelerometer': accelerometer.toJson(),
      'gyroscope': gyroscope.toJson(),
      'receivedAt': dateTimeToJson(receivedAt),
    };
  }
}
