import 'package:flutter/material.dart';
import 'package:our_story_front/core/constants/app_colors.dart';

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: AppColors.accentPrimaryLight,
    );
  }
}

