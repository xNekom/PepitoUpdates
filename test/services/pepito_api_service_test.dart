import 'package:flutter_test/flutter_test.dart';
import 'package:pepito_updates/models/pepito_activity.dart';
import 'package:pepito_updates/services/pepito_api_service.dart';

/// Manual mock for PepitoApiService to avoid real HTTP calls in tests.
class MockPepitoApiService implements PepitoApiService {
  PepitoStatus? statusResponse;
  List<PepitoActivity> activitiesResponse = [];
  Map<String, dynamic> statisticsResponse = {};
  bool shouldThrowOnStatus = false;
  bool shouldThrowOnActivities = false;

  @override
  Future<PepitoStatus> getCurrentStatus() async {
    if (shouldThrowOnStatus) {
      throw Exception('Network error');
    }
    return statusResponse ?? PepitoStatus(
      event: 'pepito',
      type: 'in',
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<List<PepitoActivity>> getTodayActivities() async {
    if (shouldThrowOnActivities) {
      throw Exception('Network error');
    }
    return activitiesResponse;
  }

  @override
  Future<List<PepitoActivity>> getActivities({
    int limit = 50,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (shouldThrowOnActivities) {
      throw Exception('Network error');
    }
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

void main() {
  group('PepitoApiService', () {
    test('singleton returns same instance', () {
      final instance1 = PepitoApiService();
      final instance2 = PepitoApiService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('initialize does not throw', () {
      final service = PepitoApiService();
      expect(() => service.initialize(), returnsNormally);
    });

    test('multiple initialize calls are safe', () {
      final service = PepitoApiService();
      service.initialize();
      expect(() => service.initialize(), returnsNormally);
    });
  });

  group('PepitoActivity.fromJson (API parsing)', () {
    test('parses int timestamp as Unix seconds', () {
      final json = {
        'event': 'pepito',
        'type': 'in',
        'time': 1700000000,
      };
      final activity = PepitoActivity.fromJson(json);
      expect(activity.timestamp, DateTime.fromMillisecondsSinceEpoch(1700000000 * 1000));
    });

    test('parses ISO 8601 timestamp string', () {
      final isoTime = '2024-01-15T10:30:00.000Z';
      final json = {
        'event': 'pepito',
        'type': 'in',
        'time': isoTime,
      };
      final activity = PepitoActivity.fromJson(json);
      expect(activity.timestamp, DateTime.parse(isoTime));
    });

    test('handles empty string timestamp gracefully', () {
      final json = {
        'event': 'pepito',
        'type': 'in',
        'time': '',
      };
      final activity = PepitoActivity.fromJson(json);
      expect(activity.timestamp, isA<DateTime>());
    });

    test('parses list of activities from API format', () {
      final jsonList = [
        {'event': 'pepito', 'type': 'in', 'time': 1700000000, 'id': '1'},
        {'event': 'pepito', 'type': 'out', 'time': 1700000100, 'id': '2'},
      ];

      final activities = jsonList
          .map((json) => PepitoActivity.fromJson(json as Map<String, dynamic>))
          .toList();

      expect(activities.length, 2);
      expect(activities[0].type, 'in');
      expect(activities[1].type, 'out');
    });
  });

  group('PepitoStatus.fromJson (API parsing)', () {
    test('parses status from API response format', () {
      final json = {
        'event': 'pepito',
        'type': 'in',
        'time': '2024-01-15T10:30:00.000',
        'img': 'https://example.com/photo.jpg',
      };

      final status = PepitoStatus.fromJson(json);
      expect(status.event, 'pepito');
      expect(status.type, 'in');
      expect(status.timestamp, DateTime.parse('2024-01-15T10:30:00.000'));
      expect(status.img, 'https://example.com/photo.jpg');
    });

    test('handles absent optional fields', () {
      final json = {
        'event': 'pepito',
        'type': 'out',
        'time': '2024-01-15T12:00:00.000',
      };

      final status = PepitoStatus.fromJson(json);
      expect(status.event, 'pepito');
      expect(status.type, 'out');
      expect(status.img, isNull);
      expect(status.cached, isFalse);
      expect(status.authenticated, isFalse);
    });
  });

  group('MockPepitoApiService (usable by other tests)', () {
    test('returns configured status', () async {
      final mock = MockPepitoApiService();
      final expectedStatus = PepitoStatus(
        event: 'test',
        type: 'out',
        timestamp: DateTime(2024, 1, 1),
      );
      mock.statusResponse = expectedStatus;

      final status = await mock.getCurrentStatus();
      expect(status.event, 'test');
      expect(status.type, 'out');
    });

    test('throws when configured to error', () async {
      final mock = MockPepitoApiService();
      mock.shouldThrowOnStatus = true;

      expect(
        () async => await mock.getCurrentStatus(),
        throwsException,
      );
    });

    test('returns activities list', () async {
      final mock = MockPepitoApiService();
      mock.activitiesResponse = [
        PepitoActivity(
          event: 'pepito',
          type: 'in',
          timestamp: DateTime.now(),
        ),
      ];

      final activities = await mock.getTodayActivities();
      expect(activities.length, 1);
      expect(activities[0].event, 'pepito');
    });
  });
}
