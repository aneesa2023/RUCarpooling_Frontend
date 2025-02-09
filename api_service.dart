import 'dart:convert';
import 'package:ru_carpooling/config/api_config.dart';
import 'package:ru_carpooling/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  /// Select the correct base URL based on the `module`
  static String _getBaseUrl(String module) {
    switch (module) {
      case 'auth':
        return ApiConfig.authBaseUrl;
      case 'user':
        return ApiConfig.userBaseUrl;
      case 'cars':
        return ApiConfig.carsBaseUrl;
      case 'post_ride':
        return ApiConfig.postRideBaseUrl;
      case 'search_ride':
        return ApiConfig.searchRideBaseUrl;
      case 'request_ride':
        return ApiConfig.requestRideBaseUrl;
      case 'gorq_api':
        return ApiConfig.gorqBaseUrl;
      default:
        throw Exception("Invalid APIx module: $module");
    }
  }

  /// POST Request
  static Future<Map<String, dynamic>> postRequest(
      {required String module,
      required String endpoint,
      required Map<String, dynamic> body}) async {
    final String baseUrl = _getBaseUrl(module);
    final Uri url = Uri.parse("$baseUrl$endpoint");

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(), // Include auth token
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception("Failed to connect to server: $e");
    }
  }

  /// GET Request
  static Future<Map<String, dynamic>> getRequest(
      {required String module, required String endpoint}) async {
    final String baseUrl = _getBaseUrl(module);
    final Uri url = Uri.parse("$baseUrl$endpoint");

    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception("Failed to connect to server: $e");
    }
  }

  static Future<Map<String, dynamic>> putRequest({
    required String module,
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final String baseUrl = _getBaseUrl(module);
    final Uri url = Uri.parse("$baseUrl$endpoint");

    try {
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception("Failed to connect to server: $e");
    }
  }

  /// DELETE Request
  static Future<Map<String, dynamic>> deleteRequest(
      {required String module, required String endpoint}) async {
    final String baseUrl = _getBaseUrl(module);
    final Uri url = Uri.parse("$baseUrl$endpoint");

    try {
      final response = await http.delete(
        url,
        headers: await _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception("Failed to connect to server: $e");
    }
  }

  /// Get headers (Includes Authorization if token is available)
  static Future<Map<String, String>> _getHeaders() async {
    String? token = await AuthService.getToken(); // Get token if available
    return {
      "Content-Type": "application/json",
      if (token != null)
        "Authorization": "Bearer $token", // Include token if present
    };
  }

  /// Handle API Responses
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Error: ${jsonDecode(response.body)['message'] ?? response.body}");
    }
  }
}
