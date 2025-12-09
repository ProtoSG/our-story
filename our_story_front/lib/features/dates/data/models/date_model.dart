import '../../../users/data/models/user_model.dart';

class DateModel {
  final int? id;
  final int? coupleId;
  final UserModel? createdBy;
  final String title;
  final String description;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime? date;
  final String? dateImage;
  final int? rating;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DateModel({
    this.id,
    this.coupleId,
    this.createdBy,
    required this.title,
    required this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.date,
    this.dateImage,
    this.rating,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  // From JSON
  factory DateModel.fromJson(Map<String, dynamic> json) {
    return DateModel(
      id: json['id'] as int?,
      coupleId: json['coupleId'] as int?,
      createdBy: json['createdBy'] != null
          ? UserModel.fromJson(json['createdBy'] as Map<String, dynamic>)
          : null,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      dateImage: json['dateImage'] as String?,
      rating: json['rating'] as int?,
      category: json['category'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'title': title,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'date': date?.toIso8601String().split('T')[0], // Solo fecha, sin hora
      'dateImage': dateImage,
      'rating': rating,
      'category': category,
    };
  }

  // To Create Request (para POST)
  Map<String, dynamic> toCreateRequest() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'date': date?.toIso8601String().split('T')[0],
      'dateImage': dateImage,
      'rating': rating,
      'category': category,
    };
  }

  // To Update Request (para PUT)
  Map<String, dynamic> toUpdateRequest() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'date': date?.toIso8601String().split('T')[0],
      'dateImage': dateImage,
      'rating': rating,
      'category': category,
    };
  }

  // CopyWith
  DateModel copyWith({
    int? id,
    int? coupleId,
    UserModel? createdBy,
    String? title,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? date,
    String? dateImage,
    int? rating,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DateModel(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      createdBy: createdBy ?? this.createdBy,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      date: date ?? this.date,
      dateImage: dateImage ?? this.dateImage,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
