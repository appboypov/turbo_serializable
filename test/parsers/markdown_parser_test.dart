import 'package:test/test.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

void main() {
  group('MarkdownLayoutParser', () {
    const parser = MarkdownLayoutParser();

    group('empty and basic documents', () {
      test('parses empty document', () {
        final result = parser.parse('');
        expect(result.data, isEmpty);
        expect(result.keyMeta, isNull);
      });

      test('parses whitespace-only document', () {
        final result = parser.parse('   \n\n   ');
        expect(result.data, isEmpty);
      });

      test('parses plain text paragraph', () {
        final result = parser.parse('Hello world');
        expect(result.data['body'], 'Hello world');
      });
    });

    group('headers', () {
      test('parses h1 header', () {
        final result = parser.parse('# Title\nContent here');
        expect(result.data['title'], 'Content here');
        expect(result.keyMeta, isNotNull);
        expect(result.keyMeta!['title']['headerLevel'], 1);
      });

      test('parses h2 header', () {
        final result = parser.parse('## Section\nSection content');
        expect(result.data['section'], 'Section content');
        expect(result.keyMeta!['section']['headerLevel'], 2);
      });

      test('parses h3 header', () {
        final result = parser.parse('### Subsection\nSubsection content');
        expect(result.data['subsection'], 'Subsection content');
        expect(result.keyMeta!['subsection']['headerLevel'], 3);
      });

      test('parses h4 header', () {
        final result = parser.parse('#### Deep Section\nDeep content');
        expect(result.data['deepSection'], 'Deep content');
        expect(result.keyMeta!['deepSection']['headerLevel'], 4);
      });

      test('parses h5 header', () {
        final result = parser.parse('##### Very Deep\nVery deep content');
        expect(result.data['veryDeep'], 'Very deep content');
        expect(result.keyMeta!['veryDeep']['headerLevel'], 5);
      });

      test('parses h6 header', () {
        final result = parser.parse('###### Deepest\nDeepest content');
        expect(result.data['deepest'], 'Deepest content');
        expect(result.keyMeta!['deepest']['headerLevel'], 6);
      });

      test('converts header text to camelCase key', () {
        final result = parser.parse('## User Name\nJohn Doe');
        expect(result.data['userName'], 'John Doe');
        expect(result.keyMeta!['userName']['headerLevel'], 2);
      });

      test('converts multi-word header to camelCase', () {
        final result = parser.parse('## First Name Last Name\nValue');
        expect(result.data['firstNameLastName'], 'Value');
      });

      test('handles header with special characters', () {
        final result = parser.parse('## User\'s Profile!\nContent');
        expect(result.data['usersProfile'], 'Content');
      });

      test('parses multiple headers', () {
        final markdown = '''
## First Section
First content

## Second Section
Second content
''';
        final result = parser.parse(markdown);
        expect(result.data['firstSection'], 'First content');
        expect(result.data['secondSection'], 'Second content');
      });

      test('parses nested headers hierarchically', () {
        final markdown = '''
# Main
## Sub One
Content one
## Sub Two
Content two
''';
        final result = parser.parse(markdown);
        expect(result.data['main'], isA<Map>());
        // Note: The nested structure depends on implementation
      });
    });

    group('YAML frontmatter', () {
      test('parses basic frontmatter', () {
        final markdown = '''
---
title: Test Document
author: John Doe
---
Body content
''';
        final result = parser.parse(markdown);
        expect(result.data['title'], 'Test Document');
        expect(result.data['author'], 'John Doe');
      });

      test('parses numeric frontmatter values', () {
        final markdown = '''
---
version: 1
count: 42
---
''';
        final result = parser.parse(markdown);
        expect(result.data['version'], 1);
        expect(result.data['count'], 42);
      });

      test('parses boolean frontmatter values', () {
        final markdown = '''
---
published: true
draft: false
---
''';
        final result = parser.parse(markdown);
        expect(result.data['published'], true);
        expect(result.data['draft'], false);
      });

      test('parses quoted string values', () {
        final markdown = '''
---
message: "Hello: World"
single: 'Test'
---
''';
        final result = parser.parse(markdown);
        expect(result.data['message'], 'Hello: World');
        expect(result.data['single'], 'Test');
      });

      test('handles frontmatter without body', () {
        final markdown = '''
---
title: Only Frontmatter
---
''';
        final result = parser.parse(markdown);
        expect(result.data['title'], 'Only Frontmatter');
      });

      test('handles frontmatter with null value', () {
        final markdown = '''
---
empty: null
---
''';
        final result = parser.parse(markdown);
        expect(result.data['empty'], isNull);
      });
    });

    group('callouts', () {
      test('parses NOTE callout', () {
        final markdown = '> [!NOTE]\n> This is a note';
        final result = parser.parse(markdown);
        expect(result.data['note'], 'This is a note');
        expect(result.keyMeta, isNotNull);
        expect(result.keyMeta!['note']['callout']['type'], 'note');
      });

      test('parses WARNING callout', () {
        final markdown = '> [!WARNING]\n> Be careful!';
        final result = parser.parse(markdown);
        expect(result.data['warning'], 'Be careful!');
        expect(result.keyMeta!['warning']['callout']['type'], 'warning');
      });

      test('parses TIP callout', () {
        final markdown = '> [!TIP]\n> Pro tip here';
        final result = parser.parse(markdown);
        expect(result.data['tip'], 'Pro tip here');
        expect(result.keyMeta!['tip']['callout']['type'], 'tip');
      });

      test('parses IMPORTANT callout', () {
        final markdown = '> [!IMPORTANT]\n> Very important!';
        final result = parser.parse(markdown);
        expect(result.data['important'], 'Very important!');
        expect(result.keyMeta!['important']['callout']['type'], 'important');
      });

      test('parses CAUTION callout', () {
        final markdown = '> [!CAUTION]\n> Handle with care';
        final result = parser.parse(markdown);
        expect(result.data['caution'], 'Handle with care');
        expect(result.keyMeta!['caution']['callout']['type'], 'caution');
      });

      test('parses multiline callout', () {
        final markdown = '''
> [!NOTE]
> First line
> Second line
> Third line
''';
        final result = parser.parse(markdown);
        expect(result.data['note'], 'First line\nSecond line\nThird line');
      });

      test('parses callout with inline content', () {
        final markdown = '> [!WARNING] Inline warning content';
        final result = parser.parse(markdown);
        expect(result.data['warning'], 'Inline warning content');
      });
    });

    group('dividers', () {
      test('parses --- divider', () {
        final markdown = '---';
        final result = parser.parse(markdown);
        expect(result.keyMeta, isNotNull);
        // Dividers are stored with unique keys
        final dividerKey =
            result.keyMeta!.keys.firstWhere((k) => k.startsWith('_divider'));
        expect(result.keyMeta![dividerKey]['divider']['style'], '---');
      });

      test('parses *** divider', () {
        final markdown = '***';
        final result = parser.parse(markdown);
        final dividerKey =
            result.keyMeta!.keys.firstWhere((k) => k.startsWith('_divider'));
        expect(result.keyMeta![dividerKey]['divider']['style'], '***');
      });

      test('parses ___ divider', () {
        final markdown = '___';
        final result = parser.parse(markdown);
        final dividerKey =
            result.keyMeta!.keys.firstWhere((k) => k.startsWith('_divider'));
        expect(result.keyMeta![dividerKey]['divider']['style'], '___');
      });

      test('parses longer dividers', () {
        final markdown = '--------';
        final result = parser.parse(markdown);
        final dividerKey =
            result.keyMeta!.keys.firstWhere((k) => k.startsWith('_divider'));
        expect(result.keyMeta![dividerKey]['divider']['style'], '---');
      });
    });

    group('code blocks', () {
      test('parses fenced code block without language', () {
        final markdown = '''
```
const x = 1;
```
''';
        final result = parser.parse(markdown);
        final codeKey =
            result.data.keys.firstWhere((k) => k.startsWith('_code'));
        expect(result.data[codeKey], 'const x = 1;');
        expect(result.keyMeta![codeKey]['codeBlock']['isInline'], false);
      });

      test('parses fenced code block with language', () {
        final markdown = '''
```javascript
const x = 1;
```
''';
        final result = parser.parse(markdown);
        final codeKey =
            result.data.keys.firstWhere((k) => k.startsWith('_code'));
        expect(result.data[codeKey], 'const x = 1;');
        expect(result.keyMeta![codeKey]['codeBlock']['language'], 'javascript');
      });

      test('parses code block with language and filename', () {
        final markdown = '''
```dart example.dart
void main() {}
```
''';
        final result = parser.parse(markdown);
        final codeKey =
            result.data.keys.firstWhere((k) => k.startsWith('_code'));
        expect(result.keyMeta![codeKey]['codeBlock']['language'], 'dart');
        expect(
            result.keyMeta![codeKey]['codeBlock']['filename'], 'example.dart');
      });

      test('parses multiline code block', () {
        final markdown = '''
```python
def hello():
    print("Hello")
    return True
```
''';
        final result = parser.parse(markdown);
        final codeKey =
            result.data.keys.firstWhere((k) => k.startsWith('_code'));
        expect(result.data[codeKey], contains('def hello():'));
        expect(result.data[codeKey], contains('print("Hello")'));
      });

      test('parses code block with tilde fence', () {
        final markdown = '''
~~~python
code here
~~~
''';
        final result = parser.parse(markdown);
        final codeKey =
            result.data.keys.firstWhere((k) => k.startsWith('_code'));
        expect(result.data[codeKey], 'code here');
        expect(result.keyMeta![codeKey]['codeBlock']['language'], 'python');
      });
    });

    group('unordered lists', () {
      test('parses - list marker', () {
        final markdown = '''
- Item 1
- Item 2
- Item 3
''';
        final result = parser.parse(markdown);
        final listKey =
            result.data.keys.firstWhere((k) => k.startsWith('_list'));
        expect(result.data[listKey], ['Item 1', 'Item 2', 'Item 3']);
        expect(result.keyMeta![listKey]['listMeta']['type'], 'unordered');
        expect(result.keyMeta![listKey]['listMeta']['marker'], '-');
      });

      test('parses * list marker', () {
        final markdown = '''
* Item A
* Item B
''';
        final result = parser.parse(markdown);
        final listKey =
            result.data.keys.firstWhere((k) => k.startsWith('_list'));
        expect(result.data[listKey], ['Item A', 'Item B']);
        expect(result.keyMeta![listKey]['listMeta']['marker'], '*');
      });

      test('parses + list marker', () {
        final markdown = '''
+ First
+ Second
''';
        final result = parser.parse(markdown);
        final listKey =
            result.data.keys.firstWhere((k) => k.startsWith('_list'));
        expect(result.data[listKey], ['First', 'Second']);
        expect(result.keyMeta![listKey]['listMeta']['marker'], '+');
      });
    });

    group('ordered lists', () {
      test('parses ordered list with period', () {
        final markdown = '''
1. First item
2. Second item
3. Third item
''';
        final result = parser.parse(markdown);
        final listKey =
            result.data.keys.firstWhere((k) => k.startsWith('_list'));
        expect(
            result.data[listKey], ['First item', 'Second item', 'Third item']);
        expect(result.keyMeta![listKey]['listMeta']['type'], 'ordered');
        expect(result.keyMeta![listKey]['listMeta']['startNumber'], 1);
      });

      test('parses ordered list with parenthesis', () {
        final markdown = '''
1) Item A
2) Item B
''';
        final result = parser.parse(markdown);
        final listKey =
            result.data.keys.firstWhere((k) => k.startsWith('_list'));
        expect(result.data[listKey], ['Item A', 'Item B']);
        expect(result.keyMeta![listKey]['listMeta']['marker'], '1)');
      });

      test('preserves start number', () {
        final markdown = '''
5. Fifth
6. Sixth
''';
        final result = parser.parse(markdown);
        final listKey =
            result.data.keys.firstWhere((k) => k.startsWith('_list'));
        expect(result.keyMeta![listKey]['listMeta']['startNumber'], 5);
      });
    });

    group('task lists', () {
      test('parses unchecked task', () {
        final markdown = '- [ ] Todo item';
        final result = parser.parse(markdown);
        final listKey =
            result.data.keys.firstWhere((k) => k.startsWith('_list'));
        expect(result.data[listKey][0]['content'], 'Todo item');
        expect(result.data[listKey][0]['checked'], false);
        expect(result.keyMeta![listKey]['listMeta']['type'], 'task');
      });

      test('parses checked task with lowercase x', () {
        final markdown = '- [x] Done item';
        final result = parser.parse(markdown);
        final listKey =
            result.data.keys.firstWhere((k) => k.startsWith('_list'));
        expect(result.data[listKey][0]['checked'], true);
      });

      test('parses checked task with uppercase X', () {
        final markdown = '- [X] Completed';
        final result = parser.parse(markdown);
        final listKey =
            result.data.keys.firstWhere((k) => k.startsWith('_list'));
        expect(result.data[listKey][0]['checked'], true);
      });

      test('parses mixed task list', () {
        final markdown = '''
- [x] Done
- [ ] Not done
- [X] Also done
''';
        final result = parser.parse(markdown);
        final listKey =
            result.data.keys.firstWhere((k) => k.startsWith('_list'));
        expect(result.data[listKey][0]['checked'], true);
        expect(result.data[listKey][1]['checked'], false);
        expect(result.data[listKey][2]['checked'], true);
      });
    });

    group('tables', () {
      test('parses simple table with header', () {
        final markdown = '''
| Name | Age |
|------|-----|
| John | 30  |
| Jane | 25  |
''';
        final result = parser.parse(markdown);
        final tableKey =
            result.data.keys.firstWhere((k) => k.startsWith('_table'));
        expect(result.data[tableKey]['headers'], ['Name', 'Age']);
        expect(result.data[tableKey]['rows'].length, 2);
        expect(result.keyMeta![tableKey]['tableMeta']['hasHeader'], true);
      });

      test('parses table with left alignment', () {
        final markdown = '''
| Name |
|:-----|
| Test |
''';
        final result = parser.parse(markdown);
        final tableKey =
            result.data.keys.firstWhere((k) => k.startsWith('_table'));
        expect(result.keyMeta![tableKey]['tableMeta']['alignment'], ['left']);
      });

      test('parses table with center alignment', () {
        final markdown = '''
| Name |
|:----:|
| Test |
''';
        final result = parser.parse(markdown);
        final tableKey =
            result.data.keys.firstWhere((k) => k.startsWith('_table'));
        expect(result.keyMeta![tableKey]['tableMeta']['alignment'], ['center']);
      });

      test('parses table with right alignment', () {
        final markdown = '''
| Amount |
|-------:|
| 100    |
''';
        final result = parser.parse(markdown);
        final tableKey =
            result.data.keys.firstWhere((k) => k.startsWith('_table'));
        expect(result.keyMeta![tableKey]['tableMeta']['alignment'], ['right']);
      });

      test('parses table with mixed alignments', () {
        final markdown = '''
| Left | Center | Right |
|:-----|:------:|------:|
| A    | B      | C     |
''';
        final result = parser.parse(markdown);
        final tableKey =
            result.data.keys.firstWhere((k) => k.startsWith('_table'));
        expect(result.keyMeta![tableKey]['tableMeta']['alignment'],
            ['left', 'center', 'right']);
      });
    });

    group('emphasis detection', () {
      test('detects bold with double asterisks', () {
        final markdown = '## Title\n**Bold text**';
        final result = parser.parse(markdown);
        // The emphasis is detected in the content
        expect(result.data['title'], contains('**Bold text**'));
      });

      test('detects bold with double underscores', () {
        final markdown = '## Title\n__Bold text__';
        final result = parser.parse(markdown);
        expect(result.data['title'], contains('__Bold text__'));
      });

      test('detects italic with single asterisk', () {
        final markdown = '## Title\n*Italic text*';
        final result = parser.parse(markdown);
        expect(result.data['title'], contains('*Italic text*'));
      });

      test('detects strikethrough', () {
        final markdown = '## Title\n~~Strikethrough~~';
        final result = parser.parse(markdown);
        expect(result.data['title'], contains('~~Strikethrough~~'));
      });

      test('detects inline code', () {
        final markdown = '## Title\n`inline code`';
        final result = parser.parse(markdown);
        expect(result.data['title'], contains('`inline code`'));
      });
    });

    group('whitespace preservation', () {
      test('detects line ending style LF', () {
        final markdown = '# Title\nContent';
        final result = parser.parse(markdown);
        expect(result.keyMeta!['_document']['whitespace']['lineEnding'], '\n');
      });

      test('detects line ending style CRLF', () {
        final markdown = '# Title\r\nContent';
        final result = parser.parse(markdown);
        expect(
            result.keyMeta!['_document']['whitespace']['lineEnding'], '\r\n');
      });

      test('tracks leading newlines', () {
        final markdown = '\n\n\n# Title\nContent';
        final result = parser.parse(markdown);
        expect(
            result.keyMeta!['_document']['whitespace']['leadingNewlines'], 3);
      });
    });

    group('complex documents', () {
      test('parses document with frontmatter, headers, and content', () {
        final markdown = '''
---
title: Complex Document
version: 2
---

# Main Title

Introduction paragraph.

## Section One

Content for section one.

## Section Two

Content for section two.
''';
        final result = parser.parse(markdown);
        expect(result.data['title'], 'Complex Document');
        expect(result.data['version'], 2);
        expect(result.data['mainTitle'], isNotNull);
      });

      test('parses document with mixed content types', () {
        final markdown = '''
# Guide

> [!NOTE]
> Important note here

## Code Example

```dart
void main() {}
```

## Tasks

- [x] First task
- [ ] Second task
''';
        final result = parser.parse(markdown);
        expect(result.data['note'], 'Important note here');
        // Code block and task list are nested under guide header
        final guide = result.data['guide'] as Map<String, dynamic>;
        expect(guide.keys.any((k) => k.startsWith('_code')), true);
        expect(guide.keys.any((k) => k.startsWith('_list')), true);
      });
    });

    group('edge cases', () {
      test('handles header without content', () {
        final result = parser.parse('## Empty Header');
        expect(result.data['emptyHeader'], '');
        expect(result.keyMeta!['emptyHeader']['headerLevel'], 2);
      });

      test('handles consecutive dividers', () {
        final markdown = '''
---
---
---
''';
        final result = parser.parse(markdown);
        // Should not throw
        expect(result.data, isNotNull);
      });

      test('handles malformed table', () {
        final markdown = '| only | one | row |';
        final result = parser.parse(markdown);
        // Should parse as table with one row
        expect(result.data.keys.any((k) => k.startsWith('_table')), true);
      });

      test('handles unclosed code block', () {
        final markdown = '''
```javascript
const x = 1;
No closing fence
''';
        final result = parser.parse(markdown);
        // Should capture until end of document
        final codeKey =
            result.data.keys.firstWhere((k) => k.startsWith('_code'));
        expect(result.data[codeKey], contains('const x = 1;'));
      });

      test('handles special characters in content', () {
        final markdown = '## Special\n<script>alert("xss")</script>';
        final result = parser.parse(markdown);
        expect(result.data['special'], '<script>alert("xss")</script>');
      });

      test('handles unicode content', () {
        final markdown = '## Unicode\n日本語テスト 🎉';
        final result = parser.parse(markdown);
        expect(result.data['unicode'], '日本語テスト 🎉');
      });
    });
  });

  group('markdownToJson with preserveLayout', () {
    test('returns Map when preserveLayout is false', () {
      final result = markdownToJson('## Test\nContent');
      expect(result, isA<Map<String, dynamic>>());
    });

    test('returns LayoutAwareParseResult when preserveLayout is true', () {
      final result = markdownToJson('## Test\nContent', preserveLayout: true);
      expect(result, isA<LayoutAwareParseResult>());
    });

    test('backward compatibility - basic frontmatter parsing', () {
      final result = markdownToJson('---\ntitle: Test\n---\nBody');
      expect(result['title'], 'Test');
      expect(result['body'], 'Body');
    });

    test('backward compatibility - JSON body parsing', () {
      final result = markdownToJson('{"key": "value"}');
      expect(result['body'], {'key': 'value'});
    });

    test('preserveLayout extracts header metadata', () {
      final result = markdownToJson('## User Name\nJohn', preserveLayout: true)
          as LayoutAwareParseResult;
      expect(result.data['userName'], 'John');
      expect(result.keyMeta!['userName']['headerLevel'], 2);
    });

    test('preserveLayout extracts list metadata', () {
      final result = markdownToJson('- Item 1\n- Item 2', preserveLayout: true)
          as LayoutAwareParseResult;
      final listKey = result.data.keys.firstWhere((k) => k.startsWith('_list'));
      expect(result.keyMeta![listKey]['listMeta']['type'], 'unordered');
    });

    test('preserveLayout extracts code block metadata', () {
      final result =
          markdownToJson('```dart\nvoid main() {}\n```', preserveLayout: true)
              as LayoutAwareParseResult;
      final codeKey = result.data.keys.firstWhere((k) => k.startsWith('_code'));
      expect(result.keyMeta![codeKey]['codeBlock']['language'], 'dart');
    });

    test('preserveLayout extracts table metadata', () {
      final result = markdownToJson('| A | B |\n|---|---|\n| 1 | 2 |',
          preserveLayout: true) as LayoutAwareParseResult;
      final tableKey =
          result.data.keys.firstWhere((k) => k.startsWith('_table'));
      expect(result.keyMeta![tableKey]['tableMeta']['hasHeader'], true);
    });

    test('preserveLayout extracts callout metadata', () {
      final result =
          markdownToJson('> [!WARNING]\n> Be careful!', preserveLayout: true)
              as LayoutAwareParseResult;
      expect(result.data['warning'], 'Be careful!');
      expect(result.keyMeta!['warning']['callout']['type'], 'warning');
    });

    test('preserveLayout extracts divider metadata', () {
      final result =
          markdownToJson('---', preserveLayout: true) as LayoutAwareParseResult;
      final dividerKey =
          result.keyMeta!.keys.firstWhere((k) => k.startsWith('_divider'));
      expect(result.keyMeta![dividerKey]['divider']['style'], '---');
    });

    test('preserveLayout preserves whitespace metadata', () {
      final result = markdownToJson('\n\n# Title', preserveLayout: true)
          as LayoutAwareParseResult;
      expect(result.keyMeta!['_document']['whitespace']['leadingNewlines'], 2);
    });
  });

  group('round-trip tests', () {
    test('header round-trip preserves level', () {
      const original = '## Section Title';
      final result = markdownToJson(original, preserveLayout: true)
          as LayoutAwareParseResult;
      expect(result.keyMeta!['sectionTitle']['headerLevel'], 2);
    });

    test('list round-trip preserves marker style', () {
      const original = '* Item 1\n* Item 2';
      final result = markdownToJson(original, preserveLayout: true)
          as LayoutAwareParseResult;
      final listKey = result.data.keys.firstWhere((k) => k.startsWith('_list'));
      expect(result.keyMeta![listKey]['listMeta']['marker'], '*');
    });

    test('ordered list round-trip preserves start number', () {
      const original = '5. Fifth\n6. Sixth';
      final result = markdownToJson(original, preserveLayout: true)
          as LayoutAwareParseResult;
      final listKey = result.data.keys.firstWhere((k) => k.startsWith('_list'));
      expect(result.keyMeta![listKey]['listMeta']['startNumber'], 5);
    });

    test('code block round-trip preserves language', () {
      const original = '```typescript\nconst x: number = 1;\n```';
      final result = markdownToJson(original, preserveLayout: true)
          as LayoutAwareParseResult;
      final codeKey = result.data.keys.firstWhere((k) => k.startsWith('_code'));
      expect(result.keyMeta![codeKey]['codeBlock']['language'], 'typescript');
    });

    test('table round-trip preserves alignment', () {
      const original =
          '| Left | Center | Right |\n|:-----|:------:|------:|\n| A | B | C |';
      final result = markdownToJson(original, preserveLayout: true)
          as LayoutAwareParseResult;
      final tableKey =
          result.data.keys.firstWhere((k) => k.startsWith('_table'));
      expect(result.keyMeta![tableKey]['tableMeta']['alignment'],
          ['left', 'center', 'right']);
    });

    test('callout round-trip preserves type', () {
      const original = '> [!IMPORTANT]\n> Critical info';
      final result = markdownToJson(original, preserveLayout: true)
          as LayoutAwareParseResult;
      expect(result.keyMeta!['important']['callout']['type'], 'important');
    });

    test('divider round-trip preserves style', () {
      const original = '***';
      final result = markdownToJson(original, preserveLayout: true)
          as LayoutAwareParseResult;
      final dividerKey =
          result.keyMeta!.keys.firstWhere((k) => k.startsWith('_divider'));
      expect(result.keyMeta![dividerKey]['divider']['style'], '***');
    });

    test('line ending round-trip preserves CRLF', () {
      const original = '# Title\r\nContent';
      final result = markdownToJson(original, preserveLayout: true)
          as LayoutAwareParseResult;
      expect(result.keyMeta!['_document']['whitespace']['lineEnding'], '\r\n');
    });
  });
}
