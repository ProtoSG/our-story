import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../data/models/date_model.dart';
import '../data/models/date_media_model.dart';
import '../data/repositories/date_repository.dart';
import '../data/repositories/date_media_repository.dart';
import 'add_edit_date_screen.dart';

class DateDetailScreen extends ConsumerStatefulWidget {
  final DateModel date;

  const DateDetailScreen({
    super.key,
    required this.date,
  });

  @override
  ConsumerState<DateDetailScreen> createState() => _DateDetailScreenState();
}

class _DateDetailScreenState extends ConsumerState<DateDetailScreen> 
    with SingleTickerProviderStateMixin {
  final DateRepository _dateRepository = DateRepository();
  final DateMediaRepository _mediaRepository = DateMediaRepository();
  List<DateMediaModel> _mediaList = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _loadMedia();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMedia() async {
    if (widget.date.id == null) return;

    try {
      final media = await _mediaRepository.getMediaByDateId(widget.date.id!);
      if (mounted) {
        setState(() {
          _mediaList = media;
        });
      }
    } catch (e) {
      // Silently fail - media is optional
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';
    final formatter = DateFormat('EEEE, dd MMMM yyyy', 'es');
    return formatter.format(date);
  }

  Color _getCategoryColor() {
    switch (widget.date.category?.toLowerCase()) {
      case 'romantic':
      case 'romántica':
        return const Color(0xFFE91E63);
      case 'fun':
      case 'diversión':
        return const Color(0xFFFF9800);
      case 'adventure':
      case 'aventura':
        return const Color(0xFF4CAF50);
      case 'cultural':
        return const Color(0xFF9C27B0);
      case 'food':
      case 'comida':
        return const Color(0xFFFF5722);
      default:
        return AppColors.accentPrimaryLight;
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.date.category?.toLowerCase()) {
      case 'romantic':
      case 'romántica':
        return Icons.favorite;
      case 'fun':
      case 'diversión':
        return Icons.celebration;
      case 'adventure':
      case 'aventura':
        return Icons.explore;
      case 'cultural':
        return Icons.museum;
      case 'food':
      case 'comida':
        return Icons.restaurant;
      default:
        return Icons.event;
    }
  }

  void _navigateToEdit() async {
    final result = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => AddEditDateScreen(date: widget.date),
        fullscreenDialog: true,
      ),
    );

    if (result == true && mounted) {
      // Recargar datos si se editó
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteDate() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          '¿Eliminar cita?',
          style: AppTheme.heading3,
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${widget.date.title}"? Esta acción no se puede deshacer.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondaryLight),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _dateRepository.deleteDate(widget.date.id!);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Custom AppBar
                _buildAppBar(),
                
                // Content
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Main Date Image Hero Section
                      if (widget.date.dateImage != null)
                        SliverToBoxAdapter(
                          child: _buildMainImage(),
                        ),
                      
                      // Content
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingL),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category & Date Tags
                              _buildTags(),
                              
                              const SizedBox(height: AppSizes.paddingL),
                              
                              // Title
                              _buildTitle(),
                              
                              const SizedBox(height: AppSizes.paddingM),
                              
                              // Location & Rating Row
                              _buildLocationAndRating(),
                              
                              const SizedBox(height: AppSizes.paddingL),
                              
                              // Description Card
                              _buildDescriptionCard(),
                              
                              const SizedBox(height: AppSizes.paddingL),
                              
                              // Map Section
                              if (widget.date.latitude != null && widget.date.longitude != null)
                                _buildMapSection(),
                              
                              if (widget.date.latitude != null && widget.date.longitude != null)
                                const SizedBox(height: AppSizes.paddingL),
                              
                              // Instagram-style Grid Gallery
                              if (_mediaList.isNotEmpty) ...[
                                _buildGalleryHeader(),
                                const SizedBox(height: AppSizes.paddingM),
                                _buildInstagramGrid(),
                                const SizedBox(height: AppSizes.paddingL),
                              ],
                              
                              // Created By Footer
                              _buildFooter(),
                              
                              const SizedBox(height: 100), // Padding bottom for FAB
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.backgroundCardLight.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimaryLight,
                size: 24,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.backgroundCardLight.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: AppColors.accentPrimaryLight,
                size: 24,
              ),
            ),
            onPressed: _navigateToEdit,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.backgroundCardLight.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: AppColors.error,
                size: 24,
              ),
            ),
            onPressed: _deleteDate,
          ),
        ],
      ),
    );
  }

  Widget _buildMainImage() {
    return GestureDetector(
      onTap: () {
        if (widget.date.dateImage != null) {
          _showFullscreenImage(widget.date.dateImage!);
        }
      },
      child: Hero(
        tag: 'date_main_image_${widget.date.id}',
        child: Container(
          height: 350,
          margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.date.dateImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCardLight,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          size: 64,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    );
                  },
                ),
                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Tap to expand hint
                Positioned(
                  top: 16,
                  right: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fullscreen_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Tocar para ampliar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryHeader() {
    return Row(
      children: [
        Icon(
          Icons.photo_library_rounded,
          size: 24,
          color: AppColors.accentPrimaryLight,
        ),
        const SizedBox(width: 8),
        Text(
          'Galería',
          style: AppTheme.heading2.copyWith(fontSize: 20),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accentPrimaryLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_mediaList.length}',
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.accentPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstagramGrid() {
    if (_mediaList.isEmpty) return const SizedBox.shrink();

    // Instagram-style uniform grid (3 columns)
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1.0, // Square images
      ),
      itemCount: _mediaList.length > 9 ? 9 : _mediaList.length,
      itemBuilder: (context, index) {
        final isLastItem = index == 8 && _mediaList.length > 9;
        
        return GestureDetector(
          onTap: () => _showGalleryDialog(index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  _mediaList[index].mediaUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder();
                  },
                ),
                // Show "+N" overlay on last item if there are more than 9 images
                if (isLastItem)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '+${_mediaList.length - 9}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
  }

  Widget _buildMapSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundCardLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.map_rounded,
                    color: const Color(0xFF4CAF50),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ubicación en el Mapa',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 250,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        widget.date.latitude!,
                        widget.date.longitude!,
                      ),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('date_location'),
                        position: LatLng(
                          widget.date.latitude!,
                          widget.date.longitude!,
                        ),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRose,
                        ),
                        infoWindow: InfoWindow(
                          title: widget.date.title,
                          snippet: widget.date.location,
                        ),
                      ),
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                  ),
                ),
              ),
              if (widget.date.location != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 16,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.date.location!,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCardLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          color: AppColors.textSecondaryLight,
          size: 48,
        ),
      ),
    );
  }

  void _showFullscreenImage(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _SingleImageDialog(imageUrl: imageUrl),
    );
  }

  void _showGalleryDialog(int initialIndex) {
    if (_mediaList.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _ImageGalleryDialog(
        mediaList: _mediaList,
        initialIndex: initialIndex,
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (widget.date.date != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentPrimaryLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accentPrimaryLight.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.accentPrimaryLight,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(widget.date.date),
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        if (widget.date.category != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getCategoryColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getCategoryColor().withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(),
                  size: 18,
                  color: _getCategoryColor(),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.date.category!,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getCategoryColor(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.date.title,
      style: AppTheme.heading1.copyWith(
        fontSize: 32,
        height: 1.2,
      ),
    );
  }

  Widget _buildLocationAndRating() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Location
        if (widget.date.location != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 20,
                  color: Color(0xFF4CAF50),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.date.location!,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4CAF50),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        // Rating
        if (widget.date.rating != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Icon(
                      index < widget.date.rating!
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 20,
                      color: Colors.amber.shade700,
                    ),
                  );
                }),
                const SizedBox(width: 6),
                Text(
                  '${widget.date.rating}/5',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            color: AppColors.backgroundCardLight.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.backgroundCardLight.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description_rounded,
                    size: 20,
                    color: AppColors.accentPrimaryLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Descripción',
                    style: AppTheme.heading3.copyWith(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                widget.date.description,
                style: AppTheme.bodyLarge.copyWith(
                  height: 1.6,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.backgroundCardLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimaryLight.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: AppColors.accentPrimaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Creado por',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      widget.date.createdBy?.fullName ?? 'Desconocido',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.date.createdAt != null)
                Text(
                  DateFormat('dd MMM yyyy', 'es').format(widget.date.createdAt!),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Single Image Dialog (for main date image)
class _SingleImageDialog extends StatelessWidget {
  final String imageUrl;

  const _SingleImageDialog({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

// Image Gallery Dialog
class _ImageGalleryDialog extends StatefulWidget {
  final List<DateMediaModel> mediaList;
  final int initialIndex;

  const _ImageGalleryDialog({
    required this.mediaList,
    required this.initialIndex,
  });

  @override
  State<_ImageGalleryDialog> createState() => _ImageGalleryDialogState();
}

class _ImageGalleryDialogState extends State<_ImageGalleryDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Images
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaList.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    widget.mediaList[index].mediaUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Counter
          if (widget.mediaList.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.mediaList.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
