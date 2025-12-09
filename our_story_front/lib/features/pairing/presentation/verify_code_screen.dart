import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/toast_bar.dart';
import '../data/models/verify_pairing_code.dart';
import '../data/repositories/pairing_repository.dart';
import 'widgets/code_input_widget.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({Key? key}) : super(key: key);

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _pairingRepository = PairingRepository();
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join('');

  Future<void> _verifyCode() async {
    final code = _code;

    if (code.length < 6) {
      AppToast.showError(
        context,
        message: 'Por favor completa el código de 6 caracteres',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = VerifyPairingCode(verificationCode: code);
      final couple = await _pairingRepository.verifyPairingCode(request);

      if (mounted) {
        AppToast.showSuccess(
          context,
          message: '¡Emparejado exitosamente con ${couple.coupleName}!',
        );

        // Navegar a la pantalla principal usando GoRouter
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Limpiar campos en caso de error
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();

      if (mounted) {
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
          extendBody: true,
          body: Container(
            decoration: AppTheme.gradientBackground,
            child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.paddingXL),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCardLight.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(30),
                      // border: Border.all(
                      //   color: AppColors.cardBorder,
                      //   width: 1.5,
                      // ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo y título
                        Text(
                          'OurStory',
                          style: AppTheme.heading1.copyWith(
                            fontSize: 42,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Conecta con tu pareja',
                          style: AppTheme.bodyLarge,
                        ),
                        const SizedBox(height: 40),

                        // Instrucción
                        Text(
                          'Ingresa el código de verificación',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Widget de código
                        CodeInputWidget(
                          controllers: _controllers,
                          focusNodes: _focusNodes,
                        ),
                        const SizedBox(height: 40),

                        // Botón Vincular
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentPrimaryLight,
                              foregroundColor: AppColors.textPrimaryLight,
                              disabledBackgroundColor: AppColors.accentPrimaryLight.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.textPrimaryLight,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Vincular',
                                    style: AppTheme.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Botón volver
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Volver',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppColors.textPrimaryLight,
                            ),
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
      ),
    );  }
}
