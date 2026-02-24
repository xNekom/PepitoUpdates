import 'package:flutter/material.dart';
import '../cat_paw_icon.dart';
import '../../generated/app_localizations.dart';
import '../../models/pepito_activity.dart';
import '../../utils/date_utils.dart';
import '../../utils/theme_utils.dart';

class StatusCard extends StatelessWidget {
  final PepitoStatus status;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const StatusCard({
    super.key,
    required this.status,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _getStatusGradient(),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, colorScheme),
              // Indicador de modo demo removido - ahora usamos datos locales
              const SizedBox(height: 16),
              _buildStatusInfo(colorScheme, context),
              const SizedBox(height: 16),
              _buildLastSeenInfo(context, colorScheme),
              if (status.lastActivity != null) ...[
                const SizedBox(height: 12),
                _buildLastActivityInfo(context, colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: status.isHome
              ? const Icon(Icons.home, size: 28, color: Colors.white)
              : const CatPawIcon(size: 28, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.appTitle.split(' ').first,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                status.displayStatus(context),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        if (onRefresh != null)
          IconButton(
            onPressed: isLoading ? null : onRefresh,
            icon: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.refresh, color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildStatusInfo(ColorScheme colorScheme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            status.isHome ? Icons.home_filled : Icons.explore,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.isHome
                      ? AppLocalizations.of(context)!.atHome
                      : AppLocalizations.of(context)!.awayFromHome,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  status.isHome
                      ? AppLocalizations.of(context)!.pepitoSafeAtHome
                      : AppLocalizations.of(context)!.pepitoExploring,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastSeenInfo(BuildContext context, ColorScheme colorScheme) {
    return _buildInfoRow(
      icon: Icons.access_time,
      title: AppLocalizations.of(context)!.lastSeen,
      subtitle: AppDateUtils.getRelativeTime(status.lastSeen, context),
      detail: AppDateUtils.formatDateTime(status.lastSeen),
    );
  }

  Widget _buildLastActivityInfo(BuildContext context, ColorScheme colorScheme) {
    final activity = status.lastActivity!;
    return _buildInfoRow(
      icon: activity.isEntry ? Icons.login : Icons.logout,
      title: AppLocalizations.of(context)!.lastActivity,
      subtitle: activity.displayTypeLocalized(context),
      detail: AppDateUtils.getRelativeTime(activity.dateTime, context),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    String? detail,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getStatusGradient() {
    if (status.isHome) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.successColor,
          AppTheme.successColor.withValues(alpha: 0.8),
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.warningColor,
          AppTheme.warningColor.withValues(alpha: 0.8),
        ],
      );
    }
  }

  // Métodos de modo demo removidos - ahora usamos datos locales
}

class CompactStatusCard extends StatelessWidget {
  final PepitoStatus status;
  final VoidCallback? onTap;

  const CompactStatusCard({super.key, required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                status.isHome
                    ? AppTheme.successColor.withValues(alpha: 0.1)
                    : AppTheme.warningColor.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: status.isHome
                      ? AppTheme.successColor.withValues(alpha: 0.2)
                      : AppTheme.warningColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: status.isHome
                    ? Icon(Icons.home, color: AppTheme.successColor, size: 20)
                    : CatPawIcon(color: AppTheme.warningColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.isHome
                          ? AppLocalizations.of(context)!.atHome
                          : AppLocalizations.of(context)!.awayFromHome,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppLocalizations.of(context)!.lastSeen} ${AppDateUtils.getRelativeTime(status.lastSeen, context)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusIndicator extends StatelessWidget {
  final bool isHome;
  final double size;
  final bool showLabel;

  const StatusIndicator({
    super.key,
    required this.isHome,
    this.size = 12,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isHome ? AppTheme.successColor : AppTheme.warningColor;
    final label = isHome
        ? AppLocalizations.of(context)!.atHome
        : AppLocalizations.of(context)!.away;

    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: size + 2,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
