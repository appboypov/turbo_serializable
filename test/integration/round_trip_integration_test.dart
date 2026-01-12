import 'package:test/test.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

void main() {
  group('Round-Trip Integration Tests', () {
    group('Markdown', () {
      test('simple document round-trip', () {
        const original = '''## User Name
John Doe

## Age
30
''';
        final parsed = markdownToJson(original, preserveLayout: true)
            as LayoutAwareParseResult;
        final regenerated =
            jsonToMarkdown(parsed.data, keyMeta: parsed.keyMeta);
        expect(regenerated.contains('## User Name'), true);
        expect(regenerated.contains('John Doe'), true);
      });

      test('with frontmatter round-trip', () {
        const original = '''---
title: Test
---
## Content
Body text
''';
        final parsed = markdownToJson(original, preserveLayout: true)
            as LayoutAwareParseResult;
        final regenerated =
            jsonToMarkdown(parsed.data, keyMeta: parsed.keyMeta);
        // Frontmatter values are parsed into data, content is preserved
        expect(regenerated.contains('Content'), true);
        expect(parsed.data['title'], 'Test');
      });
    });

    group('XML', () {
      test('simple document round-trip', () {
        const original = '<user><name>John</name><age>30</age></user>';
        final parsed =
            xmlToJson(original, preserveLayout: true) as LayoutAwareParseResult;
        final regenerated = jsonToXml(parsed.data, keyMeta: parsed.keyMeta);
        expect(regenerated.contains('<name>John</name>'), true);
        expect(regenerated.contains('<age>30</age>'), true);
      });

      test('with attributes round-trip', () {
        const original =
            '<user id="123" active="true"><name>John</name></user>';
        final parsed =
            xmlToJson(original, preserveLayout: true) as LayoutAwareParseResult;
        final regenerated = jsonToXml(parsed.data, keyMeta: parsed.keyMeta);
        expect(regenerated.contains('id="123"'), true);
        expect(regenerated.contains('active="true"'), true);
      });
    });

    group('YAML', () {
      test('simple document round-trip', () {
        const original = '''name: John
age: 30
''';
        final parsed = yamlToJson(original, preserveLayout: true)
            as LayoutAwareParseResult;
        final regenerated = jsonToYaml(parsed.data, keyMeta: parsed.keyMeta);
        expect(regenerated.contains('name:'), true);
        expect(regenerated.contains('John'), true);
      });

      test('with anchors and aliases', () {
        const original = '''defaults: &defaults
  adapter: postgres
  host: localhost

development:
  database: dev
  <<: *defaults
''';
        final parsed = yamlToJson(original, preserveLayout: true)
            as LayoutAwareParseResult;
        expect(parsed.data['defaults'], isNotNull);
      });
    });

    group('JSON', () {
      test('minified round-trip', () {
        const original = '{"name":"John","age":30}';
        const parser = JsonLayoutParser();
        const generator = JsonLayoutGenerator();
        final parsed = parser.parse(original);
        final regenerated =
            generator.generate(parsed.data, keyMeta: parsed.keyMeta);
        expect(regenerated, '{"name":"John","age":30}');
      });

      test('pretty-printed round-trip', () {
        const original = '''{
  "name": "John",
  "age": 30
}''';
        const parser = JsonLayoutParser();
        const generator = JsonLayoutGenerator();
        final parsed = parser.parse(original);
        final regenerated =
            generator.generate(parsed.data, keyMeta: parsed.keyMeta);
        expect(regenerated.contains('  "name"'), true);
      });
    });

    group('backward compatibility', () {
      test('yamlToJson without preserveLayout returns Map', () {
        const yaml = 'name: John';
        final result = yamlToJson(yaml);
        expect(result, isA<Map<String, dynamic>>());
        expect(result['name'], 'John');
      });

      test('markdownToJson without preserveLayout returns Map', () {
        const markdown = '## Title\nContent';
        final result = markdownToJson(markdown);
        expect(result, isA<Map<String, dynamic>>());
      });

      test('xmlToJson without preserveLayout returns Map', () {
        const xml = '<root><name>John</name></root>';
        final result = xmlToJson(xml);
        expect(result, isA<Map<String, dynamic>>());
      });

      test('jsonToYaml without keyMeta works', () {
        final result = jsonToYaml({'name': 'John'});
        expect(result.contains('name:'), true);
      });

      test('jsonToMarkdown without keyMeta works', () {
        final result = jsonToMarkdown({'name': 'John'});
        expect(result.contains('Name'), true);
      });

      test('jsonToXml without keyMeta works', () {
        final result = jsonToXml({'name': 'John'});
        expect(result.contains('<name>John</name>'), true);
      });
    });

    group('cross-format', () {
      test('yamlToMarkdown preserves data', () {
        const yaml = '''name: John
age: 30
''';
        final markdown = yamlToMarkdown(yaml);
        expect(markdown.contains('Name'), true);
        expect(markdown.contains('John'), true);
      });

      test('xmlToYaml preserves data', () {
        const xml = '<root><name>John</name><age>30</age></root>';
        final yaml = xmlToYaml(xml);
        expect(yaml.contains('name:'), true);
        expect(yaml.contains('John'), true);
      });

      test('markdownToXml preserves data', () {
        const markdown = '## User\nJohn';
        final xml = markdownToXml(markdown);
        expect(xml.contains('John'), true);
      });
    });
  });
}
