import 'json_helpers.dart';

class RideStartRequest {
  final String userId;
  final DateTime? startedAt;

  const RideStartRequest({required this.userId, this.startedAt});

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      if (startedAt != null) 'startedAt': dateTimeToJson(startedAt!),
    };
  }
}

class RideStartResponse {
  final String rideId;
  final String status;

  const RideStartResponse({required this.rideId, required this.status});

  factory RideStartResponse.fromJson(Map<String, dynamic> json) {
    return RideStartResponse(
      rideId: jsonString(json, 'rideId'),
      status: jsonString(json, 'status'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'rideId': rideId, 'status': status};
  }
}

class RideStopRequest {
  final String rideId;
  final DateTime? endedAt;

  const RideStopRequest({required this.rideId, this.endedAt});

  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      if (endedAt != null) 'endedAt': dateTimeToJson(endedAt!),
    };
  }
}

class RideStopResponse {
  final String rideId;
  final String status;
  final double distanceKm;
  final double co2SavedKg;
  final int pointsEarned;

  const RideStopResponse({
    required this.rideId,
    required this.status,
    required this.distanceKm,
    required this.co2SavedKg,
    required this.pointsEarned,
  });

  factory RideStopResponse.fromJson(Map<String, dynamic> json) {
    return RideStopResponse(
      rideId: jsonString(json, 'rideId'),
      status: jsonString(json, 'status'),
      distanceKm: jsonDouble(json, 'distanceKm'),
      co2SavedKg: jsonDouble(json, 'co2SavedKg'),
      pointsEarned: jsonInt(json, 'pointsEarned'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'status': status,
      'distanceKm': distanceKm,
      'co2SavedKg': co2SavedKg,
      'pointsEarned': pointsEarned,
    };
  }
}
