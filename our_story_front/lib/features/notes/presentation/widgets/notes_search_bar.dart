import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_theme.dart';

class NotesSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const NotesSearchBar({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          return TextField(
            controller: controller,
            decoration: AppTheme.inputDecoration(
              hintText: 'Buscar notas...',
            ),
          );
        },
      ),
    );
  }
}
