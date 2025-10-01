import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/pepito_providers.dart';
import '../widgets/status_card.dart';
import '../widgets/activity_card.dart';
import '../widgets/statistics_widgets.dart';
import '../widgets/animated_svg_widget.dart';
import '../utils/theme_utils.dart';
import '../utils/supabase_cleanup.dart';
import '../services/authorization_service.dart';
import '../generated/app_localizations.dart';
import 'activities_screen.dart';
import 'advanced_statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late RefreshController _refreshController;
  
  // Agregar debouncing
  Timer? _refreshDebounceTimer;
  bool _isRefreshing = false;


  // Método temporal para manejar el error de inserción
  void _handleDatabaseError() {
    // Verificar si el error persiste y mostrar información útil
    if (kDebugMode) print('DEBUG: Verificando estructura de datos...');
    
    // Agregar validación adicional en el próximo refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Forzar un refresh limpio después de que se resuelva el error de UI
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _refreshController.refreshAll();
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _handleDatabaseError(); // Agregar esta línea
  }
  
  // Método de refresh con debouncing
  Future<void> _debouncedRefresh() async {
    if (_isRefreshing) return;
    
    _refreshDebounceTimer?.cancel();
    _refreshDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (_isRefreshing) return;
      
      _isRefreshing = true;
      try {
        await _refreshController.refreshAll();
      } finally {
        _isRefreshing = false;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshController = ref.read(refreshProvider);
    
    // Initialize data loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshController.refreshAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshDebounceTimer?.cancel(); // Limpiar timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usar el tema apropiado según la plataforma
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      return _buildFluentUI(context);
    } else if (kIsWeb) {
      return _buildWebUI(context);
    } else {
      return _buildMaterialUI(context);
    }
  }
  
  Widget _buildWebUI(BuildContext context) {
    final colors = AppTheme.getColors(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Breakpoints más seguros y lógicos
    final isLargeScreen = screenWidth >= 1200;
    final isMediumScreen = screenWidth >= 768 && screenWidth < 1200;
    final isSmallScreen = screenWidth < 768;
    
    return Scaffold(
      body: Row(
        children: [
          // Navegación lateral para web
          _buildWebSidebar(colors, isLargeScreen, isMediumScreen, isSmallScreen),
          // Contenido principal
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWebHomeTab(isLargeScreen, isMediumScreen),
                const ActivitiesScreen(),
                const AdvancedStatisticsScreen(),
                const SettingsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMaterialUI(BuildContext context) {
    final colors = AppTheme.getColors(context);
    
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          const ActivitiesScreen(),
          const AdvancedStatisticsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(colors),
    );
  }
  
  Widget _buildWebSidebar(AppColors colors, bool isLargeScreen, bool isMediumScreen, bool isSmallScreen) {
    // Asegurar que minWidth <= maxWidth
    double sidebarWidth;
    double minSidebarWidth;
    bool showLabels;
    double fontSize;
    double iconSize;
    double headerPadding;
    
    if (isSmallScreen) {
      sidebarWidth = 64.0;
      minSidebarWidth = 64.0; // Mismo valor que sidebarWidth
      showLabels = false;
      fontSize = 12.0;
      iconSize = 18.0;
      headerPadding = 8.0;
    } else if (isMediumScreen && !isLargeScreen) {
      sidebarWidth = 180.0;
      minSidebarWidth = 64.0; // Menor que sidebarWidth
      showLabels = true;
      fontSize = 13.0;
      iconSize = 18.0;
      headerPadding = 12.0;
    } else {
      sidebarWidth = 260.0;
      minSidebarWidth = 64.0; // Menor que sidebarWidth
      showLabels = true;
      fontSize = 14.0;
      iconSize = 20.0;
      headerPadding = 16.0;
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: sidebarWidth,
      constraints: BoxConstraints(
        minWidth: minSidebarWidth, // CORREGIDO
        maxWidth: sidebarWidth,    // CORREGIDO
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark 
              ? [
                  AppTheme.expressivePurple.withValues(alpha: 0.08), // M3E: Gradiente expresivo
                  AppTheme.expressiveTeal.withValues(alpha: 0.05),
                  colors.surface,
                ]
              : [
                  AppTheme.primaryOrange.withValues(alpha: 0.06), // M3E: Gradiente expresivo
                  AppTheme.expressiveTeal.withValues(alpha: 0.04),
                  const Color(0xFFFAFAFA),
                ],
        ),
        border: Border(
          right: BorderSide(
            color: isDark 
                ? AppTheme.expressiveTeal.withValues(alpha: 0.3) // M3E: Borde colorido
                : AppTheme.primaryOrange.withValues(alpha: 0.2),
            width: 2, // M3E: Borde más prominente
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? AppTheme.expressivePurple.withValues(alpha: 0.2) // M3E: Sombra colorida
                : AppTheme.primaryOrange.withValues(alpha: 0.15),
            blurRadius: 16, // M3E: Sombra más expresiva
            offset: const Offset(3, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header de la sidebar
          Container(
            padding: EdgeInsets.all(headerPadding),
            child: Row(
              mainAxisAlignment: isSmallScreen ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 14), // M3E: Padding más expresivo
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryOrange.withValues(alpha: 0.2), // M3E: Gradiente expresivo
                        AppTheme.expressiveTeal.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20), // M3E: Bordes más expresivos
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryOrange.withValues(alpha: 0.3), // M3E: Sombra colorida
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.pets,
                    color: AppTheme.primaryOrange,
                    size: iconSize * 1.1, // M3E: Icono más prominente
                  ),
                ),
                if (showLabels) ...[
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pépito App',
                          style: TextStyle(
                            fontSize: fontSize + 2,
                            fontWeight: FontWeight.w700,
                            color: isDark ? colors.onSurface : const Color(0xFF1F2937),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        if (isLargeScreen)
                          Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: fontSize - 2,
                              color: isDark 
                                  ? colors.onSurface.withValues(alpha: 0.6)
                                  : const Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Navegación
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 6 : 10,
                vertical: 8,
              ),
              children: [
                _buildWebNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: AppLocalizations.of(context)!.home,
                  index: 0,
                  showLabels: showLabels,
                  isSmallScreen: isSmallScreen,
                  fontSize: fontSize,
                  iconSize: iconSize,
                ),
                _buildWebNavItem(
                  icon: Icons.list_outlined,
                  selectedIcon: Icons.list,
                  label: AppLocalizations.of(context)!.activitiesTab,
                  index: 1,
                  showLabels: showLabels,
                  isSmallScreen: isSmallScreen,
                  fontSize: fontSize,
                  iconSize: iconSize,
                ),
                _buildWebNavItem(
                  icon: Icons.analytics_outlined,
                  selectedIcon: Icons.analytics,
                  label: AppLocalizations.of(context)!.statistics,
                  index: 2,
                  showLabels: showLabels,
                  isSmallScreen: isSmallScreen,
                  fontSize: fontSize,
                  iconSize: iconSize,
                ),
                _buildWebNavItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: AppLocalizations.of(context)!.settings,
                  index: 3,
                  showLabels: showLabels,
                  isSmallScreen: isSmallScreen,
                  fontSize: fontSize,
                  iconSize: iconSize,
                ),
              ],
            ),
          ),
          // Footer con refresh
          Container(
            padding: EdgeInsets.all(headerPadding * 0.75),
            child: Consumer(
              builder: (context, ref, child) {
                final isLoading = ref.watch(loadingProvider);
                
                if (isSmallScreen) {
                  // Solo icono para pantallas pequeñas
                  return Center(
                    child: IconButton(
                      onPressed: isLoading
                          ? null
                          : () => _refreshController.refreshAll(),
                      icon: isLoading
                          ? SizedBox(
                              width: iconSize - 2,
                              height: iconSize - 2,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.refresh, size: iconSize - 2),
                      tooltip: 'Actualizar',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                        foregroundColor: const Color(0xFFFF6B35),
                        minimumSize: Size(iconSize + 16, iconSize + 16),
                        padding: EdgeInsets.all(8),
                      ),
                    ),
                  );
                }
                
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _refreshController.refreshAll(),
                    icon: isLoading
                        ? SizedBox(
                            width: iconSize - 4,
                            height: iconSize - 4,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.refresh, size: iconSize - 4),
                    label: showLabels
                        ? Text(
                            'Actualizar',
                            style: TextStyle(fontSize: fontSize),
                            overflow: TextOverflow.ellipsis,
                          )
                        : const SizedBox.shrink(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: showLabels ? 12 : 8,
                        vertical: 10,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWebNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required bool showLabels,
    required bool isSmallScreen,
    required double fontSize,
    required double iconSize,
  }) {
    final isSelected = _tabController.index == index;
    
    if (isSmallScreen) {
      // Para pantallas pequeñas, mostrar solo iconos centrados
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4), // M3E: Espaciado más expresivo
        child: Tooltip(
          message: label,
          child: InkWell(
            onTap: () {
              setState(() {
                _tabController.animateTo(index);
              });
            },
            borderRadius: BorderRadius.circular(18), // M3E: Bordes más expresivos
            child: Container(
              height: iconSize + 32, // M3E: Altura más expresiva
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryOrange.withValues(alpha: 0.2), // M3E: Gradiente expresivo
                          AppTheme.expressiveTeal.withValues(alpha: 0.15),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(18), // M3E: Bordes más expresivos
                border: isSelected 
                    ? Border.all(
                        color: AppTheme.primaryOrange.withValues(alpha: 0.3), // M3E: Borde colorido
                        width: 2,
                      )
                    : null,
                boxShadow: isSelected 
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.2), // M3E: Sombra colorida
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected
                      ? AppTheme.primaryOrange
                      : (Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.getColors(context).onSurface.withValues(alpha: 0.6)
                          : const Color(0xFF6B7280)),
                  size: iconSize * 1.1, // M3E: Icono más prominente
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3), // M3E: Espaciado más expresivo
      decoration: BoxDecoration(
        gradient: isSelected 
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryOrange.withValues(alpha: 0.15), // M3E: Gradiente expresivo
                  AppTheme.expressiveTeal.withValues(alpha: 0.1),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(20), // M3E: Bordes más expresivos
        border: isSelected 
            ? Border.all(
                color: AppTheme.primaryOrange.withValues(alpha: 0.3), // M3E: Borde colorido
                width: 2,
              )
            : null,
        boxShadow: isSelected 
            ? [
                BoxShadow(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.2), // M3E: Sombra colorida
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: EdgeInsets.all(8), // M3E: Padding para el icono
          decoration: BoxDecoration(
            gradient: isSelected 
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryOrange.withValues(alpha: 0.2),
                      AppTheme.expressivePurple.withValues(alpha: 0.15),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(12), // M3E: Bordes expresivos para icono
          ),
          child: Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected
                ? AppTheme.primaryOrange
                : (Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.getColors(context).onSurface.withValues(alpha: 0.6)
                    : const Color(0xFF6B7280)),
            size: iconSize * 1.1, // M3E: Icono más prominente
          ),
        ),
        title: showLabels
            ? Text(
                label,
                style: TextStyle(
                  fontSize: fontSize * 1.05, // M3E: Texto ligeramente más grande
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, // M3E: Peso más expresivo
                  color: isSelected
                      ? AppTheme.primaryOrange
                      : (Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.getColors(context).onSurface
                          : const Color(0xFF374151)),
                  letterSpacing: 0.5, // M3E: Espaciado de letras expresivo
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            : null,
        selected: false, // Manejamos la selección con decoración personalizada
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // M3E: Bordes consistentes
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: showLabels ? 16 : 12, // M3E: Padding más generoso
          vertical: 6, // M3E: Padding vertical más expresivo
        ),
        minLeadingWidth: iconSize + 16, // M3E: Espacio más generoso
        onTap: () {
          setState(() {
            _tabController.animateTo(index);
          });
        },
      ),
    );
  }
  
  Widget _buildFluentUI(BuildContext context) {
    return fluent.NavigationView(
      pane: fluent.NavigationPane(
        selected: _tabController.index,
        onChanged: (index) {
          setState(() {
            _tabController.animateTo(index);
          });
        },
        displayMode: fluent.PaneDisplayMode.top,
        items: [
          fluent.PaneItem(
            icon: const Icon(fluent.FluentIcons.home),
            title: Text(AppLocalizations.of(context)!.home),
            body: _buildHomeTab(),
          ),
          fluent.PaneItem(
            icon: const Icon(fluent.FluentIcons.timeline),
            title: Text(AppLocalizations.of(context)!.activitiesTab),
            body: const ActivitiesScreen(),
          ),
          fluent.PaneItem(
            icon: const Icon(fluent.FluentIcons.chart),
            title: Text(AppLocalizations.of(context)!.statistics),
            body: const AdvancedStatisticsScreen(),
          ),
          fluent.PaneItem(
            icon: const Icon(fluent.FluentIcons.settings),
            title: Text(AppLocalizations.of(context)!.settings),
            body: const SettingsScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildWebHomeTab(bool isLargeScreen, bool isMediumScreen) {
    return RefreshIndicator(
      onRefresh: _debouncedRefresh, // Usar método con debouncing
      child: CustomScrollView(
        slivers: [
          _buildWebAppBar(),
          SliverToBoxAdapter(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                child: isLargeScreen
                    ? _buildLargeScreenLayout()
                    : isMediumScreen
                        ? _buildMediumScreenLayout()
                        : _buildSmallScreenLayout(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _refreshController.refreshAll();
      },
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStatusSection(),
                const SizedBox(height: 16),
                _buildQuickStats(),
                const SizedBox(height: 16),
                _buildRecentActivities(),
                const SizedBox(height: 16),
                _buildQuickActions(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWebAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.05),
                AppTheme.primaryColor.withValues(alpha: 0.02),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Row(
            children: [
              // Icono de la aplicación
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.pets,
                  size: 32,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 20),
              // Información del dashboard - CORREGIDO
              Expanded( // Cambio de Flexible a Expanded
                child: LayoutBuilder( // Agregar LayoutBuilder para manejar constraints
                  builder: (context, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Título con overflow controlado
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight * 0.6, // Máximo 60% del espacio
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Dashboard de Pépito',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.getColors(context).onSurface,
                                letterSpacing: -0.8,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Subtítulo con overflow controlado
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight * 0.3, // Máximo 30% del espacio
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.appDescription,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.getColors(context).onSurface.withValues(alpha: 0.7),
                              height: 1.3,
                            ),
                            overflow: TextOverflow.ellipsis, // Agregar ellipsis
                            maxLines: 2, // Limitar líneas
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 16), // Reducir espacio
              // Botón de actualización
              Consumer(
                builder: (context, ref, child) {
                  final isLoading = ref.watch(loadingProvider);
                  return Container(
                    width: 48, // Ancho mínimo fijo para evitar overflow
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: isLoading
                          ? null
                          : () => _refreshController.refreshAll(),
                      icon: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.refresh_rounded,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                      tooltip: 'Actualizar datos',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLargeScreenLayout() {
    return Column(
      children: [
        // Sección de estado principal - ancho completo
        _buildStatusSection(),
        const SizedBox(height: 32),
        
        // Estadísticas rápidas - ancho completo
        _buildQuickStats(),
        const SizedBox(height: 32),
        
        // Layout de dos columnas para el resto del contenido
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna principal (2/3) - Actividades recientes
            Expanded(
              flex: 2,
              child: _buildRecentActivities(),
            ),
            const SizedBox(width: 32),
            // Columna lateral (1/3) - Acciones e insights
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildWebInsights(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildMediumScreenLayout() {
    return Column(
      children: [
        // Sección de estado - ancho completo
        _buildStatusSection(),
        const SizedBox(height: 24),
        
        // Estadísticas rápidas
        _buildQuickStats(),
        const SizedBox(height: 24),
        
        // Layout de dos columnas para actividades y acciones
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildRecentActivities(),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: _buildQuickActions(),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSmallScreenLayout() {
    return Column(
      children: [
        _buildStatusSection(),
        const SizedBox(height: 16),
        _buildQuickStats(),
        const SizedBox(height: 16),
        _buildRecentActivities(),
        const SizedBox(height: 16),
        _buildQuickActions(),
      ],
    );
  }
  
  Widget _buildWebInsights() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getColors(context).onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final statusAsync = ref.watch(pepitoStatusProvider);
                final todayActivitiesAsync = ref.watch(todayActivitiesProvider);
                
                return Column(
                  children: [
                    _buildInsightItem(
                      icon: Icons.schedule,
                      title: AppLocalizations.of(context)!.lastActivity,
                      value: statusAsync.when(
                        data: (status) => _formatLastActivity(status.lastSeen),
                        loading: () => AppLocalizations.of(context)!.loading,
                        error: (error, stackTrace) => AppLocalizations.of(context)!.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInsightItem(
                      icon: Icons.today,
                      title: AppLocalizations.of(context)!.activitiesToday,
                      value: todayActivitiesAsync.when(
                        data: (activities) => '${activities.length}',
                        loading: () => '...',
                        error: (error, stackTrace) => '0',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInsightItem(
                      icon: Icons.trending_up,
                      title: AppLocalizations.of(context)!.status,
                      value: statusAsync.when(
                        data: (status) => status.isHome ? AppLocalizations.of(context)!.atHome : AppLocalizations.of(context)!.awayFromHome,
                        loading: () => '...',
                        error: (error, stackTrace) => AppLocalizations.of(context)!.error,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getColors(context).onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getColors(context).onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _formatLastActivity(DateTime? lastActivity) {
    if (lastActivity == null) return AppLocalizations.of(context)!.noActivity;
    final now = DateTime.now();
    final difference = now.difference(lastActivity);
    
    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context)!.justNow;
    } else if (difference.inHours < 1) {
      return AppLocalizations.of(context)!.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return AppLocalizations.of(context)!.hoursAgo(difference.inHours);
    } else {
      return AppLocalizations.of(context)!.daysAgo(difference.inDays);
    }
  }
  
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Pépito App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.pets,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
      ),
      actions: [
        Consumer(
          builder: (context, ref, child) {
            final isLoading = ref.watch(loadingProvider);
            return IconButton(
              onPressed: isLoading
                  ? null
                  : () => _refreshController.refreshAll(),
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Consumer(
      builder: (context, ref, child) {
        final statusAsync = ref.watch(pepitoStatusProvider);
        final error = ref.watch(errorProvider);
        
        if (error != null) {
          return _buildErrorCard(error);
        }
        
        return statusAsync.when(
          data: (status) => StatusCard(
            status: status,
            onRefresh: () => _refreshController.refreshStatus(),
            isLoading: ref.watch(loadingProvider),
          ),
          loading: () => _buildLoadingStatusCard(),
          error: (error, stack) => _buildErrorCard(error.toString()),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Consumer(
      builder: (context, ref, child) {
        final todayActivitiesAsync = ref.watch(todayActivitiesProvider);
        final statusAsync = ref.watch(pepitoStatusProvider);
        
        return todayActivitiesAsync.when(
          data: (activities) => QuickStatsRow(
            todayActivities: activities,
            status: statusAsync.valueOrNull,
          ),
          loading: () => _buildLoadingStatsRow(),
          error: (error, stack) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildRecentActivities() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Consumer(
          builder: (context, ref, child) {
            final activitiesAsync = ref.watch(activitiesProvider(
              const ActivitiesParams(limit: 5, offset: 0),
            ));
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!.recentActivities,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getColors(context).onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Mostrar animación si hay actividades muy recientes
                    activitiesAsync.when(
                      data: (activities) {
                        if (activities.isNotEmpty) {
                          final now = DateTime.now();
                          final hasRecentActivity = activities.any((activity) {
                            final difference = now.difference(activity.dateTime);
                            return difference.inMinutes < 10;
                          });
                          
                          if (hasRecentActivity) {
                            return HeartBeatWidget(
                              size: 20,
                              color: AppTheme.primaryColor,
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _tabController.animateTo(1),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: Text(AppLocalizations.of(context)!.viewAll),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                activitiesAsync.when(
                  data: (activities) {
                    if (activities.isEmpty) {
                      return _buildEmptyActivities();
                    }
                    return Column(
                      children: activities
                          .map((activity) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ActivityCard(
                                  activity: activity,
                                  compact: true,
                                  showDate: false,
                                  onTap: () => _showActivityDetails(activity),
                                ),
                              ))
                          .toList(),
                    );
                  },
                  loading: () => _buildLoadingActivities(),
                  error: (error, stack) => _buildErrorActivities(error.toString()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Acciones rápidas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getColors(context).onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                _buildActionCard(
                  icon: Icons.timeline,
                  title: AppLocalizations.of(context)!.statistics,
                  subtitle: AppLocalizations.of(context)!.viewDetailedAnalysis,
                  color: AppTheme.primaryColor,
                  onTap: () => _navigateToStatistics(),
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  icon: Icons.notifications,
                  title: AppLocalizations.of(context)!.notifications,
                  subtitle: AppLocalizations.of(context)!.configureAlerts,
                  color: AppTheme.warningColor,
                  onTap: () => _navigateToNotifications(),
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  icon: Icons.refresh,
                  title: 'Actualizar datos',
                  subtitle: 'Sincronizar información',
                  color: AppTheme.successColor,
                  onTap: () => _refreshController.refreshAll(),
                ),
                const SizedBox(height: 12),
                // Función de limpieza removida por seguridad
                // Solo disponible en modo debug
                if (kDebugMode)
                  _buildActionCard(
                    icon: Icons.delete_sweep,
                    title: '🧹 [DEBUG] Limpiar Duplicados',
                    subtitle: 'Solo disponible en desarrollo',
                    color: Colors.orange.withValues(alpha: 0.5),
                    onTap: _clearSupabaseData,
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.05),
            color.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getColors(context).onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.getColors(context).onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withValues(alpha: 0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: colors.onSurface.withValues(alpha: 0.6),
        indicatorColor: AppTheme.primaryColor,
        tabs: [
          Tab(
            icon: const Icon(Icons.home),
            text: AppLocalizations.of(context)!.home,
          ),
          Tab(
            icon: const Icon(Icons.list),
            text: AppLocalizations.of(context)!.activitiesTab,
          ),
          Tab(
            icon: const Icon(Icons.analytics),
            text: AppLocalizations.of(context)!.statistics,
          ),
          Tab(
            icon: const Icon(Icons.settings),
            text: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }

  // Loading widgets
  Widget _buildLoadingStatusCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildLoadingStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: Card(
              child: Container(
                height: 100,
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingActivities() {
    return Column(
      children: List.generate(
        3,
        (index) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  // Error widgets
  Widget _buildErrorCard(String error) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.getColors(context).onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _refreshController.refreshAll(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorActivities(String error) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 8),
            Text(
              'Error al cargar actividades',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getColors(context).onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyActivities() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/cat_sleeping.svg',
                  width: 48,
                  height: 48,
                  colorFilter: ColorFilter.mode(
                    AppTheme.primaryColor.withValues(alpha: 0.7),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay actividades recientes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.getColors(context).onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.pepitoActivitiesWillAppearHere,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.getColors(context).onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetails(dynamic activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppTheme.getColors(context).surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.getColors(context).onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.activityDetails,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getColors(context).onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ActivityCard(
                  activity: activity,
                  showDate: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _clearSupabaseData() async {
    // Solicitar autorización para operación destructiva
    final authorized = await AuthorizationService().requestAuthorization(
      context,
      operation: 'Limpiar Duplicados',
      description: 'Esta operación eliminará las actividades duplicadas de Supabase. '
                  'Se preservará la actividad más reciente de la API.',
    );

    if (!authorized) return;

    // Mostrar diálogo de progreso
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Limpiando Supabase...'),
          ],
        ),
      ),
    );
    }

    try {
      // Ejecutar limpieza
      final success = await SupabaseCleanup.clearAllActivities();
      
      // Cerrar diálogo de progreso
      if (mounted) Navigator.of(context).pop();
      
      // Mostrar resultado
       if (mounted) {
         showDialog(
           context: context,
           builder: (context) => AlertDialog(
             title: Text(success ? 'Éxito' : 'Error'),
             content: Text(
               success 
                 ? 'Supabase limpiado exitosamente. Las actividades duplicadas han sido eliminadas.'
                : 'Error durante la limpieza de Supabase.',
             ),
             actions: [
               TextButton(
                 onPressed: () => Navigator.of(context).pop(),
                 child: const Text('OK'),
               ),
             ],
           ),
         );
        
        // Refrescar datos si fue exitoso
        if (success) {
          _refreshController.refreshAll();
        }
      }
    } catch (e) {
      // Cerrar diálogo de progreso
      if (mounted) Navigator.of(context).pop();
      
      // Mostrar error
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Error durante la limpieza: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _navigateToStatistics() {
    _tabController.animateTo(2);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Estadísticas'),
        content: const Text('Navegando a la pestaña de estadísticas donde puedes ver análisis detallados de la actividad de Pépito.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToNotifications() {
    _tabController.animateTo(3);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔔 Configuración'),
        content: const Text('Navegando a la configuración donde puedes ajustar las notificaciones y otros ajustes de la aplicación.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}