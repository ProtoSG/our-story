class VerifyPairingCode {
  final String verificationCode;

  VerifyPairingCode({required this.verificationCode});

  Map<String, dynamic> toJson() {
    return {
      'verificationCode': verificationCode.toUpperCase(),
    };
  }
}
