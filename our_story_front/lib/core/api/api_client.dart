import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _authToken;

  // Get auth token
  Future<String?> getAuthToken() async {
    if (_authToken != null) return _authToken;
    
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    return _authToken;
  }

  // Save auth token
  Future<void> saveAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear auth token
  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(ApiConstants.headers);
    final token = await getAuthToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // GET request
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    
    try {
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(ApiConstants.connectionTimeout);
      
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST request
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    
    print('🔵 POST Request: $url');
    print('🔵 Headers: ${_sanitizeHeaders(headers)}');
    print('🔵 Body: ${body != null ? json.encode(body) : 'null'}');
    
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ).timeout(ApiConstants.connectionTimeout);
      
      print('✅ Response Status: ${response.statusCode}');
      print('✅ Response Body: ${response.body}');
      
      return response;
    } catch (e) {
      print('❌ Network Error: $e');
      print('❌ Error Type: ${e.runtimeType}');
      throw Exception('Network error: $e');
    }
  }

  // Sanitize headers for logging (hide full token)
  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);
    if (sanitized.containsKey('Authorization')) {
      final token = sanitized['Authorization']!;
      if (token.startsWith('Bearer ')) {
        final actualToken = token.substring(7);
        sanitized['Authorization'] = 'Bearer ${actualToken.substring(0, 20)}...';
      }
    }
    return sanitized;
  }

  // PUT request
  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: body != null ? json.encode(body) : null,
      ).timeout(ApiConstants.connectionTimeout);
      
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE request
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    
    try {
      final response = await http.delete(
        url,
        headers: headers,
      ).timeout(ApiConstants.connectionTimeout);
      
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Handle response
  dynamic handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Unauthorized - clear token
      clearAuthToken();
      throw Exception('Unauthorized. Please login again.');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found');
    } else if (response.statusCode >= 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }
}
