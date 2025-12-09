import '../../features/auth/data/repositories/auth_repository.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final AuthRepository _authRepository = AuthRepository();

  // Get current user ID
  Future<int?> getCurrentUserId() async {
    return await _authRepository.getCurrentUserId();
  }

  // Get current couple ID
  Future<int?> getCurrentCoupleId() async {
    return await _authRepository.getCurrentCoupleId();
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    return await _authRepository.getCurrentUserData();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _authRepository.isLoggedIn();
  }
}
