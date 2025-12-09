import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_constants.dart';
import '../models/message_model.dart';

class ChatRepository {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get all messages for the authenticated user's couple
  Future<List<MessageModel>> getMessages() async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConstants.baseUrl}${ApiConstants.messages}/couples';
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConstants.connectionTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => MessageModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch messages: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  /// Send a message via REST API (fallback or initial send)
  Future<MessageModel> sendMessage(MessageModel message) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConstants.baseUrl}${ApiConstants.messages}';
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(message.toCreateRequest()),
      ).timeout(ApiConstants.connectionTimeout);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return MessageModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  /// Mark a message as read
  Future<void> markAsRead(int messageId) async {
    try {
      final headers = await _getHeaders();
      final url = '${ApiConstants.baseUrl}${ApiConstants.messages}/$messageId/read';
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConstants.connectionTimeout);
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to mark message as read: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error marking message as read: $e');
    }
  }
}
