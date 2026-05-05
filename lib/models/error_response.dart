import 'json_helpers.dart';

class ErrorResponse {
  final String error;

  const ErrorResponse({required this.error});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(error: jsonString(json, 'error'));
  }

  Map<String, dynamic> toJson() {
    return {'error': error};
  }
}
