import 'package:test/test.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

void main() {
  group('YamlLayoutGenerator', () {
    const generator = YamlLayoutGenerator();

    group('basic generation', () {
      test('generates empty output for empty data', () {
        final result = generator.generate({});
        expect(result, isEmpty);
      });

      test('generates simple key-value', () {
        final data = {'name': 'John'};
        final result = generator.generate(data);
        expect(result, equals('name: John'));
      });

      test('generates numeric value', () {
        final data = {'count': 42};
        final result = generator.generate(data);
        expect(result, equals('count: 42'));
      });

      test('generates boolean true', () {
        final data = {'active': true};
        final result = generator.generate(data);
        expect(result, equals('active: true'));
      });

      test('generates boolean false', () {
        final data = {'deleted': false};
        final result = generator.generate(data);
        expect(result, equals('deleted: false'));
      });

      test('generates double value', () {
        final data = {'price': 9.99};
        final result = generator.generate(data);
        expect(result, equals('price: 9.99'));
      });

      test('generates null value', () {
        final data = {'value': null};
        final result = generator.generate(data);
        expect(result, equals('value: null'));
      });
    });

    group('anchors', () {
      test('generates anchor on map value', () {
        final data = {
          'defaults': {
            'adapter': 'postgres',
            'host': 'localhost',
          },
        };
        final keyMeta = {
          'defaults': {
            'yamlMeta': {
              'anchor': 'defaults',
              'style': 'block',
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('defaults: &defaults'));
        expect(result, contains('adapter: postgres'));
        expect(result, contains('host: localhost'));
      });

      test('generates anchor on simple value', () {
        final data = {'name': 'John'};
        final keyMeta = {
          'name': {
            'yamlMeta': {
              'anchor': 'username',
              'style': 'block',
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('name: &username John'));
      });
    });

    group('aliases', () {
      test('generates alias reference', () {
        final data = {'ref': 'value'};
        final keyMeta = {
          'ref': {
            'yamlMeta': {
              'alias': 'defaults',
              'style': 'block',
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('ref: *defaults'));
      });
    });

    group('comments', () {
      test('generates comment before key', () {
        final data = {'name': 'John'};
        final keyMeta = {
          'name': {
            'yamlMeta': {
              'comment': 'User name',
              'style': 'block',
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('# User name'));
        expect(result, contains('name: John'));
      });

      test('generates comment for nested key', () {
        final data = {
          'config': {'value': 'test'},
        };
        final keyMeta = {
          'config': {
            'yamlMeta': {'style': 'block'},
            'children': {
              'value': {
                'yamlMeta': {
                  'comment': 'Configuration value',
                  'style': 'block',
                },
              },
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('# Configuration value'));
        expect(result, contains('value: test'));
      });
    });

    group('flow vs block style', () {
      test('generates flow style map', () {
        final data = {
          'person': {'name': 'John', 'age': 30},
        };
        final keyMeta = {
          'person': {
            'yamlMeta': {
              'style': 'flow',
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('person: {name: John, age: 30}'));
      });

      test('generates block style map by default', () {
        final data = {
          'person': {'name': 'John', 'age': 30},
        };
        final result = generator.generate(data);
        expect(result, contains('person:'));
        expect(result, contains('  name: John'));
        expect(result, contains('  age: 30'));
      });

      test('generates flow style list', () {
        final data = {
          'items': ['a', 'b', 'c'],
        };
        final keyMeta = {
          'items': {
            'yamlMeta': {
              'style': 'flow',
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('items: [a, b, c]'));
      });

      test('generates block style list by default', () {
        final data = {
          'items': ['a', 'b', 'c'],
        };
        final result = generator.generate(data);
        expect(result, contains('items:'));
        expect(result, contains('- a'));
        expect(result, contains('- b'));
        expect(result, contains('- c'));
      });
    });

    group('scalar styles', () {
      test('generates literal block scalar', () {
        final data = {'description': 'This is a\nmultiline text'};
        final keyMeta = {
          'description': {
            'yamlMeta': {
              'scalarStyle': 'literal',
              'style': 'block',
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('description: |'));
        expect(result, contains('This is a'));
        expect(result, contains('multiline text'));
      });

      test('generates folded block scalar', () {
        final data = {'description': 'This is a\nfolded text'};
        final keyMeta = {
          'description': {
            'yamlMeta': {
              'scalarStyle': 'folded',
              'style': 'block',
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('description: >'));
        expect(result, contains('This is a'));
        expect(result, contains('folded text'));
      });

      test('generates single-quoted scalar', () {
        final data = {'name': 'John Doe'};
        final keyMeta = {
          'name': {
            'yamlMeta': {
              'scalarStyle': 'single-quoted',
              'style': 'block',
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains("name: 'John Doe'"));
      });

      test('generates double-quoted scalar', () {
        final data = {'name': 'John Doe'};
        final keyMeta = {
          'name': {
            'yamlMeta': {
              'scalarStyle': 'double-quoted',
              'style': 'block',
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('name: "John Doe"'));
      });

      test('generates plain scalar without style', () {
        final data = {'name': 'John'};
        final result = generator.generate(data);
        expect(result, contains('name: John'));
      });
    });

    group('multi-document support', () {
      test('generates multiple documents with markers', () {
        final data = {
          '_document_0': {'name': 'Doc1'},
          '_document_1': {'name': 'Doc2'},
        };
        final keyMeta = {
          '_document': {
            'yamlMeta': {
              'comment': 'Multi-document YAML with 2 documents',
              'style': 'block',
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('---'));
        expect(result, contains('name: Doc1'));
        expect(result, contains('name: Doc2'));
      });
    });

    group('nested structures', () {
      test('generates nested maps', () {
        final data = {
          'user': {
            'name': 'John',
            'address': {
              'city': 'NYC',
              'zip': 10001,
            },
          },
        };
        final result = generator.generate(data);
        expect(result, contains('user:'));
        expect(result, contains('name: John'));
        expect(result, contains('address:'));
        expect(result, contains('city: NYC'));
        expect(result, contains('zip: 10001'));
      });

      test('generates nested lists', () {
        final data = {
          'matrix': [
            [1, 2],
            [3, 4],
          ],
        };
        final result = generator.generate(data);
        expect(result, contains('matrix:'));
        expect(result, contains('- 1'));
        expect(result, contains('- 2'));
        expect(result, contains('- 3'));
        expect(result, contains('- 4'));
      });

      test('generates lists of maps', () {
        final data = {
          'users': [
            {'name': 'John', 'age': 30},
            {'name': 'Jane', 'age': 25},
          ],
        };
        final result = generator.generate(data);
        expect(result, contains('users:'));
        expect(result, contains('name: John'));
        expect(result, contains('age: 30'));
        expect(result, contains('name: Jane'));
        expect(result, contains('age: 25'));
      });

      test('generates maps with list values', () {
        final data = {
          'person': {
            'name': 'John',
            'hobbies': ['reading', 'coding'],
          },
        };
        final result = generator.generate(data);
        expect(result, contains('name: John'));
        expect(result, contains('hobbies:'));
        expect(result, contains('- reading'));
        expect(result, contains('- coding'));
      });
    });

    group('edge cases', () {
      test('handles unicode content', () {
        final data = {'name': 'Hello World'};
        final result = generator.generate(data);
        expect(result, contains('name: Hello World'));
      });

      test('handles special characters in strings', () {
        final data = {'special': 'value with: colon'};
        final result = generator.generate(data);
        expect(result, contains('special: "value with: colon"'));
      });

      test('handles strings that look like booleans', () {
        final data = {'value': 'true'};
        final result = generator.generate(data);
        expect(result, contains('value: "true"'));
      });

      test('handles strings that look like numbers', () {
        final data = {'value': '42'};
        final result = generator.generate(data);
        expect(result, contains('value: "42"'));
      });

      test('handles empty nested structures', () {
        final data = {
          'empty_map': <String, dynamic>{},
          'empty_list': <String>[],
        };
        final result = generator.generate(data);
        expect(result, contains('empty_map: {}'));
        expect(result, contains('empty_list: []'));
      });

      test('handles missing keyMeta gracefully', () {
        final data = {'name': 'John'};
        final result = generator.generate(data);
        expect(result, contains('name: John'));
      });
    });

    group('metadata handling', () {
      test('includes metadata under _meta key', () {
        final data = {'name': 'John'};
        final metaData = {'version': '1.0'};
        final result = generator.generate(data, metaData: metaData);
        expect(result, contains('_meta:'));
        // "1.0" is quoted because it looks like a number
        expect(result, contains('version: "1.0"'));
        expect(result, contains('name: John'));
      });
    });
  });

  group('jsonToYaml with preserveLayout', () {
    test('uses generator when keyMeta and preserveLayout are set', () {
      final data = {
        'config': {'a': 1, 'b': 2},
      };
      final keyMeta = {
        'config': {
          'yamlMeta': {
            'style': 'flow',
          },
        },
      };
      final result = jsonToYaml(data, keyMeta: keyMeta);
      expect(result, contains('config: {a: 1, b: 2}'));
    });

    test('falls back to default behavior when preserveLayout is false', () {
      final data = {'name': 'John'};
      final keyMeta = {
        'name': {
          'yamlMeta': {
            'style': 'flow',
          },
        },
      };
      final result = jsonToYaml(data, keyMeta: keyMeta, preserveLayout: false);
      expect(result, contains('name: John'));
    });

    test('falls back to default behavior when keyMeta is null', () {
      final data = {'name': 'John'};
      final result = jsonToYaml(data);
      expect(result, contains('name: John'));
    });

    test('backward compatibility - basic YAML generation', () {
      final result = jsonToYaml({'name': 'John', 'age': 30});
      expect(result, contains('name: John'));
      expect(result, contains('age: 30'));
    });

    test('backward compatibility - nested structures', () {
      final result = jsonToYaml({
        'user': {'name': 'John'},
      });
      expect(result, contains('user:'));
      expect(result, contains('name: John'));
    });

    test('backward compatibility - list values', () {
      final result = jsonToYaml({
        'items': ['a', 'b', 'c'],
      });
      expect(result, contains('items:'));
      expect(result, contains('- a'));
      expect(result, contains('- b'));
      expect(result, contains('- c'));
    });
  });

  group('round-trip tests', () {
    const parser = YamlLayoutParser();
    const generator = YamlLayoutGenerator();

    test('anchor round-trip', () {
      const original = '''defaults: &defaults
  adapter: postgres
  host: localhost''';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('&defaults'));
      expect(generated, contains('adapter: postgres'));
      expect(generated, contains('host: localhost'));
    });

    test('comment round-trip', () {
      const original = '''# Main configuration
config:
  value: test''';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('# Main configuration'));
      expect(generated, contains('config:'));
      expect(generated, contains('value: test'));
    });

    test('scalar style round-trip - literal', () {
      const original = '''description: |
  Line 1
  Line 2''';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('description: |'));
      expect(generated, contains('Line 1'));
      expect(generated, contains('Line 2'));
    });

    test('scalar style round-trip - folded', () {
      const original = '''description: >
  This is
  folded''';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('description: >'));
    });

    test('scalar style round-trip - single-quoted', () {
      const original = "name: 'quoted value'";
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains("'quoted value'"));
    });

    test('scalar style round-trip - double-quoted', () {
      const original = 'name: "quoted value"';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('"quoted value"'));
    });

    test('flow style round-trip - map', () {
      const original = 'config: {a: 1, b: 2}';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('{a: 1, b: 2}'));
    });

    test('flow style round-trip - list', () {
      const original = 'items: [1, 2, 3]';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('[1, 2, 3]'));
    });

    test('complex document round-trip', () {
      const original = '''# Main config
defaults: &defaults
  adapter: postgres
  host: localhost

development:
  database: dev_db''';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );

      // Verify key elements are preserved
      expect(generated, contains('&defaults'));
      expect(generated, contains('# Main config'));
      expect(generated, contains('adapter: postgres'));
      expect(generated, contains('host: localhost'));
      expect(generated, contains('database: dev_db'));
    });

    test('nested structure round-trip', () {
      const original = '''user:
  name: John
  address:
    city: NYC
    zip: 10001''';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('user:'));
      expect(generated, contains('name: John'));
      expect(generated, contains('address:'));
      expect(generated, contains('city: NYC'));
      expect(generated, contains('zip: 10001'));
    });

    test('list of maps round-trip', () {
      const original = '''users:
  - name: John
    age: 30
  - name: Jane
    age: 25''';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('users:'));
      expect(generated, contains('name: John'));
      expect(generated, contains('age: 30'));
      expect(generated, contains('name: Jane'));
      expect(generated, contains('age: 25'));
    });

    test('boolean values round-trip', () {
      const original = '''settings:
  enabled: true
  debug: false''';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('enabled: true'));
      expect(generated, contains('debug: false'));
    });

    test('numeric values round-trip', () {
      const original = '''data:
  count: 42
  price: 9.99''';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('count: 42'));
      expect(generated, contains('price: 9.99'));
    });
  });

  group('edge cases', () {
    const generator = YamlLayoutGenerator();

    test('handles null values gracefully', () {
      final data = {'value': null};
      final result = generator.generate(data);
      expect(result, contains('value: null'));
    });

    test('handles empty string values', () {
      final data = {'value': ''};
      final result = generator.generate(data);
      expect(result, contains('value: ""'));
    });

    test('handles empty map values', () {
      final data = {'empty': <String, dynamic>{}};
      final result = generator.generate(data);
      expect(result, contains('empty: {}'));
    });

    test('handles empty list values', () {
      final data = {'items': <String>[]};
      final result = generator.generate(data);
      expect(result, contains('items: []'));
    });

    test('handles deeply nested structures', () {
      final data = {
        'a': {
          'b': {
            'c': {
              'd': {
                'e': 'deep value',
              },
            },
          },
        },
      };
      final result = generator.generate(data);
      expect(result, contains('e: deep value'));
    });

    test('handles strings with newlines requiring quoting', () {
      final data = {'text': 'line1\nline2'};
      final result = generator.generate(data);
      expect(result, contains('"line1\\nline2"'));
    });

    test('handles strings with hash requiring quoting', () {
      final data = {'comment': 'Not a #comment'};
      final result = generator.generate(data);
      expect(result, contains('"Not a #comment"'));
    });
  });
}
