import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/user_service.dart';
import '../data/models/date_model.dart';
import '../data/repositories/date_repository.dart';
import 'widgets/timeline_date_card.dart';
import 'add_edit_date_screen.dart';
import 'date_detail_screen.dart';

class DatesScreen extends StatefulWidget {
  final bool showBottomNav;
  
  const DatesScreen({
    Key? key,
    this.showBottomNav = true,
  }) : super(key: key);

  @override
  State<DatesScreen> createState() => _DatesScreenState();
}

class _DatesScreenState extends State<DatesScreen> {
  final DateRepository _dateRepository = DateRepository();
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  List<DateModel> _dates = [];
  List<DateModel> _filteredDates = [];
  bool _isLoading = false;
  int _currentNavIndex = 2; // Index para calendario/dates

  int? _coupleId;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _initUserData();
    _searchController.addListener(_filterDates);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterDates() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDates = _dates;
      } else {
        _filteredDates = _dates.where((date) {
          return date.title.toLowerCase().contains(query) ||
                 date.description.toLowerCase().contains(query) ||
                 (date.location?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _initUserData() async {
    try {
      final userData = await _userService.getCurrentUserData();
      if (userData != null) {
        setState(() {
          _userId = userData['userId'] as int?;
          _coupleId = userData['coupleId'] as int?;
        });
        _loadDates();
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _loadDates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dates = await _dateRepository.getDatesByCouple();
      setState(() {
        _dates = dates;
        _filteredDates = dates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar citas: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _navigateToAddDate() async {

    final result = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AddEditDateScreen(),
      ),
    );

    if (result == true) {
      _loadDates();
    }
  }

  void _navigateToDateDetail(DateModel date) async {
    final result = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => DateDetailScreen(date: date),
        fullscreenDialog: true,
      ),
    );

    if (result == true) {
      _loadDates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: FloatingActionButton(
              heroTag: 'add-edit-date',
              backgroundColor: AppColors.textPrimaryLight,
              elevation: 0,
              onPressed: _navigateToAddDate,
              shape: CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: Container(
            decoration: AppTheme.gradientBackground,
            child: SafeArea(
              top: true,
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, child) {
                      return TextField(
                        controller: _searchController,
                        style: AppTheme.bodyMedium,
                        decoration: AppTheme.inputDecoration(
                          hintText: 'Buscar citas...',
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondaryLight),
                          suffixIcon: value.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondaryLight),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: AppSizes.paddingM),
                
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentPrimaryLight,
                        ),
                      )
                    : _filteredDates.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadDates,
                            color: AppColors.accentPrimaryLight,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(
                                top: AppSizes.paddingM,
                                left: AppSizes.paddingL,
                                right: AppSizes.paddingL,
                                bottom: 120,
                              ),
                              itemCount: _filteredDates.length + 1, // +1 for end marker
                              itemBuilder: (context, index) {
                                // End of timeline marker
                                if (index == _filteredDates.length) {
                                  return _buildTimelineEnd();
                                }
                                
                                final date = _filteredDates[index];
                                
                                // Check if this is the first date without a date (for separator)
                                bool showIdeasSeparator = false;
                                if (date.date == null && 
                                    (index == 0 || _filteredDates[index - 1].date != null)) {
                                  showIdeasSeparator = true;
                                }
                                
                                return Column(
                                  children: [
                                    if (showIdeasSeparator) _buildIdeasSeparator(),
                                    TimelineDateCard(
                                      title: date.title,
                                      description: date.description,
                                      location: date.location,
                                      date: date.date,
                                      rating: date.rating,
                                      category: date.category,
                                      dateImage: date.dateImage,
                                      createdBy: date.createdBy?.fullName ?? 'Usuario',
                                      onTap: () => _navigateToDateDetail(date),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
              ),
              ],
                        ),
            ),
        ),
      ),
      // El bottomNavigationBar ahora es manejado por ShellRoute en main.dart
      // No debe agregarse aquí directamente
      bottomNavigationBar: null,
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchController.text.isNotEmpty;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.event_note,
              size: 100,
              color: AppColors.accentPrimaryLight.withOpacity(0.3),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              isSearching ? 'No se encontraron citas' : 'No hay citas aún',
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
                  : 'Comienza a registrar tus experiencias juntos',
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

  Widget _buildTimelineEnd() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXL),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentPrimaryLight.withValues(alpha: 0.3),
                  AppColors.accentPrimaryLight.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(
                color: AppColors.accentPrimaryLight.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.flag_rounded,
              color: AppColors.accentPrimaryLight.withValues(alpha: 0.5),
              size: 24,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            'El comienzo de tu historia',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdeasSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.paddingL,
        horizontal: AppSizes.paddingM,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.accentSecondaryLight.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundCardLight.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accentSecondaryLight.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: AppColors.accentSecondaryLight,
                  ),
                  const SizedBox(width: AppSizes.paddingXS),
                  Text(
                    'Ideas & Planes',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentSecondaryLight.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
