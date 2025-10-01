import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
  ];

  /// Título de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Pépito App'**
  String get appTitle;

  /// No description provided for @homeTab.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homeTab;

  /// No description provided for @activitiesTab.
  ///
  /// In es, this message translates to:
  /// **'Actividades'**
  String get activitiesTab;

  /// No description provided for @statisticsTab.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statisticsTab;

  /// No description provided for @settingsTab.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTab;

  /// No description provided for @lastActivity.
  ///
  /// In es, this message translates to:
  /// **'Última actividad'**
  String get lastActivity;

  /// No description provided for @activitiesToday.
  ///
  /// In es, this message translates to:
  /// **'Actividades hoy'**
  String get activitiesToday;

  /// No description provided for @status.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get status;

  /// No description provided for @atHome.
  ///
  /// In es, this message translates to:
  /// **'En casa'**
  String get atHome;

  /// No description provided for @awayFromHome.
  ///
  /// In es, this message translates to:
  /// **'Fuera de casa'**
  String get awayFromHome;

  /// No description provided for @recentActivities.
  ///
  /// In es, this message translates to:
  /// **'Actividades recientes'**
  String get recentActivities;

  /// No description provided for @viewAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todas'**
  String get viewAll;

  /// No description provided for @noRecentActivities.
  ///
  /// In es, this message translates to:
  /// **'No hay actividades recientes'**
  String get noRecentActivities;

  /// No description provided for @pepitoActivitiesWillAppearHere.
  ///
  /// In es, this message translates to:
  /// **'Las actividades de Pépito aparecerán aquí'**
  String get pepitoActivitiesWillAppearHere;

  /// No description provided for @errorLoadingActivities.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar actividades'**
  String get errorLoadingActivities;

  /// No description provided for @activityDetails.
  ///
  /// In es, this message translates to:
  /// **'Detalles de actividad'**
  String get activityDetails;

  /// No description provided for @noActivity.
  ///
  /// In es, this message translates to:
  /// **'Sin actividad'**
  String get noActivity;

  /// No description provided for @aFewMomentsAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace un momento'**
  String get aFewMomentsAgo;

  /// No description provided for @minutesAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {minutes}m'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {hours}h'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {days}d'**
  String daysAgo(int days);

  /// No description provided for @activities.
  ///
  /// In es, this message translates to:
  /// **'actividades'**
  String get activities;

  /// No description provided for @activeFilters.
  ///
  /// In es, this message translates to:
  /// **'Filtros activos'**
  String get activeFilters;

  /// No description provided for @clear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get clear;

  /// No description provided for @entries.
  ///
  /// In es, this message translates to:
  /// **'Entradas'**
  String get entries;

  /// No description provided for @exits.
  ///
  /// In es, this message translates to:
  /// **'Salidas'**
  String get exits;

  /// No description provided for @noActivities.
  ///
  /// In es, this message translates to:
  /// **'No hay actividades'**
  String get noActivities;

  /// No description provided for @pepitoActivitiesWillAppearWhenAvailable.
  ///
  /// In es, this message translates to:
  /// **'Las actividades de Pépito aparecerán aquí cuando estén disponibles'**
  String get pepitoActivitiesWillAppearWhenAvailable;

  /// No description provided for @update.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get update;

  /// No description provided for @filterActivities.
  ///
  /// In es, this message translates to:
  /// **'Filtrar actividades'**
  String get filterActivities;

  /// No description provided for @activityType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de actividad'**
  String get activityType;

  /// No description provided for @dateRange.
  ///
  /// In es, this message translates to:
  /// **'Rango de fechas'**
  String get dateRange;

  /// No description provided for @apply.
  ///
  /// In es, this message translates to:
  /// **'Aplicar'**
  String get apply;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @all.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get all;

  /// No description provided for @entry.
  ///
  /// In es, this message translates to:
  /// **'Entrada'**
  String get entry;

  /// No description provided for @exit.
  ///
  /// In es, this message translates to:
  /// **'Salida'**
  String get exit;

  /// No description provided for @selectDateRange.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar rango de fechas'**
  String get selectDateRange;

  /// No description provided for @from.
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get from;

  /// No description provided for @to.
  ///
  /// In es, this message translates to:
  /// **'Hasta'**
  String get to;

  /// No description provided for @statistics.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statistics;

  /// No description provided for @overview.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get overview;

  /// No description provided for @charts.
  ///
  /// In es, this message translates to:
  /// **'Gráficos'**
  String get charts;

  /// No description provided for @insights.
  ///
  /// In es, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @totalActivities.
  ///
  /// In es, this message translates to:
  /// **'Total actividades'**
  String get totalActivities;

  /// No description provided for @inSelectedPeriod.
  ///
  /// In es, this message translates to:
  /// **'En el período seleccionado'**
  String get inSelectedPeriod;

  /// No description provided for @ofTotal.
  ///
  /// In es, this message translates to:
  /// **'{percentage}% del total'**
  String ofTotal(String percentage);

  /// No description provided for @dailyAverage.
  ///
  /// In es, this message translates to:
  /// **'Promedio diario'**
  String get dailyAverage;

  /// No description provided for @activitiesPerDay.
  ///
  /// In es, this message translates to:
  /// **'Actividades por día'**
  String get activitiesPerDay;

  /// No description provided for @activitiesByDay.
  ///
  /// In es, this message translates to:
  /// **'Actividades por día'**
  String get activitiesByDay;

  /// No description provided for @notEnoughDataForInsights.
  ///
  /// In es, this message translates to:
  /// **'No hay suficientes datos para generar insights.'**
  String get notEnoughDataForInsights;

  /// No description provided for @pepitoSpendsMoreTimeAtHome.
  ///
  /// In es, this message translates to:
  /// **'Pépito tiende a pasar más tiempo en casa que fuera.'**
  String get pepitoSpendsMoreTimeAtHome;

  /// No description provided for @pepitoIsAdventurous.
  ///
  /// In es, this message translates to:
  /// **'Pépito es muy aventurero y le gusta explorar fuera de casa.'**
  String get pepitoIsAdventurous;

  /// No description provided for @pepitoIsMoreActiveMornings.
  ///
  /// In es, this message translates to:
  /// **'Pépito es más activo en las mañanas.'**
  String get pepitoIsMoreActiveMornings;

  /// No description provided for @pepitoPrefersEveningActivities.
  ///
  /// In es, this message translates to:
  /// **'Pépito prefiere las actividades vespertinas.'**
  String get pepitoPrefersEveningActivities;

  /// No description provided for @notEnoughDataForPatterns.
  ///
  /// In es, this message translates to:
  /// **'No hay suficientes datos para detectar patrones.'**
  String get notEnoughDataForPatterns;

  /// No description provided for @mondaysAreMostActive.
  ///
  /// In es, this message translates to:
  /// **'Los lunes son los días más activos para Pépito.'**
  String get mondaysAreMostActive;

  /// No description provided for @tuesdaysAreMostActive.
  ///
  /// In es, this message translates to:
  /// **'Los martes son los días más activos para Pépito.'**
  String get tuesdaysAreMostActive;

  /// No description provided for @wednesdaysAreMostActive.
  ///
  /// In es, this message translates to:
  /// **'Los miércoles son los días más activos para Pépito.'**
  String get wednesdaysAreMostActive;

  /// No description provided for @thursdaysAreMostActive.
  ///
  /// In es, this message translates to:
  /// **'Los jueves son los días más activos para Pépito.'**
  String get thursdaysAreMostActive;

  /// No description provided for @fridaysAreMostActive.
  ///
  /// In es, this message translates to:
  /// **'Los viernes son los días más activos para Pépito.'**
  String get fridaysAreMostActive;

  /// No description provided for @saturdaysAreMostActive.
  ///
  /// In es, this message translates to:
  /// **'Los sábados son los días más activos para Pépito.'**
  String get saturdaysAreMostActive;

  /// No description provided for @sundaysAreMostActive.
  ///
  /// In es, this message translates to:
  /// **'Los domingos son los días más activos para Pépito.'**
  String get sundaysAreMostActive;

  /// No description provided for @pepitoHasRegularPattern.
  ///
  /// In es, this message translates to:
  /// **'Pépito tiene un patrón de actividad muy regular.'**
  String get pepitoHasRegularPattern;

  /// No description provided for @pepitoHasLowActivityPeriods.
  ///
  /// In es, this message translates to:
  /// **'Pépito tiene períodos de baja actividad.'**
  String get pepitoHasLowActivityPeriods;

  /// No description provided for @configureNotifications.
  ///
  /// In es, this message translates to:
  /// **'Configura las notificaciones para recibir alertas de actividad.'**
  String get configureNotifications;

  /// No description provided for @considerAdjustingSensor.
  ///
  /// In es, this message translates to:
  /// **'Considera ajustar la configuración del sensor para mejorar la precisión.'**
  String get considerAdjustingSensor;

  /// No description provided for @pepitoGoesOutMuch.
  ///
  /// In es, this message translates to:
  /// **'Pépito sale mucho de casa. Considera revisar su seguridad exterior.'**
  String get pepitoGoesOutMuch;

  /// No description provided for @reviewStatisticsRegularly.
  ///
  /// In es, this message translates to:
  /// **'Revisa las estadísticas regularmente para entender mejor los hábitos de Pépito.'**
  String get reviewStatisticsRegularly;

  /// No description provided for @timeAnalysis.
  ///
  /// In es, this message translates to:
  /// **'Análisis de tiempo'**
  String get timeAnalysis;

  /// No description provided for @monday.
  ///
  /// In es, this message translates to:
  /// **'lunes'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In es, this message translates to:
  /// **'martes'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In es, this message translates to:
  /// **'miércoles'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In es, this message translates to:
  /// **'jueves'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In es, this message translates to:
  /// **'viernes'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In es, this message translates to:
  /// **'sábado'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In es, this message translates to:
  /// **'domingo'**
  String get sunday;

  /// No description provided for @spendsMoreTimeInside.
  ///
  /// In es, this message translates to:
  /// **'Pépito tiende a pasar más tiempo en casa que fuera.'**
  String get spendsMoreTimeInside;

  /// No description provided for @adventurousOutside.
  ///
  /// In es, this message translates to:
  /// **'Pépito es muy aventurero y le gusta explorar fuera de casa.'**
  String get adventurousOutside;

  /// No description provided for @moreActiveMornings.
  ///
  /// In es, this message translates to:
  /// **'Pépito es más activo en las mañanas.'**
  String get moreActiveMornings;

  /// No description provided for @prefersEveningActivities.
  ///
  /// In es, this message translates to:
  /// **'Pépito prefiere las actividades vespertinas.'**
  String get prefersEveningActivities;

  /// No description provided for @mostActiveDays.
  ///
  /// In es, this message translates to:
  /// **'Los {day}s son los días más activos para Pépito.'**
  String mostActiveDays(String day);

  /// No description provided for @checkOutdoorSafety.
  ///
  /// In es, this message translates to:
  /// **'Pépito sale mucho de casa. Considera revisar su seguridad exterior.'**
  String get checkOutdoorSafety;

  /// No description provided for @pepitoSafeAtHome.
  ///
  /// In es, this message translates to:
  /// **'Pépito está seguro en casa'**
  String get pepitoSafeAtHome;

  /// No description provided for @pepitoExploring.
  ///
  /// In es, this message translates to:
  /// **'Pépito está explorando'**
  String get pepitoExploring;

  /// No description provided for @lastSeen.
  ///
  /// In es, this message translates to:
  /// **'Última vez visto'**
  String get lastSeen;

  /// No description provided for @additionalInformation.
  ///
  /// In es, this message translates to:
  /// **'Información adicional:'**
  String get additionalInformation;

  /// No description provided for @away.
  ///
  /// In es, this message translates to:
  /// **'Fuera'**
  String get away;

  /// No description provided for @noDataAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay datos disponibles'**
  String get noDataAvailable;

  /// No description provided for @noActivitiesInPeriod.
  ///
  /// In es, this message translates to:
  /// **'No hay actividades en este período'**
  String get noActivitiesInPeriod;

  /// No description provided for @summaryOf.
  ///
  /// In es, this message translates to:
  /// **'Resumen de'**
  String get summaryOf;

  /// No description provided for @mostActiveHour.
  ///
  /// In es, this message translates to:
  /// **'Hora más activa'**
  String get mostActiveHour;

  /// No description provided for @entriesToday.
  ///
  /// In es, this message translates to:
  /// **'Entradas hoy'**
  String get entriesToday;

  /// No description provided for @exitsToday.
  ///
  /// In es, this message translates to:
  /// **'Salidas hoy'**
  String get exitsToday;

  /// No description provided for @timeAtHome.
  ///
  /// In es, this message translates to:
  /// **'Tiempo en casa'**
  String get timeAtHome;

  /// No description provided for @atHomeStatus.
  ///
  /// In es, this message translates to:
  /// **'En casa'**
  String get atHomeStatus;

  /// No description provided for @awayStatus.
  ///
  /// In es, this message translates to:
  /// **'Fuera'**
  String get awayStatus;

  /// No description provided for @hoursAway.
  ///
  /// In es, this message translates to:
  /// **'h fuera'**
  String get hoursAway;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @aboutDesign.
  ///
  /// In es, this message translates to:
  /// **'Acerca del diseño'**
  String get aboutDesign;

  /// No description provided for @appDesign.
  ///
  /// In es, this message translates to:
  /// **'Diseño de la aplicación'**
  String get appDesign;

  /// No description provided for @termsOfService.
  ///
  /// In es, this message translates to:
  /// **'Términos de servicio'**
  String get termsOfService;

  /// No description provided for @contact.
  ///
  /// In es, this message translates to:
  /// **'Contacto'**
  String get contact;

  /// No description provided for @data.
  ///
  /// In es, this message translates to:
  /// **'Datos'**
  String get data;

  /// No description provided for @updateData.
  ///
  /// In es, this message translates to:
  /// **'Actualizar datos'**
  String get updateData;

  /// No description provided for @syncWithServer.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar con el servidor'**
  String get syncWithServer;

  /// No description provided for @clearCache.
  ///
  /// In es, this message translates to:
  /// **'Limpiar caché'**
  String get clearCache;

  /// No description provided for @freeStorageSpace.
  ///
  /// In es, this message translates to:
  /// **'Liberar espacio de almacenamiento'**
  String get freeStorageSpace;

  /// No description provided for @exportData.
  ///
  /// In es, this message translates to:
  /// **'Exportar datos'**
  String get exportData;

  /// No description provided for @downloadActivityHistory.
  ///
  /// In es, this message translates to:
  /// **'Descargar historial de actividades'**
  String get downloadActivityHistory;

  /// No description provided for @versionInfo.
  ///
  /// In es, this message translates to:
  /// **'Información de la versión'**
  String get versionInfo;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// No description provided for @build.
  ///
  /// In es, this message translates to:
  /// **'Compilación'**
  String get build;

  /// No description provided for @flutter.
  ///
  /// In es, this message translates to:
  /// **'Flutter: 3.8.1'**
  String get flutter;

  /// No description provided for @dart.
  ///
  /// In es, this message translates to:
  /// **'Dart: 3.0.0'**
  String get dart;

  /// No description provided for @appDescription.
  ///
  /// In es, this message translates to:
  /// **'Aplicación para monitorear las actividades del gato Pépito.'**
  String get appDescription;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @contactDescription.
  ///
  /// In es, this message translates to:
  /// **'¿Tienes algún problema o sugerencia?\n\nPuedes contactarnos a través de:\n\n• GitHub Issues\n• Email: pedrojuuu@gmail.com\n• Twitter: @pedrojuuu\n\nEstaremos encantados de ayudarte.'**
  String get contactDescription;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In es, this message translates to:
  /// **'Hecho'**
  String get done;

  /// No description provided for @yes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In es, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get english;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @sound.
  ///
  /// In es, this message translates to:
  /// **'Sonido'**
  String get sound;

  /// No description provided for @vibration.
  ///
  /// In es, this message translates to:
  /// **'Vibración'**
  String get vibration;

  /// No description provided for @quietHours.
  ///
  /// In es, this message translates to:
  /// **'Horas silenciosas'**
  String get quietHours;

  /// No description provided for @selectTheme.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar tema'**
  String get selectTheme;

  /// No description provided for @light.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get system;

  /// No description provided for @clearCacheConfirmation.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres limpiar la caché?'**
  String get clearCacheConfirmation;

  /// No description provided for @cacheCleared.
  ///
  /// In es, this message translates to:
  /// **'Caché limpiada exitosamente'**
  String get cacheCleared;

  /// No description provided for @dataExported.
  ///
  /// In es, this message translates to:
  /// **'Datos exportados exitosamente'**
  String get dataExported;

  /// No description provided for @exportError.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar datos'**
  String get exportError;

  /// No description provided for @noData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos'**
  String get noData;

  /// No description provided for @averageTimeAtHome.
  ///
  /// In es, this message translates to:
  /// **'Tiempo promedio en casa'**
  String get averageTimeAtHome;

  /// No description provided for @averageTimeAway.
  ///
  /// In es, this message translates to:
  /// **'Tiempo promedio fuera'**
  String get averageTimeAway;

  /// No description provided for @justNow.
  ///
  /// In es, this message translates to:
  /// **'Hace un momento'**
  String get justNow;

  /// No description provided for @home.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get home;

  /// No description provided for @viewDetailedAnalysis.
  ///
  /// In es, this message translates to:
  /// **'Ver análisis detallado'**
  String get viewDetailedAnalysis;

  /// No description provided for @configureAlerts.
  ///
  /// In es, this message translates to:
  /// **'Configurar alertas'**
  String get configureAlerts;

  /// No description provided for @pushNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones push'**
  String get pushNotifications;

  /// No description provided for @receiveNotificationsWhenPepitoEntersOrLeaves.
  ///
  /// In es, this message translates to:
  /// **'Recibir notificaciones cuando Pépito entre o salga'**
  String get receiveNotificationsWhenPepitoEntersOrLeaves;

  /// No description provided for @entryNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones de entrada'**
  String get entryNotifications;

  /// No description provided for @notifyWhenPepitoArrivesHome.
  ///
  /// In es, this message translates to:
  /// **'Notificar cuando Pépito llegue a casa'**
  String get notifyWhenPepitoArrivesHome;

  /// No description provided for @exitNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones de salida'**
  String get exitNotifications;

  /// No description provided for @notifyWhenPepitoLeavesHome.
  ///
  /// In es, this message translates to:
  /// **'Notificar cuando Pépito salga de casa'**
  String get notifyWhenPepitoLeavesHome;

  /// No description provided for @playSoundWithNotifications.
  ///
  /// In es, this message translates to:
  /// **'Reproducir sonido con las notificaciones'**
  String get playSoundWithNotifications;

  /// No description provided for @vibrateWithNotifications.
  ///
  /// In es, this message translates to:
  /// **'Vibrar con las notificaciones'**
  String get vibrateWithNotifications;

  /// No description provided for @doNotDisturbDuringCertainHours.
  ///
  /// In es, this message translates to:
  /// **'No molestar durante ciertas horas'**
  String get doNotDisturbDuringCertainHours;

  /// No description provided for @quietHoursStart.
  ///
  /// In es, this message translates to:
  /// **'Inicio de horas silenciosas'**
  String get quietHoursStart;

  /// No description provided for @quietHoursEnd.
  ///
  /// In es, this message translates to:
  /// **'Fin de horas silenciosas'**
  String get quietHoursEnd;

  /// No description provided for @automatic.
  ///
  /// In es, this message translates to:
  /// **'Automático (sistema)'**
  String get automatic;

  /// No description provided for @understood.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get understood;

  /// No description provided for @appVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión de la app'**
  String get appVersion;

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get privacyPolicy;

  /// No description provided for @howWeProtectYourData.
  ///
  /// In es, this message translates to:
  /// **'Cómo protegemos tus datos'**
  String get howWeProtectYourData;

  /// No description provided for @termsOfServiceFull.
  ///
  /// In es, this message translates to:
  /// **'Términos de servicio'**
  String get termsOfServiceFull;

  /// No description provided for @conditionsOfUse.
  ///
  /// In es, this message translates to:
  /// **'Condiciones de uso'**
  String get conditionsOfUse;

  /// No description provided for @reportProblemsOrSuggestions.
  ///
  /// In es, this message translates to:
  /// **'Reportar problemas o sugerencias'**
  String get reportProblemsOrSuggestions;

  /// No description provided for @sourceCode.
  ///
  /// In es, this message translates to:
  /// **'Código fuente'**
  String get sourceCode;

  /// No description provided for @viewOnGitHub.
  ///
  /// In es, this message translates to:
  /// **'Ver en GitHub'**
  String get viewOnGitHub;

  /// No description provided for @about.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get about;

  /// No description provided for @dataUpdated.
  ///
  /// In es, this message translates to:
  /// **'Datos actualizados'**
  String get dataUpdated;

  /// No description provided for @errorUpdating.
  ///
  /// In es, this message translates to:
  /// **'Error al actualizar: {error}'**
  String errorUpdating(String error);

  /// No description provided for @importantInformation.
  ///
  /// In es, this message translates to:
  /// **'Información importante'**
  String get importantInformation;

  /// No description provided for @currentStatusOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo se muestra el estado actual de Pépito'**
  String get currentStatusOnly;

  /// No description provided for @percentOfTotal.
  ///
  /// In es, this message translates to:
  /// **'% del total'**
  String get percentOfTotal;

  /// No description provided for @temporalAnalysis.
  ///
  /// In es, this message translates to:
  /// **'Análisis temporal'**
  String get temporalAnalysis;

  /// No description provided for @leastActiveHour.
  ///
  /// In es, this message translates to:
  /// **'Hora menos activa'**
  String get leastActiveHour;

  /// No description provided for @averageConfidence.
  ///
  /// In es, this message translates to:
  /// **'Confianza promedio'**
  String get averageConfidence;

  /// No description provided for @hourlyDistribution.
  ///
  /// In es, this message translates to:
  /// **'Distribución por horas'**
  String get hourlyDistribution;

  /// No description provided for @weeklyPattern.
  ///
  /// In es, this message translates to:
  /// **'Patrón semanal'**
  String get weeklyPattern;

  /// No description provided for @behaviorInsights.
  ///
  /// In es, this message translates to:
  /// **'Insights de comportamiento'**
  String get behaviorInsights;

  /// No description provided for @detectedPatterns.
  ///
  /// In es, this message translates to:
  /// **'Patrones detectados'**
  String get detectedPatterns;

  /// No description provided for @recommendations.
  ///
  /// In es, this message translates to:
  /// **'Recomendaciones'**
  String get recommendations;

  /// No description provided for @errorLoadingStatistics.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar estadísticas'**
  String get errorLoadingStatistics;

  /// No description provided for @customPeriod.
  ///
  /// In es, this message translates to:
  /// **'período personalizado'**
  String get customPeriod;

  /// No description provided for @notEnoughDataInsights.
  ///
  /// In es, this message translates to:
  /// **'No hay suficientes datos para generar insights.'**
  String get notEnoughDataInsights;

  /// No description provided for @pepitoHomeTendency.
  ///
  /// In es, this message translates to:
  /// **'Pépito tiende a pasar más tiempo en casa que fuera.'**
  String get pepitoHomeTendency;

  /// No description provided for @pepitoAdventurous.
  ///
  /// In es, this message translates to:
  /// **'Pépito es muy aventurero y le gusta explorar fuera de casa.'**
  String get pepitoAdventurous;

  /// No description provided for @pepitoMorningActive.
  ///
  /// In es, this message translates to:
  /// **'Pépito es más activo en las mañanas.'**
  String get pepitoMorningActive;

  /// No description provided for @pepitoEveningActive.
  ///
  /// In es, this message translates to:
  /// **'Pépito prefiere las actividades vespertinas.'**
  String get pepitoEveningActive;

  /// No description provided for @notEnoughDataPatterns.
  ///
  /// In es, this message translates to:
  /// **'No hay suficientes datos para detectar patrones.'**
  String get notEnoughDataPatterns;

  /// No description provided for @mondaysActive.
  ///
  /// In es, this message translates to:
  /// **'Los lunes son los días más activos para Pépito.'**
  String get mondaysActive;

  /// No description provided for @tuesdaysActive.
  ///
  /// In es, this message translates to:
  /// **'Los martes son los días más activos para Pépito.'**
  String get tuesdaysActive;

  /// No description provided for @wednesdaysActive.
  ///
  /// In es, this message translates to:
  /// **'Los miércoles son los días más activos para Pépito.'**
  String get wednesdaysActive;

  /// No description provided for @thursdaysActive.
  ///
  /// In es, this message translates to:
  /// **'Los jueves son los días más activos para Pépito.'**
  String get thursdaysActive;

  /// No description provided for @fridaysActive.
  ///
  /// In es, this message translates to:
  /// **'Los viernes son los días más activos para Pépito.'**
  String get fridaysActive;

  /// No description provided for @saturdaysActive.
  ///
  /// In es, this message translates to:
  /// **'Los sábados son los días más activos para Pépito.'**
  String get saturdaysActive;

  /// No description provided for @sundaysActive.
  ///
  /// In es, this message translates to:
  /// **'Los domingos son los días más activos para Pépito.'**
  String get sundaysActive;

  /// No description provided for @regularActivityPattern.
  ///
  /// In es, this message translates to:
  /// **'Pépito tiene un patrón de actividad muy regular.'**
  String get regularActivityPattern;

  /// No description provided for @lowActivityPeriods.
  ///
  /// In es, this message translates to:
  /// **'Pépito tiene períodos de baja actividad.'**
  String get lowActivityPeriods;

  /// No description provided for @adjustSensorConfiguration.
  ///
  /// In es, this message translates to:
  /// **'Considera ajustar la configuración del sensor para mejorar la precisión.'**
  String get adjustSensorConfiguration;

  /// No description provided for @reviewOutdoorSafety.
  ///
  /// In es, this message translates to:
  /// **'Pépito sale mucho de casa. Considera revisar su seguridad exterior.'**
  String get reviewOutdoorSafety;

  /// No description provided for @errorClearingCache.
  ///
  /// In es, this message translates to:
  /// **'Error al limpiar caché'**
  String get errorClearingCache;

  /// No description provided for @openingGitHub.
  ///
  /// In es, this message translates to:
  /// **'Abriendo GitHub...'**
  String get openingGitHub;

  /// No description provided for @selectLanguage.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar idioma'**
  String get selectLanguage;

  /// No description provided for @errorRequestingPermissions.
  ///
  /// In es, this message translates to:
  /// **'Error al solicitar permisos'**
  String get errorRequestingPermissions;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In es, this message translates to:
  /// **'Semana pasada'**
  String get lastWeek;

  /// No description provided for @thisMonth.
  ///
  /// In es, this message translates to:
  /// **'Este mes'**
  String get thisMonth;

  /// No description provided for @last30Days.
  ///
  /// In es, this message translates to:
  /// **'Últimos 30 días'**
  String get last30Days;

  /// No description provided for @analysis.
  ///
  /// In es, this message translates to:
  /// **'Análisis'**
  String get analysis;

  /// No description provided for @refreshData.
  ///
  /// In es, this message translates to:
  /// **'Actualizar datos'**
  String get refreshData;

  /// No description provided for @synchronizeWithServer.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar con el servidor'**
  String get synchronizeWithServer;

  /// No description provided for @termsOfUse.
  ///
  /// In es, this message translates to:
  /// **'Condiciones de uso'**
  String get termsOfUse;

  /// No description provided for @reportIssuesOrSuggestions.
  ///
  /// In es, this message translates to:
  /// **'Reportar problemas o sugerencias'**
  String get reportIssuesOrSuggestions;

  /// No description provided for @appDesignDescription.
  ///
  /// In es, this message translates to:
  /// **'Esta aplicación utiliza el sistema de diseño nativo de cada plataforma:\n\n• Android/Web: Material 3 Expressive\n• iOS/macOS: Liquid Glass Design\n• Windows: Fluent Design\n\nEsto garantiza una experiencia familiar y consistente en cada dispositivo.'**
  String get appDesignDescription;

  /// No description provided for @versionInformation.
  ///
  /// In es, this message translates to:
  /// **'Información de la versión'**
  String get versionInformation;

  /// No description provided for @release.
  ///
  /// In es, this message translates to:
  /// **'Release'**
  String get release;

  /// No description provided for @applicationToMonitorPepito.
  ///
  /// In es, this message translates to:
  /// **'Aplicación para monitorear las actividades del gato Pépito.'**
  String get applicationToMonitorPepito;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In es, this message translates to:
  /// **'POLÍTICA DE PRIVACIDAD'**
  String get privacyPolicyTitle;

  /// No description provided for @informationWeCollect.
  ///
  /// In es, this message translates to:
  /// **'1. INFORMACIÓN QUE RECOPILAMOS'**
  String get informationWeCollect;

  /// No description provided for @informationWeCollectDescription.
  ///
  /// In es, this message translates to:
  /// **'Esta aplicación recopila únicamente los datos de actividad de Pépito proporcionados por la API oficial.'**
  String get informationWeCollectDescription;

  /// No description provided for @useOfInformation.
  ///
  /// In es, this message translates to:
  /// **'2. USO DE LA INFORMACIÓN'**
  String get useOfInformation;

  /// No description provided for @useOfInformationDescription.
  ///
  /// In es, this message translates to:
  /// **'Los datos se utilizan exclusivamente para mostrar el estado y actividades de Pépito.'**
  String get useOfInformationDescription;

  /// No description provided for @storage.
  ///
  /// In es, this message translates to:
  /// **'3. ALMACENAMIENTO'**
  String get storage;

  /// No description provided for @storageDescription.
  ///
  /// In es, this message translates to:
  /// **'Los datos del estado de Pépito se obtienen de la API y se almacenan temporalmente en caché local para mejorar el rendimiento.'**
  String get storageDescription;

  /// No description provided for @notificationsSection.
  ///
  /// In es, this message translates to:
  /// **'4. NOTIFICACIONES'**
  String get notificationsSection;

  /// No description provided for @notificationsSectionDescription.
  ///
  /// In es, this message translates to:
  /// **'Las notificaciones push requieren un token de dispositivo que se maneja de forma segura.'**
  String get notificationsSectionDescription;

  /// No description provided for @thirdParties.
  ///
  /// In es, this message translates to:
  /// **'5. TERCEROS'**
  String get thirdParties;

  /// No description provided for @thirdPartiesDescription.
  ///
  /// In es, this message translates to:
  /// **'No compartimos información personal con terceros.'**
  String get thirdPartiesDescription;

  /// No description provided for @lastUpdated.
  ///
  /// In es, this message translates to:
  /// **'Última actualización: Octubre 2025'**
  String get lastUpdated;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In es, this message translates to:
  /// **'TÉRMINOS DE SERVICIO'**
  String get termsOfServiceTitle;

  /// No description provided for @acceptance.
  ///
  /// In es, this message translates to:
  /// **'1. ACEPTACIÓN'**
  String get acceptance;

  /// No description provided for @acceptanceDescription.
  ///
  /// In es, this message translates to:
  /// **'Al usar esta aplicación, aceptas estos términos.'**
  String get acceptanceDescription;

  /// No description provided for @permittedUse.
  ///
  /// In es, this message translates to:
  /// **'2. USO PERMITIDO'**
  String get permittedUse;

  /// No description provided for @permittedUseDescription.
  ///
  /// In es, this message translates to:
  /// **'Esta aplicación es para uso personal y monitoreo de Pépito.'**
  String get permittedUseDescription;

  /// No description provided for @availability.
  ///
  /// In es, this message translates to:
  /// **'3. DISPONIBILIDAD'**
  String get availability;

  /// No description provided for @availabilityDescription.
  ///
  /// In es, this message translates to:
  /// **'El servicio depende de la API de Pépito y puede no estar disponible en todo momento.'**
  String get availabilityDescription;

  /// No description provided for @responsibility.
  ///
  /// In es, this message translates to:
  /// **'4. RESPONSABILIDAD'**
  String get responsibility;

  /// No description provided for @responsibilityDescription.
  ///
  /// In es, this message translates to:
  /// **'No nos hacemos responsables por decisiones tomadas basadas en los datos mostrados.'**
  String get responsibilityDescription;

  /// No description provided for @modifications.
  ///
  /// In es, this message translates to:
  /// **'5. MODIFICACIONES'**
  String get modifications;

  /// No description provided for @modificationsDescription.
  ///
  /// In es, this message translates to:
  /// **'Nos reservamos el derecho de modificar estos términos.'**
  String get modificationsDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
