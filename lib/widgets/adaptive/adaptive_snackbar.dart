import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pepito_providers.dart';
import '../../theme/liquid_glass/apple_colors.dart';

class AdaptiveSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    WidgetRef? ref,
  }) {
    final platformStyle = ref?.read(platformStyleProvider) ?? WidgetStyle.liquidGlass;

    switch (platformStyle) {
      case WidgetStyle.liquidGlass:
        _showGlassSnackbar(context, message, isError, duration);
      case WidgetStyle.fluentDesign:
        _showMaterialSnackbar(context, message, isError, duration);
      case WidgetStyle.materialExpressive:
        _showMaterialSnackbar(context, message, isError, duration);
    }
  }

  static void _showGlassSnackbar(
    BuildContext context,
    String message,
    bool isError,
    Duration duration,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isError
        ? AppleColors.errorRed
        : (isDark ? CupertinoColors.black : CupertinoColors.white);
    final textColor = isError
        ? CupertinoColors.white
        : (isDark ? CupertinoColors.white : CupertinoColors.black);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: bgColor.withValues(alpha: isError ? 0.9 : 0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: duration,
      ),
    );
  }

  static void _showMaterialSnackbar(
    BuildContext context,
    String message,
    bool isError,
    Duration duration,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: duration,
      ),
    );
  }
}
