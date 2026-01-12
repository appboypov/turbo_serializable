import 'package:test/test.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

void main() {
  const generator = JsonLayoutGenerator();

  group('JsonLayoutGenerator', () {
    group('basic generation', () {
      test('generates empty object', () {
        final result = generator.generate({});
        expect(result, '{}');
      });

      test('generates simple object', () {
        final result = generator.generate({'name': 'John'});
        expect(result.contains('"name"'), true);
        expect(result.contains('"John"'), true);
      });

      test('generates null value', () {
        final result = generator.generate({'value': null});
        expect(result.contains('null'), true);
      });

      test('generates boolean values', () {
        final result = generator.generate({'active': true, 'deleted': false});
        expect(result.contains('true'), true);
        expect(result.contains('false'), true);
      });

      test('generates numeric values', () {
        final result = generator.generate({'count': 42, 'price': 19.99});
        expect(result.contains('42'), true);
        expect(result.contains('19.99'), true);
      });

      test('generates arrays', () {
        final result = generator.generate({
          'items': [1, 2, 3]
        });
        expect(result.contains('['), true);
        expect(result.contains(']'), true);
      });
    });

    group('indentation', () {
      test('uses 2-space indentation by default', () {
        final result = generator.generate({'name': 'John'});
        expect(result.contains('  "name"'), true);
      });

      test('uses custom indentation from metadata', () {
        final keyMeta = {
          '_root': const KeyMetadata(
            jsonMeta: JsonMeta(indentSpaces: 4),
          ).toJson(),
        };
        final result = generator.generate({'name': 'John'}, keyMeta: keyMeta);
        expect(result.contains('    "name"'), true);
      });

      test('generates minified when indentSpaces is 0', () {
        final keyMeta = {
          '_root': const KeyMetadata(
            jsonMeta: JsonMeta(indentSpaces: 0),
          ).toJson(),
        };
        final result = generator.generate({'name': 'John'}, keyMeta: keyMeta);
        expect(result, '{"name":"John"}');
      });
    });

    group('string escaping', () {
      test('escapes double quotes', () {
        final result = generator.generate({'text': 'Say "hello"'});
        expect(result.contains('\\"hello\\"'), true);
      });

      test('escapes newlines', () {
        final result = generator.generate({'text': 'line1\nline2'});
        expect(result.contains('\\n'), true);
      });

      test('escapes backslashes', () {
        final result = generator.generate({'path': 'C:\\Users'});
        expect(result.contains('\\\\'), true);
      });
    });

    group('nested structures', () {
      test('generates nested objects', () {
        final result = generator.generate({
          'user': {'name': 'John', 'age': 30}
        });
        expect(result.contains('"user"'), true);
        expect(result.contains('"name"'), true);
      });

      test('generates arrays of objects', () {
        final result = generator.generate({
          'users': [
            {'name': 'John'},
            {'name': 'Jane'}
          ]
        });
        expect(result.contains('"users"'), true);
        expect(result.contains('"John"'), true);
        expect(result.contains('"Jane"'), true);
      });
    });

    group('round-trip', () {
      test('parser and generator round-trip with 2-space indent', () {
        const original = '''{
  "name": "John",
  "age": 30
}''';
        const parser = JsonLayoutParser();
        final parsed = parser.parse(original);
        final regenerated =
            generator.generate(parsed.data, keyMeta: parsed.keyMeta);

        // Compare normalized (both should have same structure)
        expect(regenerated.contains('"name": "John"'), true);
        expect(regenerated.contains('"age": 30'), true);
      });

      test('parser and generator round-trip minified', () {
        const original = '{"name":"John","age":30}';
        const parser = JsonLayoutParser();
        final parsed = parser.parse(original);
        final regenerated =
            generator.generate(parsed.data, keyMeta: parsed.keyMeta);

        expect(regenerated, '{"name":"John","age":30}');
      });
    });
  });
}
