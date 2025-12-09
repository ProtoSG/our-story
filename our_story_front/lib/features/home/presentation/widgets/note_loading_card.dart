import 'package:flutter/material.dart';
import 'package:our_story_front/core/constants/app_colors.dart';

class NoteLoadingCard extends StatelessWidget {
  const NoteLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.shadowLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.accentPrimaryLight.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}
