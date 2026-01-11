import 'package:test/test.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

void main() {
  const parser = JsonLayoutParser();

  group('JsonLayoutParser', () {
    group('basic parsing', () {
      test('parses empty string', () {
        final result = parser.parse('');
        expect(result.data, isEmpty);
      });

      test('parses empty object', () {
        final result = parser.parse('{}');
        expect(result.data, isEmpty);
      });

      test('parses simple object', () {
        final result = parser.parse('{"name": "John"}');
        expect(result.data['name'], 'John');
      });

      test('parses nested object', () {
        final result = parser.parse('{"user": {"name": "John"}}');
        expect(result.data['user']['name'], 'John');
      });

      test('parses array', () {
        final result = parser.parse('{"items": [1, 2, 3]}');
        expect(result.data['items'], [1, 2, 3]);
      });
    });

    group('indentation detection', () {
      test('detects 2-space indentation', () {
        const json = '''{
  "name": "John",
  "age": 30
}''';
        final result = parser.parse(json);
        final rootMeta = KeyMetadata.fromJson(
          result.keyMeta!['_root'] as Map<String, dynamic>,
        );
        expect(rootMeta.jsonMeta?.indentSpaces, 2);
      });

      test('detects 4-space indentation', () {
        const json = '''{
    "name": "John",
    "age": 30
}''';
        final result = parser.parse(json);
        final rootMeta = KeyMetadata.fromJson(
          result.keyMeta!['_root'] as Map<String, dynamic>,
        );
        expect(rootMeta.jsonMeta?.indentSpaces, 4);
      });

      test('detects minified JSON', () {
        const json = '{"name":"John","age":30}';
        final result = parser.parse(json);
        final rootMeta = KeyMetadata.fromJson(
          result.keyMeta!['_root'] as Map<String, dynamic>,
        );
        expect(rootMeta.jsonMeta?.indentSpaces, 0);
      });
    });

    group('edge cases', () {
      test('handles non-object JSON', () {
        final result = parser.parse('"just a string"');
        expect(result.data['_value'], 'just a string');
      });

      test('handles whitespace-only string', () {
        final result = parser.parse('   ');
        expect(result.data, isEmpty);
      });

      test('handles deeply nested structures', () {
        const json = '''{
  "level1": {
    "level2": {
      "level3": "value"
    }
  }
}''';
        final result = parser.parse(json);
        expect(result.data['level1']['level2']['level3'], 'value');
      });
    });
  });
}
