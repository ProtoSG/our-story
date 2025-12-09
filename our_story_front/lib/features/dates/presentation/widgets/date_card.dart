import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../data/models/date_media_model.dart';

class DateCard extends StatelessWidget {
  final String title;
  final String description;
  final String? location;
  final DateTime? date;
  final int? rating;
  final String? category;
  final DateTime createdAt;
  final String createdBy;
  final VoidCallback onTap;
  final List<DateMediaModel>? mediaList;

  const DateCard({
    Key? key,
    required this.title,
    required this.description,
    this.location,
    this.date,
    this.rating,
    this.category,
    required this.createdAt,
    required this.createdBy,
    required this.onTap,
    this.mediaList,
  }) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final formatter = DateFormat('dd MMM yyyy', 'es');
    return formatter.format(date);
  }

  Color _getCategoryColor() {
    switch (category?.toLowerCase()) {
      case 'romantic':
      case 'romántica':
        return const Color(0xFFE91E63); // Rosa
      case 'fun':
      case 'diversión':
        return const Color(0xFFFF9800); // Naranja
      case 'adventure':
      case 'aventura':
        return const Color(0xFF4CAF50); // Verde
      case 'cultural':
        return const Color(0xFF9C27B0); // Morado
      case 'food':
      case 'comida':
        return const Color(0xFFFF5722); // Rojo-naranja
      default:
        return AppColors.accentPrimaryLight;
    }
  }

  IconData _getCategoryIcon() {
    switch (category?.toLowerCase()) {
      case 'romantic':
      case 'romántica':
        return Icons.favorite;
      case 'fun':
      case 'diversión':
        return Icons.celebration;
      case 'adventure':
      case 'aventura':
        return Icons.explore;
      case 'cultural':
        return Icons.museum;
      case 'food':
      case 'comida':
        return Icons.restaurant;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundCardLight.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              // border: Border.all(
              //   color: AppColors.cardBorder,
              //   width: 1,
              // ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con fecha y categoría
                      Row(
                        children: [
                          if (date != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentPrimaryLight.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.accentPrimaryLight.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: AppColors.accentPrimaryLight,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(date),
                                    style: AppTheme.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accentPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor().withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getCategoryColor().withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getCategoryIcon(),
                                    size: 14,
                                    color: _getCategoryColor(),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    category!,
                                    style: AppTheme.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: _getCategoryColor(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      
                      // Título
                      Text(
                        title,
                        style: AppTheme.heading3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.paddingXS),
                      
                      // Descripción
                      Text(
                        description,
                        style: AppTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Image Gallery
                      if (mediaList != null && mediaList!.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.paddingM),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: mediaList!.length > 4 ? 4 : mediaList!.length,
                            itemBuilder: (context, index) {
                              final media = mediaList![index];
                              final isLast = index == 3 && mediaList!.length > 4;
                              
                              return Container(
                                margin: EdgeInsets.only(
                                  right: index < (mediaList!.length > 4 ? 3 : mediaList!.length - 1) 
                                      ? 8 
                                      : 0,
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        media.mediaUrl,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: AppColors.backgroundCardLight.withValues(alpha: 0.5),
                                              borderRadius: BorderRadius.circular(8),
                                              // border: Border.all(
                                              //   color: AppColors.cardBorder,
                                              //   width: 1,
                                              // ),
                                            ),
                                            child: const Icon(
                                              Icons.image_not_supported_rounded,
                                              color: AppColors.textSecondaryLight,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    if (isLast)
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                            child: Container(
                                              color: AppColors.backgroundCardLight.withValues(alpha: 0.8),
                                              child: Center(
                                                child: Text(
                                                  '+${mediaList!.length - 3}',
                                                  style: AppTheme.heading3.copyWith(
                                                    color: AppColors.accentPrimaryLight,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      
                      // Ubicación y rating
                      if (location != null || rating != null) ...[
                        const SizedBox(height: AppSizes.paddingM),
                        Row(
                          children: [
                            if (location != null) ...[
                              const Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location!,
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            if (rating != null) ...[
                              const SizedBox(width: 12),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < rating! ? Icons.star_rounded : Icons.star_border_rounded,
                                    size: 16,
                                    color: Colors.amber,
                                  );
                                }),
                              ),
                            ],
                          ],
                        ),
                      ],
                      
                      // Footer con creador
                      const SizedBox(height: AppSizes.paddingS),
                      Divider(
                        height: 1,
                        color: AppColors.backgroundCardLight,
                      ),
                      const SizedBox(height: AppSizes.paddingS),
                      Text(
                        'Por $createdBy',
                        style: AppTheme.bodySmall.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
