import 'package:test/test.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

void main() {
  group('MarkdownLayoutGenerator', () {
    const generator = MarkdownLayoutGenerator();

    group('basic generation', () {
      test('generates empty output for empty data', () {
        final result = generator.generate({});
        expect(result, isEmpty);
      });

      test('generates body content without header', () {
        final result = generator.generate({'body': 'Hello world'});
        expect(result, 'Hello world');
      });

      test('generates header with content', () {
        final data = {'title': 'Content here'};
        final keyMeta = {
          'title': {'headerLevel': 1},
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('# Title'));
        expect(result, contains('Content here'));
      });
    });

    group('header generation', () {
      test('generates h1 header', () {
        final data = {'mainTitle': 'Content'};
        final keyMeta = {
          'mainTitle': {'headerLevel': 1},
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('# Main Title'));
      });

      test('generates h2 header', () {
        final data = {'section': 'Content'};
        final keyMeta = {
          'section': {'headerLevel': 2},
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('## Section'));
      });

      test('generates h3 header', () {
        final data = {'subsection': 'Content'};
        final keyMeta = {
          'subsection': {'headerLevel': 3},
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('### Subsection'));
      });

      test('generates h4 header', () {
        final data = {'deepSection': 'Content'};
        final keyMeta = {
          'deepSection': {'headerLevel': 4},
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('#### Deep Section'));
      });

      test('generates h5 header', () {
        final data = {'veryDeep': 'Content'};
        final keyMeta = {
          'veryDeep': {'headerLevel': 5},
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('##### Very Deep'));
      });

      test('generates h6 header', () {
        final data = {'deepest': 'Content'};
        final keyMeta = {
          'deepest': {'headerLevel': 6},
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('###### Deepest'));
      });

      test('converts camelCase key to Title Case', () {
        final data = {'userName': 'John'};
        final keyMeta = {
          'userName': {'headerLevel': 2},
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('## User Name'));
      });

      test('preserves trailing whitespace from metadata', () {
        final data = {'title': 'Content'};
        final keyMeta = {
          'title': {
            'headerLevel': 1,
            'whitespace': {'trailingNewlines': 2},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result.contains('# Title\n\n'), isTrue);
      });
    });

    group('callout generation', () {
      test('generates NOTE callout', () {
        final data = {'note': 'This is a note'};
        final keyMeta = {
          'note': {
            'callout': {
              'type': 'note',
              'content': 'This is a note',
              'position': 'before',
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('> [!NOTE]'));
        expect(result, contains('> This is a note'));
      });

      test('generates WARNING callout', () {
        final data = {'warning': 'Be careful!'};
        final keyMeta = {
          'warning': {
            'callout': {
              'type': 'warning',
              'content': 'Be careful!',
              'position': 'before',
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('> [!WARNING]'));
        expect(result, contains('> Be careful!'));
      });

      test('generates TIP callout', () {
        final data = {'tip': 'Pro tip here'};
        final keyMeta = {
          'tip': {
            'callout': {
              'type': 'tip',
              'content': 'Pro tip here',
              'position': 'before',
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('> [!TIP]'));
        expect(result, contains('> Pro tip here'));
      });

      test('generates multiline callout', () {
        final data = {'note': 'First line\nSecond line'};
        final keyMeta = {
          'note': {
            'callout': {
              'type': 'note',
              'content': 'First line\nSecond line',
              'position': 'before',
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('> [!NOTE]'));
        expect(result, contains('> First line'));
        expect(result, contains('> Second line'));
      });
    });

    group('divider generation', () {
      test('generates --- divider', () {
        final data = {'_divider_0': ''};
        final keyMeta = {
          '_divider_0': {
            'divider': {'before': true, 'after': false, 'style': '---'},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('---'));
      });

      test('generates *** divider', () {
        final data = {'_divider_0': ''};
        final keyMeta = {
          '_divider_0': {
            'divider': {'before': true, 'after': false, 'style': '***'},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('***'));
      });

      test('generates ___ divider', () {
        final data = {'_divider_0': ''};
        final keyMeta = {
          '_divider_0': {
            'divider': {'before': true, 'after': false, 'style': '___'},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('___'));
      });
    });

    group('code block generation', () {
      test('generates code block without language', () {
        final data = {'_code_0': 'const x = 1;'};
        final keyMeta = {
          '_code_0': {
            'codeBlock': {'isInline': false},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('```'));
        expect(result, contains('const x = 1;'));
      });

      test('generates code block with language', () {
        final data = {'_code_0': 'const x = 1;'};
        final keyMeta = {
          '_code_0': {
            'codeBlock': {'language': 'javascript', 'isInline': false},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('```javascript'));
        expect(result, contains('const x = 1;'));
      });

      test('generates code block with language and filename', () {
        final data = {'_code_0': 'void main() {}'};
        final keyMeta = {
          '_code_0': {
            'codeBlock': {
              'language': 'dart',
              'filename': 'example.dart',
              'isInline': false,
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('```dart example.dart'));
        expect(result, contains('void main() {}'));
      });

      test('generates multiline code block', () {
        final code = 'def hello():\n    print("Hello")';
        final data = {'_code_0': code};
        final keyMeta = {
          '_code_0': {
            'codeBlock': {'language': 'python', 'isInline': false},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('```python'));
        expect(result, contains('def hello():'));
        expect(result, contains('print("Hello")'));
      });
    });

    group('unordered list generation', () {
      test('generates list with - marker', () {
        final data = {
          '_list_0': ['Item 1', 'Item 2', 'Item 3']
        };
        final keyMeta = {
          '_list_0': {
            'listMeta': {'type': 'unordered', 'marker': '-'},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('- Item 1'));
        expect(result, contains('- Item 2'));
        expect(result, contains('- Item 3'));
      });

      test('generates list with * marker', () {
        final data = {
          '_list_0': ['Item A', 'Item B']
        };
        final keyMeta = {
          '_list_0': {
            'listMeta': {'type': 'unordered', 'marker': '*'},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('* Item A'));
        expect(result, contains('* Item B'));
      });

      test('generates list with + marker', () {
        final data = {
          '_list_0': ['First', 'Second']
        };
        final keyMeta = {
          '_list_0': {
            'listMeta': {'type': 'unordered', 'marker': '+'},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('+ First'));
        expect(result, contains('+ Second'));
      });
    });

    group('ordered list generation', () {
      test('generates ordered list with period', () {
        final data = {
          '_list_0': ['First item', 'Second item', 'Third item']
        };
        final keyMeta = {
          '_list_0': {
            'listMeta': {'type': 'ordered', 'marker': '1.', 'startNumber': 1},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('1. First item'));
        expect(result, contains('2. Second item'));
        expect(result, contains('3. Third item'));
      });

      test('generates ordered list with parenthesis', () {
        final data = {
          '_list_0': ['Item A', 'Item B']
        };
        final keyMeta = {
          '_list_0': {
            'listMeta': {'type': 'ordered', 'marker': '1)', 'startNumber': 1},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('1) Item A'));
        expect(result, contains('2) Item B'));
      });

      test('preserves start number', () {
        final data = {
          '_list_0': ['Fifth', 'Sixth']
        };
        final keyMeta = {
          '_list_0': {
            'listMeta': {'type': 'ordered', 'marker': '5.', 'startNumber': 5},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('5. Fifth'));
        expect(result, contains('6. Sixth'));
      });
    });

    group('task list generation', () {
      test('generates unchecked task', () {
        final data = {
          '_list_0': [
            {'content': 'Todo item', 'checked': false}
          ]
        };
        final keyMeta = {
          '_list_0': {
            'listMeta': {'type': 'task', 'marker': '-'},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('- [ ] Todo item'));
      });

      test('generates checked task', () {
        final data = {
          '_list_0': [
            {'content': 'Done item', 'checked': true}
          ]
        };
        final keyMeta = {
          '_list_0': {
            'listMeta': {'type': 'task', 'marker': '-'},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('- [x] Done item'));
      });

      test('generates mixed task list', () {
        final data = {
          '_list_0': [
            {'content': 'Done', 'checked': true},
            {'content': 'Not done', 'checked': false},
            {'content': 'Also done', 'checked': true},
          ]
        };
        final keyMeta = {
          '_list_0': {
            'listMeta': {'type': 'task', 'marker': '-'},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('- [x] Done'));
        expect(result, contains('- [ ] Not done'));
        expect(result, contains('- [x] Also done'));
      });
    });

    group('table generation', () {
      test('generates simple table with header', () {
        final data = {
          '_table_0': {
            'headers': ['Name', 'Age'],
            'rows': [
              ['John', '30'],
              ['Jane', '25'],
            ],
          }
        };
        final keyMeta = {
          '_table_0': {
            'tableMeta': {
              'alignment': ['left', 'left'],
              'hasHeader': true,
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('| Name | Age |'));
        expect(result, contains('|---|'));
        expect(result, contains('| John | 30 |'));
        expect(result, contains('| Jane | 25 |'));
      });

      test('generates table with left alignment', () {
        final data = {
          '_table_0': {
            'headers': ['Name'],
            'rows': [
              ['Test']
            ],
          }
        };
        final keyMeta = {
          '_table_0': {
            'tableMeta': {
              'alignment': ['left'],
              'hasHeader': true,
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('|---|'));
      });

      test('generates table with center alignment', () {
        final data = {
          '_table_0': {
            'headers': ['Name'],
            'rows': [
              ['Test']
            ],
          }
        };
        final keyMeta = {
          '_table_0': {
            'tableMeta': {
              'alignment': ['center'],
              'hasHeader': true,
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('|:---:|'));
      });

      test('generates table with right alignment', () {
        final data = {
          '_table_0': {
            'headers': ['Amount'],
            'rows': [
              ['100']
            ],
          }
        };
        final keyMeta = {
          '_table_0': {
            'tableMeta': {
              'alignment': ['right'],
              'hasHeader': true,
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('|---:|'));
      });

      test('generates table with mixed alignments', () {
        final data = {
          '_table_0': {
            'headers': ['Left', 'Center', 'Right'],
            'rows': [
              ['A', 'B', 'C']
            ],
          }
        };
        final keyMeta = {
          '_table_0': {
            'tableMeta': {
              'alignment': ['left', 'center', 'right'],
              'hasHeader': true,
            },
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result, contains('|---|:---:|---:|'));
      });
    });

    group('whitespace preservation', () {
      test('uses LF line ending by default', () {
        final data = {'title': 'Content'};
        final keyMeta = {
          'title': {'headerLevel': 1},
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result.contains('\r\n'), isFalse);
        expect(result.contains('\n'), isTrue);
      });

      test('uses CRLF line ending when specified', () {
        final data = {'title': 'Content'};
        final keyMeta = {
          'title': {'headerLevel': 1},
          '_document': {
            'whitespace': {'lineEnding': '\r\n'},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result.contains('\r\n'), isTrue);
      });

      test('adds leading newlines when specified', () {
        final data = {'title': 'Content'};
        final keyMeta = {
          'title': {'headerLevel': 1},
          '_document': {
            'whitespace': {'leadingNewlines': 2, 'lineEnding': '\n'},
          },
        };
        final result = generator.generate(data, keyMeta: keyMeta);
        expect(result.startsWith('\n\n'), isTrue);
      });
    });

    group('frontmatter generation', () {
      test('generates frontmatter when metadata provided', () {
        final data = {'body': 'Content'};
        final metaData = {'title': 'Test', 'version': 1};
        final result = generator.generate(data, metaData: metaData);
        expect(result, contains('---'));
        expect(result, contains('title: Test'));
        expect(result, contains('version: 1'));
      });

      test('quotes strings with colons in frontmatter', () {
        final data = {'body': 'Content'};
        final metaData = {'message': 'Hello: World'};
        final result = generator.generate(data, metaData: metaData);
        expect(result, contains('message: "Hello: World"'));
      });
    });

    group('jsonToMarkdown integration', () {
      test('uses generator when keyMeta and preserveLayout are set', () {
        final data = {'title': 'Content'};
        final keyMeta = {
          'title': {'headerLevel': 2},
        };
        final result = jsonToMarkdown(data, keyMeta: keyMeta);
        expect(result, contains('## Title'));
        expect(result, contains('Content'));
      });

      test('falls back to default behavior when preserveLayout is false', () {
        final data = {'title': 'Content'};
        final keyMeta = {
          'title': {'headerLevel': 2},
        };
        final result =
            jsonToMarkdown(data, keyMeta: keyMeta, preserveLayout: false);
        // Default behavior converts keys starting at level 2
        expect(result, contains('## Title'));
      });

      test('falls back to default behavior when keyMeta is null', () {
        final data = {'section': 'Content'};
        final result = jsonToMarkdown(data);
        expect(result, contains('## Section'));
        expect(result, contains('Content'));
      });
    });
  });

  group('round-trip fidelity tests', () {
    const parser = MarkdownLayoutParser();
    const generator = MarkdownLayoutGenerator();

    test('header round-trip', () {
      const original = '## Section Title\n\nSection content';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('## Section Title'));
      expect(generated, contains('Section content'));
    });

    test('unordered list round-trip preserves marker style', () {
      const original = '* Item 1\n* Item 2';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('* Item 1'));
      expect(generated, contains('* Item 2'));
    });

    test('ordered list round-trip preserves start number', () {
      const original = '5. Fifth\n6. Sixth';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('5. Fifth'));
      expect(generated, contains('6. Sixth'));
    });

    test('code block round-trip preserves language', () {
      const original = '```typescript\nconst x: number = 1;\n```';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('```typescript'));
      expect(generated, contains('const x: number = 1;'));
    });

    test('table round-trip preserves alignment', () {
      const original =
          '| Left | Center | Right |\n|:-----|:------:|------:|\n| A | B | C |';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('| Left | Center | Right |'));
      expect(generated, contains('|---|:---:|---:|'));
      expect(generated, contains('| A | B | C |'));
    });

    test('callout round-trip preserves type', () {
      const original = '> [!IMPORTANT]\n> Critical info';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('> [!IMPORTANT]'));
      expect(generated, contains('> Critical info'));
    });

    test('divider round-trip preserves style', () {
      const original = '***';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated.trim(), '***');
    });

    test('task list round-trip preserves checked state', () {
      const original = '- [x] Done\n- [ ] Todo';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated, contains('- [x] Done'));
      expect(generated, contains('- [ ] Todo'));
    });

    test('CRLF line ending round-trip', () {
      const original = '# Title\r\nContent';
      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );
      expect(generated.contains('\r\n'), isTrue);
    });

    test('complex document round-trip', () {
      const original = '''## Features

- [x] Task done
- [ ] Task pending

## Code Example

```dart
void main() {
  print('Hello');
}
```

## Data

| Name | Value |
|------|-------|
| Key | 42 |''';

      final parseResult = parser.parse(original);
      final generated = generator.generate(
        parseResult.data,
        keyMeta: parseResult.keyMeta,
      );

      expect(generated, contains('## Features'));
      expect(generated, contains('- [x] Task done'));
      expect(generated, contains('- [ ] Task pending'));
      expect(generated, contains('```dart'));
      expect(generated, contains('void main()'));
      expect(generated, contains('| Name | Value |'));
    });
  });

  group('edge cases', () {
    const generator = MarkdownLayoutGenerator();

    test('handles null values gracefully', () {
      final data = {'title': null};
      final keyMeta = {
        'title': {'headerLevel': 2},
      };
      final result = generator.generate(data, keyMeta: keyMeta);
      expect(result, isNotNull);
    });

    test('handles empty string values', () {
      final data = {'title': ''};
      final keyMeta = {
        'title': {'headerLevel': 2},
      };
      final result = generator.generate(data, keyMeta: keyMeta);
      expect(result, contains('## Title'));
    });

    test('handles missing keyMeta gracefully', () {
      final data = {'section': 'Content'};
      final result = generator.generate(data);
      expect(result, isNotNull);
    });

    test('handles unicode content', () {
      final data = {'unicode': 'Content'};
      final keyMeta = {
        'unicode': {'headerLevel': 2},
      };
      final result = generator.generate(
        data,
        keyMeta: keyMeta,
      );
      expect(result, contains('## Unicode'));
    });

    test('handles special characters in content', () {
      final data = {'special': '<script>alert("xss")</script>'};
      final keyMeta = {
        'special': {'headerLevel': 2},
      };
      final result = generator.generate(data, keyMeta: keyMeta);
      expect(result, contains('<script>alert("xss")</script>'));
    });

    test('handles nested maps without header metadata', () {
      final data = {
        'outer': {'inner': 'value'}
      };
      final result = generator.generate(data);
      expect(result, isNotNull);
    });

    test('handles empty list', () {
      final data = {'_list_0': <String>[]};
      final keyMeta = {
        '_list_0': {
          'listMeta': {'type': 'unordered', 'marker': '-'},
        },
      };
      final result = generator.generate(data, keyMeta: keyMeta);
      expect(result, isEmpty);
    });

    test('handles table without headers', () {
      final data = {
        '_table_0': {
          'rows': [
            ['A', 'B'],
            ['C', 'D'],
          ],
        }
      };
      final keyMeta = {
        '_table_0': {
          'tableMeta': {
            'alignment': ['left', 'left'],
            'hasHeader': false,
          },
        },
      };
      final result = generator.generate(data, keyMeta: keyMeta);
      expect(result, contains('| A | B |'));
      expect(result, contains('| C | D |'));
    });
  });
}
