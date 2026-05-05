import '../../models/tracking_model.dart';
import 'api_service.dart';

class TrackingApi {
  final ApiClient apiClient;

  TrackingApi(this.apiClient);

  Future<TrackingResponse> sendTrackingData(TrackingRequest request) async {
    return TrackingResponse.fromJson(
      await apiClient.post('/tracking', request.toJson()),
    );
  }
}
