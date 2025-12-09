import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/stickers.dart';

class StickerSelector extends StatelessWidget {
  final String? selectedSticker;
  final Function(String?) onStickerSelected;

  const StickerSelector({
    Key? key,
    this.selectedSticker,
    required this.onStickerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: Stickers.availableStickers.length + 1, // +1 para "sin sticker"
        itemBuilder: (context, index) {
                if (index == 0) {
                  // Opción "Sin sticker"
                  return _buildStickerOption(
                    context,
                    isSelected: selectedSticker == null,
                    child: const Icon(Icons.close, size: 30, color: AppColors.textSecondaryLight),
                    onTap: () => onStickerSelected(null),
                  );
                }
                
                final stickerName = Stickers.availableStickers[index - 1];
                return _buildStickerOption(
                  context,
                  isSelected: selectedSticker == stickerName,
                  child: Image.asset(
                    Stickers.getPath(stickerName),
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
            onTap: () => onStickerSelected(stickerName),
          );
        },
      ),
    );
  }

  Widget _buildStickerOption(
    BuildContext context, {
    required bool isSelected,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.accentPrimaryLight.withOpacity(0.2) 
              : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentPrimaryLight : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}
