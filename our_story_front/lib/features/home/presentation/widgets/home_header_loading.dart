import 'package:flutter/material.dart';
import 'package:our_story_front/core/constants/app_colors.dart';
import 'package:our_story_front/core/constants/app_sizes.dart';

class HomeHeaderLoading extends StatelessWidget {
  const HomeHeaderLoading({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      child: Column(
        children: [
          Container(
            height: 24,
            width: 150,
            decoration: BoxDecoration(
              color: AppColors.shadowLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: AppColors.shadowLight.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 32,
            width: 200,
            decoration: BoxDecoration(
              color: AppColors.shadowLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
