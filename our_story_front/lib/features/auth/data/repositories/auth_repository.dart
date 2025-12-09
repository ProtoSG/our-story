import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/auth_response.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final String _apiAuth = ApiConstants.auth;

  // Keys for SharedPreferences
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _firstNameKey = 'user_first_name';
  static const String _lastNameKey = 'user_last_name';
  static const String _coupleIdKey = 'couple_id';


  Future<AuthResponse> login(LoginRequest request) async {
    try {
      // Clear any existing session first
      await _apiClient.clearAuthToken();
      await _clearUserData();

      final response = await _apiClient.post(
        "$_apiAuth/login",
        body: request.toJson(),
      );

      final data = _apiClient.handleResponse(response);
      final authResponse = AuthResponse.fromJson(data);

      await _apiClient.saveAuthToken(authResponse.token);
      await _saveUserData(authResponse);

      return authResponse;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Register
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      // Clear any existing session first
      await _apiClient.clearAuthToken();
      await _clearUserData();
      
      final response = await _apiClient.post(
        "$_apiAuth/register",
        body: request.toJson(),
      );
      final data = _apiClient.handleResponse(response);
      final authResponse = AuthResponse.fromJson(data);
      
      // Save token and user data
      await _apiClient.saveAuthToken(authResponse.token);
      await _saveUserData(authResponse);
      
      return authResponse;
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, authResponse.userId);
    await prefs.setString(_usernameKey, authResponse.username);
    await prefs.setString(_firstNameKey, authResponse.firstName);
    await prefs.setString(_lastNameKey, authResponse.lastName);
    if (authResponse.coupleId != null) {
      await prefs.setInt(_coupleIdKey, authResponse.coupleId!);
    }
  }

  // Get current user ID
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Get current couple ID
  Future<int?> getCurrentCoupleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coupleIdKey);
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);
    if (userId == null) return null;

    return {
      'userId': userId,
      'username': prefs.getString(_usernameKey),
      'firstName': prefs.getString(_firstNameKey),
      'lastName': prefs.getString(_lastNameKey),
      'coupleId': prefs.getInt(_coupleIdKey),
    };
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiClient.clearAuthToken();
      await _clearUserData();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  // Clear user data from SharedPreferences
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);
    await prefs.remove(_coupleIdKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await _apiClient.getAuthToken();
      final userId = await getCurrentUserId();
      return token != null && token.isNotEmpty && userId != null;
    } catch (e) {
      return false;
    }
  }

  // Get current username
  Future<String?> getCurrentUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_usernameKey);
    } catch (e) {
      return null;
    }
  }
}
