class MessageModel {
  final int? id;
  final int coupleId;
  final int senderId;
  final String senderName;
  final String content;
  final String msgType;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MessageModel({
    this.id,
    required this.coupleId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.msgType = 'TEXT',
    this.readAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Handle sender as an object or as individual fields
    int senderId;
    String senderName;
    
    if (json['sender'] != null && json['sender'] is Map) {
      // Backend format: sender is an object
      senderId = json['sender']['id'] as int;
      senderName = json['sender']['name'] as String? ?? 
                   json['sender']['username'] as String? ?? 
                   json['sender']['email'] as String? ?? 
                   'Usuario';
    } else {
      // Direct format: senderId and senderName as separate fields
      senderId = json['senderId'] as int;
      senderName = json['senderName'] as String? ?? 'Usuario';
    }

    return MessageModel(
      id: json['id'] as int?,
      coupleId: json['coupleId'] as int,
      senderId: senderId,
      senderName: senderName,
      content: json['content'] as String,
      msgType: json['msgType'] as String? ?? 'TEXT',
      readAt: json['readAT'] != null ? DateTime.parse(json['readAT']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'senderId': senderId,
      'content': content,
      'msgType': msgType,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateRequest() {
    return {
      'coupleId': coupleId,
      'senderId': senderId,
      'content': content,
      'msgType': msgType,
    };
  }

  bool get isRead => readAt != null;
  
  bool isSentByUser(int userId) => senderId == userId;
}
