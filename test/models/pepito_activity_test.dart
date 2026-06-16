import 'package:flutter_test/flutter_test.dart';
import 'package:pepito_updates/models/pepito_activity.dart';

void main() {
  group('PepitoActivity', () {
    test('fromJson parses basic fields correctly', () {
      final json = {
        'event': 'pepito',
        'type': 'in',
        'time': 1700000000,
        'img': 'https://example.com/photo.jpg',
      };

      final activity = PepitoActivity.fromJson(json);

      expect(activity.event, 'pepito');
      expect(activity.type, 'in');
      expect(activity.timestamp, DateTime.fromMillisecondsSinceEpoch(1700000000 * 1000));
      expect(activity.img, 'https://example.com/photo.jpg');
    });

    test('fromJson handles null img', () {
      final json = {
        'event': 'pepito',
        'type': 'out',
        'time': 1700000000,
      };

      final activity = PepitoActivity.fromJson(json);
      expect(activity.event, 'pepito');
      expect(activity.type, 'out');
      expect(activity.img, isNull);
    });

    test('fromJson handles int timestamp as Unix seconds', () {
      final json = {
        'event': 'pepito',
        'type': 'in',
        'time': 1700000000,
      };

      final activity = PepitoActivity.fromJson(json);
      expect(activity.timestamp, DateTime.fromMillisecondsSinceEpoch(1700000000 * 1000));
    });

    test('fromJson handles ISO 8601 timestamp string', () {
      final isoTime = '2024-01-15T10:30:00.000Z';
      final json = {
        'event': 'pepito',
        'type': 'in',
        'time': isoTime,
      };

      final activity = PepitoActivity.fromJson(json);
      expect(activity.timestamp, DateTime.parse(isoTime));
    });

    test('fromJson handles null metadata', () {
      final json = {
        'event': 'pepito',
        'type': 'in',
        'time': 1700000000,
      };

      final activity = PepitoActivity.fromJson(json);
      expect(activity.metadata, isNull);
    });

    test('fromJson handles empty metadata', () {
      final json = {
        'event': 'pepito',
        'type': 'in',
        'time': 1700000000,
        'metadata': <String, dynamic>{},
      };

      final activity = PepitoActivity.fromJson(json);
      expect(activity.metadata, <String, dynamic>{});
    });

    test('fromJson handles empty event string', () {
      final json = {
        'event': '',
        'type': 'in',
        'time': 1700000000,
      };

      final activity = PepitoActivity.fromJson(json);
      expect(activity.event, '');
      expect(activity.type, 'in');
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'event': 'pepito',
        'type': 'in',
        'time': 1700000000,
      };

      final activity = PepitoActivity.fromJson(json);
      expect(activity.id, isNull);
      expect(activity.imageUrl, isNull);
      expect(activity.location, isNull);
      expect(activity.confidence, isNull);
      expect(activity.source, isNull);
      expect(activity.createdAt, isNull);
      expect(activity.updatedAt, isNull);
    });

    test('fromJson handles confidence as double', () {
      final json = {
        'event': 'pepito',
        'type': 'in',
        'time': 1700000000,
        'confidence': 0.95,
      };

      final activity = PepitoActivity.fromJson(json);
      expect(activity.confidence, 0.95);
    });

    test('preferredImageUrl returns imageUrl when available', () {
      final activity = PepitoActivity(
        event: 'pepito',
        type: 'in',
        timestamp: DateTime.now(),
        img: 'img.jpg',
        imageUrl: 'image_url.jpg',
      );
      expect(activity.preferredImageUrl, 'image_url.jpg');
    });

    test('preferredImageUrl falls back to img when imageUrl is null', () {
      final activity = PepitoActivity(
        event: 'pepito',
        type: 'in',
        timestamp: DateTime.now(),
        img: 'img.jpg',
      );
      expect(activity.preferredImageUrl, 'img.jpg');
    });

    test('isEntry returns true for in type', () {
      final activity = PepitoActivity(
        event: 'pepito',
        type: 'in',
        timestamp: DateTime.now(),
      );
      expect(activity.isEntry, isTrue);
      expect(activity.isExit, isFalse);
    });

    test('isExit returns true for out type', () {
      final activity = PepitoActivity(
        event: 'pepito',
        type: 'out',
        timestamp: DateTime.now(),
      );
      expect(activity.isExit, isTrue);
      expect(activity.isEntry, isFalse);
    });

    test('isReliable returns true when source is api and not cached and confidence > 0.8', () {
      final activity = PepitoActivity(
        event: 'pepito',
        type: 'in',
        timestamp: DateTime.now(),
        source: 'api',
        cached: false,
        confidence: 0.9,
      );
      expect(activity.isReliable, isTrue);
    });

    test('isReliable returns false when cached', () {
      final activity = PepitoActivity(
        event: 'pepito',
        type: 'in',
        timestamp: DateTime.now(),
        source: 'api',
        cached: true,
        confidence: 0.9,
      );
      expect(activity.isReliable, isFalse);
    });

    test('formattedTime returns HH:mm format', () {
      final dt = DateTime(2024, 1, 15, 8, 5);
      final activity = PepitoActivity(
        event: 'pepito',
        type: 'in',
        timestamp: dt,
      );
      expect(activity.formattedTime, '08:05');
    });

    test('formattedDate returns dd/MM/yyyy format', () {
      final dt = DateTime(2024, 1, 15);
      final activity = PepitoActivity(
        event: 'pepito',
        type: 'in',
        timestamp: dt,
      );
      expect(activity.formattedDate, '15/01/2024');
    });

    group('equality', () {
      test('identical objects are equal', () {
        final activity = PepitoActivity(
          event: 'pepito',
          type: 'in',
          timestamp: DateTime.now(),
        );
        expect(activity == activity, isTrue);
        expect(activity.hashCode, activity.hashCode);
      });

      test('same id returns true', () {
        final a1 = PepitoActivity(
          id: '123',
          event: 'pepito',
          type: 'in',
          timestamp: DateTime.now(),
        );
        final a2 = PepitoActivity(
          id: '123',
          event: 'pepito',
          type: 'out',
          timestamp: DateTime.now(),
        );
        expect(a1 == a2, isTrue);
        expect(a1.hashCode, a2.hashCode);
      });

      test('different id returns false', () {
        final a1 = PepitoActivity(
          id: '123',
          event: 'pepito',
          type: 'in',
          timestamp: DateTime.now(),
        );
        final a2 = PepitoActivity(
          id: '456',
          event: 'pepito',
          type: 'in',
          timestamp: DateTime.now(),
        );
        expect(a1 == a2, isFalse);
      });

      test('null id objects are equal because null == null', () {
        final a1 = PepitoActivity(
          id: null,
          event: 'pepito',
          type: 'in',
          timestamp: DateTime.now(),
        );
        final a2 = PepitoActivity(
          id: null,
          event: 'pepito',
          type: 'in',
          timestamp: DateTime.now(),
        );
        expect(a1 == a2, isTrue);
      });

      test('has correct runtime type', () {
        final activity = PepitoActivity(
          event: 'pepito',
          type: 'in',
          timestamp: DateTime.now(),
        );
        expect(activity, isA<PepitoActivity>());
      });
    });

    group('copyWith', () {
      test('keeps original fields when no overrides', () {
        final original = PepitoActivity(
          id: '1',
          event: 'pepito',
          type: 'in',
          timestamp: DateTime(2024, 1, 15),
        );
        final copy = original.copyWith();
        expect(copy.id, '1');
        expect(copy.event, 'pepito');
        expect(copy.type, 'in');
      });

      test('overrides specified fields', () {
        final original = PepitoActivity(
          id: '1',
          event: 'pepito',
          type: 'in',
          timestamp: DateTime(2024, 1, 15),
        );
        final copy = original.copyWith(type: 'out');
        expect(copy.id, '1');
        expect(copy.type, 'out');
      });
    });
  });

  group('PepitoStatus', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'event': 'pepito',
        'type': 'in',
        'time': '2024-01-15T10:30:00.000',
        'img': 'https://example.com/photo.jpg',
        'cached': false,
        'authenticated': true,
      };

      final status = PepitoStatus.fromJson(json);

      expect(status.event, 'pepito');
      expect(status.type, 'in');
      expect(status.timestamp, DateTime.parse('2024-01-15T10:30:00.000'));
      expect(status.img, 'https://example.com/photo.jpg');
      expect(status.cached, isFalse);
      expect(status.authenticated, isTrue);
    });

    test('fromJson defaults cached and authenticated to false', () {
      final json = {
        'event': 'pepito',
        'type': 'in',
        'time': '2024-01-15T10:30:00.000',
      };

      final status = PepitoStatus.fromJson(json);
      expect(status.cached, isFalse);
      expect(status.authenticated, isFalse);
      expect(status.img, isNull);
    });

    test('isHome returns true for in type', () {
      final status = PepitoStatus(
        event: 'pepito',
        type: 'in',
        timestamp: DateTime.now(),
      );
      expect(status.isHome, isTrue);
      expect(status.status, 'en_casa');
    });

    test('isHome returns false for out type', () {
      final status = PepitoStatus(
        event: 'pepito',
        type: 'out',
        timestamp: DateTime.now(),
      );
      expect(status.isHome, isFalse);
      expect(status.status, 'fuera');
    });

    test('displayStatusWithoutContext returns correct strings', () {
      final statusIn = PepitoStatus(
        event: 'pepito',
        type: 'in',
        timestamp: DateTime.now(),
      );
      expect(statusIn.displayStatusWithoutContext, '🏠 En casa');

      final statusOut = PepitoStatus(
        event: 'pepito',
        type: 'out',
        timestamp: DateTime.now(),
      );
      expect(statusOut.displayStatusWithoutContext, '🌍 Fuera de casa');
    });

    test('statusEmoji returns correct emoji', () {
      final statusIn = PepitoStatus(
        event: 'pepito',
        type: 'in',
        timestamp: DateTime.now(),
      );
      expect(statusIn.statusEmoji, '🏠');

      final statusOut = PepitoStatus(
        event: 'pepito',
        type: 'out',
        timestamp: DateTime.now(),
      );
      expect(statusOut.statusEmoji, '🌍');
    });

    test('lastActivity creates PepitoActivity with correct fields', () {
      final now = DateTime(2024, 1, 15, 10, 30);
      final status = PepitoStatus(
        event: 'pepito',
        type: 'in',
        timestamp: now,
        img: 'photo.jpg',
        cached: false,
        authenticated: true,
      );

      final activity = status.lastActivity;
      expect(activity, isA<PepitoActivity>());
      expect(activity!.event, 'pepito');
      expect(activity.type, 'in');
      expect(activity.timestamp, now);
      expect(activity.img, 'photo.jpg');
      expect(activity.source, 'api');
      expect(activity.cached, isFalse);
      expect(activity.authenticated, isTrue);
    });

    test('toJson produces correct format', () {
      final now = DateTime(2024, 1, 15, 10, 30);
      final status = PepitoStatus(
        event: 'pepito',
        type: 'in',
        timestamp: now,
        img: 'photo.jpg',
        cached: false,
        authenticated: true,
      );

      final json = status.toJson();
      expect(json['event'], 'pepito');
      expect(json['type'], 'in');
      expect(json['time'], now.toIso8601String());
      expect(json['img'], 'photo.jpg');
      expect(json['cached'], isFalse);
      expect(json['authenticated'], isTrue);
    });
  });
}
