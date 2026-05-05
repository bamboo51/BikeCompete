import 'json_helpers.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final int points;
  final bool completed;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.completed,
  });

  bool get isDone => completed;

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: jsonString(json, 'id'),
      title: jsonString(json, 'title'),
      description: jsonString(json, 'description'),
      points: jsonInt(json, 'points'),
      completed: jsonBool(json, 'completed'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'completed': completed,
    };
  }
}
