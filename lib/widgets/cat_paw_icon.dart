import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom cat paw icon widget that replaces Icons.pets (which is a dog paw print).
/// Uses the cat_paw.svg asset for a feline-specific paw print.
class CatPawIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const CatPawIcon({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final iconColor =
        color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurface;

    return SvgPicture.asset(
      'assets/icons/cat_paw.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );
  }
}
