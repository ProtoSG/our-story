class SendPairingRequest {
  final String recipientUsername;

  SendPairingRequest({required this.recipientUsername});

  Map<String, dynamic> toJson() {
    return {
      'recipientUsername': recipientUsername,
    };
  }
}
