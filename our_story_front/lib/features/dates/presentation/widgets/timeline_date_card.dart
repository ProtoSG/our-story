import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TimelineDateCard extends StatelessWidget {
  final String title;
  final String description;
  final String? location;
  final DateTime? date;
  final int? rating;
  final String? category;
  final String? dateImage;
  final String createdBy;
  final VoidCallback onTap;

  const TimelineDateCard({
    Key? key,
    required this.title,
    required this.description,
    this.location,
    this.date,
    this.rating,
    this.category,
    this.dateImage,
    required this.createdBy,
    required this.onTap,
  }) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final formatter = DateFormat('dd MMM', 'es');
    return formatter.format(date);
  }

  String _formatYear(DateTime? date) {
    if (date == null) return '';
    final formatter = DateFormat('yyyy', 'es');
    return formatter.format(date);
  }

  Color _getCategoryColor() {
    switch (category?.toLowerCase()) {
      case 'romantic':
      case 'romántica':
        return const Color(0xFFE91E63);
      case 'fun':
      case 'diversión':
        return const Color(0xFFFF9800);
      case 'adventure':
      case 'aventura':
        return const Color(0xFF4CAF50);
      case 'cultural':
        return const Color(0xFF9C27B0);
      case 'food':
      case 'comida':
        return const Color(0xFFFF5722);
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline indicator on the left
            _buildTimelineIndicator(),
            
            const SizedBox(width: 16),
            
            // Card content (takes all remaining space)
            Expanded(
              child: _buildDateCard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineIndicator() {
    return SizedBox(
      width: 48,
      child: Column(
        children: [
          // Connecting line from previous
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _getCategoryColor().withValues(alpha: 0.2),
                  _getCategoryColor().withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          
          // Circle indicator
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getCategoryColor(),
                  _getCategoryColor().withValues(alpha: 0.7),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getCategoryColor().withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _getCategoryIcon(),
              color: Colors.white,
              size: 24,
            ),
          ),
          
          // Connecting line to next (expands to fill remaining space)
          Expanded(
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _getCategoryColor().withValues(alpha: 0.6),
                    _getCategoryColor().withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main card
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity, // Force full width
                constraints: BoxConstraints(
                  minHeight: dateImage != null ? 0 : 200, // Minimum height for cards without images
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCardLight.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getCategoryColor().withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Changed from start to stretch
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image if available
                    if (dateImage != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.network(
                          dateImage!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _getCategoryColor().withValues(alpha: 0.3),
                                    _getCategoryColor().withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  _getCategoryIcon(),
                                  size: 48,
                                  color: _getCategoryColor().withValues(alpha: 0.5),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            title,
                            style: AppTheme.heading3.copyWith(fontSize: 18),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: AppSizes.paddingS),
                          
                          // Description
                          Text(
                            description,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppColors.textSecondaryLight,
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: AppSizes.paddingM),
                          
                          // Bottom row: location, rating, category
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // Location
                              if (location != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: 14,
                                        color: AppColors.textSecondaryLight,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
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
                                  ),
                                ),
                              
                              // Rating
                              if (rating != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: Colors.amber.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$rating/5',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: Colors.amber.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              
                              // Category
                              if (category != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor().withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getCategoryIcon(),
                                        size: 12,
                                        color: _getCategoryColor(),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        category!,
                                        style: AppTheme.bodySmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: _getCategoryColor(),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Floating date badge or "Idea" badge (top right)
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: date != null
                      ? [
                          AppColors.accentPrimaryLight,
                          AppColors.accentPrimaryLight.withValues(alpha: 0.8),
                        ]
                      : [
                          AppColors.accentSecondaryLight,
                          AppColors.accentSecondaryLight.withValues(alpha: 0.8),
                        ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: date != null
                        ? AppColors.accentPrimaryLight.withValues(alpha: 0.4)
                        : AppColors.accentSecondaryLight.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: date != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatDate(date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatYear(date),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Idea',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
