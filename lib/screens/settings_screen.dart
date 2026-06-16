// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import '../providers/pepito_providers.dart';
import '../utils/theme_utils.dart';
import '../generated/app_localizations.dart';
import '../services/localization_service.dart';
import '../widgets/adaptive/adaptive_system_status_widget.dart';
import '../widgets/liquid_glass/components/glass_card.dart';
import '../widgets/liquid_glass/components/frosted_panel.dart';
import '../widgets/liquid_glass/components/liquid_glass_switch.dart';
import '../theme/liquid_glass/apple_colors.dart';
import '../theme/liquid_glass/glass_effects.dart';
import '../widgets/liquid_glass/liquid_app_bar.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final platformStyle = ref.watch(platformStyleProvider);

    return switch (platformStyle) {
      WidgetStyle.liquidGlass => _buildLiquidGlassUI(context),
      WidgetStyle.fluentDesign => _buildMaterialUI(context),
      WidgetStyle.materialExpressive => _buildMaterialUI(context),
    };
  }

  Widget _buildMaterialUI(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationSection(),
            _buildAppearanceSection(),
            _buildDataSection(),
            _buildAboutSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLiquidGlassUI(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          LiquidAppBar(title: AppLocalizations.of(context)!.settings),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              _buildNotificationSection(),
              _buildAppearanceSection(),
              _buildDataSection(),
              _buildAboutSection(),
              const SizedBox(height: 100), // Extra padding for bottom navbar
            ]),
          ),
        ],
      ),
    );
  }



  Widget _buildNotificationSection() {
    return Consumer(
      builder: (context, ref, child) {
        final notificationSettings = ref.watch(notificationSettingsProvider);
        
        return _buildSection(
          title: AppLocalizations.of(context)!.notifications,
          icon: Icons.notifications,
          children: [
            _buildSwitchTile(
              title: AppLocalizations.of(context)!.pushNotifications,
              subtitle: AppLocalizations.of(context)!.receiveNotificationsWhenPepitoEntersOrLeaves,
              value: notificationSettings.pushEnabled,
              onChanged: (value) {
                ref.read(notificationSettingsProvider.notifier).updatePushEnabled(value);
                if (value) {
                  _requestNotificationPermission();
                }
              },
            ),
            _buildSwitchTile(
              title: AppLocalizations.of(context)!.entryNotifications,
              subtitle: AppLocalizations.of(context)!.notifyWhenPepitoArrivesHome,
              value: notificationSettings.entryNotifications,
              enabled: notificationSettings.pushEnabled,
              onChanged: (value) {
                ref.read(notificationSettingsProvider.notifier).updateEntryNotifications(value);
              },
            ),
            _buildSwitchTile(
              title: AppLocalizations.of(context)!.exitNotifications,
              subtitle: AppLocalizations.of(context)!.notifyWhenPepitoLeavesHome,
              value: notificationSettings.exitNotifications,
              enabled: notificationSettings.pushEnabled,
              onChanged: (value) {
                ref.read(notificationSettingsProvider.notifier).updateExitNotifications(value);
              },
            ),
            _buildSwitchTile(
              title: AppLocalizations.of(context)!.sound,
              subtitle: 'Reproducir sonido con las notificaciones',
              value: notificationSettings.soundEnabled,
              enabled: notificationSettings.pushEnabled,
              onChanged: (value) {
                ref.read(notificationSettingsProvider.notifier).updateSoundEnabled(value);
              },
            ),
            if (!kIsWeb) _buildSwitchTile(
              title: AppLocalizations.of(context)!.vibration,
              subtitle: 'Vibrar con las notificaciones',
              value: notificationSettings.vibrationEnabled,
              enabled: notificationSettings.pushEnabled,
              onChanged: (value) {
                ref.read(notificationSettingsProvider.notifier).updateVibrationEnabled(value);
              },
            ),
            if (notificationSettings.pushEnabled) ...
              _buildQuietHoursSection(notificationSettings),
          ],
        );
      },
    );
  }

  List<Widget> _buildQuietHoursSection(NotificationSettings settings) {
    return [
      const Divider(),
      _buildSwitchTile(
        title: AppLocalizations.of(context)!.quietHours,
        subtitle: AppLocalizations.of(context)!.doNotDisturbDuringCertainHours,
        value: settings.quietHoursEnabled,
        onChanged: (value) {
          ref.read(notificationSettingsProvider.notifier).updateQuietHoursEnabled(value);
        },
      ),
      if (settings.quietHoursEnabled) ...[
        _buildTimeTile(
          title: AppLocalizations.of(context)!.quietHoursStart,
          time: settings.quietHoursStart,
          onChanged: (time) {
            ref.read(notificationSettingsProvider.notifier).updateQuietHoursStart(time);
          },
        ),
        _buildTimeTile(
          title: AppLocalizations.of(context)!.quietHoursEnd,
          time: settings.quietHoursEnd,
          onChanged: (time) {
            ref.read(notificationSettingsProvider.notifier).updateQuietHoursEnd(time);
          },
        ),
      ],
    ];
  }

  Widget _buildAppearanceSection() {
    return Consumer(
      builder: (context, ref, child) {
        final appThemeMode = ref.watch(themeProvider);
        final locale = ref.watch(localeProvider);
        
        return _buildSection(
          title: AppLocalizations.of(context)!.appearance,
          icon: Icons.palette,
          children: [
            _buildListTile(
              title: AppLocalizations.of(context)!.theme,
              subtitle: _getThemeModeLabel(appThemeMode),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeDialog(appThemeMode),
            ),
            _buildListTile(
              title: AppLocalizations.of(context)!.language,
              subtitle: LocalizationService.getLanguageName(locale.languageCode),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(locale),
            ),
            _buildListTile(
              title: AppLocalizations.of(context)!.aboutDesign,
              subtitle: 'Material 3 Expressive, Liquid Glass, Fluent Design',
              trailing: const Icon(Icons.info_outline),
              onTap: () => _showDesignInfoDialog(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataSection() {
    return Column(
      children: [
        // Widget de estado del sistema
        const AdaptiveSystemStatusWidget(),
        
        // Sección de datos original
        _buildSection(
          title: AppLocalizations.of(context)!.data,
          icon: Icons.storage,
          children: [
            _buildListTile(
              title: AppLocalizations.of(context)!.refreshData,
              subtitle: AppLocalizations.of(context)!.synchronizeWithServer,
              trailing: const Icon(Icons.refresh),
              onTap: _refreshAllData,
            ),

            _buildListTile(
              title: AppLocalizations.of(context)!.exportData,
              subtitle: 'Descargar historial de actividades',
              trailing: const Icon(Icons.download),
              onTap: _exportData,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: AppLocalizations.of(context)!.about,
      icon: Icons.info,
      children: [
        _buildListTile(
          title: AppLocalizations.of(context)!.appVersion,
          subtitle: '1.0.0',
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showVersionDialog(),
        ),
        _buildListTile(
          title: AppLocalizations.of(context)!.privacyPolicy,
          subtitle: AppLocalizations.of(context)!.howWeProtectYourData,
          trailing: const Icon(Icons.privacy_tip),
          onTap: _showPrivacyPolicy,
        ),
        _buildListTile(
          title: AppLocalizations.of(context)!.termsOfService,
          subtitle: AppLocalizations.of(context)!.termsOfUse,
          trailing: const Icon(Icons.description),
          onTap: _showTermsOfService,
        ),
        _buildListTile(
          title: AppLocalizations.of(context)!.contact,
          subtitle: AppLocalizations.of(context)!.reportIssuesOrSuggestions,
          trailing: const Icon(Icons.email),
          onTap: _showContactDialog,
        ),
        _buildListTile(
          title: AppLocalizations.of(context)!.sourceCode,
          subtitle: AppLocalizations.of(context)!.viewOnGitHub,
          trailing: const Icon(Icons.code),
          onTap: _openSourceCode,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final spacing = isSmallScreen ? 8.0 : 12.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: GlassCard(
        accentColor: AppleColors.getActivityColor(ActivityType.entrada),
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppleColors.getActivityColor(ActivityType.entrada).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppleColors.getActivityColor(ActivityType.entrada).withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: GlassEffects.glassShadows(
                        accentColor: AppleColors.getActivityColor(ActivityType.entrada),
                        intensity: 0.3,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: AppleColors.getActivityColor(ActivityType.entrada),
                      size: iconSize,
                    ),
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: Text(
                      title,
                      style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
                        fontSize: isSmallScreen ? 18.0 : 20.0,
                        fontWeight: FontWeight.w700,
                        color: AppleColors.textPrimary(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;
    final titleFontSize = isSmallScreen ? 14.0 : 16.0;
    final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;

    return FrostedPanel(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12.0 : 16.0,
        vertical: isSmallScreen ? 8.0 : 12.0,
      ),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: enabled
          ? (Theme.of(context).brightness == Brightness.dark
              ? CupertinoColors.black.withValues(alpha: 0.2)
              : CupertinoColors.white.withValues(alpha: 0.6))
          : (Theme.of(context).brightness == Brightness.dark 
              ? CupertinoColors.systemGrey.withValues(alpha: 0.3) 
              : CupertinoColors.systemGrey6.withValues(alpha: 0.5)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? AppleColors.textPrimary(context)
                        : AppleColors.textSecondary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                    fontSize: subtitleFontSize,
                    color: enabled
                        ? AppleColors.textSecondary(context)
                        : AppleColors.textSecondary(context).withValues(alpha: 0.5),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          LiquidGlassSwitch(
            value: value,
            onChanged: enabled ? onChanged : (_) {},
            activeColor: AppleColors.getActivityColor(ActivityType.entrada),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 600;
    final titleFontSize = isSmallScreen ? 14.0 : 16.0;
    final subtitleFontSize = isSmallScreen ? 12.0 : 14.0;

    return GestureDetector(
      onTap: onTap,
      child: FrostedPanel(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12.0 : 16.0,
          vertical: isSmallScreen ? 8.0 : 12.0,
        ),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? CupertinoColors.black.withValues(alpha: 0.2)
            : CupertinoColors.white.withValues(alpha: 0.6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppleColors.textPrimary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                      fontSize: subtitleFontSize,
                      color: AppleColors.textSecondary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTile({
    required String title,
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: FrostedPanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? CupertinoColors.black.withValues(alpha: 0.2)
            : CupertinoColors.white.withValues(alpha: 0.6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppleColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time.format(context),
                    style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                      fontSize: 14,
                      color: AppleColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.time,
              color: AppleColors.getActivityColor(ActivityType.entrada).withValues(alpha: 0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return AppLocalizations.of(context)!.light;
      case AppThemeMode.dark:
        return AppLocalizations.of(context)!.dark;
      case AppThemeMode.system:
        return AppLocalizations.of(context)!.system;
    }
  }

  Future<void> _requestNotificationPermission() async {
    try {
      // TODO: Implementar notificaciones si es necesario
      // await notificationService.requestPermissions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorRequestingPermissions}: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showThemeDialog(AppThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppThemeMode>(
              title: Text(AppLocalizations.of(context)!.light),
              value: AppThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<AppThemeMode>(
              title: Text(AppLocalizations.of(context)!.dark),
              value: AppThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<AppThemeMode>(
              title: Text(AppLocalizations.of(context)!.system),
              value: AppThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDesignInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.appDesign),
        content: Text(
          AppLocalizations.of(context)!.appDesignDescription,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.understood),
          ),
        ],
      ),
    );
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.versionInformation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppLocalizations.of(context)!.version}: 1.0.0'),
            const SizedBox(height: 8),
            Text('${AppLocalizations.of(context)!.build}: ${AppLocalizations.of(context)!.release}'),
            const SizedBox(height: 8),
            const Text('Flutter: 3.8.1'),
            const SizedBox(height: 8),
            const Text('Dart: 3.0.0'),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.applicationToMonitorPepito,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.privacyPolicy),
        content: SingleChildScrollView(
          child: Text(
            '${AppLocalizations.of(context)!.privacyPolicyTitle}\n\n'
            '${AppLocalizations.of(context)!.informationWeCollect}\n'
            '${AppLocalizations.of(context)!.informationWeCollectDescription}\n\n'
            '${AppLocalizations.of(context)!.useOfInformation}\n'
            '${AppLocalizations.of(context)!.useOfInformationDescription}\n\n'
            '${AppLocalizations.of(context)!.storage}\n'
            '${AppLocalizations.of(context)!.storageDescription}\n\n'
            '${AppLocalizations.of(context)!.notificationsSection}\n'
            '${AppLocalizations.of(context)!.notificationsSectionDescription}\n\n'
            '${AppLocalizations.of(context)!.thirdParties}\n'
            '${AppLocalizations.of(context)!.thirdPartiesDescription}\n\n'
            '${AppLocalizations.of(context)!.lastUpdated}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.termsOfServiceFull),
        content: SingleChildScrollView(
          child: Text(
            '${AppLocalizations.of(context)!.termsOfServiceTitle}\n\n'
            '${AppLocalizations.of(context)!.acceptance}\n'
            '${AppLocalizations.of(context)!.acceptanceDescription}\n\n'
            '${AppLocalizations.of(context)!.permittedUse}\n'
            '${AppLocalizations.of(context)!.permittedUseDescription}\n\n'
            '${AppLocalizations.of(context)!.availability}\n'
            '${AppLocalizations.of(context)!.availabilityDescription}\n\n'
            '${AppLocalizations.of(context)!.responsibility}\n'
            '${AppLocalizations.of(context)!.responsibilityDescription}\n\n'
            '${AppLocalizations.of(context)!.modifications}\n'
            '${AppLocalizations.of(context)!.modificationsDescription}\n\n'
            '${AppLocalizations.of(context)!.lastUpdated}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.contact),
        content: Text(
          AppLocalizations.of(context)!.contactDescription,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _openSourceCode() {
    // En una implementación real, esto abriría el navegador
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.openingGitHub),
      ),
    );
  }

  Future<void> _refreshAllData() async {
    try {
      // Refrescar todos los providers para forzar actualización
      await ref.read(pepitoStatusProvider.notifier).refresh();
      ref.invalidate(todayActivitiesProvider);
      ref.invalidate(activitiesProvider);
      ref.invalidate(statisticsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.dataUpdated),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorUpdating}: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _exportData() async {
    try {
      // En una implementación real, esto exportaría los datos
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.dataExported),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.exportError}: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }



  void _showLanguageDialog(Locale currentLocale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'es',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }
}