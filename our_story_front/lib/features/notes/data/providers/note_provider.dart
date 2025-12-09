import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:our_story_front/features/notes/data/models/note_model.dart';
import 'package:our_story_front/features/notes/data/repositories/note_repository.dart';

final noteRepositoryProvider =
  Provider<NoteRepository>((ref) {
    return NoteRepository();
  }
);

final pinnedNotesProvider =
  FutureProvider.autoDispose<List<NoteModel>>((ref) async {
    final repository = ref.read(noteRepositoryProvider);
    return repository.getPinnedNotes();
  }
);

final allNotesProvider = 
  FutureProvider.autoDispose<List<NoteModel>>((ref) async {
    final repository = ref.read(noteRepositoryProvider);
    return repository.getNotesByCouple();
  }
);

// Provider para notas filtradas y ordenadas
final filteredNotesProvider = Provider.family<List<NoteModel>, String>((ref, query) {
  final notesAsync = ref.watch(allNotesProvider);
  
  return notesAsync.when(
    data: (notes) {
      if (query.isEmpty) {
        return _sortNotes(notes);
      }
      
      final filtered = notes.where((note) {
        return note.title.toLowerCase().contains(query.toLowerCase()) ||
               note.content.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      return _sortNotes(filtered);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

List<NoteModel> _sortNotes(List<NoteModel> notes) {
  final sorted = List<NoteModel>.from(notes);
  sorted.sort((a, b) {
    // Primero ordenar por pinned (pinned primero)
    final aPinned = a.isPinned ?? false;
    final bPinned = b.isPinned ?? false;
    if (aPinned && !bPinned) return -1;
    if (!aPinned && bPinned) return 1;
    
    // Luego ordenar por fecha (más reciente primero)
    final aDate = a.createdAt ?? DateTime(2000);
    final bDate = b.createdAt ?? DateTime(2000);
    return bDate.compareTo(aDate);
  });
  return sorted;
}

