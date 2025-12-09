import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:our_story_front/core/constants/app_colors.dart';
import 'package:our_story_front/core/constants/app_sizes.dart';
import 'package:our_story_front/core/theme/app_theme.dart';

class ImagePickerModal extends StatefulWidget {
  final XFile? initialImage;
  final Function(XFile?) onImageSelected;
  final Function(XFile)? onSave;

  const ImagePickerModal({
    super.key,
    this.initialImage,
    required this.onImageSelected,
    this.onSave,
  });

  @override
  State<ImagePickerModal> createState() => _ImagePickerModalState();
}

class _ImagePickerModalState extends State<ImagePickerModal> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
        widget.onImageSelected(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _saveImage() async {
    if (_selectedImage != null && widget.onSave != null) {
      widget.onSave!(_selectedImage!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppSizes.paddingXL,
        left: AppSizes.paddingXL,
        right: AppSizes.paddingXL,
        bottom: 60,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Selecciona una imagen', style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),
          
          _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.file(
                  File(_selectedImage!.path),
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
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: Icon(
                    Icons.photo_rounded,
                    size: 40,
                    color: AppColors.shadowLight,
                  ),
                ),
              ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildPhotoButton(
                  icon: Icons.photo_library_rounded,
                  label: "Galería",
                  onTap: _pickImage,
                  color: AppColors.accentPrimaryLight,
                ),
              ),
              const SizedBox(width: 12),
            
              Expanded(
                child: _buildPhotoButton(
                  icon: Icons.save_rounded,
                  label: "Guardar",
                  onTap: _selectedImage != null ? _saveImage : null,
                  color: AppColors.accentSpecialLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              onTap != null ? color.withOpacity(0.3) : color.withOpacity(0.2),
              onTap != null ? color.withOpacity(0.1) : color.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onTap != null ? color.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
