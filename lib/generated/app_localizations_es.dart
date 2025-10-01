// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Pépito App';

  @override
  String get homeTab => 'Inicio';

  @override
  String get activitiesTab => 'Actividades';

  @override
  String get statisticsTab => 'Estadísticas';

  @override
  String get settingsTab => 'Configuración';

  @override
  String get lastActivity => 'Última actividad';

  @override
  String get activitiesToday => 'Actividades hoy';

  @override
  String get status => 'Estado';

  @override
  String get atHome => 'En casa';

  @override
  String get awayFromHome => 'Fuera de casa';

  @override
  String get recentActivities => 'Actividades recientes';

  @override
  String get viewAll => 'Ver todas';

  @override
  String get noRecentActivities => 'No hay actividades recientes';

  @override
  String get pepitoActivitiesWillAppearHere =>
      'Las actividades de Pépito aparecerán aquí';

  @override
  String get errorLoadingActivities => 'Error al cargar actividades';

  @override
  String get activityDetails => 'Detalles de actividad';

  @override
  String get noActivity => 'Sin actividad';

  @override
  String get aFewMomentsAgo => 'Hace un momento';

  @override
  String minutesAgo(int minutes) {
    return 'Hace ${minutes}m';
  }

  @override
  String hoursAgo(int hours) {
    return 'Hace ${hours}h';
  }

  @override
  String daysAgo(int days) {
    return 'Hace ${days}d';
  }

  @override
  String get activities => 'actividades';

  @override
  String get activeFilters => 'Filtros activos';

  @override
  String get clear => 'Limpiar';

  @override
  String get entries => 'Entradas';

  @override
  String get exits => 'Salidas';

  @override
  String get noActivities => 'No hay actividades';

  @override
  String get pepitoActivitiesWillAppearWhenAvailable =>
      'Las actividades de Pépito aparecerán aquí cuando estén disponibles';

  @override
  String get update => 'Actualizar';

  @override
  String get filterActivities => 'Filtrar actividades';

  @override
  String get activityType => 'Tipo de actividad';

  @override
  String get dateRange => 'Rango de fechas';

  @override
  String get apply => 'Aplicar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get all => 'Todas';

  @override
  String get entry => 'Entrada';

  @override
  String get exit => 'Salida';

  @override
  String get selectDateRange => 'Seleccionar rango de fechas';

  @override
  String get from => 'Desde';

  @override
  String get to => 'Hasta';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get overview => 'Resumen';

  @override
  String get charts => 'Gráficos';

  @override
  String get insights => 'Insights';

  @override
  String get totalActivities => 'Total actividades';

  @override
  String get inSelectedPeriod => 'En el período seleccionado';

  @override
  String ofTotal(String percentage) {
    return '$percentage% del total';
  }

  @override
  String get dailyAverage => 'Promedio diario';

  @override
  String get activitiesPerDay => 'Actividades por día';

  @override
  String get activitiesByDay => 'Actividades por día';

  @override
  String get notEnoughDataForInsights =>
      'No hay suficientes datos para generar insights.';

  @override
  String get pepitoSpendsMoreTimeAtHome =>
      'Pépito tiende a pasar más tiempo en casa que fuera.';

  @override
  String get pepitoIsAdventurous =>
      'Pépito es muy aventurero y le gusta explorar fuera de casa.';

  @override
  String get pepitoIsMoreActiveMornings =>
      'Pépito es más activo en las mañanas.';

  @override
  String get pepitoPrefersEveningActivities =>
      'Pépito prefiere las actividades vespertinas.';

  @override
  String get notEnoughDataForPatterns =>
      'No hay suficientes datos para detectar patrones.';

  @override
  String get mondaysAreMostActive =>
      'Los lunes son los días más activos para Pépito.';

  @override
  String get tuesdaysAreMostActive =>
      'Los martes son los días más activos para Pépito.';

  @override
  String get wednesdaysAreMostActive =>
      'Los miércoles son los días más activos para Pépito.';

  @override
  String get thursdaysAreMostActive =>
      'Los jueves son los días más activos para Pépito.';

  @override
  String get fridaysAreMostActive =>
      'Los viernes son los días más activos para Pépito.';

  @override
  String get saturdaysAreMostActive =>
      'Los sábados son los días más activos para Pépito.';

  @override
  String get sundaysAreMostActive =>
      'Los domingos son los días más activos para Pépito.';

  @override
  String get pepitoHasRegularPattern =>
      'Pépito tiene un patrón de actividad muy regular.';

  @override
  String get pepitoHasLowActivityPeriods =>
      'Pépito tiene períodos de baja actividad.';

  @override
  String get configureNotifications =>
      'Configura las notificaciones para recibir alertas de actividad.';

  @override
  String get considerAdjustingSensor =>
      'Considera ajustar la configuración del sensor para mejorar la precisión.';

  @override
  String get pepitoGoesOutMuch =>
      'Pépito sale mucho de casa. Considera revisar su seguridad exterior.';

  @override
  String get reviewStatisticsRegularly =>
      'Revisa las estadísticas regularmente para entender mejor los hábitos de Pépito.';

  @override
  String get timeAnalysis => 'Análisis de tiempo';

  @override
  String get monday => 'lunes';

  @override
  String get tuesday => 'martes';

  @override
  String get wednesday => 'miércoles';

  @override
  String get thursday => 'jueves';

  @override
  String get friday => 'viernes';

  @override
  String get saturday => 'sábado';

  @override
  String get sunday => 'domingo';

  @override
  String get spendsMoreTimeInside =>
      'Pépito tiende a pasar más tiempo en casa que fuera.';

  @override
  String get adventurousOutside =>
      'Pépito es muy aventurero y le gusta explorar fuera de casa.';

  @override
  String get moreActiveMornings => 'Pépito es más activo en las mañanas.';

  @override
  String get prefersEveningActivities =>
      'Pépito prefiere las actividades vespertinas.';

  @override
  String mostActiveDays(String day) {
    return 'Los ${day}s son los días más activos para Pépito.';
  }

  @override
  String get checkOutdoorSafety =>
      'Pépito sale mucho de casa. Considera revisar su seguridad exterior.';

  @override
  String get pepitoSafeAtHome => 'Pépito está seguro en casa';

  @override
  String get pepitoExploring => 'Pépito está explorando';

  @override
  String get lastSeen => 'Última vez visto';

  @override
  String get additionalInformation => 'Información adicional:';

  @override
  String get away => 'Fuera';

  @override
  String get noDataAvailable => 'No hay datos disponibles';

  @override
  String get noActivitiesInPeriod => 'No hay actividades en este período';

  @override
  String get summaryOf => 'Resumen de';

  @override
  String get mostActiveHour => 'Hora más activa';

  @override
  String get entriesToday => 'Entradas hoy';

  @override
  String get exitsToday => 'Salidas hoy';

  @override
  String get timeAtHome => 'Tiempo en casa';

  @override
  String get atHomeStatus => 'En casa';

  @override
  String get awayStatus => 'Fuera';

  @override
  String get hoursAway => 'h fuera';

  @override
  String get settings => 'Configuración';

  @override
  String get appearance => 'Apariencia';

  @override
  String get theme => 'Tema';

  @override
  String get aboutDesign => 'Acerca del diseño';

  @override
  String get appDesign => 'Diseño de la aplicación';

  @override
  String get termsOfService => 'Términos de servicio';

  @override
  String get contact => 'Contacto';

  @override
  String get data => 'Datos';

  @override
  String get updateData => 'Actualizar datos';

  @override
  String get syncWithServer => 'Sincronizar con el servidor';

  @override
  String get clearCache => 'Limpiar caché';

  @override
  String get freeStorageSpace => 'Liberar espacio de almacenamiento';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get downloadActivityHistory => 'Descargar historial de actividades';

  @override
  String get versionInfo => 'Información de la versión';

  @override
  String get version => 'Versión';

  @override
  String get build => 'Compilación';

  @override
  String get flutter => 'Flutter: 3.8.1';

  @override
  String get dart => 'Dart: 3.0.0';

  @override
  String get appDescription =>
      'Aplicación para monitorear las actividades del gato Pépito.';

  @override
  String get close => 'Cerrar';

  @override
  String get contactDescription =>
      '¿Tienes algún problema o sugerencia?\n\nPuedes contactarnos a través de:\n\n• GitHub Issues\n• Email: pedrojuuu@gmail.com\n• Twitter: @pedrojuuu\n\nEstaremos encantados de ayudarte.';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get done => 'Hecho';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get sound => 'Sonido';

  @override
  String get vibration => 'Vibración';

  @override
  String get quietHours => 'Horas silenciosas';

  @override
  String get selectTheme => 'Seleccionar tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get system => 'Sistema';

  @override
  String get clearCacheConfirmation =>
      '¿Estás seguro de que quieres limpiar la caché?';

  @override
  String get cacheCleared => 'Caché limpiada exitosamente';

  @override
  String get dataExported => 'Datos exportados exitosamente';

  @override
  String get exportError => 'Error al exportar datos';

  @override
  String get noData => 'Sin datos';

  @override
  String get averageTimeAtHome => 'Tiempo promedio en casa';

  @override
  String get averageTimeAway => 'Tiempo promedio fuera';

  @override
  String get justNow => 'Hace un momento';

  @override
  String get home => 'Inicio';

  @override
  String get viewDetailedAnalysis => 'Ver análisis detallado';

  @override
  String get configureAlerts => 'Configurar alertas';

  @override
  String get pushNotifications => 'Notificaciones push';

  @override
  String get receiveNotificationsWhenPepitoEntersOrLeaves =>
      'Recibir notificaciones cuando Pépito entre o salga';

  @override
  String get entryNotifications => 'Notificaciones de entrada';

  @override
  String get notifyWhenPepitoArrivesHome =>
      'Notificar cuando Pépito llegue a casa';

  @override
  String get exitNotifications => 'Notificaciones de salida';

  @override
  String get notifyWhenPepitoLeavesHome =>
      'Notificar cuando Pépito salga de casa';

  @override
  String get playSoundWithNotifications =>
      'Reproducir sonido con las notificaciones';

  @override
  String get vibrateWithNotifications => 'Vibrar con las notificaciones';

  @override
  String get doNotDisturbDuringCertainHours =>
      'No molestar durante ciertas horas';

  @override
  String get quietHoursStart => 'Inicio de horas silenciosas';

  @override
  String get quietHoursEnd => 'Fin de horas silenciosas';

  @override
  String get automatic => 'Automático (sistema)';

  @override
  String get understood => 'Entendido';

  @override
  String get appVersion => 'Versión de la app';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get howWeProtectYourData => 'Cómo protegemos tus datos';

  @override
  String get termsOfServiceFull => 'Términos de servicio';

  @override
  String get conditionsOfUse => 'Condiciones de uso';

  @override
  String get reportProblemsOrSuggestions => 'Reportar problemas o sugerencias';

  @override
  String get sourceCode => 'Código fuente';

  @override
  String get viewOnGitHub => 'Ver en GitHub';

  @override
  String get about => 'Acerca de';

  @override
  String get dataUpdated => 'Datos actualizados';

  @override
  String errorUpdating(String error) {
    return 'Error al actualizar: $error';
  }

  @override
  String get importantInformation => 'Información importante';

  @override
  String get currentStatusOnly => 'Solo se muestra el estado actual de Pépito';

  @override
  String get percentOfTotal => '% del total';

  @override
  String get temporalAnalysis => 'Análisis temporal';

  @override
  String get leastActiveHour => 'Hora menos activa';

  @override
  String get averageConfidence => 'Confianza promedio';

  @override
  String get hourlyDistribution => 'Distribución por horas';

  @override
  String get weeklyPattern => 'Patrón semanal';

  @override
  String get behaviorInsights => 'Insights de comportamiento';

  @override
  String get detectedPatterns => 'Patrones detectados';

  @override
  String get recommendations => 'Recomendaciones';

  @override
  String get errorLoadingStatistics => 'Error al cargar estadísticas';

  @override
  String get customPeriod => 'período personalizado';

  @override
  String get notEnoughDataInsights =>
      'No hay suficientes datos para generar insights.';

  @override
  String get pepitoHomeTendency =>
      'Pépito tiende a pasar más tiempo en casa que fuera.';

  @override
  String get pepitoAdventurous =>
      'Pépito es muy aventurero y le gusta explorar fuera de casa.';

  @override
  String get pepitoMorningActive => 'Pépito es más activo en las mañanas.';

  @override
  String get pepitoEveningActive =>
      'Pépito prefiere las actividades vespertinas.';

  @override
  String get notEnoughDataPatterns =>
      'No hay suficientes datos para detectar patrones.';

  @override
  String get mondaysActive => 'Los lunes son los días más activos para Pépito.';

  @override
  String get tuesdaysActive =>
      'Los martes son los días más activos para Pépito.';

  @override
  String get wednesdaysActive =>
      'Los miércoles son los días más activos para Pépito.';

  @override
  String get thursdaysActive =>
      'Los jueves son los días más activos para Pépito.';

  @override
  String get fridaysActive =>
      'Los viernes son los días más activos para Pépito.';

  @override
  String get saturdaysActive =>
      'Los sábados son los días más activos para Pépito.';

  @override
  String get sundaysActive =>
      'Los domingos son los días más activos para Pépito.';

  @override
  String get regularActivityPattern =>
      'Pépito tiene un patrón de actividad muy regular.';

  @override
  String get lowActivityPeriods => 'Pépito tiene períodos de baja actividad.';

  @override
  String get adjustSensorConfiguration =>
      'Considera ajustar la configuración del sensor para mejorar la precisión.';

  @override
  String get reviewOutdoorSafety =>
      'Pépito sale mucho de casa. Considera revisar su seguridad exterior.';

  @override
  String get errorClearingCache => 'Error al limpiar caché';

  @override
  String get openingGitHub => 'Abriendo GitHub...';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get errorRequestingPermissions => 'Error al solicitar permisos';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get lastWeek => 'Semana pasada';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get last30Days => 'Últimos 30 días';

  @override
  String get analysis => 'Análisis';

  @override
  String get refreshData => 'Actualizar datos';

  @override
  String get synchronizeWithServer => 'Sincronizar con el servidor';

  @override
  String get termsOfUse => 'Condiciones de uso';

  @override
  String get reportIssuesOrSuggestions => 'Reportar problemas o sugerencias';

  @override
  String get appDesignDescription =>
      'Esta aplicación utiliza el sistema de diseño nativo de cada plataforma:\n\n• Android/Web: Material 3 Expressive\n• iOS/macOS: Liquid Glass Design\n• Windows: Fluent Design\n\nEsto garantiza una experiencia familiar y consistente en cada dispositivo.';

  @override
  String get versionInformation => 'Información de la versión';

  @override
  String get release => 'Release';

  @override
  String get applicationToMonitorPepito =>
      'Aplicación para monitorear las actividades del gato Pépito.';

  @override
  String get privacyPolicyTitle => 'POLÍTICA DE PRIVACIDAD';

  @override
  String get informationWeCollect => '1. INFORMACIÓN QUE RECOPILAMOS';

  @override
  String get informationWeCollectDescription =>
      'Esta aplicación recopila únicamente los datos de actividad de Pépito proporcionados por la API oficial.';

  @override
  String get useOfInformation => '2. USO DE LA INFORMACIÓN';

  @override
  String get useOfInformationDescription =>
      'Los datos se utilizan exclusivamente para mostrar el estado y actividades de Pépito.';

  @override
  String get storage => '3. ALMACENAMIENTO';

  @override
  String get storageDescription =>
      'Los datos del estado de Pépito se obtienen de la API y se almacenan temporalmente en caché local para mejorar el rendimiento.';

  @override
  String get notificationsSection => '4. NOTIFICACIONES';

  @override
  String get notificationsSectionDescription =>
      'Las notificaciones push requieren un token de dispositivo que se maneja de forma segura.';

  @override
  String get thirdParties => '5. TERCEROS';

  @override
  String get thirdPartiesDescription =>
      'No compartimos información personal con terceros.';

  @override
  String get lastUpdated => 'Última actualización: Octubre 2025';

  @override
  String get termsOfServiceTitle => 'TÉRMINOS DE SERVICIO';

  @override
  String get acceptance => '1. ACEPTACIÓN';

  @override
  String get acceptanceDescription =>
      'Al usar esta aplicación, aceptas estos términos.';

  @override
  String get permittedUse => '2. USO PERMITIDO';

  @override
  String get permittedUseDescription =>
      'Esta aplicación es para uso personal y monitoreo de Pépito.';

  @override
  String get availability => '3. DISPONIBILIDAD';

  @override
  String get availabilityDescription =>
      'El servicio depende de la API de Pépito y puede no estar disponible en todo momento.';

  @override
  String get responsibility => '4. RESPONSABILIDAD';

  @override
  String get responsibilityDescription =>
      'No nos hacemos responsables por decisiones tomadas basadas en los datos mostrados.';

  @override
  String get modifications => '5. MODIFICACIONES';

  @override
  String get modificationsDescription =>
      'Nos reservamos el derecho de modificar estos términos.';
}
