import 'package:flutter/cupertino.dart';
import '../../../models/pepito_activity.dart';
import '../../../theme/liquid_glass/apple_colors.dart';
import '../../../utils/platform_detector.dart';
import '../components/glass_card.dart';

/// Widget de tarjeta de estado con diseño Liquid Glass
class LiquidStatusCard extends StatelessWidget {
  final PepitoStatus status;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const LiquidStatusCard({
    super.key,
    required this.status,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformDetector.isDesktop;

    return GlassCard(
      accentColor: status.isHome
          ? AppleColors.successGreen
          : AppleColors.errorRed,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isDesktop),
            const SizedBox(height: 12.0),
            _buildStatusInfo(context, isDesktop),
            if (onRefresh != null) ...[
              const SizedBox(height: 12.0),
              _buildRefreshButton(context, isDesktop),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    return Row(
      children: [
        Icon(
          status.isHome
              ? CupertinoIcons.house_fill
              : CupertinoIcons.house,
          color: status.isHome
              ? AppleColors.successGreen
              : AppleColors.errorRed,
          size: isDesktop ? 28.0 : 24.0,
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            status.isHome ? 'En Casa' : 'Fuera de Casa',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
              fontSize: isDesktop ? 18.0 : 16.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusInfo(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Última actualización',
          style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
            color: CupertinoColors.systemGrey,
            fontSize: isDesktop ? 12.0 : 10.0,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          _formatLastUpdate(status.lastSeen),
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            fontSize: isDesktop ? 14.0 : 12.0,
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshButton(BuildContext context, bool isDesktop) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        color: CupertinoColors.activeBlue,
        borderRadius: BorderRadius.circular(8.0),
        onPressed: isLoading ? null : onRefresh,
        child: isLoading
            ? const CupertinoActivityIndicator()
            : Text(
                'Actualizar',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  String _formatLastUpdate(DateTime lastUpdate) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    if (difference.inMinutes < 1) {
      return 'ahora';
    } else if (difference.inHours < 1) {
      return 'hace ${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return 'hace ${difference.inHours}h';
    } else {
      return 'hace ${difference.inDays}d';
    }
  }
}