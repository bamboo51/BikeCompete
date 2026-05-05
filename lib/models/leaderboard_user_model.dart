import 'json_helpers.dart';

class LeaderboardResponse {
  final List<WorkerLeaderboardItem> workers;
  final List<DepartmentLeaderboardItem> departments;

  const LeaderboardResponse({required this.workers, required this.departments});

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      workers: jsonList(json, 'workers')
          .map(
            (item) =>
                WorkerLeaderboardItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      departments: jsonList(json, 'departments')
          .map(
            (item) => DepartmentLeaderboardItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workers': workers.map((worker) => worker.toJson()).toList(),
      'departments': departments
          .map((department) => department.toJson())
          .toList(),
    };
  }
}

class WorkerLeaderboardItem {
  final int rank;
  final String userId;
  final String name;
  final int points;
  final double distanceKm;
  final double co2SavedKg;

  const WorkerLeaderboardItem({
    required this.rank,
    required this.userId,
    required this.name,
    required this.points,
    required this.distanceKm,
    required this.co2SavedKg,
  });

  factory WorkerLeaderboardItem.fromJson(Map<String, dynamic> json) {
    return WorkerLeaderboardItem(
      rank: jsonInt(json, 'rank'),
      userId: jsonString(json, 'userId'),
      name: jsonString(json, 'name'),
      points: jsonInt(json, 'points'),
      distanceKm: jsonDouble(json, 'distanceKm'),
      co2SavedKg: jsonDouble(json, 'co2SavedKg'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'userId': userId,
      'name': name,
      'points': points,
      'distanceKm': distanceKm,
      'co2SavedKg': co2SavedKg,
    };
  }
}

class DepartmentLeaderboardItem {
  final int rank;
  final String departmentName;
  final int points;
  final double co2SavedKg;

  const DepartmentLeaderboardItem({
    required this.rank,
    required this.departmentName,
    required this.points,
    required this.co2SavedKg,
  });

  factory DepartmentLeaderboardItem.fromJson(Map<String, dynamic> json) {
    return DepartmentLeaderboardItem(
      rank: jsonInt(json, 'rank'),
      departmentName: jsonString(json, 'departmentName'),
      points: jsonInt(json, 'points'),
      co2SavedKg: jsonDouble(json, 'co2SavedKg'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'departmentName': departmentName,
      'points': points,
      'co2SavedKg': co2SavedKg,
    };
  }
}

typedef LeaderboardUserModel = WorkerLeaderboardItem;
