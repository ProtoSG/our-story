import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ColorPicker extends StatelessWidget {
  final String selectedColor;
  final Function(String) onColorSelected;

  const ColorPicker({
    Key? key,
    required this.selectedColor,
    required this.onColorSelected,
  }) : super(key: key);

  // Paleta de colores disponibles (similares a Google Keep y MEMO)
  static const List<Map<String, String>> colors = [
    {'name': 'Lavanda', 'hex': '#B8A7D9'},
    {'name': 'Azul', 'hex': '#A8C9E8'},
    {'name': 'Verde', 'hex': '#A8E6CF'},
    {'name': 'Amarillo', 'hex': '#FFE599'},
    {'name': 'Naranja', 'hex': '#FFD4A3'},
    {'name': 'Rosa', 'hex': '#FFB3BA'},
    {'name': 'Coral', 'hex': '#FFABAB'},
    {'name': 'Menta', 'hex': '#BFEFFF'},
    {'name': 'Durazno', 'hex': '#FFE4E1'},
    {'name': 'Gris', 'hex': '#E0E0E0'},
    {'name': 'Beige', 'hex': '#F5E6D3'},
    {'name': 'Lila', 'hex': '#E1BEE7'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final colorHex = color['hex']!;
          final isSelected = selectedColor == colorHex;

          return GestureDetector(
            onTap: () => onColorSelected(colorHex),
            child: Container(
              decoration: BoxDecoration(
                color: Color(int.parse(colorHex.replaceFirst('#', '0xFF'))),
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppColors.accentPrimaryLight, width: 3)
                    : Border.all(color: Colors.black.withOpacity(0.1), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 28,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
