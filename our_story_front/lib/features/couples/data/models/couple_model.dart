import '../../../users/data/models/user_model.dart';

class CoupleModel {
  final int id;
  final UserModel user1;
  final UserModel user2;
  final String? coupleName;
  final DateTime? relationshipStart;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  CoupleModel({
    required this.id,
    required this.user1,
    required this.user2,
    this.coupleName,
    this.relationshipStart,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CoupleModel.fromJson(Map<String, dynamic> json) {
    return CoupleModel(
      id: json['id'] ?? 0,
      user1: UserModel.fromJson(json['user1']),
      user2: UserModel.fromJson(json['user2']),
      coupleName: json['coupleName'],
      relationshipStart: json['relationshipStart'] != null 
        ? DateTime.parse(json['relationshipStart']) 
        : null,
      status: json['status'] ?? 'ACTIVE',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  bool get isActive => status == 'ACTIVE';
}
