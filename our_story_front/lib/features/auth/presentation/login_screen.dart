import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/toast_bar.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/login_request.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final loginRequest = LoginRequest(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      final response = await _authRepository.login(loginRequest);

      if (mounted) {
        AppToast.showSuccess(
          context,
          message: '¡Bienvenido de nuevo, ${response.fullName}!',
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
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                children: [
                  Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      width: 340,
                  ),
                  const SizedBox(height: 40),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(
                          left: AppSizes.paddingXL, 
                          right: AppSizes.paddingXL, 
                          bottom: AppSizes.paddingXL,
                          top: 84
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCardLight.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              // Username field
                              TextFormField(
                                controller: _usernameController,
                                keyboardType: TextInputType.text,
                                style: AppTheme.bodyMedium,
                                decoration: AppTheme.inputDecoration(
                                  hintText: 'Username',
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                    color: AppColors.accentPrimaryLight,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa tu username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingM),
                              
                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: AppTheme.bodyMedium,
                                decoration: AppTheme.inputDecoration(
                                  hintText: AppStrings.password,
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: AppColors.accentPrimaryLight,
                                  ),
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
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa tu contraseña';
                                  }
                                  if (value.length < 6) {
                                    return 'La contraseña debe tener al menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSizes.paddingXL),
                              
                              // Login button
                              CustomButton(
                                text: AppStrings.login,
                                onPressed: _handleLogin,
                                isLoading: _isLoading,
                                isGradient: true,
                              ),
                              const SizedBox(height: AppSizes.paddingL),
                              
                              // Register link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.noAccount,
                                    style: AppTheme.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.push('/register');
                                    },
                                    child: Text(
                                      AppStrings.register,
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

                      Positioned(
                        top: -100,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SizedBox(
                            width: 220,
                            child: Image.asset(
                              "assets/images/cabana.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
