import 'package:flutter/material.dart';
import 'package:our_story_front/core/constants/app_sizes.dart';
import 'package:our_story_front/features/notes/data/models/note_model.dart';

class NoteCardItem extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final String color;

  const NoteCardItem({
    super.key,
    required this.note,
    required this.onTap,
    required this.color,
  });

  String _getNoteImage(String? color) {
    switch (color?.toLowerCase()) {
      case 'pink':
      case 'rosa':
        return 'assets/images/note_pink.webp';
      case 'blue':
      case 'azul':
        return 'assets/images/note_blue.webp';
      case 'yellow':
      case 'amarillo':
        return 'assets/images/note_yellow.webp';
      case 'green':
      case 'verde':
        return 'assets/images/note_green.webp';
      default:
        return 'assets/images/note_pink.webp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: [
                // Imagen de fondo según color
                Image.asset(
                  _getNoteImage(color),
                  fit: BoxFit.contain,  
                ),
                
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Text(
                    note.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
