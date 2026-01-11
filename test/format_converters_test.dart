import 'package:test/test.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

void main() {
  group('jsonEncodeFormatted', () {
    test('encodes empty map', () {
      final result = jsonEncodeFormatted({});
      expect(result, '{}');
    });

    test('encodes map with null values', () {
      final result = jsonEncodeFormatted({'key': null});
      expect(result, contains('"key": null'));
    });

    test('encodes nested objects', () {
      final result = jsonEncodeFormatted({
        'outer': {
          'inner': {'deep': 'value'}
        }
      });
      expect(result, contains('"outer"'));
      expect(result, contains('"inner"'));
      expect(result, contains('"deep": "value"'));
    });

    test('escapes special characters in strings', () {
      final result = jsonEncodeFormatted({'key': 'value with "quotes"'});
      expect(result, contains('\\"quotes\\"'));
    });

    test('escapes newlines in strings', () {
      final result = jsonEncodeFormatted({'key': 'line1\nline2'});
      expect(result, contains('\\n'));
    });

    test('encodes unicode characters', () {
      final result = jsonEncodeFormatted({'emoji': '👍', 'chinese': '中文'});
      expect(result, contains('👍'));
      expect(result, contains('中文'));
    });

    test('encodes numeric values', () {
      final result = jsonEncodeFormatted({
        'int': 42,
        'double': 3.14,
        'negative': -100,
      });
      expect(result, contains('"int": 42'));
      expect(result, contains('"double": 3.14'));
      expect(result, contains('"negative": -100'));
    });

    test('encodes boolean values', () {
      final result = jsonEncodeFormatted({'yes': true, 'no': false});
      expect(result, contains('"yes": true'));
      expect(result, contains('"no": false'));
    });

    test('encodes arrays', () {
      final result = jsonEncodeFormatted({
        'items': [1, 2, 3]
      });
      expect(result, contains('"items": ['));
      expect(result, contains('1'));
      expect(result, contains('2'));
      expect(result, contains('3'));
    });

    test('encodes empty arrays', () {
      final result = jsonEncodeFormatted({'empty': <dynamic>[]});
      expect(result, contains('"empty": []'));
    });
  });

  group('formatJsonValue', () {
    test('formats null', () {
      expect(formatJsonValue(null, 0), 'null');
    });

    test('formats string', () {
      expect(formatJsonValue('hello', 0), '"hello"');
    });

    test('formats integer', () {
      expect(formatJsonValue(42, 0), '42');
    });

    test('formats double', () {
      expect(formatJsonValue(3.14, 0), '3.14');
    });

    test('formats boolean', () {
      expect(formatJsonValue(true, 0), 'true');
      expect(formatJsonValue(false, 0), 'false');
    });

    test('formats empty list', () {
      expect(formatJsonValue(<dynamic>[], 0), '[]');
    });

    test('formats empty map', () {
      expect(formatJsonValue(<String, dynamic>{}, 0), '{}');
    });

    test('respects indent level', () {
      final result = formatJsonValue({'key': 'value'}, 2);
      expect(result, contains('      "key"'));
    });

    test('handles deep nesting', () {
      final result = formatJsonValue({
        'level1': {
          'level2': {
            'level3': {
              'level4': 'deep'
            }
          }
        }
      }, 0);
      expect(result, contains('level4'));
      expect(result, contains('deep'));
    });
  });

  group('convertMapToYaml', () {
    test('converts empty map', () {
      final result = convertMapToYaml({}, 0);
      expect(result, isEmpty);
    });

    test('converts simple map', () {
      final result = convertMapToYaml({'key': 'value'}, 0);
      expect(result, 'key: value\n');
    });

    test('converts nested maps', () {
      final result = convertMapToYaml({
        'parent': {'child': 'value'}
      }, 0);
      expect(result, contains('parent:'));
      expect(result, contains('  child: value'));
    });

    test('converts lists', () {
      final result = convertMapToYaml({
        'items': ['a', 'b', 'c']
      }, 0);
      expect(result, contains('items:'));
      expect(result, contains('  - a'));
      expect(result, contains('  - b'));
      expect(result, contains('  - c'));
    });

    test('converts lists of maps', () {
      final result = convertMapToYaml({
        'users': [
          {'name': 'Alice'},
          {'name': 'Bob'}
        ]
      }, 0);
      expect(result, contains('users:'));
      expect(result, contains('  -'));
      expect(result, contains('    name: Alice'));
    });

    test('handles null values', () {
      final result = convertMapToYaml({'nullable': null}, 0);
      expect(result, 'nullable: null\n');
    });

    test('respects indent level', () {
      final result = convertMapToYaml({'key': 'value'}, 2);
      expect(result, '    key: value\n');
    });
  });

  group('convertValueToYamlString', () {
    test('returns plain string', () {
      expect(convertValueToYamlString('hello'), 'hello');
    });

    test('quotes string with colon', () {
      final result = convertValueToYamlString('key: value');
      expect(result, '"key: value"');
    });

    test('quotes string with newline', () {
      final result = convertValueToYamlString('line1\nline2');
      expect(result, '"line1\nline2"');
    });

    test('quotes string with leading space', () {
      final result = convertValueToYamlString(' leading');
      expect(result, '" leading"');
    });

    test('escapes quotes in string with colon', () {
      final result = convertValueToYamlString('key: say "hello"');
      expect(result, contains('\\"'));
    });

    test('returns plain string without special chars', () {
      final result = convertValueToYamlString('say "hello"');
      expect(result, 'say "hello"');
    });

    test('converts boolean', () {
      expect(convertValueToYamlString(true), 'true');
      expect(convertValueToYamlString(false), 'false');
    });

    test('converts integer', () {
      expect(convertValueToYamlString(42), '42');
    });

    test('converts double', () {
      expect(convertValueToYamlString(3.14), '3.14');
    });
  });

  group('convertYamlToMap', () {
    test('converts simple map', () {
      final yamlMap = {'key': 'value'};
      final result = convertYamlToMap(yamlMap);
      expect(result, {'key': 'value'});
    });

    test('converts nested structures', () {
      final yamlMap = {
        'outer': {'inner': 'value'}
      };
      final result = convertYamlToMap(yamlMap);
      expect(result['outer']['inner'], 'value');
    });

    test('converts lists', () {
      final yamlList = ['a', 'b', 'c'];
      final result = convertYamlToMap(yamlList);
      expect(result, ['a', 'b', 'c']);
    });

    test('handles mixed types', () {
      final yamlMixed = {
        'string': 'value',
        'number': 42,
        'bool': true,
        'null': null,
        'list': [1, 2],
        'map': {'nested': 'value'}
      };
      final result = convertYamlToMap(yamlMixed) as Map<String, dynamic>;
      expect(result['string'], 'value');
      expect(result['number'], 42);
      expect(result['bool'], true);
      expect(result['null'], isNull);
      expect(result['list'], [1, 2]);
      expect(result['map'], {'nested': 'value'});
    });

    test('converts non-string keys to strings', () {
      final yamlMap = {1: 'one', 2: 'two'};
      final result = convertYamlToMap(yamlMap) as Map<String, dynamic>;
      expect(result['1'], 'one');
      expect(result['2'], 'two');
    });

    test('returns primitive values unchanged', () {
      expect(convertYamlToMap('string'), 'string');
      expect(convertYamlToMap(42), 42);
      expect(convertYamlToMap(true), true);
      expect(convertYamlToMap(null), null);
    });
  });

  group('jsonToYaml', () {
    test('converts simple JSON', () {
      final result = jsonToYaml({'name': 'test'});
      expect(result, contains('name: test'));
    });

    test('includes metadata when provided', () {
      final result = jsonToYaml(
        {'data': 'value'},
        metaData: {'version': '1.0'},
      );
      expect(result, contains('_meta:'));
      expect(result, contains('version: 1.0'));
    });

    test('handles empty metadata', () {
      final result = jsonToYaml(
        {'data': 'value'},
        metaData: {},
      );
      expect(result, isNot(contains('_meta:')));
    });
  });

  group('jsonToMarkdown', () {
    test('converts simple JSON to headers', () {
      final result = jsonToMarkdown({'key': 'value'});
      expect(result, contains('## Key'));
      expect(result, contains('value'));
    });

    test('adds frontmatter with metadata', () {
      final result = jsonToMarkdown(
        {'data': 'value'},
        metaData: {'title': 'Test'},
      );
      expect(result, startsWith('---\n'));
      expect(result, contains('title: Test'));
      expect(result, contains('---\n## Data'));
    });

    test('converts nested objects to deeper headers', () {
      final result = jsonToMarkdown({
        'user': {'name': 'John'},
      });
      expect(result, contains('## User'));
      expect(result, contains('### Name'));
      expect(result, contains('John'));
    });

    test('converts arrays to markdown lists', () {
      final result = jsonToMarkdown({
        'items': ['a', 'b', 'c'],
      });
      expect(result, contains('## Items'));
      expect(result, contains('- a'));
      expect(result, contains('- b'));
      expect(result, contains('- c'));
    });

    test('converts keys to Title Case', () {
      final result = jsonToMarkdown({
        'userName': 'John',
        'first_name': 'Jane',
        'last-name': 'Doe',
      });
      expect(result, contains('## User Name'));
      expect(result, contains('## First Name'));
      expect(result, contains('## Last Name'));
    });
  });

  group('convertToTitleCase', () {
    test('converts camelCase', () {
      expect(convertToTitleCase('userName'), 'User Name');
      expect(convertToTitleCase('firstName'), 'First Name');
    });

    test('converts snake_case', () {
      expect(convertToTitleCase('user_name'), 'User Name');
      expect(convertToTitleCase('first_name'), 'First Name');
    });

    test('converts kebab-case', () {
      expect(convertToTitleCase('user-name'), 'User Name');
      expect(convertToTitleCase('first-name'), 'First Name');
    });

    test('converts PascalCase', () {
      expect(convertToTitleCase('UserName'), 'User Name');
      expect(convertToTitleCase('FirstName'), 'First Name');
    });

    test('handles empty string', () {
      expect(convertToTitleCase(''), '');
    });

    test('handles single word', () {
      expect(convertToTitleCase('name'), 'Name');
    });
  });

  group('convertMapToMarkdownHeaders', () {
    test('converts simple map with level 2 headers', () {
      final result = convertMapToMarkdownHeaders({'name': 'John'}, 2);
      expect(result, contains('## Name'));
      expect(result, contains('John'));
    });

    test('converts nested map with incrementing headers', () {
      final result = convertMapToMarkdownHeaders({
        'user': {'name': 'John'},
      }, 2);
      expect(result, contains('## User'));
      expect(result, contains('### Name'));
    });

    test('uses bold for levels beyond h4', () {
      final result = convertMapToMarkdownHeaders({
        'l1': {
          'l2': {
            'l3': {
              'l4': 'deep',
            },
          },
        },
      }, 2);
      expect(result, contains('## L1'));
      expect(result, contains('### L2'));
      expect(result, contains('#### L3'));
      expect(result, contains('**L4**'));
    });

    test('converts arrays of primitives to lists', () {
      final result = convertMapToMarkdownHeaders({
        'items': ['a', 'b'],
      }, 2);
      expect(result, contains('- a'));
      expect(result, contains('- b'));
    });

    test('flattens arrays of objects', () {
      final result = convertMapToMarkdownHeaders({
        'users': [
          {'name': 'Alice'},
          {'name': 'Bob'},
        ],
      }, 2);
      expect(result, contains('### Name'));
      expect(result, contains('Alice'));
      expect(result, contains('Bob'));
    });
  });

  group('yamlToJson', () {
    test('parses simple YAML', () {
      final result = yamlToJson('name: test\nage: 30');
      expect(result['name'], 'test');
      expect(result['age'], 30);
    });

    test('parses nested YAML', () {
      final result = yamlToJson('user:\n  name: test\n  active: true');
      expect(result['user']['name'], 'test');
      expect(result['user']['active'], true);
    });

    test('parses lists', () {
      final result = yamlToJson('items:\n  - one\n  - two');
      expect(result['items'], ['one', 'two']);
    });

    test('throws on invalid YAML', () {
      expect(
        () => yamlToJson('invalid: yaml: syntax: {{'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('markdownToJson', () {
    test('parses frontmatter', () {
      final result = markdownToJson('---\ntitle: Test\n---\nBody content');
      expect(result['title'], 'Test');
      expect(result['body'], 'Body content');
    });

    test('parses JSON body', () {
      final result = markdownToJson('---\ntitle: Test\n---\n{"key": "value"}');
      expect(result['title'], 'Test');
      expect(result['body'], {'key': 'value'});
    });

    test('handles no frontmatter', () {
      final result = markdownToJson('{"key": "value"}');
      expect(result['body'], {'key': 'value'});
    });

    test('handles empty content', () {
      final result = markdownToJson('');
      expect(result, isEmpty);
    });

    test('handles only frontmatter', () {
      final result = markdownToJson('---\ntitle: Test\n---');
      expect(result['title'], 'Test');
    });

    test('stores non-JSON body as string', () {
      final result = markdownToJson('---\ntitle: Test\n---\nPlain text body');
      expect(result['body'], 'Plain text body');
    });
  });

  group('xmlToJson', () {
    test('parses simple XML', () {
      final result = xmlToJson('<root><name>test</name></root>');
      expect(result['name'], 'test');
    });

    test('throws on invalid XML', () {
      expect(
        () => xmlToJson('<invalid>'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
