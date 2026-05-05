import '../../models/home_model.dart';
import 'api_service.dart';

class HomeApi {
  final ApiClient apiClient;

  HomeApi(this.apiClient);

  Future<HomeResponse> getHomeData() async {
    return HomeResponse.fromJson(await apiClient.get('/home'));
  }

  Future<HomeResponse> fetchHomeData() => getHomeData();
}
