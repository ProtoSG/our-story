import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../models/send_pairing_request.dart';
import '../models/verify_pairing_code.dart';
import '../models/pairing_response.dart';
import '../../../couples/data/models/couple_model.dart';

class PairingRepository {
  final ApiClient _apiClient = ApiClient();

  Future<PairingResponse> sendPairingRequest(SendPairingRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.pairingSend,
        body: request.toJson(),
      );
      final data = _apiClient.handleResponse(response);
      return PairingResponse.fromJson(data);
    } catch (e) {
      throw Exception('Error al enviar solicitud: $e');
    }
  }

  Future<CoupleModel> verifyPairingCode(VerifyPairingCode request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.pairingVerify,
        body: request.toJson(),
      );
      final data = _apiClient.handleResponse(response);
      return CoupleModel.fromJson(data);
    } catch (e) {
      throw Exception('Error al verificar código: $e');
    }
  }

  Future<PairingResponse> getMyActiveRequest() async {
    try {
      final response = await _apiClient.get(ApiConstants.pairingMyRequest);
      final data = _apiClient.handleResponse(response);
      return PairingResponse.fromJson(data);
    } catch (e) {
      throw Exception('Error al obtener solicitud: $e');
    }
  }

  Future<void> cancelMyRequest() async {
    try {
      final response = await _apiClient.delete(ApiConstants.pairingMyRequest);
      _apiClient.handleResponse(response);
    } catch (e) {
      throw Exception('Error al cancelar solicitud: $e');
    }
  }
}
