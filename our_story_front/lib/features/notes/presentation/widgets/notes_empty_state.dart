import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class NotesEmptyState extends StatelessWidget {
  final bool isSearching;

  const NotesEmptyState({
    required this.isSearching,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.note_add_outlined,
              size: 100,
              color: AppColors.textPrimaryLight.withOpacity(0.3),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              isSearching ? 'No se encontraron notas' : 'No hay memorias aún',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              isSearching
                  ? 'Intenta con otros términos de búsqueda'
                  : 'Comienza a capturar tus momentos especiales juntos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondaryLight.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
