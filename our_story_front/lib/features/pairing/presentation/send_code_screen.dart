import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/toast_bar.dart';
import '../data/models/send_pairing_request.dart';
import '../data/repositories/pairing_repository.dart';
import 'verify_code_screen.dart';

class SendCodeScreen extends StatefulWidget {
  const SendCodeScreen({Key? key}) : super(key: key);
  @override
  State<SendCodeScreen> createState() => _SendCodeScreenState();
}
class _SendCodeScreenState extends State<SendCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _pairingRepository = PairingRepository();
  bool _isLoading = false;
  String? _generatedCode;
  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
  Future<void> _sendRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final request = SendPairingRequest(
        recipientUsername: _usernameController.text.trim(),
      );
      final response = await _pairingRepository.sendPairingRequest(request);
      setState(() {
        _generatedCode = response.verificationCode;
        _isLoading = false;
      });
      if (mounted) {
        AppToast.showSuccess(
          context,
          message: '¡Código generado exitosamente!',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        AppToast.showError(
          context,
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }
  void _copyCode() {
    if (_generatedCode != null) {
      Clipboard.setData(ClipboardData(text: _generatedCode!));
      AppToast.showInfo(
        context,
        message: 'Código copiado al portapapeles',
      );
    }
  }
  void _navigateToVerifyScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VerifyCodeScreen()),
    );
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
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingXL),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCardLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(30),
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
                    // Mostrar código generado o formulario
                    if (_generatedCode != null) ...[
                      _buildCodeDisplay(),
                    ] else ...[
                      _buildRequestForm(),
                    ],
                    const SizedBox(height: AppSizes.paddingL),
                    // Botón para ir a verificar código
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "¿Tienes un código?",
                          style: AppTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: _navigateToVerifyScreen,
                          child: Text(
                            'Verifícalo aquí',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppColors.textPrimaryLight,
                              decoration: TextDecoration.underline,
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
        ),
      ),
    );
  }
  Widget _buildRequestForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo de username
          TextFormField(
            controller: _usernameController,
            style: AppTheme.bodyMedium,
            decoration: AppTheme.inputDecoration(
              hintText: 'username',
              prefixIcon: const Icon(
                Icons.person_outline,
                color: AppColors.textPrimaryLight,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa un username';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // Botón Enviar Solicitud
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundCardLight,
                foregroundColor: AppColors.textPrimaryLight,
                disabledBackgroundColor: AppColors.textPrimaryLight.withOpacity(0.5),
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
                      'Enviar Solicitud',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCodeDisplay() {
    return Column(
      children: [
        // Código con estilo especial
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.backgroundCardLight.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Column(
                children: [
                  // Texto
                  Text(
                    'Compártelo con @${_usernameController.text}',
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  // Código
                  Text(
                    _generatedCode!,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentPrimaryLight,
                      letterSpacing: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Botón copiar
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _copyCode,
            icon: const Icon(Icons.copy, size: 20),
            label: const Text('Copiar código'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPrimaryLight,
              foregroundColor: AppColors.textPrimaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
