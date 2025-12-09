import 'pairing_status.dart';

class PairingResponse {
  final int id;
  final String senderUsername;
  final String recipientUsername;
  final String verificationCode;
  final PairingStatus status;
  final int attempts;
  final DateTime expiresAt;
  final DateTime createdAt;

  PairingResponse({
    required this.id,
    required this.senderUsername,
    required this.recipientUsername,
    required this.verificationCode,
    required this.status,
    required this.attempts,
    required this.expiresAt,
    required this.createdAt,
  });

  factory PairingResponse.fromJson(Map<String, dynamic> json) {
    return PairingResponse(
      id: json['id'] ?? 0,
      senderUsername: json['senderUsername'] ?? '',
      recipientUsername: json['recipientUsername'] ?? '',
      verificationCode: json['verificationCode'] ?? '',
      status: PairingStatus.fromString(json['status'] ?? 'PENDING'),
      attempts: json['attempts'] ?? 0,
      expiresAt: DateTime.parse(json['expiresAt']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  
  bool get isPending => status == PairingStatus.pending && !isExpired;
}
