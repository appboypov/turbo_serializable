import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

/// Integration tests that convert between all formats and save results to files.
///
/// Input files: test/integration/input/
/// Output files: test/integration/output/
///
/// Run: dart test test/integration/integration_test.dart
void main() {
  final inputDir = Directory('test/integration/input');
  final outputDir = Directory('test/integration/output');

  setUpAll(() {
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }
  });

  group('JSON conversions', () {
    late Map<String, dynamic> jsonData;

    setUpAll(() {
      final jsonFile = File('${inputDir.path}/sample.json');
      final content = jsonFile.readAsStringSync();
      jsonData = jsonDecode(content) as Map<String, dynamic>;
    });

    test('JSON → YAML', () {
      final result = jsonToYaml(jsonData);

      expect(result, isNotEmpty);
      expect(result, contains('user:'));
      expect(result, contains('name: John Doe'));
      expect(result, contains('age: 30'));
      expect(result, contains('roles:'));
      expect(result, contains('- admin'));

      File('${outputDir.path}/json_to_yaml.yaml').writeAsStringSync(result);
    });

    test('JSON → Markdown', () {
      final result = jsonToMarkdown(jsonData);

      expect(result, isNotEmpty);
      expect(result, contains('"user"'));
      expect(result, contains('"name"'));
      expect(result, contains('"John Doe"'));

      File('${outputDir.path}/json_to_markdown.md').writeAsStringSync(result);
    });

    test('JSON → Markdown with metadata', () {
      final metadata = {'title': 'User Data', 'generated': '2026-01-10'};
      final result = jsonToMarkdown(jsonData, metaData: metadata);

      expect(result, isNotEmpty);
      expect(result, contains('---'));
      expect(result, contains('title: User Data'));

      File('${outputDir.path}/json_to_markdown_with_meta.md')
          .writeAsStringSync(result);
    });

    test('JSON → XML', () {
      final result = mapToXml(jsonData);

      expect(result, isNotEmpty);
      expect(result, contains('<?xml'));
      expect(result, contains('<root>'));
      expect(result, contains('<user>'));
      expect(result, contains('<name>John Doe</name>'));

      File('${outputDir.path}/json_to_xml.xml').writeAsStringSync(result);
    });
  });

  group('YAML conversions', () {
    late String yamlContent;

    setUpAll(() {
      final yamlFile = File('${inputDir.path}/sample.yaml');
      yamlContent = yamlFile.readAsStringSync();
    });

    test('YAML → JSON', () {
      final result = yamlToJson(yamlContent);

      expect(result, isNotEmpty);
      expect(result['user'], isA<Map>());
      expect(result['user']['name'], 'Jane Smith');
      expect(result['user']['age'], 25);
      expect(result['roles'], ['viewer', 'commenter']);

      final jsonString = const JsonEncoder.withIndent('  ').convert(result);
      File('${outputDir.path}/yaml_to_json.json')
          .writeAsStringSync(jsonString);
    });

    test('YAML → Markdown', () {
      final result = yamlToMarkdown(yamlContent);

      expect(result, isNotEmpty);
      expect(result, contains('"user"'));
      expect(result, contains('"Jane Smith"'));

      File('${outputDir.path}/yaml_to_markdown.md').writeAsStringSync(result);
    });

    test('YAML → XML', () {
      final result = yamlToXml(yamlContent);

      expect(result, isNotEmpty);
      expect(result, contains('<?xml'));
      expect(result, contains('<root>'));
      expect(result, contains('<name>Jane Smith</name>'));

      File('${outputDir.path}/yaml_to_xml.xml').writeAsStringSync(result);
    });
  });

  group('Markdown conversions', () {
    late String markdownContent;

    setUpAll(() {
      final mdFile = File('${inputDir.path}/sample.md');
      markdownContent = mdFile.readAsStringSync();
    });

    test('Markdown → JSON', () {
      final result = markdownToJson(markdownContent);

      expect(result, isNotEmpty);
      expect(result['title'], 'Sample Document');
      expect(result['author'], 'Test Author');
      expect(result['tags'], ['example', 'test']);
      expect(result['body'], isA<Map>());
      expect(result['body']['content'], 'This is the main content');
      expect(result['body']['version'], 1);

      final jsonString = const JsonEncoder.withIndent('  ').convert(result);
      File('${outputDir.path}/markdown_to_json.json')
          .writeAsStringSync(jsonString);
    });

    test('Markdown → YAML', () {
      final result = markdownToYaml(markdownContent);

      expect(result, isNotEmpty);
      expect(result, contains('title: Sample Document'));
      expect(result, contains('author: Test Author'));
      expect(result, contains('body:'));

      File('${outputDir.path}/markdown_to_yaml.yaml')
          .writeAsStringSync(result);
    });

    test('Markdown → XML', () {
      final result = markdownToXml(markdownContent);

      expect(result, isNotEmpty);
      expect(result, contains('<?xml'));
      expect(result, contains('<root>'));
      expect(result, contains('<title>Sample Document</title>'));

      File('${outputDir.path}/markdown_to_xml.xml').writeAsStringSync(result);
    });
  });

  group('XML conversions', () {
    late String xmlContent;

    setUpAll(() {
      final xmlFile = File('${inputDir.path}/sample.xml');
      xmlContent = xmlFile.readAsStringSync();
    });

    test('XML → JSON', () {
      final result = xmlToJson(xmlContent);

      expect(result, isNotEmpty);
      expect(result['product'], isA<Map>());
      expect(result['product']['name'], 'Widget');
      expect(result['product']['price'], 29.99);
      expect(result['product']['inStock'], true);
      expect(result['category'], 'Electronics');

      final jsonString = const JsonEncoder.withIndent('  ').convert(result);
      File('${outputDir.path}/xml_to_json.json').writeAsStringSync(jsonString);
    });

    test('XML → YAML', () {
      final result = xmlToYaml(xmlContent);

      expect(result, isNotEmpty);
      expect(result, contains('product:'));
      expect(result, contains('name: Widget'));
      expect(result, contains('price: 29.99'));
      expect(result, contains('category: Electronics'));

      File('${outputDir.path}/xml_to_yaml.yaml').writeAsStringSync(result);
    });

    test('XML → Markdown', () {
      final result = xmlToMarkdown(xmlContent);

      expect(result, isNotEmpty);
      expect(result, contains('"product"'));
      expect(result, contains('"Widget"'));

      File('${outputDir.path}/xml_to_markdown.md').writeAsStringSync(result);
    });
  });

  group('Round-trip conversions', () {
    test('JSON → YAML → JSON preserves data', () {
      final jsonFile = File('${inputDir.path}/sample.json');
      final originalJson =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

      final yaml = jsonToYaml(originalJson);
      final roundTrippedJson = yamlToJson(yaml);

      expect(roundTrippedJson['user']['name'], originalJson['user']['name']);
      expect(roundTrippedJson['user']['age'], originalJson['user']['age']);
      expect(roundTrippedJson['roles'], originalJson['roles']);
    });

    test('JSON → XML → JSON preserves structure', () {
      final jsonFile = File('${inputDir.path}/sample.json');
      final originalJson =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

      final xml = mapToXml(originalJson);
      final roundTrippedJson = xmlToJson(xml);

      expect(roundTrippedJson['user']['name'], originalJson['user']['name']);
      expect(roundTrippedJson['user']['age'], originalJson['user']['age']);
      expect(roundTrippedJson['settings']['theme'],
          originalJson['settings']['theme']);
    });

    test('YAML → XML → YAML preserves data', () {
      final yamlFile = File('${inputDir.path}/sample.yaml');
      final originalYaml = yamlFile.readAsStringSync();
      final originalJson = yamlToJson(originalYaml);

      final xml = yamlToXml(originalYaml);
      final roundTrippedJson = xmlToJson(xml);

      expect(roundTrippedJson['user']['name'], originalJson['user']['name']);
      expect(roundTrippedJson['settings']['theme'],
          originalJson['settings']['theme']);
    });
  });
}
