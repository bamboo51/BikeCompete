import '../../models/ride_model.dart';
import 'api_service.dart';

class RideApi {
  final ApiClient apiClient;

  RideApi(this.apiClient);

  Future<RideStartResponse> startRide(RideStartRequest request) async {
    return RideStartResponse.fromJson(
      await apiClient.post('/ride/start', request.toJson()),
    );
  }

  Future<RideStopResponse> stopRide(RideStopRequest request) async {
    return RideStopResponse.fromJson(
      await apiClient.post('/ride/stop', request.toJson()),
    );
  }
}
