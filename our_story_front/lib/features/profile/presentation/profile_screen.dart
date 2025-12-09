import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:our_story_front/shared/widgets/toast_bar.dart';
import 'dart:ui';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/user_service.dart';
import '../../auth/data/repositories/auth_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final AuthRepository _authRepository = AuthRepository();
  
  bool _isLoading = true;
  String? _firstName;
  String? _lastName;
  String? _username;
  int? _userId;
  int? _coupleId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final userData = await _userService.getCurrentUserData();
      if (userData != null) {
        setState(() {
          _userId = userData['userId'] as int?;
          _username = userData['username'] as String?;
          _firstName = userData['firstName'] as String?;
          _lastName = userData['lastName'] as String?;
          _coupleId = userData['coupleId'] as int?;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          context.go('/login');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppToast.showError(context, message: 'Error al cargar datos');
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildLogoutDialog(),
    );

    if (confirmed == true) {
      try {
        await _authRepository.logout();
        if (mounted) {
          AppToast.showSuccess(context, message: 'Sesión cerrada');
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          AppToast.showError(context, message: 'Error al cerrar sesión');
        }
      }
    }
  }

  Future<void> _handleUnpair() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildUnpairDialog(),
    );

    if (confirmed == true) {
      if (mounted) {
        AppToast.showInfo(context, message: 'Función de desemparejar por implementar');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accentPrimaryLight,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSizes.paddingM),
                      _buildProfileHeader(),
                      const SizedBox(height: AppSizes.paddingXL),
                      _buildInfoSection(),
                      const SizedBox(height: AppSizes.paddingL),
                      _buildCoupleSection(),
                      const SizedBox(height: AppSizes.paddingL),
                      _buildSettingsSection(),
                      const SizedBox(height: AppSizes.paddingXL),
                      _buildLogoutButton(),
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final initials = _getInitials();
    
    return Column(
      children: [
        // Avatar with glassmorphism
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentPrimaryLight.withValues(alpha: 0.8),
                AppColors.accentSecondaryLight.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPrimaryLight.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        // Name
        Text(
          '$_firstName $_lastName',
          style: AppTheme.heading1.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.paddingXS),
        // Username
        Text(
          '@$_username',
          style: AppTheme.bodyMedium.copyWith(
            color: AppColors.textSecondaryLight,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.accentPrimaryLight,
                size: 24,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                'Información Personal',
                style: AppTheme.heading3,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'Nombre Completo',
            value: '$_firstName $_lastName',
          ),
          const Divider(height: 32, color: AppColors.textSecondaryLight),
          _buildInfoRow(
            icon: Icons.alternate_email,
            label: 'Usuario',
            value: '@$_username',
          ),
          const Divider(height: 32, color: AppColors.textSecondaryLight),
          _buildInfoRow(
            icon: Icons.tag,
            label: 'ID de Usuario',
            value: '#$_userId',
          ),
        ],
      ),
    );
  }

  Widget _buildCoupleSection() {
    final hasCoupleId = _coupleId != null;
    
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                color: AppColors.accentPrimaryLight,
                size: 24,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                'Estado de Pareja',
                style: AppTheme.heading3,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          if (hasCoupleId) ...[
            _buildInfoRow(
              icon: Icons.check_circle_outline,
              label: 'Estado',
              value: 'Emparejado',
              valueColor: AppColors.success,
            ),
            const Divider(height: 32, color: AppColors.textSecondaryLight),
            _buildInfoRow(
              icon: Icons.people_outline,
              label: 'ID de Pareja',
              value: '#$_coupleId',
            ),
            const SizedBox(height: AppSizes.paddingM),
            // Unpair button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleUnpair,
                icon: const Icon(Icons.link_off),
                label: const Text('Desemparejar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            _buildInfoRow(
              icon: Icons.cancel_outlined,
              label: 'Estado',
              value: 'Sin pareja',
              valueColor: AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppSizes.paddingM),
            // Pair button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/pairing'),
                icon: const Icon(Icons.link),
                label: const Text('Emparejar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPrimaryLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings_outlined,
                color: AppColors.accentPrimaryLight,
                size: 24,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                'Configuración',
                style: AppTheme.heading3,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildSettingsTile(
            icon: Icons.edit_outlined,
            title: 'Editar Perfil',
            onTap: () {
              AppToast.showInfo(context, message: 'Función por implementar');
            },
          ),
          const Divider(height: 1, color: AppColors.textSecondaryLight),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            onTap: () {
              AppToast.showInfo(context, message: 'Función por implementar');
            },
          ),
          const Divider(height: 1, color: AppColors.textSecondaryLight),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Privacidad y Seguridad',
            onTap: () {
              AppToast.showInfo(context, message: 'Función por implementar');
            },
          ),
          const Divider(height: 1, color: AppColors.textSecondaryLight),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Ayuda y Soporte',
            onTap: () {
              AppToast.showInfo(context, message: 'Función por implementar');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar Sesión'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.paddingM + 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            color: AppColors.backgroundCardLight.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.accentSecondaryLight,
        ),
        const SizedBox(width: AppSizes.paddingS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.paddingM,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.accentSecondaryLight,
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutDialog() {
    return AlertDialog(
      backgroundColor: AppColors.backgroundCardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(
            Icons.logout,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSizes.paddingS),
          const Text('Cerrar Sesión'),
        ],
      ),
      content: const Text(
        '¿Estás seguro que deseas cerrar sesión?',
        style: AppTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancelar',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Cerrar Sesión'),
        ),
      ],
    );
  }

  Widget _buildUnpairDialog() {
    return AlertDialog(
      backgroundColor: AppColors.backgroundCardLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(
            Icons.link_off,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSizes.paddingS),
          const Text('Desemparejar'),
        ],
      ),
      content: const Text(
        '¿Estás seguro que deseas desemparejarte? Esta acción no se puede deshacer.',
        style: AppTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancelar',
            style: AppTheme.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Desemparejar'),
        ),
      ],
    );
  }

  String _getInitials() {
    if (_firstName == null || _lastName == null) return '?';
    final first = _firstName!.isNotEmpty ? _firstName![0].toUpperCase() : '';
    final last = _lastName!.isNotEmpty ? _lastName![0].toUpperCase() : '';
    return '$first$last';
  }
}
