class RegisterRequest {
  final String username;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final String? avatarUrl;

  RegisterRequest({
    required this.username,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'passwordHash': passwordHash,
      'firstName': firstName,
      'lastName': lastName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }
}
