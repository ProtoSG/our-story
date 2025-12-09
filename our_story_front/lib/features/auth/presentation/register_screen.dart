import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/toast_bar.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/register_request.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      AppToast.showError(
        context,
        message: 'Las contraseñas no coinciden',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final registerRequest = RegisterRequest(
        username: _usernameController.text.trim(),
        passwordHash: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      final response = await _authRepository.register(registerRequest);

      if (mounted) {
        AppToast.showSuccess(
          context,
          message: '¡Bienvenido, ${response.fullName}!',
        );

        // Navigate based on couple status
        if (response.hasActiveCouple) {
          context.go('/home');
        } else {
          context.go('/pairing');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        AppToast.showError(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimaryLight),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
            decoration: AppTheme.gradientBackground,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Column(
                  children: [
                    // Title
                    Text(
                      'Crear Cuenta',
                      style: AppTheme.heading1.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: AppSizes.paddingS),
                    Text(
                      'Únete y comienza a capturar tus momentos especiales',
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSizes.paddingXL),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.paddingXL),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCardLight.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // First Name
                              CustomTextField(
                                hintText: 'Tu nombre',
                                controller: _firstNameController,
                                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.accentPrimaryLight),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Por favor ingresa tu nombre';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'El nombre debe tener al menos 2 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingM),

                              // Last Name
                              CustomTextField(
                                hintText: 'Tu apellido',
                                controller: _lastNameController,
                                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.accentPrimaryLight),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Por favor ingresa tu apellido';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'El apellido debe tener al menos 2 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingM),

                              // Username
                              CustomTextField(
                                hintText: 'Tu username',
                                controller: _usernameController,
                                keyboardType: TextInputType.text,
                                prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.accentPrimaryLight),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Por favor ingresa tu username';
                                  }
                                  if (value.trim().length < 3) {
                                    return 'El username debe tener al menos 3 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingM),

                              // Password
                              CustomTextField(
                                hintText: 'Mínimo 6 caracteres',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.accentPrimaryLight),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa una contraseña';
                                  }
                                  if (value.length < 6) {
                                    return 'La contraseña debe tener al menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingM),

                              // Confirm Password
                              CustomTextField(
                                hintText: 'Repite tu contraseña',
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.accentPrimaryLight),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor confirma tu contraseña';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Las contraseñas no coinciden';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingXL),

                              CustomButton(
                                text: 'Crear Cuenta',
                                onPressed: _handleRegister,
                                isLoading: _isLoading,
                                isGradient: true,
                              ),
                              const SizedBox(height: AppSizes.paddingL),

                              // Login link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '¿Ya tienes cuenta?',
                                    style: AppTheme.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Inicia Sesión',
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppColors.accentPrimaryLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ],
                  )
                ),
              ),
              ),
            ),
          );
  }
}
