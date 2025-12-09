import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:our_story_front/core/constants/app_colors.dart';
import 'package:our_story_front/core/constants/app_sizes.dart';
import 'package:our_story_front/core/theme/app_theme.dart';
import 'package:our_story_front/features/notes/data/models/note_model.dart';
import 'package:our_story_front/features/notes/data/providers/note_provider.dart';
import 'package:our_story_front/features/home/presentation/widgets/note_card_item.dart';
import 'package:our_story_front/features/home/presentation/widgets/note_loading_card.dart';

class PinnedNotesSection extends ConsumerWidget {
  final Function(NoteModel) onNoteTap;
  final VoidCallback onAddNoteTap;

  const PinnedNotesSection({
    super.key,
    required this.onNoteTap,
    required this.onAddNoteTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinnedNotesAsync = ref.watch(pinnedNotesProvider);

    return switch (pinnedNotesAsync) {
      AsyncData(:final value) when value.isNotEmpty => IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [ 
            ...value.take(2).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final note = entry.value;
              final colors = ['pink', 'blue'];  
              
              return NoteCardItem(
                note: note,
                color: colors[index], 
                onTap: () => onNoteTap(note),
              );
            }),
      
            
            if (value.length < 2) Spacer(flex: 2 - value.length),
          ],
        ),
      ),
      
      AsyncData(:final value) when value.isEmpty => Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.push_pin_outlined,
                size: 48,
                color: AppColors.textSecondaryLight.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'No hay notas destacadas',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: onAddNoteTap,
                child: Text(
                  'Crear nota',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.accentPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      AsyncError() => Container(
        padding: const EdgeInsets.all(AppSizes.paddingS),
        child: Text(
          'Error al cargar notas',
          style: AppTheme.bodySmall.copyWith(color: AppColors.error),
        ),
      ),
      
      _ => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(2, (_) => NoteLoadingCard()),
      ),
    };
  }
}
