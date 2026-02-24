import 'package:flutter/material.dart';
import '../../generated/app_localizations.dart';
import '../../models/pepito_activity.dart';
import '../../utils/date_utils.dart';
import '../../utils/theme_utils.dart';
import 'activity_svg_icon.dart';

class ActivityCard extends StatelessWidget {
  final PepitoActivity activity;
  final VoidCallback? onTap;
  final bool showDate;
  final bool compact;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.showDate = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;
    
    // Responsive margins and padding
    final horizontalMargin = compact ? (isSmallScreen ? 6.0 : 8.0) : (isSmallScreen ? 12.0 : 16.0);
    final verticalMargin = compact ? (isSmallScreen ? 3.0 : 4.0) : (isSmallScreen ? 6.0 : 8.0);
    final padding = compact ? (isSmallScreen ? 8.0 : 12.0) : (isSmallScreen ? 12.0 : 16.0);
    
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: verticalMargin,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: compact ? _buildCompactContent(colorScheme, context) : _buildFullContent(colorScheme, context),
        ),
      ),
    );
  }

  Widget _buildFullContent(ColorScheme colorScheme, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;
    final spacing = isSmallScreen ? 8.0 : 12.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _buildActivityIcon(colorScheme),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activity.displayTypeLocalized(context),
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppDateUtils.getRelativeTime(activity.dateTime, context),
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            if (activity.confidence != null) ...[
              const SizedBox(width: 8),
              _buildConfidenceChip(colorScheme),
            ],
          ],
        ),
        if (showDate) ...[
          SizedBox(height: spacing),
          _buildDateTimeInfo(colorScheme),
        ],
        if (activity.location != null) ...[
          SizedBox(height: isSmallScreen ? 6 : 8),
          _buildLocationInfo(colorScheme),
        ],
        if (activity.metadata != null && activity.metadata!.isNotEmpty) ...[
          SizedBox(height: isSmallScreen ? 6 : 8),
          _buildMetadataInfo(context, colorScheme),
        ],
      ],
    );
  }

  Widget _buildCompactContent(ColorScheme colorScheme, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;
    final iconSize = isSmallScreen ? 18.0 : 20.0;
    final titleFontSize = isSmallScreen ? 14.0 : 16.0;
    final timeFontSize = isSmallScreen ? 10.0 : 12.0;
    final spacing = isSmallScreen ? 8.0 : 12.0;
    
    return Row(
      children: [
        _buildActivityIcon(colorScheme, size: iconSize),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                activity.displayTypeLocalized(context),
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                AppDateUtils.formatTime(activity.dateTime),
                style: TextStyle(
                  fontSize: timeFontSize,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        if (activity.confidence != null) ...[
          const SizedBox(width: 8),
          _buildConfidenceChip(colorScheme, compact: true),
        ],
      ],
    );
  }

  Widget _buildActivityIcon(ColorScheme colorScheme, {double size = 24}) {
    // Verificar si es una actividad reciente para mostrar animación
    final now = DateTime.now();
    final difference = now.difference(activity.dateTime);
    final isRecent = difference.inMinutes < 5;
    
    if (isRecent) {
      return ActivityAnimatedIcon(
        activity: activity,
        size: size,
      );
    } else {
      return ActivitySvgIcon(
        activity: activity,
        size: size,
      );
    }
  }

  Widget _buildConfidenceChip(ColorScheme colorScheme, {bool compact = false}) {
    final confidence = activity.confidence!;
    final percentage = (confidence * 100).round();
    
    Color chipColor;
    if (confidence >= 0.8) {
      chipColor = AppTheme.successColor;
    } else if (confidence >= 0.6) {
      chipColor = AppTheme.warningColor;
    } else {
      chipColor = AppTheme.errorColor;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: chipColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w500,
          color: chipColor,
        ),
      ),
    );
  }

  Widget _buildDateTimeInfo(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Text(
            '${AppDateUtils.formatDate(activity.dateTime)} a las ${AppDateUtils.formatTime(activity.dateTime)}',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 16,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            activity.location!,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataInfo(BuildContext context, ColorScheme colorScheme) {
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

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.additionalInformation,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          ...transformedMetadata.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityListTile extends StatelessWidget {
  final PepitoActivity activity;
  final VoidCallback? onTap;
  final bool showTrailing;

  const ActivityListTile({
    super.key,
    required this.activity,
    this.onTap,
    this.showTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activityColor = AppTheme.getActivityColor(activity.type);
    
    return ListTile(
      onTap: onTap,
      leading: ActivitySvgIcon(
        activity: activity,
        size: 20,
      ),
      title: Text(
        activity.displayTypeLocalized(context),
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        AppDateUtils.getRelativeTime(activity.dateTime, context),
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      trailing: showTrailing && activity.confidence != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: activityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(activity.confidence! * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: activityColor,
                ),
              ),
            )
          : showTrailing
              ? Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                )
              : null,
    );
  }
}