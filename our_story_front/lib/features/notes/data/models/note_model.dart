import '../../../users/data/models/user_model.dart';

class NoteModel {
  final int? id;
  final String title;
  final String content;
  final String? color;
  final bool? isPinned;
  final String? sticker;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? coupleId;
  final UserModel? createdBy;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    this.color,
    this.isPinned,
    this.sticker,
    this.createdAt,
    this.updatedAt,
    this.coupleId,
    this.createdBy,
  });

  // From JSON
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      color: json['color'],
      isPinned: json['isPinned'] ?? false,
      sticker: json['sticker'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      coupleId: json['coupleId'],
      createdBy: json['createdBy'] != null
          ? UserModel.fromJson(json['createdBy'])
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
      'isPinned': isPinned,
      'sticker': sticker,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'coupleId': coupleId,
      'createdBy': createdBy?.toJson(),
    };
  }

  // To create request (without id and timestamps)
  Map<String, dynamic> toCreateRequest() {
    return {
      'title': title,
      'content': content,
      'color': color,
      'isPinned': isPinned ?? false,
      'sticker': sticker,
    };
  }

  // To update request
  Map<String, dynamic> toUpdateRequest() {
    return {
      'title': title,
      'content': content,
      'color': color,
      'isPinned': isPinned,
      'sticker': sticker,
    };
  }

  // Copy with
  NoteModel copyWith({
    int? id,
    String? title,
    String? content,
    String? color,
    bool? isPinned,
    String? sticker,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? coupleId,
    UserModel? createdBy,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      sticker: sticker ?? this.sticker,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coupleId: coupleId ?? this.coupleId,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
