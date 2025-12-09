class TypingNotification {
  final int userId;
  final int coupleId;
  final bool isTyping;

  TypingNotification({
    required this.userId,
    required this.coupleId,
    required this.isTyping,
  });

  factory TypingNotification.fromJson(Map<String, dynamic> json) {
    return TypingNotification(
      userId: json['userId'],
      coupleId: json['coupleId'],
      isTyping: json['isTyping'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'coupleId': coupleId,
      'isTyping': isTyping,
    };
  }
}
