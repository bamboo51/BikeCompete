import '../../models/task_complete_model.dart';
import 'api_service.dart';

class TaskApi {
  final ApiClient apiClient;

  TaskApi(this.apiClient);

  Future<TaskCompleteResponse> completeTask(TaskCompleteRequest request) async {
    return TaskCompleteResponse.fromJson(
      await apiClient.post('/tasks/complete', request.toJson()),
    );
  }
}
