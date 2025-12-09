import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:our_story_front/features/notes/data/providers/note_provider.dart';
import 'package:our_story_front/shared/widgets/toast_bar.dart';
import 'dart:ui';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/stickers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/models/note_model.dart';
import '../data/repositories/note_repository.dart';
import 'widgets/sticker_selector.dart';
import 'widgets/color_picker.dart';

class AddEditNoteScreen extends ConsumerStatefulWidget {
  final int? coupleId;
  final int? userId;
  final NoteModel? note; // Si es null, es modo "agregar", si no es modo "editar"
  const AddEditNoteScreen({
    Key? key,
    this.coupleId,
    this.userId,
    this.note,
  }) : super(key: key);
  @override
  ConsumerState<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}
class _AddEditNoteScreenState extends ConsumerState<AddEditNoteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final NoteRepository _noteRepository = NoteRepository();
  bool _isLoading = false;
  String? _selectedSticker;
  String _selectedColor = '#B8A7D9'; // Color por defecto (lavanda)
  bool get _isEditMode => widget.note != null;
  @override
  void initState() {
    super.initState();
    
    // Si estamos en modo editar, cargar los datos de la nota
    if (_isEditMode) {
      _titleController = TextEditingController(text: widget.note!.title);
      _contentController = TextEditingController(text: widget.note!.content);
      _selectedColor = widget.note!.color ?? '#B8A7D9';
      _selectedSticker = widget.note!.sticker;
    } else {
      _titleController = TextEditingController(text: '');
      _contentController = TextEditingController(text: '');
    }
  }
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Selecciona un color', style: AppTheme.heading3),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textPrimaryLight),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),
            SizedBox(
              height: 200,
              child: ColorPicker(
                selectedColor: _selectedColor,
                onColorSelected: (color) {
                  setState(() {
                    _selectedColor = color;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showStickerPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Selecciona un sticker', style: AppTheme.heading3),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textPrimaryLight),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),
            SizedBox(
              height: 300,
              child: StickerSelector(
                selectedSticker: _selectedSticker,
                onStickerSelected: (sticker) {
                  setState(() {
                    _selectedSticker = sticker;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _saveNote() async {
    // Validación básica
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      AppToast.showError(context, message: 'Por favor complete el título y contenido');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      if (_isEditMode) {
        // Modo editar - actualizar nota existente
        final updatedNote = widget.note!.copyWith(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          color: _selectedColor,
          sticker: _selectedSticker,
        );
        
        await _noteRepository.updateNote(widget.note!.id!, updatedNote);
        
        if (mounted) {
          AppToast.showSuccess(context, message: '¡Nota actualizada exitosamente!');
          Navigator.pop(context, true);
        }
      } else {
        // Modo agregar - crear nueva nota
        final note = NoteModel(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          color: _selectedColor,
          sticker: _selectedSticker,
          isPinned: false,
        );
        await _noteRepository.createNote(note);
        if (mounted) {
          AppToast.showSuccess(context, message: '¡Nota guardada exitosamente!');
          Navigator.pop(context, true);
        }
      }
      ref.invalidate(allNotesProvider);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        AppToast.showError(context, message: 'Error al guardar: ${e.toString()}');
      }
    }
  }
  Future<void> _deleteNote() async {
    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Nota'),
        content: const Text('¿Estás seguro de que quieres eliminar esta nota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await _noteRepository.deleteNote(widget.note!.id!);
      if (mounted) {
        AppToast.showSuccess(context, message: 'Nota eliminada exitosamente');
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        AppToast.showError(context, message: 'Error al eliminar: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundCardLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _isEditMode ? 'Editar Nota' : 'Nueva Nota',
                style: AppTheme.heading3.copyWith(fontSize: 16),
              ),
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: AppColors.error),
              onPressed: _deleteNote,
              tooltip: 'Eliminar nota',
            ),
        ],
      ),
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + AppSizes.paddingM),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nota editable (Card)
                    _buildEditableNoteCard(),
              
                    const SizedBox(height: AppSizes.paddingXL),
              
                    // Botones de Fondo y Sticker
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showColorPicker,
                            icon: const Icon(Icons.palette_rounded),
                            label: const Text('Cambiar Fondo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.backgroundCardLight,
                              foregroundColor: AppColors.textPrimaryLight,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingM),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showStickerPicker,
                            icon: const Icon(Icons.emoji_emotions_rounded),
                            label: const Text('Agregar Sticker'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.backgroundCardLight,
                              foregroundColor: AppColors.textPrimaryLight,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-edit-note',
        onPressed: _isLoading ? null : _saveNote,
        backgroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        shape: CircleBorder(),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  Widget _buildEditableNoteCard() {
    final cardColor = Color(int.parse(_selectedColor.replaceFirst('#', '0xFF')));
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cardColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: cardColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo de título editable
                  TextField(
                    controller: _titleController,
                    style: AppTheme.heading3.copyWith(fontSize: 20),
                    maxLines: 2,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: 'Título de la nota',
                      hintStyle: AppTheme.heading3.copyWith(
                        fontSize: 20,
                        color: AppColors.textSecondaryLight,
                      ),
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Campo de contenido editable
                  TextField(
                    controller: _contentController,
                    style: AppTheme.bodyMedium.copyWith(height: 1.5),
                    maxLines: 8,
                    maxLength: 500,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: 'Descripción de la nota...',
                      hintStyle: AppTheme.bodyMedium.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                      counterStyle: AppTheme.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                    ),
                  ),
                ],
              ),
              
              // Sticker en esquina inferior derecha
              if (_selectedSticker != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Image.asset(
                    Stickers.getPath(_selectedSticker!),
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
