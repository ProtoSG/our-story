enum PairingStatus {
  pending,
  used,
  expired,
  cancelled;

  static PairingStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return PairingStatus.pending;
      case 'USED':
        return PairingStatus.used;
      case 'EXPIRED':
        return PairingStatus.expired;
      case 'CANCELLED':
        return PairingStatus.cancelled;
      default:
        return PairingStatus.pending;
    }
  }
}
