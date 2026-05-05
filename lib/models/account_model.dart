import 'json_helpers.dart';

class AccountModel {
  final String userId;
  final String name;
  final String department;
  final UserStats stats;
  final List<BadgeModel> badges;

  const AccountModel({
    required this.userId,
    required this.name,
    required this.department,
    required this.stats,
    required this.badges,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      userId: jsonString(json, 'userId'),
      name: jsonString(json, 'name'),
      department: jsonString(json, 'department'),
      stats: UserStats.fromJson(jsonObject(json, 'stats')),
      badges: jsonList(json, 'badges')
          .map((item) => BadgeModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'department': department,
      'stats': stats.toJson(),
      'badges': badges.map((badge) => badge.toJson()).toList(),
    };
  }
}

typedef AccountResponse = AccountModel;

class UserStats {
  final int totalPoints;
  final double totalDistanceKm;
  final double totalCo2SavedKg;
  final int cyclingDays;

  const UserStats({
    required this.totalPoints,
    required this.totalDistanceKm,
    required this.totalCo2SavedKg,
    required this.cyclingDays,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalPoints: jsonInt(json, 'totalPoints'),
      totalDistanceKm: jsonDouble(json, 'totalDistanceKm'),
      totalCo2SavedKg: jsonDouble(json, 'totalCo2SavedKg'),
      cyclingDays: jsonInt(json, 'cyclingDays'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'totalDistanceKm': totalDistanceKm,
      'totalCo2SavedKg': totalCo2SavedKg,
      'cyclingDays': cyclingDays,
    };
  }
}

class BadgeModel {
  final String id;
  final String name;

  const BadgeModel({required this.id, required this.name});

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: jsonString(json, 'id'),
      name: jsonString(json, 'name'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
