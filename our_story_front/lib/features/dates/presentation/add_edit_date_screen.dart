import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../data/models/date_model.dart';
import '../data/models/date_media_model.dart';
import '../data/repositories/date_repository.dart';
import '../data/repositories/date_media_repository.dart';
import 'widgets/location_picker.dart';

class AddEditDateScreen extends StatefulWidget {
  final int? coupleId;
  final int? userId;
  final DateModel? date;

  const AddEditDateScreen({
    super.key,
    this.coupleId,
    this.userId,
    this.date,
  });

  @override
  State<AddEditDateScreen> createState() => _AddEditDateScreenState();
}

class _AddEditDateScreenState extends State<AddEditDateScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  final DateRepository _dateRepository = DateRepository();
  final DateMediaRepository _dateMediaRepository = DateMediaRepository();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  DateTime? _selectedDate;
  int? _selectedRating;
  String? _selectedCategory;
  double? _selectedLatitude;
  double? _selectedLongitude;
  bool get _isEditMode => widget.date != null;
  
  // Selected images to upload
  final List<XFile> _selectedImages = [];
  List<DateMediaModel> _existingMedia = [];
  
  // Date image (place/location image)
  XFile? _selectedDateImage;
  String? _existingDateImageUrl;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Romántica', 'icon': Icons.favorite_rounded, 'color': Color(0xFFFF6B9D), 'emoji': '💕'},
    {'name': 'Diversión', 'icon': Icons.celebration_rounded, 'color': Color(0xFFFFB74D), 'emoji': '🎉'},
    {'name': 'Aventura', 'icon': Icons.explore_rounded, 'color': Color(0xFF66BB6A), 'emoji': '🌍'},
    {'name': 'Cultural', 'icon': Icons.museum_rounded, 'color': Color(0xFFBA68C8), 'emoji': '🎨'},
    {'name': 'Comida', 'icon': Icons.restaurant_rounded, 'color': Color(0xFFFF7043), 'emoji': '🍽️'},
    {'name': 'Relax', 'icon': Icons.spa_rounded, 'color': Color(0xFF81C784), 'emoji': '🧘'},
  ];

  @override
  void initState() {
    super.initState();
    
    if (_isEditMode) {
      _titleController = TextEditingController(text: widget.date!.title);
      _descriptionController = TextEditingController(text: widget.date!.description);
      _locationController = TextEditingController(text: widget.date!.location ?? '');
      _selectedDate = widget.date!.date;
      _selectedRating = widget.date!.rating;
      _selectedCategory = widget.date!.category;
      _selectedLatitude = widget.date!.latitude;
      _selectedLongitude = widget.date!.longitude;
      _existingDateImageUrl = widget.date!.dateImage;
      _loadExistingMedia();
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _locationController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accentPrimaryLight,
              onPrimary: AppColors.textPrimaryLight,
              surface: AppColors.backgroundCardLight,
              onSurface: AppColors.textPrimaryLight,
            ),
            dialogBackgroundColor: AppColors.backgroundCardLight,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectLocation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPicker(
          initialLatitude: _selectedLatitude,
          initialLongitude: _selectedLongitude,
          initialAddress: _locationController.text,
          onLocationSelected: (latitude, longitude, address) {
            setState(() {
              _selectedLatitude = latitude;
              _selectedLongitude = longitude;
              _locationController.text = address;
            });
          },
        ),
      ),
    );
  }

  Future<void> _loadExistingMedia() async {
    if (!_isEditMode || widget.date?.id == null) return;
    
    try {
      final media = await _dateMediaRepository.getMediaByDateId(widget.date!.id!);
      setState(() {
        _existingMedia = media;
      });
    } catch (e) {
      // Error loading media, continue without images
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imágenes: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickDateImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _selectedDateImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen del lugar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickDateImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _selectedDateImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto del lugar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeDateImage() {
    setState(() {
      _selectedDateImage = null;
      _existingDateImageUrl = null;
    });
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _deleteExistingMedia(int mediaId, int index) async {
    try {
      await _dateMediaRepository.deleteMedia(mediaId);
      setState(() {
        _existingMedia.removeAt(index);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagen eliminada'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _uploadImages(int dateId) async {
    if (_selectedImages.isEmpty) return;

    try {
      for (int i = 0; i < _selectedImages.length; i++) {
        final image = _selectedImages[i];
        await _dateMediaRepository.uploadMedia(
          file: File(image.path),
          dateId: dateId,
          mediaType: 'IMAGE',
          uploadedBy: widget.userId ?? 0,
          orderIndex: _existingMedia.length + i,
        );
      }
      
      _selectedImages.clear();
      
      // Reload media after upload
      await _loadExistingMedia();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir imágenes: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _uploadDateImage(int dateId) async {
    if (_selectedDateImage == null) return;

    try {
      await _dateRepository.updateDateImage(
        dateId: dateId,
        imageFile: File(_selectedDateImage!.path),
      );
      
      // Clear the selected image after successful upload
      setState(() {
        _existingDateImageUrl = _selectedDateImage!.path;
        _selectedDateImage = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir imagen del lugar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveDate() async {
    // Validación básica
    if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa el título y descripción'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditMode) {
        final updatedDate = widget.date!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
          latitude: _selectedLatitude,
          longitude: _selectedLongitude,
          date: _selectedDate,
          rating: _selectedRating,
          category: _selectedCategory,
        );
        
        await _dateRepository.updateDate(widget.date!.id!, updatedDate);
        
        // Upload date image if a new one was selected
        if (_selectedDateImage != null) {
          await _uploadDateImage(widget.date!.id!);
        }
        
        // Upload new images if any
        if (_selectedImages.isNotEmpty) {
          await _uploadImages(widget.date!.id!);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Cita actualizada exitosamente!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        final date = DateModel(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
          latitude: _selectedLatitude,
          longitude: _selectedLongitude,
          date: _selectedDate,
          rating: _selectedRating,
          category: _selectedCategory,
        );

        final createdDate = await _dateRepository.createDate(date);
        
        // Upload date image if one was selected
        if (_selectedDateImage != null && createdDate.id != null) {
          await _uploadDateImage(createdDate.id!);
        }
        
        // Upload images if any
        if (_selectedImages.isNotEmpty && createdDate.id != null) {
          await _uploadImages(createdDate.id!);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Cita guardada exitosamente!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteDate() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Cita'),
        content: const Text('¿Estás seguro de que quieres eliminar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _dateRepository.deleteDate(widget.date!.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita eliminada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getCategoryColor() {
    if (_selectedCategory == null) return AppColors.textPrimaryLight;
    
    final category = _categories.firstWhere(
      (cat) => cat['name'] == _selectedCategory,
      orElse: () => _categories[0],
    );
    return category['color'] as Color;
  }

  IconData _getCategoryIcon() {
    if (_selectedCategory == null) return Icons.event_rounded;
    
    final category = _categories.firstWhere(
      (cat) => cat['name'] == _selectedCategory,
      orElse: () => _categories[0],
    );
    return category['icon'] as IconData;
  }

  String _getCategoryEmoji() {
    if (_selectedCategory == null) return '📅';
    
    final category = _categories.firstWhere(
      (cat) => cat['name'] == _selectedCategory,
      orElse: () => _categories[0],
    );
    return category['emoji'] as String;
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundCardLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            // border: Border.all(
            //   color: AppColors.cardBorder.withOpacity(0.5),
            //   width: 1.5,
            // ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    final totalPhotos = _existingMedia.length + _selectedImages.length;
    
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_library_rounded, color: AppColors.textPrimaryLight, size: 22),
              const SizedBox(width: 8),
              Text('Fotos', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (totalPhotos > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimaryLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalPhotos',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Photo Grid
          if (totalPhotos > 0) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: totalPhotos,
              itemBuilder: (context, index) {
                final isExisting = index < _existingMedia.length;
                
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (isExisting)
                        Image.network(
                          _existingMedia[index].mediaUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.backgroundCardLight,
                            child: const Icon(Icons.error, color: AppColors.error),
                          ),
                        )
                      else
                        Image.file(
                          File(_selectedImages[index - _existingMedia.length].path),
                          fit: BoxFit.cover,
                        ),
                      
                      // Delete overlay
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            if (isExisting) {
                              _deleteExistingMedia(_existingMedia[index].id!, index);
                            } else {
                              _removeSelectedImage(index - _existingMedia.length);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
          
          // Add Photo Buttons
          Row(
            children: [
              Expanded(
                child: _buildPhotoButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Galería',
                  onTap: _pickImages,
                  color: AppColors.accentPrimaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPhotoButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Cámara',
                  onTap: _pickCamera,
                  color: AppColors.accentPrimaryLight,
                ),
              ),
            ],
          ),
          
          if (totalPhotos == 0) ...[
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega fotos de tu experiencia',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.5),
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

  Widget _buildDateImageSection() {
    final hasImage = _selectedDateImage != null || _existingDateImageUrl != null;
    
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.place_rounded, color: AppColors.error, size: 22),
              const SizedBox(width: 8),
              Text('Imagen del Lugar', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Sube una foto del lugar de la cita',
            style: AppTheme.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          
          // Image preview
          if (hasImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _selectedDateImage != null
                        ? Image.file(
                            File(_selectedDateImage!.path),
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            _existingDateImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.backgroundCardLight,
                              child: const Icon(Icons.error, color: AppColors.error),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _removeDateImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Add Image Buttons
          Row(
            children: [
              Expanded(
                child: _buildPhotoButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Galería',
                  onTap: _pickDateImage,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPhotoButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Cámara',
                  onTap: _pickDateImageFromCamera,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          
          if (!hasImage) ...[
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Opcional: Agrega una foto del lugar',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          extendBody: true,
          body: Container(
            decoration: AppTheme.gradientBackground,
            child: Column(
          children: [
            // Custom AppBar
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textPrimaryLight, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    if (_isEditMode)
                      IconButton(
                        icon: const Icon(Icons.delete_rounded, color: AppColors.error, size: 26),
                        onPressed: _deleteDate,
                      ),
                  ],
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with emoji/icon
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getCategoryColor().withOpacity(0.3),
                              _getCategoryColor().withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getCategoryColor().withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getCategoryEmoji(),
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingXL),
                    
                    // Title input
                    Text(
                      _isEditMode ? 'Editar Experiencia' : 'Nueva Experiencia',
                      style: AppTheme.heading1.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    Text(
                      'Captura los momentos especiales que viven juntos',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingXL),
                    
                    // Title Card
                    _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.title_rounded, color: AppColors.textPrimaryLight, size: 22),
                              const SizedBox(width: 8),
                              Text('Título', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _titleController,
                            style: AppTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: 'Ej: Cena romántica en la playa',
                              hintStyle: TextStyle(color: AppColors.textSecondaryLight),
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,

                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingM),
                    
                    // Description Card
                    _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description_rounded, color: AppColors.accentPrimaryLight, size: 22),
                              const SizedBox(width: 8),
                              Text('Descripción', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _descriptionController,
                            style: AppTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Cuenta tu experiencia...',
                              hintStyle: TextStyle(color: AppColors.textSecondaryLight),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                            maxLines: 5,
                            maxLength: 500,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingM),
                    
                    // Location and Date Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildGlassCard(
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.calendar_today_rounded, color: AppColors.accentPrimaryLight, size: 24),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Fecha',
                                    style: AppTheme.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedDate != null
                                        ? DateFormat('dd MMM', 'es').format(_selectedDate!)
                                        : 'Seleccionar',
                                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGlassCard(
                            child: InkWell(
                              onTap: _selectLocation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on_rounded, color: AppColors.error, size: 24),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ubicación',
                                    style: AppTheme.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _locationController.text.isEmpty 
                                        ? 'Seleccionar' 
                                        : _locationController.text,
                                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.paddingM),
                    
                    // Category Selection
                    _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.category_rounded, color: AppColors.accentPrimaryLight, size: 22),
                              const SizedBox(width: 8),
                              Text('Categoría', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categories.map((category) {
                              final isSelected = _selectedCategory == category['name'];
                              final categoryColor = category['color'] as Color;
                              final categoryEmoji = category['emoji'] as String;
                              final categoryName = category['name'] as String;
                              
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = isSelected ? null : categoryName;
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: [categoryColor.withOpacity(0.3), categoryColor.withOpacity(0.1)],
                                          )
                                        : null,
                                    color: isSelected ? null : AppColors.backgroundCardLight.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                    // border: Border.all(
                                    //   color: isSelected ? categoryColor : AppColors.cardBorder.withOpacity(0.3),
                                    //   width: 1.5,
                                    // ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(categoryEmoji, style: const TextStyle(fontSize: 18)),
                                      const SizedBox(width: 6),
                                      Text(
                                        categoryName,
                                        style: AppTheme.bodyMedium.copyWith(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? categoryColor : AppColors.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingM),
                    
                    // Date Image Section
                    _buildDateImageSection(),
                    
                    const SizedBox(height: AppSizes.paddingM),
                    
                    // Rating
                    _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                              const SizedBox(width: 8),
                              Text('Calificación', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(5, (index) {
                              final rating = index + 1;
                              final isSelected = _selectedRating == rating;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedRating = isSelected ? null : rating;
                                  });
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isSelected
                                        ? const LinearGradient(
                                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                          )
                                        : null,
                                    color: isSelected ? null : AppColors.backgroundCardLight.withOpacity(0.3),
                                    // border: Border.all(
                                    //   color: isSelected ? Colors.amber : AppColors.cardBorder.withOpacity(0.3),
                                    //   width: 2,
                                    // ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.star_rounded,
                                      color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.paddingM),
                    
                    // Photos Section
                    _buildPhotosSection(),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveDate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentPrimaryLight,
            foregroundColor: AppColors.textPrimaryLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 8,
            shadowColor: AppColors.accentPrimaryLight.withOpacity(0.4),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isEditMode ? Icons.check_rounded : Icons.add_rounded, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      _isEditMode ? 'Actualizar Experiencia' : 'Guardar Experiencia',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );  }
}
