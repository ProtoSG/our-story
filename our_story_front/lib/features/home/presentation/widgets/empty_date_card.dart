import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:our_story_front/core/constants/app_colors.dart';
import 'package:our_story_front/core/constants/app_sizes.dart';

class EmptyDateCard extends StatelessWidget {
  final VoidCallback onTap;

  const EmptyDateCard({
    super.key,
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
            child: Ink(
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: Radius.circular(8),
                  strokeWidth: 2,
                  dashPattern: [8, 4],
                  color: AppColors.shadowLight
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded),
                        Text("Agregar una nueva cita",
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
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
