import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
class AppToast {
  // Toast de éxito
  static void showSuccess(
    BuildContext context, {
    required String message,
    DelightSnackbarPosition position = DelightSnackbarPosition.top,
    Duration duration = Durations.extralong4,
  }) {
    DelightToastBar(
      builder: (context) {
        return ToastCard(
          title: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          color: AppColors.success,
        );
      },
      position: position,
      autoDismiss: true,
      snackbarDuration: duration,
    ).show(context);
  }
  // Toast de error
  static void showError(
    BuildContext context, {
    required String message,
    DelightSnackbarPosition position = DelightSnackbarPosition.top,
    Duration duration = Durations.extralong4,
  }) {
    DelightToastBar(
      builder: (context) {
        return ToastCard(
          title: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          color: AppColors.error,
        );
      },
      position: position,
      autoDismiss: true,
      snackbarDuration: duration,
    ).show(context);
  }
  // Toast de advertencia
  static void showWarning(
    BuildContext context, {
    required String message,
    DelightSnackbarPosition position = DelightSnackbarPosition.top,
    Duration duration = Durations.extralong4,
  }) {
    DelightToastBar(
      builder: (context) {
        return ToastCard(
          title: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          color: AppColors.warning,
        );
      },
      position: position,
      autoDismiss: true,
      snackbarDuration: duration,
    ).show(context);
  }
  // Toast de información
  static void showInfo(
    BuildContext context, {
    required String message,
    DelightSnackbarPosition position = DelightSnackbarPosition.top,
    Duration duration = Durations.extralong4,
  }) {
    DelightToastBar(
      builder: (context) {
        return ToastCard(
          title: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          color: AppColors.info,
        );
      },
      position: position,
      autoDismiss: true,
      snackbarDuration: duration,
    ).show(context);
  }
  // Toast personalizado
  static void showCustom(
    BuildContext context, {
    required String message,
    required Color color,
    Color textColor = Colors.white,
    DelightSnackbarPosition position = DelightSnackbarPosition.top,
    Duration duration = Durations.extralong4,
  }) {
    DelightToastBar(
      builder: (context) {
        return ToastCard(
          title: Text(
            message,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          color: color,
        );
      },
      position: position,
      autoDismiss: true,
      snackbarDuration: duration,
    ).show(context);
  }
}
