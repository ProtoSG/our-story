class ApiConstants {
  static const String baseUrl = 'http://192.168.230.164:8080'; // USB connection
  // static const String baseUrl = 'http://localhost:8080'; // Local connection

  static const String apiPrefix = '/api';

  // Auth endpoints (already have /api prefix from context-path)
  static const String auth = '$apiPrefix/auth';

  // User endpoints
  static const String users = '$apiPrefix/users';

  // Note endpoints
  static const String notes = '$apiPrefix/notes';

  // Couple endpoints
  static const String couples = '$apiPrefix/couples';

  static const String couplesSummary = '$couples/summary';
  static const String couplesImage = '$couples/image';

  // Pairing endpoints
  static const String pairing = '$apiPrefix/pairing';

  static const String pairingSend = '$pairing/send';
  static const String pairingVerify = '$pairing/verify';
  static const String pairingMyRequest = '$pairing/my-request';

  // Message endpoints
  static const String messages = '$apiPrefix/messages';

  // Date endpoints
  static const String dates = '$apiPrefix/dates';

  // Date Media endpoints
  static const String dateMedias = '$apiPrefix/date-medias';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);

}
