import '../../models/tracking_model.dart';
import 'api_service.dart';

class DebugApi {
  final ApiClient apiClient;

  DebugApi(this.apiClient);

  Future<DebugTrackingResponse> getDebugTrackingData() async {
    return DebugTrackingResponse.fromJson(
      await apiClient.get('/debug/tracking'),
    );
  }
}
