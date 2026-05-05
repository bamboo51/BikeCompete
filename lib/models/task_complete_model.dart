import 'json_helpers.dart';

class TaskCompleteRequest {
  final String taskId;
  final DateTime? completedAt;

  const TaskCompleteRequest({required this.taskId, this.completedAt});

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      if (completedAt != null) 'completedAt': dateTimeToJson(completedAt!),
    };
  }
}

class TaskCompleteResponse {
  final String taskId;
  final bool completed;
  final DateTime completedAt;
  final int pointsEarned;

  const TaskCompleteResponse({
    required this.taskId,
    required this.completed,
    required this.completedAt,
    required this.pointsEarned,
  });

  factory TaskCompleteResponse.fromJson(Map<String, dynamic> json) {
    return TaskCompleteResponse(
      taskId: jsonString(json, 'taskId'),
      completed: jsonBool(json, 'completed'),
      completedAt: jsonDateTime(json, 'completedAt'),
      pointsEarned: jsonInt(json, 'pointsEarned'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'completed': completed,
      'completedAt': dateTimeToJson(completedAt),
      'pointsEarned': pointsEarned,
    };
  }
}
