import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pepito_providers.dart';
import '../../utils/platform_detector.dart';
import '../../utils/theme_utils.dart';

class AdaptiveAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isDefault;

  const AdaptiveAction({
    required this.label,
    this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });
}

class AdaptiveDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<AdaptiveAction> actions = const [],
    WidgetRef? ref,
  }) async {
    final platformStyle = ref?.read(platformStyleProvider) ?? PlatformDetector.recommendedStyle;

    switch (platformStyle) {
      case WidgetStyle.liquidGlass:
        return _showCupertinoDialog(context, title, content, actions);
      case WidgetStyle.fluentDesign:
        return _showMaterialDialog(context, title, content, actions);
      case WidgetStyle.materialExpressive:
        return _showMaterialDialog(context, title, content, actions);
    }
  }

  static Future<T?> _showCupertinoDialog<T>(
    BuildContext context,
    String title,
    Widget content,
    List<AdaptiveAction> actions,
  ) {
    final cupertinoActions = actions.map((action) {
      return CupertinoDialogAction(
        onPressed: () {
          Navigator.of(context).pop();
          action.onPressed?.call();
        },
        isDestructiveAction: action.isDestructive,
        isDefaultAction: action.isDefault,
        child: Text(action.label),
      );
    }).toList();

    return showCupertinoDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: content,
        actions: cupertinoActions,
      ),
    );
  }

  static Future<T?> _showMaterialDialog<T>(
    BuildContext context,
    String title,
    Widget content,
    List<AdaptiveAction> actions,
  ) {
    final materialActions = actions.map((action) {
      return TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          action.onPressed?.call();
        },
        child: Text(
          action.label,
          style: TextStyle(
            color: action.isDestructive ? AppTheme.errorColor : null,
            fontWeight: action.isDefault ? FontWeight.w600 : null,
          ),
        ),
      );
    }).toList();

    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions: materialActions,
      ),
    );
  }

  static Future<T?> showGlass<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<AdaptiveAction> actions = const [],
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final materialActions = actions.map((action) {
      return TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          action.onPressed?.call();
        },
        child: Text(action.label),
      );
    }).toList();

    return showDialog<T>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.85),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                        child: content,
                      ),
                    ),
                    if (actions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: materialActions,
                        ),
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
}
