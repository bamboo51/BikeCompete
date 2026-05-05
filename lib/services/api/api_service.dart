import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/account_model.dart';
import '../../models/error_response.dart';
import '../auth_service.dart';
import '../../models/home_model.dart';
import '../../models/leaderboard_user_model.dart';
import '../../models/ride_model.dart';
import '../../models/task_complete_model.dart';
import '../../models/tracking_model.dart';
import 'account_api.dart';
import 'debug_api.dart';
import 'home_api.dart';
import 'leaderboard_api.dart';
import 'ride_api.dart';
import 'task_api.dart';
import 'tracking_api.dart';

class ApiClient {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get defaultBaseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }

    return 'http://localhost:3000/api';
  }

  final String baseUrl;
  final http.Client _httpClient;

  ApiClient({String? baseUrl, http.Client? httpClient})
    : baseUrl = baseUrl ?? defaultBaseUrl,
      _httpClient = httpClient ?? http.Client();

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (AuthService.instance.token != null)
      'Authorization': 'Bearer ${AuthService.instance.token}',
  };

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await _httpClient.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _decodeObjectResponse('GET', endpoint, response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _decodeObjectResponse('POST', endpoint, response);
  }

  Map<String, dynamic> _decodeObjectResponse(
    String method,
    String endpoint,
    http.Response response,
  ) {
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    final body = decoded is Map<String, dynamic>
        ? decoded
        : decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : throw FormatException(
            '$method $endpoint returned a non-object JSON response.',
          );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      ErrorResponse? error;
      try {
        error = ErrorResponse.fromJson(body);
      } on FormatException {
        error = null;
      }

      throw ApiException(
        method: method,
        endpoint: endpoint,
        statusCode: response.statusCode,
        error: error,
      );
    }

    return body;
  }
}

class ApiException implements Exception {
  final String method;
  final String endpoint;
  final int statusCode;
  final ErrorResponse? error;

  const ApiException({
    required this.method,
    required this.endpoint,
    required this.statusCode,
    this.error,
  });

  @override
  String toString() {
    final message = error?.error;
    if (message == null || message.isEmpty) {
      return '$method $endpoint failed: $statusCode';
    }

    return '$method $endpoint failed: $statusCode ($message)';
  }
}

class ApiService {
  final HomeApi homeApi;
  final LeaderboardApi leaderboardApi;
  final AccountApi accountApi;
  final RideApi rideApi;
  final TrackingApi trackingApi;
  final TaskApi taskApi;
  final DebugApi debugApi;

  ApiService({ApiClient? apiClient}) : this._(apiClient ?? ApiClient());

  ApiService._(ApiClient apiClient)
    : homeApi = HomeApi(apiClient),
      leaderboardApi = LeaderboardApi(apiClient),
      accountApi = AccountApi(apiClient),
      rideApi = RideApi(apiClient),
      trackingApi = TrackingApi(apiClient),
      taskApi = TaskApi(apiClient),
      debugApi = DebugApi(apiClient);

  Future<HomeResponse> getHomeData() => homeApi.getHomeData();

  Future<HomeResponse> fetchHomeData() => getHomeData();

  Future<LeaderboardResponse> getLeaderboard() {
    return leaderboardApi.getLeaderboard();
  }

  Future<AccountResponse> getAccount() => accountApi.getAccount();

  Future<AccountResponse> fetchAccount() => getAccount();

  Future<RideStartResponse> startRide(RideStartRequest request) {
    return rideApi.startRide(request);
  }

  Future<TrackingResponse> sendTrackingData(TrackingRequest request) {
    return trackingApi.sendTrackingData(request);
  }

  Future<RideStopResponse> stopRide(RideStopRequest request) {
    return rideApi.stopRide(request);
  }

  Future<TaskCompleteResponse> completeTask(TaskCompleteRequest request) {
    return taskApi.completeTask(request);
  }

  Future<DebugTrackingResponse> getDebugTrackingData() {
    return debugApi.getDebugTrackingData();
  }
}
