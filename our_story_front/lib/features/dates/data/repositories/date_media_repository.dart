import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_constants.dart';
import '../models/date_media_model.dart';

class DateMediaRepository {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  /// Upload an image or video for a date
  Future<DateMediaModel> uploadMedia({
    required File file,
    required int dateId,
    required String mediaType,
    required int uploadedBy,
    int? orderIndex,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dateMedias}/upload');
      
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      
      // Add file
      final fileExtension = file.path.split('.').last.toLowerCase();
      final mimeType = _getMimeType(fileExtension);
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
      
      // Add other fields
      request.fields['dateId'] = dateId.toString();
      request.fields['mediaType'] = mediaType;
      request.fields['uploadedBy'] = uploadedBy.toString();
      if (orderIndex != null) {
        request.fields['orderIndex'] = orderIndex.toString();
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return DateMediaModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to upload media: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading media: $e');
    }
  }

  /// Get all media for a specific date
  Future<List<DateMediaModel>> getMediaByDateId(int dateId) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConstants.baseUrl}${ApiConstants.dateMedias}/dates/$dateId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConstants.connectionTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => DateMediaModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return []; // No media found for this date
      } else {
        throw Exception('Failed to fetch media: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching media: $e');
    }
  }

  /// Delete a media item
  Future<void> deleteMedia(int mediaId) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConstants.baseUrl}${ApiConstants.dateMedias}/$mediaId';
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConstants.connectionTimeout);
      
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete media: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting media: $e');
    }
  }

  /// Helper method to determine MIME type from file extension
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
