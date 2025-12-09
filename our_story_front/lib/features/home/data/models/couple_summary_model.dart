class CoupleSummaryModel {
  final int id;
  final String coupleName;
  final String? coupleImage;
  final int daysTogether;

  CoupleSummaryModel({
    required this.id,
    required this.coupleName, 
    this.coupleImage, 
    required this.daysTogether
  });

  factory CoupleSummaryModel.fromJson(Map<String, dynamic> json) {
    return CoupleSummaryModel(
      id: json['id'] as int,
      coupleName: json['coupleName'] as String, 
      daysTogether: json['daysTogether'] as int? ?? 0,
      coupleImage: json['coupleImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleName': coupleName,
      'coupleImage': coupleImage,
      'daysTogether': daysTogether
    };
  }

  String get daysTogetherText {
    if (daysTogether == 0) return "¡HOY COMENZAMOS!";
    if (daysTogether == 1) return "¡1 DÏA JUNTOS!";
    return "¡$daysTogether DÍAS JUNTOS!";
  }
}
