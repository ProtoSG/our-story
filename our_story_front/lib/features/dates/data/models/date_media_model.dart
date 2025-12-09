class DateMediaModel {
  final int? id;
  final int dateId;
  final String mediaType;
  final String mediaUrl;
  final String fileName;
  final int? fileSize;
  final int uploadedBy;
  final int? orderIndex;
  final String? thumbnailUrl;
  final DateTime? uploadedAt;

  DateMediaModel({
    this.id,
    required this.dateId,
    required this.mediaType,
    required this.mediaUrl,
    required this.fileName,
    this.fileSize,
    required this.uploadedBy,
    this.orderIndex,
    this.thumbnailUrl,
    this.uploadedAt,
  });

  factory DateMediaModel.fromJson(Map<String, dynamic> json) {
    return DateMediaModel(
      id: json['id'],
      dateId: json['dateId'],
      mediaType: json['mediaType'],
      mediaUrl: json['mediaUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      uploadedBy: json['uploadedBy'],
      orderIndex: json['orderIndex'],
      thumbnailUrl: json['thumbnailUrl'],
      uploadedAt: json['uploadedAt'] != null 
          ? DateTime.parse(json['uploadedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateId': dateId,
      'mediaType': mediaType,
      'mediaUrl': mediaUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'uploadedBy': uploadedBy,
      'orderIndex': orderIndex,
      'thumbnailUrl': thumbnailUrl,
      'uploadedAt': uploadedAt?.toIso8601String(),
    };
  }

  bool get isImage => mediaType == 'IMAGE';
  bool get isVideo => mediaType == 'VIDEO';
}
