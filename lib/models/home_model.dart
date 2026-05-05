import 'json_helpers.dart';
import 'task_model.dart';

class HomeResponse {
  final int totalPoints;
  final double co2SavedKg;
  final double weeklyDistanceKm;
  final double weeklyGoalKm;
  final List<TaskModel> tasks;

  const HomeResponse({
    required this.totalPoints,
    required this.co2SavedKg,
    required this.weeklyDistanceKm,
    required this.weeklyGoalKm,
    required this.tasks,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      totalPoints: jsonInt(json, 'totalPoints'),
      co2SavedKg: jsonDouble(json, 'co2SavedKg'),
      weeklyDistanceKm: jsonDouble(json, 'weeklyDistanceKm'),
      weeklyGoalKm: jsonDouble(json, 'weeklyGoalKm'),
      tasks: jsonList(json, 'tasks')
          .map((item) => TaskModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'co2SavedKg': co2SavedKg,
      'weeklyDistanceKm': weeklyDistanceKm,
      'weeklyGoalKm': weeklyGoalKm,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }
}
