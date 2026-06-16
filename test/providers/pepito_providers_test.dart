import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pepito_updates/models/pepito_activity.dart';
import 'package:pepito_updates/providers/pepito_providers.dart';
import 'package:pepito_updates/services/pepito_api_service.dart';
import 'package:pepito_updates/services/supabase_service.dart';
import 'package:pepito_updates/services/sse_service.dart';

/// Manual mock for PepitoApiService — no mockito required.
class MockApiService implements PepitoApiService {
  PepitoStatus? statusResponse;
  List<PepitoActivity> activitiesResponse = [];
  Map<String, dynamic> statisticsResponse = {};
  bool shouldThrowOnStatus = false;
  bool shouldThrowOnActivities = false;

  @override
  Future<PepitoStatus> getCurrentStatus() async {
    if (shouldThrowOnStatus) throw Exception('Simulated network error');
    return statusResponse!;
  }

  @override
  Future<List<PepitoActivity>> getTodayActivities() async {
    if (shouldThrowOnActivities) throw Exception('Simulated network error');
    return activitiesResponse;
  }

  @override
  Future<List<PepitoActivity>> getActivities({
    int limit = 50,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (shouldThrowOnActivities) throw Exception('Simulated network error');
    return activitiesResponse;
  }

  @override
  Future<Map<String, dynamic>> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return statisticsResponse;
  }

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
  SupabaseClient get client => throw UnimplementedError('Not needed in mock');
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

void main() {
  group('apiServiceProvider', () {
    test('provides a PepitoApiService instance', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final service = container.read(apiServiceProvider);
      expect(service, isA<PepitoApiService>());
    });
  });

  group('localeProvider', () {
    testWidgets('default state is Locale("es")', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final locale = container.read(localeProvider);
      expect(locale, const Locale('es'));
    });

    testWidgets('setLocale updates the locale', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await container.read(localeProvider.notifier).setLocale(const Locale('en'));
      final locale = container.read(localeProvider);
      expect(locale, const Locale('en'));
    });
  });

  group('todayActivitiesProvider', () {
    test('returns a list of activities when API succeeds', () async {
      final mockService = MockApiService();
      mockService.statusResponse = PepitoStatus(
        event: 'pepito',
        type: 'in',
        timestamp: DateTime.now(),
      );
      mockService.activitiesResponse = [
        PepitoActivity(
          id: '1',
          event: 'pepito',
          type: 'in',
          timestamp: DateTime(2024, 1, 15, 10, 30),
        ),
        PepitoActivity(
          id: '2',
          event: 'pepito',
          type: 'out',
          timestamp: DateTime(2024, 1, 15, 14, 0),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(() => container.dispose());

      final activities = await container.read(todayActivitiesProvider.future);
      expect(activities, isA<List<PepitoActivity>>());
      expect(activities.length, 2);
      expect(activities[0].event, 'pepito');
      expect(activities[0].type, 'in');
      expect(activities[1].type, 'out');
    });

    test('returns empty list when API returns no activities', () async {
      final mockService = MockApiService();
      mockService.statusResponse = PepitoStatus(
        event: 'pepito',
        type: 'in',
        timestamp: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(() => container.dispose());

      final activities = await container.read(todayActivitiesProvider.future);
      expect(activities, isEmpty);
    });
  });

  group('pepitoStatusProvider', () {
    test('builds a PepitoStatus when API succeeds', () async {
      final mockStatus = PepitoStatus(
        event: 'pepito',
        type: 'in',
        timestamp: DateTime(2024, 1, 15, 10, 30),
      );
      final mockApi = MockApiService();
      mockApi.statusResponse = mockStatus;

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApi),
          supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
          sseServiceProvider.overrideWithValue(MockSSEService()),
        ],
      );
      addTearDown(() => container.dispose());

      final status = await container.read(pepitoStatusProvider.future);
      expect(status, isA<PepitoStatus>());
      expect(status.event, 'pepito');
      expect(status.type, 'in');
      expect(status.isHome, isTrue);
    });

    test('handles API error gracefully', () async {
      final mockApi = MockApiService();
      mockApi.shouldThrowOnStatus = true;

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApi),
          supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
          sseServiceProvider.overrideWithValue(MockSSEService()),
        ],
      );
      addTearDown(() => container.dispose());

      try {
        await container.read(pepitoStatusProvider.future);
        fail('Expected an exception to be thrown');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });

  group('connectionStatusProvider', () {
    test('defaults to true', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      expect(container.read(connectionStatusProvider), isTrue);
    });
  });

  group('loadingProvider', () {
    test('defaults to false', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      expect(container.read(loadingProvider), isFalse);
    });
  });

  group('errorProvider', () {
    test('defaults to null', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      expect(container.read(errorProvider), isNull);
    });
  });

  group('validateActivityData', () {
    test('returns safe data with default event for empty event', () {
      final activity = PepitoActivity(
        event: '',
        type: 'in',
        timestamp: DateTime.now(),
      );

      final data = validateActivityData(activity);
      expect(data['event'], 'pepito');
      expect(data['type'], 'in');
      expect(data['metadata'], <String, dynamic>{});
    });

    test('preserves original event when not empty', () {
      final activity = PepitoActivity(
        event: 'pepito',
        type: 'out',
        timestamp: DateTime.now(),
      );

      final data = validateActivityData(activity);
      expect(data['event'], 'pepito');
    });
  });
}
