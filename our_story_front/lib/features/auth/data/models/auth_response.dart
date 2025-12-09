class AuthResponse {
  final int userId;
  final String username;
  final String firstName;
  final String lastName;
  final int? coupleId;
  final bool hasActiveCouple;
  final String token;
  final String? refreshToken;

  AuthResponse({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.coupleId,
    required this.hasActiveCouple,
    required this.token,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] ?? 0,
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      coupleId: json['coupleId'],
      hasActiveCouple: json['hasActiveCouple'] ?? false,
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      if (coupleId != null) 'coupleId': coupleId,
      'hasActiveCouple': hasActiveCouple,
      'token': token,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }

  String get fullName => '$firstName $lastName';
}
