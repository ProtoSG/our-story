import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/stickers.dart';
import '../../core/theme/app_theme.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final DateTime createdAt;
  final String createdBy;
  final String? color;
  final String? sticker;
  final bool isPinned;
  final VoidCallback onTap;
  final VoidCallback onPinned;
  final Function(String action)? onOptionSelected;

  const NoteCard({
    Key? key,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.createdBy,
    this.color,
    this.sticker,
    this.isPinned = false,
    required this.onPinned,
    required this.onTap,
    this.onOptionSelected,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Color _getCardColor() {
    if (color != null && color!.isNotEmpty) {
      try {
        return Color(int.parse(color!.replaceFirst('#', '0xff')));
      } catch (e) {
        return AppColors.backgroundCardLight;
      }
    }
    return AppColors.backgroundCardLight;
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundCardLight.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                // border: const Border(
                //   top: BorderSide(color: AppColors.cardBorder, width: 1),
                // ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimaryLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Título
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Text(
                      title,
                      style: AppTheme.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Divider(height: 1, color: AppColors.backgroundCardLight),
                  // Opciones
                  _buildOption(
                    context,
                    icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    label: isPinned ? 'Desfijar' : 'Fijar',
                    onTap: () {
                      Navigator.pop(context);
                      onOptionSelected?.call('pin');
                    },
                  ),
                  _buildOption(
                    context,
                    icon: Icons.edit_rounded,
                    label: 'Editar',
                    onTap: () {
                      Navigator.pop(context);
                      onOptionSelected?.call('edit');
                    },
                  ),
                  _buildOption(
                    context,
                    icon: Icons.content_copy_rounded,
                    label: 'Copiar texto',
                    onTap: () {
                      Navigator.pop(context);
                      onOptionSelected?.call('copy');
                    },
                  ),
                  _buildOption(
                    context,
                    icon: Icons.delete_rounded,
                    label: 'Eliminar',
                    color: AppColors.error,
                    onTap: () {
                      Navigator.pop(context);
                      onOptionSelected?.call('delete');
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.textPrimaryLight, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTheme.bodyLarge.copyWith(
                color: color ?? AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
     final cardColor = _getCardColor();
        
        return Container(
          margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.8), // Color con transparencia para glassmorphism
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: cardColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cardColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onLongPress: () => _showOptions(context),
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                      // Contenido principal
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header con usuario y pin
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.accentPrimaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      createdBy.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  createdBy,
                                  style: AppTheme.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 8),
                                Text("•", style: AppTheme.bodySmall),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: AppColors.textPrimaryLight
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(createdAt),
                                  style: AppTheme.bodySmall,
                                ),
                              ],
                            ),
                            // Fecha
                            const SizedBox(height: 12),
                            // Título
                            Text(
                              title,
                              style: AppTheme.heading3.copyWith(fontSize: 18),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            // Contenido
                            Text(
                              content,
                              style: AppTheme.bodyMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isPinned)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: IconButton(
                            icon: Icon(
                              Icons.push_pin,
                              color: AppColors.textPrimaryLight,
                              size: 16,
                            ),
                            onPressed: (() => print("pinned")),
                          ),
                        ),

                      // Sticker en la esquina inferior derecha
                      if (sticker != null && sticker!.isNotEmpty)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Image.asset(
                            Stickers.getPath(sticker!),
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );  }
}
