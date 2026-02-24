import 'package:flutter/cupertino.dart';
import '../../../models/pepito_activity.dart';
import '../../../theme/liquid_glass/apple_colors.dart';
import '../../../theme/liquid_glass/glass_effects.dart';
import '../../../utils/date_utils.dart';
import '../../../utils/platform_detector.dart';
import '../../../generated/app_localizations.dart';
import '../components/glass_card.dart';
import '../components/frosted_panel.dart';
import 'liquid_activity_icon.dart';

/// Widget de tarjeta de actividad con diseño Liquid Glass completo
class LiquidActivityCard extends StatelessWidget {
  final PepitoActivity activity;
  final VoidCallback? onTap;
  final bool showDate;
  final bool compact;

  const LiquidActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.showDate = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformDetector.isDesktop;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;

    // Responsive margins and padding
    final horizontalMargin = compact ? (isSmallScreen ? 6.0 : 8.0) : (isSmallScreen ? 12.0 : 16.0);
    final verticalMargin = compact ? (isSmallScreen ? 3.0 : 4.0) : (isSmallScreen ? 6.0 : 8.0);
    final padding = compact ? (isSmallScreen ? 12.0 : 16.0) : (isSmallScreen ? 16.0 : 20.0);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: verticalMargin,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          accentColor: AppleColors.getActivityColor(_getActivityType()),
          padding: EdgeInsets.all(padding),
          child: compact
              ? _buildCompactContent(context, isDesktop, isSmallScreen)
              : _buildFullContent(context, isDesktop, isSmallScreen),
        ),
      ),
    );
  }

  Widget _buildFullContent(BuildContext context, bool isDesktop, bool isSmallScreen) {
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;
    final spacing = isSmallScreen ? 8.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _buildActivityIcon(isDesktop),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activity.displayTypeLocalized(context),
                    style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppleColors.textPrimary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppDateUtils.getRelativeTime(activity.dateTime, context),
                    style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                      color: AppleColors.textSecondary(context),
                      fontSize: subtitleFontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            if (activity.confidence != null) ...[
              const SizedBox(width: 8),
              _buildConfidenceChip(context, isSmallScreen),
            ],
          ],
        ),
        if (showDate) ...[
          SizedBox(height: spacing),
          _buildDateTimeInfo(context, isSmallScreen),
        ],
        if (activity.location != null) ...[
          SizedBox(height: isSmallScreen ? 6 : 8),
          _buildLocationInfo(context, isSmallScreen),
        ],
        if (activity.metadata != null && activity.metadata!.isNotEmpty) ...[
          SizedBox(height: isSmallScreen ? 6 : 8),
          _buildMetadataInfo(context, isSmallScreen),
        ],
      ],
    );
  }

  Widget _buildCompactContent(BuildContext context, bool isDesktop, bool isSmallScreen) {
    final iconSize = isSmallScreen ? 18.0 : 20.0;
    final titleFontSize = isSmallScreen ? 14.0 : 16.0;
    final timeFontSize = isSmallScreen ? 10.0 : 12.0;
    final spacing = isSmallScreen ? 8.0 : 12.0;

    return Row(
      children: [
        _buildActivityIcon(isDesktop, size: iconSize),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                activity.displayTypeLocalized(context),
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppleColors.textPrimary(context),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                AppDateUtils.formatTime(activity.dateTime),
                style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                  color: AppleColors.textSecondary(context),
                  fontSize: timeFontSize,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        if (activity.confidence != null) ...[
          const SizedBox(width: 8),
          _buildConfidenceChip(context, isSmallScreen, compact: true),
        ],
      ],
    );
  }

  Widget _buildActivityIcon(bool isDesktop, {double size = 24}) {
    // Verificar si es una actividad reciente para mostrar animación
    final now = DateTime.now();
    final difference = now.difference(activity.dateTime);
    final isRecent = difference.inMinutes < 5;

    return LiquidActivityIcon(
      activity: activity,
      size: size,
      showAnimation: isRecent,
    );
  }

  Widget _buildConfidenceChip(BuildContext context, bool isSmallScreen, {bool compact = false}) {
    final confidence = activity.confidence!;
    final percentage = (confidence * 100).round();

    Color chipColor;
    if (confidence >= 0.8) {
      chipColor = AppleColors.successGreen;
    } else if (confidence >= 0.6) {
      chipColor = AppleColors.warningOrange;
    } else {
      chipColor = AppleColors.errorRed;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: chipColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: GlassEffects.glassShadows(
          accentColor: chipColor,
          intensity: 0.3,
        ),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w600,
          color: chipColor,
        ),
      ),
    );
  }

  Widget _buildDateTimeInfo(BuildContext context, bool isSmallScreen) {
    return FrostedPanel(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.time,
            size: 16,
            color: AppleColors.textSecondary(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${AppDateUtils.formatDate(activity.dateTime)} a las ${AppDateUtils.formatTime(activity.dateTime)}',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontSize: 14,
                color: AppleColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(BuildContext context, bool isSmallScreen) {
    return Row(
      children: [
        Icon(
          CupertinoIcons.location,
          size: 16,
          color: AppleColors.textSecondary(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            activity.location!,
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              fontSize: 14,
              color: AppleColors.textPrimary(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataInfo(BuildContext context, bool isSmallScreen) {
    // Transformar campos técnicos a nombres más amigables para el usuario
    final transformedMetadata = activity.metadata!.entries.map((entry) {
      String displayKey;
      String displayValue = entry.value.toString();

      switch (entry.key.toLowerCase()) {
        case 'processed_at':
          displayKey = 'Procesado el';
          // Formatear la fecha si es posible
          try {
            final date = DateTime.parse(displayValue);
            displayValue = AppDateUtils.formatDateTime(date);
          } catch (e) {
            // Mantener el valor original si no se puede parsear
          }
          break;
        case 'api_timestamp':
          displayKey = 'Recibido de API';
          // Convertir timestamp a fecha legible si es numérico
          try {
            final timestamp = int.tryParse(displayValue);
            if (timestamp != null) {
              final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
              displayValue = AppDateUtils.formatDateTime(date);
            }
          } catch (e) {
            // Mantener el valor original si no se puede convertir
          }
          break;
        case 'timestamp':
          displayKey = 'Fecha y hora';
          try {
            final timestamp = int.tryParse(displayValue);
            if (timestamp != null) {
              final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
              displayValue = AppDateUtils.formatDateTime(date);
            }
          } catch (e) {
            // Mantener el valor original si no se puede convertir
          }
          break;
        case 'created_at':
          displayKey = 'Creado el';
          try {
            final date = DateTime.parse(displayValue);
            displayValue = AppDateUtils.formatDateTime(date);
          } catch (e) {
            // Mantener el valor original si no se puede parsear
          }
          break;
        case 'updated_at':
          displayKey = 'Actualizado el';
          try {
            final date = DateTime.parse(displayValue);
            displayValue = AppDateUtils.formatDateTime(date);
          } catch (e) {
            // Mantener el valor original si no se puede parsear
          }
          break;
        default:
          // Filtrar campos técnicos que no deberían mostrarse
          final key = entry.key.toLowerCase();
          if (key.contains('id') || key == 'source' || key == 'cached' || key == 'authenticated') {
            return null; // Excluir estos campos
          }
          displayKey = entry.key;
      }

      return MapEntry(displayKey, displayValue);
    }).where((entry) => entry != null).cast<MapEntry<String, String>>().toList();

    // Si no hay metadata relevante para mostrar, no mostrar la sección
    if (transformedMetadata.isEmpty) return const SizedBox.shrink();

    return FrostedPanel(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.additionalInformation,
            style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppleColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 6),
          ...transformedMetadata.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                  fontSize: 12,
                  color: AppleColors.textSecondary(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ActivityType _getActivityType() {
    switch (activity.type) {
      case 'in':
        return ActivityType.entrada;
      case 'out':
        return ActivityType.salida;
      default:
        return ActivityType.entrada;
    }
  }
}