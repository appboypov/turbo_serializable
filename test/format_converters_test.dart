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
            'level3': {'level4': 'deep'}
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

    test('formats with indentation when prettyPrint is true', () {
      final result = convertMapToYaml(
        {
          'parent': {'child': 'value'}
        },
        0,
        prettyPrint: true,
      );
      expect(result, contains('parent:\n'));
      expect(result, contains('  child: value'));
    });

    test('formats without indentation when prettyPrint is false', () {
      final result = convertMapToYaml(
        {'key': 'value'},
        0,
        prettyPrint: false,
      );
      expect(result, contains('key: value'));
      // Should not have trailing newline when prettyPrint is false
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

    test('excludes null values when includeNulls is false', () {
      final result = jsonToYaml(
        {'name': 'test', 'nullable': null, 'age': 30},
        includeNulls: false,
      );
      expect(result, contains('name: test'));
      expect(result, contains('age: 30'));
      expect(result, isNot(contains('nullable')));
    });

    test('includes null values when includeNulls is true', () {
      final result = jsonToYaml(
        {'name': 'test', 'nullable': null},
        includeNulls: true,
      );
      expect(result, contains('name: test'));
      expect(result, contains('nullable: null'));
    });

    test('formats with indentation when prettyPrint is true', () {
      final result = jsonToYaml(
        {
          'parent': {'child': 'value'}
        },
        prettyPrint: true,
      );
      expect(result, contains('parent:'));
      expect(result, contains('  child: value'));
    });

    test('formats without indentation when prettyPrint is false', () {
      final result = jsonToYaml(
        {'name': 'test'},
        prettyPrint: false,
      );
      // When prettyPrint is false, there should be no newlines/indentation
      expect(result, contains('name: test'));
    });

    test('filters nulls recursively', () {
      final result = jsonToYaml(
        {
          'parent': {
            'child': 'value',
            'nullable': null,
            'nested': {
              'deep': null,
              'value': 'kept',
            },
          },
          'topNull': null,
        },
        includeNulls: false,
      );
      expect(result, contains('child: value'));
      expect(result, contains('value: kept'));
      expect(result, isNot(contains('nullable')));
      expect(result, isNot(contains('deep')));
      expect(result, isNot(contains('topNull')));
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

    test('excludes null values when includeNulls is false', () {
      final result = jsonToMarkdown(
        {'name': 'test', 'nullable': null, 'age': 30},
        includeNulls: false,
      );
      expect(result, contains('## Name'));
      expect(result, contains('## Age'));
      expect(result, isNot(contains('Nullable')));
    });

    test('includes null values when includeNulls is true', () {
      final result = jsonToMarkdown(
        {'name': 'test', 'nullable': null},
        includeNulls: true,
      );
      expect(result, contains('## Name'));
      expect(result, contains('## Nullable'));
    });

    test('adds spacing when prettyPrint is true', () {
      final result = jsonToMarkdown(
        {'key1': 'value1', 'key2': 'value2'},
        prettyPrint: true,
      );
      // Should have blank lines between sections
      expect(result, contains('## Key1\nvalue1\n\n## Key2'));
    });

    test('removes spacing when prettyPrint is false', () {
      final result = jsonToMarkdown(
        {'key1': 'value1', 'key2': 'value2'},
        prettyPrint: false,
      );
      // Should have minimal spacing
      expect(result, contains('## Key1\nvalue1\n## Key2'));
    });

    test('filters nulls recursively', () {
      final result = jsonToMarkdown(
        {
          'parent': {
            'child': 'value',
            'nullable': null,
            'nested': {
              'deep': null,
              'value': 'kept',
            },
          },
          'topNull': null,
        },
        includeNulls: false,
      );
      expect(result, contains('## Parent'));
      expect(result, contains('### Child'));
      expect(result, contains('### Value'));
      expect(result, isNot(contains('Nullable')));
      expect(result, isNot(contains('Deep')));
      expect(result, isNot(contains('Top Null')));
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

    test('adds spacing when prettyPrint is true', () {
      final result = convertMapToMarkdownHeaders(
        {'key1': 'value1', 'key2': 'value2'},
        2,
        prettyPrint: true,
      );
      expect(result, contains('## Key1\nvalue1\n\n## Key2'));
    });

    test('removes spacing when prettyPrint is false', () {
      final result = convertMapToMarkdownHeaders(
        {'key1': 'value1', 'key2': 'value2'},
        2,
        prettyPrint: false,
      );
      expect(result, contains('## Key1\nvalue1\n## Key2'));
      expect(result, isNot(contains('## Key1\nvalue1\n\n## Key2')));
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

  group('yamlToXml with case styles', () {
    test('converts YAML to XML with camelCase', () {
      final yaml = 'user_name: test\nfirst_name: John';
      final result = yamlToXml(yaml, caseStyle: CaseStyle.camelCase);
      expect(result, contains('<userName>test</userName>'));
      expect(result, contains('<firstName>John</firstName>'));
    });

    test('converts YAML to XML with PascalCase', () {
      final yaml = 'user_name: test\nfirst_name: John';
      final result = yamlToXml(yaml, caseStyle: CaseStyle.pascalCase);
      expect(result, contains('<UserName>test</UserName>'));
      expect(result, contains('<FirstName>John</FirstName>'));
    });

    test('converts YAML to XML with snakeCase', () {
      final yaml = 'userName: test\nfirstName: John';
      final result = yamlToXml(yaml, caseStyle: CaseStyle.snakeCase);
      expect(result, contains('<user_name>test</user_name>'));
      expect(result, contains('<first_name>John</first_name>'));
    });

    test('converts YAML to XML with kebabCase', () {
      final yaml = 'userName: test\nfirstName: John';
      final result = yamlToXml(yaml, caseStyle: CaseStyle.kebabCase);
      expect(result, contains('<user-name>test</user-name>'));
      expect(result, contains('<first-name>John</first-name>'));
    });

    test('converts YAML to XML with none case style', () {
      final yaml = 'userName: test\nuser_name: test2';
      final result = yamlToXml(yaml, caseStyle: CaseStyle.none);
      expect(result, contains('<userName>test</userName>'));
      expect(result, contains('<user_name>test2</user_name>'));
    });

    test('camelCase with nested YAML', () {
      final yaml = 'user_info:\n  first_name: John\n  last_name: Doe';
      final result = yamlToXml(yaml, caseStyle: CaseStyle.camelCase);
      expect(result, contains('<userInfo>'));
      expect(result, contains('<firstName>John</firstName>'));
      expect(result, contains('<lastName>Doe</lastName>'));
    });

    test('snakeCase with nested YAML', () {
      final yaml = 'userInfo:\n  firstName: John\n  lastName: Doe';
      final result = yamlToXml(yaml, caseStyle: CaseStyle.snakeCase);
      expect(result, contains('<user_info>'));
      expect(result, contains('<first_name>John</first_name>'));
      expect(result, contains('<last_name>Doe</last_name>'));
    });

    test('kebabCase with nested YAML', () {
      final yaml = 'userInfo:\n  firstName: John\n  lastName: Doe';
      final result = yamlToXml(yaml, caseStyle: CaseStyle.kebabCase);
      expect(result, contains('<user-info>'));
      expect(result, contains('<first-name>John</first-name>'));
      expect(result, contains('<last-name>Doe</last-name>'));
    });

    test('camelCase with metadata', () {
      final yaml = 'data: value';
      final result = yamlToXml(
        yaml,
        caseStyle: CaseStyle.camelCase,
        metaData: {'version': '1.0'},
      );
      // Note: '_meta' with leading underscore converts to 'Meta' in camelCase
      expect(result, contains('<Meta>'));
      expect(result, contains('<version>1.0</version>'));
    });

    test('custom root element with camelCase', () {
      final yaml = 'user_name: test';
      final result = yamlToXml(
        yaml,
        rootElementName: 'user_profile',
        caseStyle: CaseStyle.camelCase,
      );
      expect(result, contains('<userProfile>'));
      expect(result, contains('<userName>test</userName>'));
    });
  });

  group('markdownToXml with case styles', () {
    test('converts Markdown to XML with camelCase', () {
      final markdown = '{"user_name": "test", "first_name": "John"}';
      final result = markdownToXml(markdown, caseStyle: CaseStyle.camelCase);
      expect(result, contains('<userName>test</userName>'));
      expect(result, contains('<firstName>John</firstName>'));
    });

    test('converts Markdown to XML with PascalCase', () {
      final markdown = '{"user_name": "test", "first_name": "John"}';
      final result = markdownToXml(markdown, caseStyle: CaseStyle.pascalCase);
      expect(result, contains('<UserName>test</UserName>'));
      expect(result, contains('<FirstName>John</FirstName>'));
    });

    test('converts Markdown to XML with snakeCase', () {
      final markdown = '{"userName": "test", "firstName": "John"}';
      final result = markdownToXml(markdown, caseStyle: CaseStyle.snakeCase);
      expect(result, contains('<user_name>test</user_name>'));
      expect(result, contains('<first_name>John</first_name>'));
    });

    test('converts Markdown to XML with kebabCase', () {
      final markdown = '{"userName": "test", "firstName": "John"}';
      final result = markdownToXml(markdown, caseStyle: CaseStyle.kebabCase);
      expect(result, contains('<user-name>test</user-name>'));
      expect(result, contains('<first-name>John</first-name>'));
    });

    test('converts Markdown to XML with none case style', () {
      final markdown = '{"userName": "test", "user_name": "test2"}';
      final result = markdownToXml(markdown, caseStyle: CaseStyle.none);
      expect(result, contains('<userName>test</userName>'));
      expect(result, contains('<user_name>test2</user_name>'));
    });

    test('camelCase with nested JSON in Markdown', () {
      final markdown =
          '{"user_info": {"first_name": "John", "last_name": "Doe"}}';
      final result = markdownToXml(markdown, caseStyle: CaseStyle.camelCase);
      expect(result, contains('<userInfo>'));
      expect(result, contains('<firstName>John</firstName>'));
      expect(result, contains('<lastName>Doe</lastName>'));
    });

    test('snakeCase with nested JSON in Markdown', () {
      final markdown = '{"userInfo": {"firstName": "John", "lastName": "Doe"}}';
      final result = markdownToXml(markdown, caseStyle: CaseStyle.snakeCase);
      expect(result, contains('<user_info>'));
      expect(result, contains('<first_name>John</first_name>'));
      expect(result, contains('<last_name>Doe</last_name>'));
    });

    test('kebabCase with nested JSON in Markdown', () {
      final markdown = '{"userInfo": {"firstName": "John", "lastName": "Doe"}}';
      final result = markdownToXml(markdown, caseStyle: CaseStyle.kebabCase);
      expect(result, contains('<user-info>'));
      expect(result, contains('<first-name>John</first-name>'));
      expect(result, contains('<last-name>Doe</last-name>'));
    });

    test('custom root element with camelCase', () {
      final markdown = '{"user_name": "test"}';
      final result = markdownToXml(
        markdown,
        rootElementName: 'user_profile',
        caseStyle: CaseStyle.camelCase,
      );
      expect(result, contains('<userProfile>'));
      expect(result, contains('<userName>test</userName>'));
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

  group('filterNullsFromMap', () {
    test('removes top-level null values', () {
      final result = filterNullsFromMap({
        'name': 'test',
        'nullable': null,
        'age': 30,
      });
      expect(result, {'name': 'test', 'age': 30});
      expect(result, isNot(contains('nullable')));
    });

    test('removes nested null values', () {
      final result = filterNullsFromMap({
        'parent': {
          'child': 'value',
          'nullable': null,
        },
      });
      expect(result['parent'], {'child': 'value'});
      expect(result['parent'], isNot(contains('nullable')));
    });

    test('removes null values from lists', () {
      final result = filterNullsFromMap({
        'items': ['a', null, 'b', null, 'c'],
      });
      expect(result['items'], ['a', 'b', 'c']);
    });

    test('preserves empty maps after filtering', () {
      final result = filterNullsFromMap({
        'parent': {
          'nullable': null,
        },
      });
      expect(result['parent'], isEmpty);
      expect(result['parent'], isA<Map>());
    });

    test('preserves empty lists after filtering', () {
      final result = filterNullsFromMap({
        'items': [null, null],
      });
      expect(result['items'], isEmpty);
      expect(result['items'], isA<List>());
    });

    test('preserves non-null values', () {
      final result = filterNullsFromMap({
        'string': 'value',
        'number': 42,
        'boolean': true,
        'list': [1, 2, 3],
        'map': {'nested': 'value'},
      });
      expect(result['string'], 'value');
      expect(result['number'], 42);
      expect(result['boolean'], true);
      expect(result['list'], [1, 2, 3]);
      expect(result['map'], {'nested': 'value'});
    });

    test('handles deeply nested structures', () {
      final result = filterNullsFromMap({
        'level1': {
          'level2': {
            'level3': {
              'value': 'kept',
              'nullable': null,
            },
            'nullable': null,
          },
          'kept': 'value',
        },
        'topNull': null,
      });
      expect(result['level1']['level2']['level3'], {'value': 'kept'});
      expect(result['level1']['kept'], 'value');
      expect(result, isNot(contains('topNull')));
    });
  });
}
