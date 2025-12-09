import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:our_story_front/core/api/api_client.dart';
import 'package:our_story_front/core/api/api_constants.dart';
import 'package:our_story_front/features/home/data/models/couple_summary_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoupleSummaryRepository {
  final ApiClient _apiClient = ApiClient();

  Future<CoupleSummaryModel> getMyCoupleSummary() async {
    try {
      final response = await _apiClient.get(ApiConstants.couplesSummary);
      final data = _apiClient.handleResponse(response);
      return CoupleSummaryModel.fromJson(data);
    } catch (e) {
      throw Exception('Error al obtener solicitud: $e');
    }
  }

  Future<void> uploadCoupleImage(File imageFile) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.couplesImage}');

      var request = http.MultipartRequest(
        'PUT',
        uri
      );

      request.headers.addAll(headers);

      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      final mimeType = _getMimeType(fileExtension);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType.parse(mimeType)
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 204) {
        print('✅ Imagen subida exitosamente');
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading media: $e');
    }
  }
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      default:
        return 'application/octet-stream';
    }
  }
}
