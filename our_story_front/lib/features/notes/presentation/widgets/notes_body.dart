import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/note_card.dart';
import '../../data/models/note_model.dart';
import '../../data/providers/note_provider.dart';
import 'notes_empty_state.dart';

class NotesBody extends ConsumerWidget {
  final List<NoteModel> filteredNotes;
  final bool isSearching;
  final Function(NoteModel) onNoteTap;
  final Function(int) onPinned;
  final Function(String, NoteModel) onOptionSelected;
  final VoidCallback onRefresh;

  const NotesBody({
    required this.filteredNotes,
    required this.isSearching,
    required this.onNoteTap,
    required this.onPinned,
    required this.onOptionSelected,
    required this.onRefresh,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(allNotesProvider);

    return notesAsync.when(
      data: (notes) {
        if (filteredNotes.isEmpty) {
          return NotesEmptyState(isSearching: isSearching);
        }

        return RefreshIndicator(
          onRefresh: () async {
            onRefresh();
            ref.invalidate(allNotesProvider);
          },
          color: AppColors.textPrimaryLight,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
            ),
            itemCount: filteredNotes.length,
            itemBuilder: (context, index) {
              final note = filteredNotes[index];
              return NoteCard(
                title: note.title,
                content: note.content,
                createdAt: note.createdAt ?? DateTime.now(),
                createdBy: note.createdBy?.fullName ?? 'Usuario',
                color: note.color,
                sticker: note.sticker,
                isPinned: note.isPinned ?? false,
                onPinned: () => onPinned(note.id ?? 0),
                onTap: () => onNoteTap(note),
                onOptionSelected: (action) => onOptionSelected(action, note),
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.textPrimaryLight,
        ),
      ),
      error: (error, stack) => Center(
        child: Text('Error: ${error.toString()}'),
      ),
    );
  }
}
