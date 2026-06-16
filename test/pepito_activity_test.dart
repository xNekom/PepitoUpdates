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
  });
}
