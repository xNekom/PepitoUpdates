import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../../../theme/liquid_glass/glass_effects.dart';
import '../../../utils/platform_detector.dart';
import '../components/glass_card.dart';

class LiquidStatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const LiquidStatisticsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? CupertinoColors.activeBlue;
    return GlassCard(
      accentColor: cardColor,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconContainer(cardColor, PlatformDetector.isDesktop ? 32.0 : 28.0, PlatformDetector.isDesktop),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    Text(
                      value,
                      style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        subtitle!,
                        style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(Color color, double iconSize, bool isDesktop) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(GlassEffects.radiusSmall),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: GlassEffects.blurSigmaLight, sigmaY: GlassEffects.blurSigmaLight),
        child: Container(
          width: iconSize + 16.0,
          height: iconSize + 16.0,
          decoration: BoxDecoration(
            gradient: GlassEffects.glassGradient(
              accentColor: color,
              brightness: Brightness.light, // Asumir light para icono
            ),
            border: Border.all(
              color: color.withValues(alpha: GlassEffects.borderOpacity),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(GlassEffects.radiusSmall),
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}