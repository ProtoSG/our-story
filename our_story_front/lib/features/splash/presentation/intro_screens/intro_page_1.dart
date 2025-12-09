import 'package:flutter/material.dart';
import 'package:our_story_front/core/constants/app_colors.dart';
import 'package:our_story_front/core/constants/app_sizes.dart';
import 'package:our_story_front/core/theme/app_theme.dart';

class IntroPage1 extends StatelessWidget {
  final String title;
  final String subTitle;
  final String content;
  final String image;

  const IntroPage1({
    super.key, 
    required this.title, 
    required this.subTitle, 
    required this.content, 
    required this.image
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.gradientBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            children: [
              if (title.isEmpty)
                const SizedBox(height: 40),

              Text( subTitle,
                style: TextStyle(
                  color: AppColors.textPrimaryLight,
                  fontSize: 32,
                  fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.center,
              ),

              if (title.isNotEmpty)
                Text( title,
                  style: TextStyle(
                    color: AppColors.textPrimaryLight,
                    fontSize: 62,
                    fontWeight: FontWeight.w400
                  ),
                ),

              const SizedBox(height: AppSizes.paddingM),

              Text( content,
                style: TextStyle(
                  color: AppColors.textPrimaryLight,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              Image.asset(image,
                fit: BoxFit.contain,
                width: 380,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
