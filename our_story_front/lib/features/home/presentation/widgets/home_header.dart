import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:our_story_front/core/constants/app_colors.dart';
import 'package:our_story_front/core/constants/app_sizes.dart';
import 'package:our_story_front/core/theme/app_theme.dart';
import 'package:our_story_front/features/home/data/repositories/couple_summary_repository.dart';
import 'package:our_story_front/features/home/presentation/widgets/home_header_loading.dart';
import 'package:our_story_front/features/home/presentation/widgets/modal_pick_image_header.dart';
import 'package:our_story_front/features/home/providers/couple_summary_provider.dart';
import 'package:our_story_front/shared/widgets/error_card.dart';

class HomeHeader extends ConsumerStatefulWidget {

  const HomeHeader({
    super.key,
  });

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
  final CoupleSummaryRepository coupleSummaryRepository = CoupleSummaryRepository();

  XFile? _selectedImage;

  Future<void> _showModal() {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext modalContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundCardLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ImagePickerModal(
            initialImage: _selectedImage,
            onImageSelected: (image) {
              setState(() {
                _selectedImage = image;
              });
            },
            onSave: (image) async {
              print('Guardando imagen: ${image.path}');
              await coupleSummaryRepository.uploadCoupleImage(File(image.path));
              ref.invalidate(coupleSummaryProvider);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final coupleSummaryAsync = ref.watch(coupleSummaryProvider);

    return switch (coupleSummaryAsync) {
      AsyncData(:final value) => Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          children: [
            Text(value.coupleName.toUpperCase(),
              style: AppTheme.heading3,
            ),

            const SizedBox(height: 16),

            value.coupleImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    value.coupleImage ?? "",
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                )
              : DottedBorder(
                  options: CircularDottedBorderOptions(
                    strokeWidth: 2,
                    dashPattern: [8, 4],
                    color: AppColors.shadowLight,
                  ),
                  child: InkWell(
                    onTap: _showModal,
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColors.backgroundCardLight,  // ← Fondo visible
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: 40,
                            color: AppColors.shadowLight,
                          ),
                          Text("Agregar foto"),
                        ],
                      ),
                    ),
                  ),
                ),

            const SizedBox(height: 16),

            Stack(
              children: [
                Text(
                  value.daysTogetherText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 4
                      ..color = AppColors.accentPrimaryLight,
                  ),
                ),
                Text(
                  value.daysTogetherText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: AppColors.backgroundLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      AsyncError(:final error) => ErrorCard(
        error: error,
        onPressed: () {
          ref.invalidate(coupleSummaryProvider);
        },
      ),
      _ => Center(
        child: HomeHeaderLoading(),
      ),
    };
  }
}
