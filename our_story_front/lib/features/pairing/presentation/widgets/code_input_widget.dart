import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class CodeInputWidget extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  const CodeInputWidget({
    Key? key,
    required this.controllers,
    required this.focusNodes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(
              maxWidth: 50,
              minWidth: 40,
            ),
            child: AspectRatio(
              aspectRatio: 0.8, // Ancho:Alto = 48:60
              child: _buildCodeBox(context, index),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCodeBox(BuildContext context, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              textAlign: TextAlign.center,
              style: AppTheme.bodyLarge.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              maxLength: 1,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                filled: false
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  // Auto-avanzar al siguiente campo
                  if (index < 5) {
                    focusNodes[index + 1].requestFocus();
                  } else {
                    // Último campo, quitar foco
                    focusNodes[index].unfocus();
                  }
                } else {
                  // Si borra, retroceder al campo anterior
                  if (index > 0) {
                    focusNodes[index - 1].requestFocus();
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
