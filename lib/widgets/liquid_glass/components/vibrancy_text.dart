import 'dart:ui';
import 'package:flutter/material.dart';

class VibrancyText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color vibrantColor;
  final double blurSigma;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const VibrancyText({
    super.key,
    required this.text,
    this.style,
    this.vibrantColor = Colors.white,
    this.blurSigma = 20.0,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final effectiveColor = vibrantColor.withValues(
      alpha: brightness == Brightness.dark ? 0.95 : 0.85,
    );

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            effectiveColor,
            effectiveColor.withValues(alpha: 0.7),
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Text(
            text,
            style: (style ?? const TextStyle()).copyWith(
              color: Colors.white,
            ),
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          ),
        ),
      ),
    );
  }
}
