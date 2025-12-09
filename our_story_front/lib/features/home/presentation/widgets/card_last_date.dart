import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:our_story_front/core/constants/app_colors.dart';
import 'package:our_story_front/core/constants/app_sizes.dart';
import 'package:our_story_front/core/theme/app_theme.dart';
import 'package:our_story_front/features/dates/data/models/date_model.dart';
import 'package:our_story_front/features/dates/data/providers/date_provider.dart';
import 'package:our_story_front/features/home/presentation/widgets/card_last_date_loading.dart';
import 'package:our_story_front/features/home/providers/couple_summary_provider.dart';
import 'package:our_story_front/shared/widgets/loading_card.dart';
import 'package:our_story_front/shared/widgets/error_card.dart';

class CardLastDate extends ConsumerStatefulWidget {
  final VoidCallback navigateToAddDate;
  final Function(DateModel date) navigateToEditDate;

  const CardLastDate({
    super.key,
    required this.navigateToAddDate,
    required this.navigateToEditDate
  });

  @override
  ConsumerState<CardLastDate> createState() => _CardLastDateState();
}

class _CardLastDateState extends ConsumerState<CardLastDate> {

  @override
  Widget build(BuildContext context) {
    final latestUnrankedDate = ref.watch(latestUnrankedDateProvider);

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.backgroundCardLight,
          borderRadius: BorderRadiusGeometry.circular(12)
        ),
        child: switch (latestUnrankedDate) {
          AsyncData(value: null) => InkWell(
            onTap: () => widget.navigateToAddDate(),
            child: Container(
            width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                children: [
                  Icon(Icons.calendar_today_rounded,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: 12),
                  Text("Agrega una nueva cita",
                    style: TextStyle(
                      color: AppColors.textSecondaryLight
                    ),
                  )
                ],
              )
            ),
          ),
          AsyncData(:final value) when value != null => InkWell(
            onTap: () => widget.navigateToEditDate(value),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value.title,
                    style: AppTheme.heading3,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_outlined,
                        color: AppColors.textPrimaryLight,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(value.location ?? "No hay ubicación seleccionada",
                        style: AppTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      value.dateImage != null
                        ? ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(8),
                          child: Image.network(
                            value.dateImage ?? "assets/images/logo.png",
                            height: 80,
                            width: 112,
                            fit: BoxFit.cover,
                          ),
                        )
                        : DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              radius: Radius.circular(8),
                              strokeWidth: 2,
                              dashPattern: [8, 4],
                              color: AppColors.shadowLight
                            ),
                            child: SizedBox(
                              height: 72,
                              width: 72,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_rounded,
                                    size: 30,
                                    color: AppColors.shadowLight,
                                  ),
                                  Text("Agrega una imagen",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textSecondaryLight,
                                      fontSize: 12
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(value.description,
                          style: AppTheme.bodyLarge,
                          maxLines: 3,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          AsyncError(:final error) => ErrorCard(
            error: error,
            onPressed: () {
              ref.invalidate(coupleSummaryProvider);
            },
          ),
          _ => CardLastDateLoading(),
        }, 
      ),
    );
  }
}
