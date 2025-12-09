import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:our_story_front/features/notes/data/providers/note_provider.dart';
import 'package:our_story_front/features/notes/presentation/widgets/notes_search_bar.dart';
import 'package:our_story_front/features/notes/presentation/widgets/notes_body.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../data/models/note_model.dart';
import '../data/repositories/note_repository.dart';
import 'add_edit_note_screen.dart';

class NotesScreen extends ConsumerStatefulWidget {
  final bool showBottomNav;
  
  const NotesScreen({
    Key? key,
    this.showBottomNav = true,
  }) : super(key: key);

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final NoteRepository _noteRepository = NoteRepository();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _setPinned(int id) async {
    await _noteRepository.setPinned(id);
    ref.invalidate(allNotesProvider);
  }

  void _navigateToEditNote(NoteModel note) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AddEditNoteScreen(note: note),
      ),
    );
    // context.push("/add-edit-note", extra: note);
    ref.invalidate(allNotesProvider);
  }

  void _navigateToAddNote() async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AddEditNoteScreen(),
      ),
    );
    ref.invalidate(allNotesProvider);
  }

  void _handleNoteAction(String action, NoteModel note) {
    switch (action) {
      case 'pin':
        _setPinned(note.id ?? 0);
        break;
      case 'edit':
        _navigateToEditNote(note);
        break;
      case 'copy':
        _copyNoteText(note);
        break;
      case 'delete':
        _confirmDeleteNote(note);
        break;
    }
  }

  void _copyNoteText(NoteModel note) {
    Clipboard.setData(ClipboardData(text: '${note.title}\n\n${note.content}'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Texto copiado al portapapeles'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _confirmDeleteNote(NoteModel note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: Text('¿Estás seguro de que quieres eliminar "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNote(note.id ?? 0);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(int id) async {
    try {
      await _noteRepository.deleteNote(id);
      ref.invalidate(allNotesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nota eliminada correctamente'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = ref.watch(filteredNotesProvider(_searchQuery));

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton(
          onPressed: _navigateToAddNote,
          heroTag: 'add-note',
          shape: const CircleBorder(),
          elevation: 4,
          backgroundColor: AppColors.textPrimaryLight,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 24
            ),
            child: Column(
              children: [
                NotesSearchBar(controller: _searchController),
                const SizedBox(height: AppSizes.paddingM),
                Expanded(
                  child: NotesBody(
                    filteredNotes: filteredNotes,
                    isSearching: _searchQuery.isNotEmpty,
                    onNoteTap: _navigateToEditNote,
                    onPinned: _setPinned,
                    onOptionSelected: _handleNoteAction,
                    onRefresh: () {
                      ref.invalidate(allNotesProvider);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

