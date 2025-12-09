import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../models/note_model.dart';

class NoteRepository {
  final ApiClient _apiClient = ApiClient();

  // Get all notes
  Future<List<NoteModel>> getAllNotes() async {
    try {
      final response = await _apiClient.get(ApiConstants.notes);
      final data = _apiClient.handleResponse(response);
      
      if (data is List) {
        return data.map((json) => NoteModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  // Get note by ID
  Future<NoteModel> getNoteById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.notes}/$id');
      final data = _apiClient.handleResponse(response);
      return NoteModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch note: $e');
    }
  }

  // Get notes by couple ID
  Future<List<NoteModel>> getNotesByCouple() async {
    try {
      final response = await _apiClient.get('${ApiConstants.notes}/couples');
      final data = _apiClient.handleResponse(response);
      
      if (data is List) {
        return data.map((json) => NoteModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  // Create note
  Future<NoteModel> createNote(NoteModel note) async {
    try {
      final requestBody = note.toCreateRequest();
      
      final response = await _apiClient.post(
        ApiConstants.notes,
        body: requestBody,
      );
      final data = _apiClient.handleResponse(response);
      
      return NoteModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  // Update note
  Future<NoteModel> updateNote(int id, NoteModel note) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.notes}/$id',
        body: note.toUpdateRequest(),
      );
      final data = _apiClient.handleResponse(response);
      return NoteModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  // Delete note
  Future<void> deleteNote(int id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.notes}/$id');
      _apiClient.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  // set pinned note
  Future<void> setPinned(int id) async {
    try {
      final response = await _apiClient.put('${ApiConstants.notes}/$id/pinned');
      _apiClient.handleResponse(response);
    } catch (e) {
      throw Exception('Failed to set pinned: $e');
    }
  }

  // Get pinned notes (top 2)
  Future<List<NoteModel>> getPinnedNotes() async {
    try {
      final response = await _apiClient.get('${ApiConstants.notes}/pinned');
      final data = _apiClient.handleResponse(response);
      
      if (data is List) {
        return data.map((json) => NoteModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching pinned notes: $e');
      return [];
    }
  }
}
