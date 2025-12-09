import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:our_story_front/core/constants/app_colors.dart';
import 'package:our_story_front/core/constants/app_sizes.dart';
import 'package:our_story_front/core/theme/app_theme.dart';
import 'package:our_story_front/features/dates/data/models/date_model.dart';
import 'package:our_story_front/features/dates/data/providers/date_provider.dart';
import 'package:our_story_front/features/home/presentation/widgets/date_card_item.dart';
import 'package:our_story_front/features/home/presentation/widgets/empty_date_card.dart';
import 'package:our_story_front/features/home/presentation/widgets/date_loading_card.dart';

class RecentDatesSection extends ConsumerWidget {
  final Function(DateModel) onDateTap;
  final VoidCallback onAddDateTap;

  const RecentDatesSection({
    super.key,
    required this.onDateTap,
    required this.onAddDateTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentDatesAsync = ref.watch(recentRatedDatesProvider);

    return switch (recentDatesAsync) {
      AsyncData(:final value) when value.isNotEmpty => IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...value.take(3).map((date) => DateCardItem(
              date: date,
              onTap: () => onDateTap(date),
            )),
        
            if (value.length < 3) EmptyDateCard(onTap: onAddDateTap),
        
            if (value.length < 2) Spacer(flex: 2 - value.length),
          ],
        ),
      ),
      
      AsyncData(:final value) when value.isEmpty => Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Center(
          child: Text(
            'No hay citas rankeadas aún',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
      
      AsyncError() => Container(
        padding: const EdgeInsets.all(AppSizes.paddingS),
        child: Text(
          'Error al cargar citas',
          style: AppTheme.bodySmall.copyWith(color: AppColors.error),
        ),
      ),
      
      _ => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (_) => DateLoadingCard()),
      ),
    };
  }
}
