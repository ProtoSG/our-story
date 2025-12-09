import 'package:flutter/material.dart';
import 'package:our_story_front/core/constants/app_colors.dart';
import 'package:our_story_front/core/constants/app_sizes.dart';
import 'package:our_story_front/core/theme/app_theme.dart';
import 'package:our_story_front/features/dates/data/models/date_model.dart';

class DateCardItem extends StatelessWidget {
  final DateModel date;
  final VoidCallback onTap;

  const DateCardItem({
    super.key,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.backgroundCardLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Imagen o placeholder
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: date.dateImage != null
                        ? Image.network(
                            date.dateImage!,
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                date.dateImage ?? "assets/images/logo.png",
                                height: 80,
                                fit: BoxFit.contain
                              );
                            },
                          )
                        : Image.asset(
                            "assets/images/logo.png",
                            height: 80,
                          ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Título
                    Text(
                      date.title,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Rating (estrellas)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 5; i++) 
                          Icon(
                            i < (date.rating ?? 0) 
                              ? Icons.star 
                              : Icons.star_border,
                            size: 16,
                            color: AppColors.warning,
                          )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
