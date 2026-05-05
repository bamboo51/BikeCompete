import '../../models/leaderboard_user_model.dart';
import 'api_service.dart';

class LeaderboardApi {
  final ApiClient apiClient;

  LeaderboardApi(this.apiClient);

  Future<LeaderboardResponse> getLeaderboard() async {
    return LeaderboardResponse.fromJson(await apiClient.get('/leaderboard'));
  }
}
