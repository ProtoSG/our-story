import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:our_story_front/core/constants/app_colors.dart';
import 'package:our_story_front/core/constants/app_sizes.dart';
import 'package:our_story_front/features/notes/data/providers/note_provider.dart';
import 'package:our_story_front/features/notes/presentation/add_edit_note_screen.dart';

class NotesHeader extends ConsumerStatefulWidget {

  const NotesHeader({super.key});

  @override
  ConsumerState<NotesHeader> createState() => _NotesHeaderState();
}

class _NotesHeaderState extends ConsumerState<NotesHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.textPrimaryLight, AppColors.textPrimaryLight],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimaryLight.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: _navigateToAddNote,
              child: const Icon(Icons.add, color: AppColors.backgroundCardLight),
            ),
          ),
        ],
      ),
    );
  }
}


