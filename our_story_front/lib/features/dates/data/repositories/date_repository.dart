import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../models/date_model.dart';

class DateRepository {
  final ApiClient _apiClient = ApiClient();

  // Get all dates for the couple
  Future<List<DateModel>> getDatesByCouple() async {
    try {
      final response = await _apiClient.get('${ApiConstants.dates}/couples');
      final data = _apiClient.handleResponse(response);
      
      if (data is List) {
        return data.map((json) => DateModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch dates: $e');
    }
  }

  // Get date by ID
  Future<DateModel> getDateById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.dates}/$id');
      final data = _apiClient.handleResponse(response);
      return DateModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch date: $e');
    }
  }

  // Create date
  Future<DateModel> createDate(DateModel date) async {
    try {
      final requestBody = date.toCreateRequest();
      
      final response = await _apiClient.post(
        ApiConstants.dates,
        body: requestBody,
      );
      final data = _apiClient.handleResponse(response);
      
      return DateModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create date: $e');
    }
  }

  // Update date
  Future<DateModel> updateDate(int id, DateModel date) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.dates}/$id',
        body: date.toUpdateRequest(),
      );
      final data = _apiClient.handleResponse(response);
      return DateModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update date: $e');
    }
  }

  // Delete date
  Future<void> deleteDate(int id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.dates}/$id');
      _apiClient.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete date: $e');
    }
  }

  // Get latest unranked date
  Future<DateModel?> getLatestUnrankedDate() async {
    try {
      final response = await _apiClient.get('${ApiConstants.dates}/unranked');

      if (response.statusCode == 204) {
        return null;
      }

      final data = _apiClient.handleResponse(response);

      if (data == null) {
        return null;
      }

      return DateModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch date: $e');
    }
  }

  // Get recent rated dates (top 3)
  Future<List<DateModel>> getRecentRatedDates() async {
    try {
      final response = await _apiClient.get('${ApiConstants.dates}/recent');
      final data = _apiClient.handleResponse(response);
      
      if (data is List) {
        return data.map((json) => DateModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching recent dates: $e');
      return [];
    }
  }

  // Update date image (place/location image)
  Future<void> updateDateImage({
    required int dateId,
    required File imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dates}/$dateId/image');
      
      var request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      
      // Add file
      final fileExtension = imageFile.path.split('.').last.toLowerCase();
      final mimeType = _getMimeType(fileExtension);
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
      
      final streamedResponse = await request.send().timeout(
        ApiConstants.uploadTimeout,
        onTimeout: () {
          throw Exception('Timeout al subir la imagen. Por favor intenta con una imagen más pequeña.');
        },
      );
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to upload date image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading date image: $e');
    }
  }

  // Helper method to determine MIME type from file extension
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
      default:
        return 'application/octet-stream';
    }
  }
}
