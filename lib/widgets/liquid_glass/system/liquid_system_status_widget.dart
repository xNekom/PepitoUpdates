import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../../providers/hybrid_pepito_provider.dart';
import '../../../providers/pepito_providers.dart';
import '../../../theme/liquid_glass/glass_effects.dart';
import '../../../theme/liquid_glass/apple_colors.dart';
import '../../../utils/platform_detector.dart';
import '../components/glass_card.dart';
import '../components/apple_pressable.dart';

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

class LiquidSystemStatusWidget extends ConsumerWidget {
  const LiquidSystemStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pepitoStateAsync = ref.watch(hybridPepitoStatusProvider);

    return pepitoStateAsync.when(
      data: (pepitoState) => _buildContent(context, pepitoState),
      loading: () => _buildLoading(context),
      error: (error, stack) => _buildError(context, error),
    );
  }

  Widget _buildContent(BuildContext context, PepitoStatus pepitoState) {
    final isDesktop = PlatformDetector.isDesktop;

    return GlassCard(
      accentColor: pepitoState.isHome
          ? AppleColors.successGreen
          : AppleColors.errorRed,
      child: Column(
        children: [
          _buildHeader(context, pepitoState, isDesktop),
          const SizedBox(height: 16.0),
          _buildStatusGrid(context, pepitoState, isDesktop),
          const SizedBox(height: 12.0),
          _buildActions(context, pepitoState, isDesktop),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return GlassCard(
      accentColor: CupertinoColors.systemGrey,
      child: const Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return GlassCard(
      accentColor: AppleColors.errorRed,
      child: Column(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            color: AppleColors.errorRed,
            size: 24.0,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Error: $error',
            style: CupertinoTheme.of(context).textTheme.textStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PepitoStatus pepitoState, bool isDesktop) {
    return Row(
      children: [
        Icon(
          pepitoState.isHome
              ? CupertinoIcons.house_fill
              : CupertinoIcons.house,
          color: pepitoState.isHome
              ? AppleColors.successGreen
              : AppleColors.errorRed,
          size: isDesktop ? 28.0 : 24.0,
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            pepitoState.isHome ? 'En Casa' : 'Fuera de Casa',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
        ),
        Text(
          _formatLastUpdate(pepitoState.lastSeen),
          style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusGrid(BuildContext context, PepitoStatus pepitoState, bool isDesktop) {
    return _buildStatusItem(
      context: context,
      isDesktop: isDesktop,
      title: 'Estado',
      value: pepitoState.isHome ? 'En casa' : 'Fuera de casa',
      color: pepitoState.isHome ? AppleColors.successGreen : AppleColors.errorRed,
    );
  }

  Widget _buildStatusItem({
    required BuildContext context,
    required bool isDesktop,
    required String title,
    required String value,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(GlassEffects.radiusSmall),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: GlassEffects.blurSigmaLight, sigmaY: GlassEffects.blurSigmaLight),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            gradient: GlassEffects.glassGradient(
              accentColor: color,
              brightness: CupertinoTheme.of(context).brightness ?? Brightness.light,
            ),
            border: Border.all(
              color: color.withValues(alpha: GlassEffects.borderOpacity),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(GlassEffects.radiusSmall),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                        color: CupertinoColors.systemGrey,
                        fontSize: isDesktop ? 12.0 : 10.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      value,
                      style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: isDesktop ? 14.0 : 12.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, PepitoStatus pepitoState, bool isDesktop) {
    return Row(
      children: [
        Expanded(
          child: ApplePressable(
            onPressed: () => _refresh(context),
            child: Text(
              'Actualizar',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                color: CupertinoColors.activeBlue,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: ApplePressable(
            onPressed: () => _showDiagnostics(context),
            child: Text(
              'Diagnóstico',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                color: CupertinoColors.activeBlue,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  void _refresh(BuildContext context) {
    // Implementar lógica de refresh
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Actualizando...'),
        content: const Text('Obteniendo el estado más reciente.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showDiagnostics(BuildContext context) {
    // Implementar vista de diagnóstico
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        child: Column(
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('Vista de diagnóstico próximamente'),
              ),
            ),
          ],
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

/// Widget compacto para mostrar estado
class CompactLiquidSystemStatus extends ConsumerWidget {
  const CompactLiquidSystemStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pepitoStateAsync = ref.watch(hybridPepitoStatusProvider);

    return pepitoStateAsync.when(
      data: (pepitoState) => _buildCompactContent(context, pepitoState),
      loading: () => _buildCompactLoading(context),
      error: (error, stack) => _buildCompactError(context, error),
    );
  }

  Widget _buildCompactContent(BuildContext context, PepitoStatus pepitoState) {
    return GlassCard(
      accentColor: pepitoState.isHome
          ? AppleColors.successGreen
          : AppleColors.errorRed,
      child: Row(
        children: [
          Icon(
            pepitoState.isHome
                ? CupertinoIcons.house_fill
                : CupertinoIcons.house,
            color: pepitoState.isHome
                ? AppleColors.successGreen
                : AppleColors.errorRed,
            size: 20.0,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pepitoState.isHome ? 'En Casa' : 'Fuera de Casa',
                  style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatLastUpdate(pepitoState.lastSeen),
                  style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showQuickActions(context, pepitoState),
            child: Icon(
              CupertinoIcons.ellipsis,
              size: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLoading(BuildContext context) {
    return GlassCard(
      accentColor: CupertinoColors.systemGrey,
      child: const Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  Widget _buildCompactError(BuildContext context, Object error) {
    return GlassCard(
      accentColor: AppleColors.errorRed,
      child: Row(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            color: AppleColors.errorRed,
            size: 20.0,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              'Error: $error',
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context, PepitoStatus pepitoState) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              // Implementar refresh
            },
            child: const Text('Actualizar'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              // Implementar diagnóstico
            },
            child: const Text('Diagnóstico'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ),
    );
  }
}