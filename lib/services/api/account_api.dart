import '../../models/account_model.dart';
import 'api_service.dart';

class AccountApi {
  final ApiClient apiClient;

  AccountApi(this.apiClient);

  Future<AccountResponse> getAccount() async {
    return AccountModel.fromJson(await apiClient.get('/account'));
  }

  Future<AccountResponse> fetchAccount() => getAccount();
}
