import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pepito_updates/generated/app_localizations.dart';
import 'package:pepito_updates/models/pepito_activity.dart';
import 'package:pepito_updates/providers/pepito_providers.dart';
import 'package:pepito_updates/widgets/home/home_status_section.dart';
import 'package:pepito_updates/providers/platform_style_provider.dart';
import 'package:pepito_updates/services/pepito_api_service.dart';
import 'package:pepito_updates/services/supabase_service.dart';
import 'package:pepito_updates/services/sse_service.dart';

// ---------------------------------------------------------------------------
// Mock services
// ---------------------------------------------------------------------------

class MockApiService implements PepitoApiService {
  bool shouldThrow = false;
  bool shouldHang = false;
  PepitoStatus? statusResponse;

  @override
  Future<PepitoStatus> getCurrentStatus() async {
    if (shouldHang) {
      await Completer<PepitoStatus>().future;
    }
    if (shouldThrow) throw Exception('Network error');
    return statusResponse!;
  }

  @override
  Future<List<PepitoActivity>> getTodayActivities() async => [];

  @override
  Future<List<PepitoActivity>> getActivities({
    int limit = 50,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  }) async => [];

  @override
  Future<Map<String, dynamic>> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async => {};

  @override
  void initialize() {}
}

class MockSupabaseService implements SupabaseService {
  @override
  Future<bool> logStatusUpdate(PepitoActivity activity) async => true;

  @override
  Future<List<PepitoActivity>> getStatusHistory({
    int limit = 50,
    DateTime? since,
  }) async => [];

  @override
  Future<List<PepitoActivity>> getTodayActivities() async => [];

  @override
  Future<Map<String, dynamic>> getActivityStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async => {};

  @override
  Future<bool> cleanupOldActivities({int daysToKeep = 30}) async => true;

  @override
  Future<bool> clearAllActivities() async => true;

  @override
  Future<int> getTotalActivitiesCount() async => 0;

  @override
  Stream<List<PepitoActivity>> watchRecentActivities({int limit = 10}) {
    return Stream.value(<PepitoActivity>[]);
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  String get configurationStatus => 'mock';

  @override
  SupabaseClient get client => throw UnimplementedError('Not needed');
}

class MockSSEService implements SSEService {
  @override
  Stream<PepitoActivity> get activityStream => const Stream.empty();

  @override
  Stream<Map<String, dynamic>> get heartbeatStream => const Stream.empty();

  @override
  bool get isConnected => false;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  void dispose() {}
}

class FixedStyleNotifier extends PlatformStyleNotifier {
  @override
  WidgetStyle build() => WidgetStyle.materialExpressive;
}

// ---------------------------------------------------------------------------

void main() {
  group('HomeStatusSection', () {
    testWidgets('shows loading state with CircularProgressIndicator', (
      tester,
    ) async {
      final mockApi = MockApiService();
      mockApi.shouldHang = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(mockApi),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            sseServiceProvider.overrideWithValue(MockSSEService()),
            platformStyleProvider.overrideWith(() => FixedStyleNotifier()),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeStatusSection(),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state with error message', (tester) async {
      final mockApi = MockApiService();
      mockApi.statusResponse = PepitoStatus(
        event: 'pepito',
        type: 'in',
        timestamp: DateTime.now(),
      );
      mockApi.shouldThrow = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(mockApi),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            sseServiceProvider.overrideWithValue(MockSSEService()),
            platformStyleProvider.overrideWith(() => FixedStyleNotifier()),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeStatusSection(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.text('Error al cargar datos'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders status data without error', (tester) async {
      final mockApi = MockApiService();
      mockApi.statusResponse = PepitoStatus(
        event: 'pepito',
        type: 'in',
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(mockApi),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            sseServiceProvider.overrideWithValue(MockSSEService()),
            platformStyleProvider.overrideWith(() => FixedStyleNotifier()),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeStatusSection(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });
  });
}
