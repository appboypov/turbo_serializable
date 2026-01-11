import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

/// Integration tests that convert between all formats and save results to files.
///
/// Input files: test/integration/input/{json,yaml,xml,markdown}/
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

  group('JSON parsing', () {
    test('parses basic camelCase JSON', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final content = jsonFile.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;

      expect(data['firstName'], 'John');
      expect(data['lastName'], 'Doe');
      expect(data['age'], 30);
      expect(data['active'], true);
    });

    test('parses snake_case JSON', () {
      final jsonFile = File('${inputDir.path}/json/snake_case.json');
      final content = jsonFile.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;

      expect(data['first_name'], 'John');
      expect(data['last_name'], 'Doe');
      expect(data['user_age'], 30);
      expect(data['is_active'], true);
    });

    test('parses deep nesting (6 levels)', () {
      final jsonFile = File('${inputDir.path}/json/deep_nesting.json');
      final content = jsonFile.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;

      expect(data['level1']['level2']['level3']['level4']['level5']['level6'],
          'deep value');
    });

    test('parses edge values', () {
      final jsonFile = File('${inputDir.path}/json/edge_values.json');
      final content = jsonFile.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;

      expect(data['nullValue'], isNull);
      expect(data['emptyString'], '');
      expect(data['emptyArray'], isEmpty);
      expect(data['emptyObject'], isEmpty);
      expect(data['unicode'], '日本語 中文 العربية');
      expect(data['emoji'], '👍🎉🚀');
      expect(data['scientificNotation'], 1.23e10);
      expect(data['negativeNumber'], -999.99);
      expect(data['zero'], 0);
      expect(data['largeNumber'], 9999999999999);
    });

    test('parses arrays', () {
      final jsonFile = File('${inputDir.path}/json/arrays.json');
      final content = jsonFile.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;

      expect(data['primitiveArray'], ['a', 'b', 'c']);
      expect(data['numberArray'], [1, 2, 3, 4.5]);
      expect(data['booleanArray'], [true, false, true]);
      expect(data['objectArray'], hasLength(2));
      expect(data['mixedArray'], hasLength(5));
      expect(data['nestedArray'], hasLength(3));
      expect(data['emptyArray'], isEmpty);
    });
  });

  group('YAML parsing', () {
    test('parses basic YAML', () {
      final yamlFile = File('${inputDir.path}/yaml/basic.yaml');
      final content = yamlFile.readAsStringSync();
      final data = yamlToJson(content);

      expect(data['firstName'], 'John');
      expect(data['lastName'], 'Doe');
      expect(data['age'], 30);
      expect(data['active'], true);
    });

    test('parses multiline strings', () {
      final yamlFile = File('${inputDir.path}/yaml/multiline.yaml');
      final content = yamlFile.readAsStringSync();
      final data = yamlToJson(content);

      expect(data['literalBlock'], contains('Line 1'));
      expect(data['literalBlock'], contains('Line 2'));
      expect(data['foldedBlock'], isNotEmpty);
      expect(data['preserveNewlines'], isNotEmpty);
      expect(data['stripNewlines'], isNotEmpty);
    });

    test('parses boolean variants', () {
      final yamlFile = File('${inputDir.path}/yaml/boolean_variants.yaml');
      final content = yamlFile.readAsStringSync();
      final data = yamlToJson(content);

      // YAML 1.2 only recognizes true/false as booleans
      // yes/no/on/off are treated as strings
      expect(data['bool1'], true);
      expect(data['bool2'], false);
      expect(data['bool3'], 'yes');
      expect(data['bool4'], 'no');
      expect(data['bool5'], 'on');
      expect(data['bool6'], 'off');
      expect(data['bool7'], true);
      expect(data['bool8'], false);
      expect(data['quotedTrue'], 'true');
      expect(data['quotedYes'], 'yes');
    });

    test('parses edge values with anchors and aliases', () {
      final yamlFile = File('${inputDir.path}/yaml/edge_values.yaml');
      final content = yamlFile.readAsStringSync();
      final data = yamlToJson(content);

      expect(data['anchor']['shared'], 'value');
      expect(data['alias']['shared'], 'value');
      expect(data['colonInValue'], 'key: value');
      expect(data['hashInValue'], 'use #hashtag');
      expect(data['quotedNumber'], '123');
      expect(data['unquotedNumber'], 123);
    });
  });

  group('XML parsing', () {
    test('parses XML without declaration', () {
      final xmlFile = File('${inputDir.path}/xml/basic.xml');
      final content = xmlFile.readAsStringSync();
      final data = xmlToJson(content);

      expect(data['firstName'], 'John');
      expect(data['lastName'], 'Doe');
      expect(data['age'], 30);
      expect(data['active'], true);
    });

    test('parses XML with declaration', () {
      final xmlFile = File('${inputDir.path}/xml/with_declaration.xml');
      final content = xmlFile.readAsStringSync();
      final data = xmlToJson(content);

      expect(data['item'], 'value');
      expect(data['count'], 42);
      expect(data['enabled'], true);
    });

    test('parses PascalCase XML', () {
      final xmlFile = File('${inputDir.path}/xml/pascal_case.xml');
      final content = xmlFile.readAsStringSync();
      final data = xmlToJson(content);

      expect(data['FirstName'], 'John');
      expect(data['LastName'], 'Doe');
      expect(data['UserSettings']['Theme'], 'dark');
      expect(data['UserSettings']['Language'], 'en');
    });

    test('parses XML with attributes (ignores attributes)', () {
      // Note: The XML parser ignores attributes and only parses element content
      // Self-closing elements with only attributes are skipped
      final xmlFile = File('${inputDir.path}/xml/attributes.xml');
      final content = xmlFile.readAsStringSync();
      final data = xmlToJson(content);

      // user has child elements so it's parsed
      expect(data['user'], isNotNull);
      expect(data['user']['name'], 'John');
      // item is self-closing with only attributes - skipped
      expect(data.containsKey('item'), false);
    });

    test('parses mixed content', () {
      final xmlFile = File('${inputDir.path}/xml/mixed_content.xml');
      final content = xmlFile.readAsStringSync();
      final data = xmlToJson(content);

      expect(data['paragraph'], isNotNull);
      expect(data['note'], isNotNull);
    });
  });

  group('Markdown parsing', () {
    test('parses frontmatter with JSON body', () {
      final mdFile = File('${inputDir.path}/markdown/frontmatter_json.md');
      final content = mdFile.readAsStringSync();
      final data = markdownToJson(content);

      expect(data['title'], 'JSON Body Test');
      expect(data['version'], 1);
      expect(data['body'], isA<Map>());
      expect(data['body']['key'], 'value');
      expect(data['body']['nested']['inner'], 'data');
    });

    test('parses frontmatter with plain text body', () {
      final mdFile = File('${inputDir.path}/markdown/frontmatter_text.md');
      final content = mdFile.readAsStringSync();
      final data = markdownToJson(content);

      expect(data['title'], 'Plain Text Body');
      expect(data['author'], 'Test');
      expect(data['body'], contains('plain text content'));
    });

    test('parses header-based format as body string', () {
      // Note: markdownToJson doesn't parse markdown headers back to structured data
      // It only extracts YAML frontmatter. Headers are treated as body content.
      final mdFile = File('${inputDir.path}/markdown/headers_only.md');
      final content = mdFile.readAsStringSync();
      final data = markdownToJson(content);

      // Without frontmatter, the whole content becomes the body
      expect(data['body'], isA<String>());
      expect(data['body'], contains('## First Name'));
      expect(data['body'], contains('John'));
    });

    test('parses rich content with tables and code blocks', () {
      final mdFile = File('${inputDir.path}/markdown/rich_content.md');
      final content = mdFile.readAsStringSync();
      final data = markdownToJson(content);

      expect(data['title'], 'Rich Markdown');
      expect(data['body'], contains('bold'));
    });

    test('parses edge cases with emoji and special chars', () {
      final mdFile = File('${inputDir.path}/markdown/edge_cases.md');
      final content = mdFile.readAsStringSync();
      final data = markdownToJson(content);

      expect(data['emoji'], '👍');
      expect(data['special'], contains('quotes'));
    });
  });

  group('JSON → YAML conversion', () {
    test('converts basic JSON to YAML', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final result = jsonToYaml(data);

      expect(result, contains('firstName: John'));
      expect(result, contains('lastName: Doe'));
      expect(result, contains('age: 30'));
      expect(result, contains('active: true'));

      File('${outputDir.path}/json_to_yaml.yaml').writeAsStringSync(result);
    });

    test('converts snake_case keys to YAML', () {
      final jsonFile = File('${inputDir.path}/json/snake_case.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final result = jsonToYaml(data);

      expect(result, contains('first_name: John'));
      expect(result, contains('user_age: 30'));

      File('${outputDir.path}/snake_case_to_yaml.yaml')
          .writeAsStringSync(result);
    });

    test('preserves edge values in YAML', () {
      final jsonFile = File('${inputDir.path}/json/edge_values.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final result = jsonToYaml(data, includeNulls: true);

      expect(result, contains('nullValue: null'));
      expect(result, contains('unicode:'));
      expect(result, contains('emoji:'));

      File('${outputDir.path}/edge_values_to_yaml.yaml')
          .writeAsStringSync(result);
    });
  });

  group('JSON → XML conversion', () {
    test('converts basic JSON to XML', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final result = jsonToXml(data);

      expect(result, contains('<?xml'));
      expect(result, contains('<root>'));
      expect(result, contains('<firstName>John</firstName>'));
      expect(result, contains('<age>30</age>'));

      File('${outputDir.path}/json_to_xml.xml').writeAsStringSync(result);
    });

    test('converts to PascalCase XML', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final result = jsonToXml(data, caseStyle: CaseStyle.pascalCase);

      expect(result, contains('<Root>'));
      expect(result, contains('<FirstName>John</FirstName>'));
      expect(result, contains('<Age>30</Age>'));

      File('${outputDir.path}/json_to_xml_pascal.xml')
          .writeAsStringSync(result);
    });

    test('converts deep nesting to XML', () {
      final jsonFile = File('${inputDir.path}/json/deep_nesting.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final result = jsonToXml(data);

      expect(result, contains('<level1>'));
      expect(result, contains('<level6>deep value</level6>'));

      File('${outputDir.path}/deep_nesting_to_xml.xml')
          .writeAsStringSync(result);
    });
  });

  group('JSON → Markdown conversion', () {
    test('converts basic JSON with header format', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final result = jsonToMarkdown(data);

      expect(result, contains('## First Name'));
      expect(result, contains('John'));
      expect(result, contains('## Age'));
      expect(result, contains('30'));

      File('${outputDir.path}/json_to_markdown.md').writeAsStringSync(result);
    });

    test('converts with metadata frontmatter', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final metadata = {'title': 'User Data', 'generated': '2026-01-11'};
      final result = jsonToMarkdown(data, metaData: metadata);

      expect(result, contains('---'));
      expect(result, contains('title: User Data'));
      expect(result, contains('---\n## '));

      File('${outputDir.path}/json_to_markdown_with_meta.md')
          .writeAsStringSync(result);
    });

    test('deep nesting uses bold at level 5+', () {
      final jsonFile = File('${inputDir.path}/json/deep_nesting.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final result = jsonToMarkdown(data);

      expect(result, contains('## Level1'));
      expect(result, contains('### Level2'));
      expect(result, contains('#### Level3'));
      expect(result, contains('**Level4**'));
      expect(result, contains('**Level5**'));
      expect(result, contains('**Level6**'));
      expect(result, contains('deep value'));

      File('${outputDir.path}/deep_nesting_to_markdown.md')
          .writeAsStringSync(result);
    });

    test('converts arrays correctly', () {
      final jsonFile = File('${inputDir.path}/json/arrays.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final result = jsonToMarkdown(data);

      expect(result, contains('## Primitive Array'));
      expect(result, contains('- a'));
      expect(result, contains('- b'));

      File('${outputDir.path}/arrays_to_markdown.md').writeAsStringSync(result);
    });
  });

  group('YAML → JSON conversion', () {
    test('converts basic YAML to JSON', () {
      final yamlFile = File('${inputDir.path}/yaml/basic.yaml');
      final content = yamlFile.readAsStringSync();
      final result = yamlToJson(content);

      expect(result['firstName'], 'John');
      expect(result['age'], 30);

      final jsonString = const JsonEncoder.withIndent('  ').convert(result);
      File('${outputDir.path}/yaml_to_json.json').writeAsStringSync(jsonString);
    });

    test('preserves YAML 1.2 boolean semantics', () {
      // YAML 1.2 only treats true/false as booleans, not yes/no/on/off
      final yamlFile = File('${inputDir.path}/yaml/boolean_variants.yaml');
      final content = yamlFile.readAsStringSync();
      final result = yamlToJson(content);

      expect(result['bool1'], true);
      expect(result['bool2'], false);
      expect(result['bool3'], 'yes');
      expect(result['bool4'], 'no');
      expect(result['bool5'], 'on');
      expect(result['bool6'], 'off');
      expect(result['bool7'], true);
      expect(result['bool8'], false);

      final jsonString = const JsonEncoder.withIndent('  ').convert(result);
      File('${outputDir.path}/boolean_variants_to_json.json')
          .writeAsStringSync(jsonString);
    });

    test('resolves anchors and aliases', () {
      final yamlFile = File('${inputDir.path}/yaml/edge_values.yaml');
      final content = yamlFile.readAsStringSync();
      final result = yamlToJson(content);

      expect(result['anchor']['shared'], result['alias']['shared']);

      final jsonString = const JsonEncoder.withIndent('  ').convert(result);
      File('${outputDir.path}/yaml_edge_values_to_json.json')
          .writeAsStringSync(jsonString);
    });
  });

  group('XML → JSON conversion', () {
    test('converts basic XML to JSON', () {
      final xmlFile = File('${inputDir.path}/xml/basic.xml');
      final content = xmlFile.readAsStringSync();
      final result = xmlToJson(content);

      expect(result['firstName'], 'John');
      expect(result['age'], 30);

      final jsonString = const JsonEncoder.withIndent('  ').convert(result);
      File('${outputDir.path}/xml_to_json.json').writeAsStringSync(jsonString);
    });

    test('strips XML declaration', () {
      final xmlFile = File('${inputDir.path}/xml/with_declaration.xml');
      final content = xmlFile.readAsStringSync();
      final result = xmlToJson(content);

      expect(result.containsKey('?xml'), false);
      expect(result['item'], 'value');

      final jsonString = const JsonEncoder.withIndent('  ').convert(result);
      File('${outputDir.path}/xml_with_declaration_to_json.json')
          .writeAsStringSync(jsonString);
    });

    test('preserves PascalCase keys', () {
      final xmlFile = File('${inputDir.path}/xml/pascal_case.xml');
      final content = xmlFile.readAsStringSync();
      final result = xmlToJson(content);

      expect(result['FirstName'], 'John');
      expect(result['UserSettings']['Theme'], 'dark');

      final jsonString = const JsonEncoder.withIndent('  ').convert(result);
      File('${outputDir.path}/xml_pascal_to_json.json')
          .writeAsStringSync(jsonString);
    });
  });

  group('Round-trip conversions', () {
    test('JSON → YAML → JSON preserves data', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final original =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

      final yaml = jsonToYaml(original);
      final roundTripped = yamlToJson(yaml);

      expect(roundTripped['firstName'], original['firstName']);
      expect(roundTripped['lastName'], original['lastName']);
      expect(roundTripped['age'], original['age']);
      expect(roundTripped['active'], original['active']);
    });

    test('JSON → XML → JSON preserves data', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final original =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

      final xml = jsonToXml(original);
      final roundTripped = xmlToJson(xml);

      expect(roundTripped['firstName'], original['firstName']);
      expect(roundTripped['lastName'], original['lastName']);
      expect(roundTripped['age'], original['age']);
      expect(roundTripped['active'], original['active']);
    });

    test('YAML → XML → YAML preserves structure', () {
      final yamlFile = File('${inputDir.path}/yaml/basic.yaml');
      final original = yamlFile.readAsStringSync();
      final originalJson = yamlToJson(original);

      final xml = yamlToXml(original);
      final roundTrippedJson = xmlToJson(xml);

      expect(roundTrippedJson['firstName'], originalJson['firstName']);
      expect(roundTrippedJson['age'], originalJson['age']);
    });

    test('deep nesting survives JSON → YAML → JSON', () {
      final jsonFile = File('${inputDir.path}/json/deep_nesting.json');
      final original =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

      final yaml = jsonToYaml(original);
      final roundTripped = yamlToJson(yaml);

      expect(
        roundTripped['level1']['level2']['level3']['level4']['level5']
            ['level6'],
        'deep value',
      );
    });

    test('arrays survive JSON → YAML → JSON', () {
      final jsonFile = File('${inputDir.path}/json/arrays.json');
      final original =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

      final yaml = jsonToYaml(original);
      final roundTripped = yamlToJson(yaml);

      expect(roundTripped['primitiveArray'], original['primitiveArray']);
      expect(roundTripped['numberArray'], original['numberArray']);
      expect(roundTripped['booleanArray'], original['booleanArray']);
    });
  });

  group('Format options', () {
    test('YAML with metadata', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final metadata = {'title': 'Test', 'version': '1.0'};
      final result = jsonToYaml(data, metaData: metadata);

      expect(result, contains('_meta:'));
      expect(result, contains('title: Test'));
      expect(result, contains('firstName: John'));

      File('${outputDir.path}/yaml_with_meta.yaml').writeAsStringSync(result);
    });

    test('XML with metadata', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final metadata = {'title': 'Test', 'version': '1.0'};
      final result = jsonToXml(data, metaData: metadata);

      expect(result, contains('<_meta>'));
      expect(result, contains('<title>Test</title>'));
      expect(result, contains('<firstName>John</firstName>'));

      File('${outputDir.path}/xml_with_meta.xml').writeAsStringSync(result);
    });

    test('XML with PascalCase and metadata', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final metadata = {'title': 'Test'};
      final result =
          jsonToXml(data, caseStyle: CaseStyle.pascalCase, metaData: metadata);

      // Note: '_meta' converts to 'Meta' in PascalCase (leading underscore removed)
      expect(result, contains('<Meta>'));
      expect(result, contains('<Title>Test</Title>'));
      expect(result, contains('<FirstName>John</FirstName>'));

      File('${outputDir.path}/xml_pascal_with_meta.xml')
          .writeAsStringSync(result);
    });
  });

  group('Case style integration tests', () {
    test('JSON → XML (camelCase) → JSON round-trip', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final originalData =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

      // Convert to XML with camelCase
      final xml = jsonToXml(originalData, caseStyle: CaseStyle.camelCase);
      expect(xml, isNotNull);
      expect(xml, contains('<firstName>'));
      expect(xml, contains('<lastName>'));

      // Convert back to JSON
      final convertedData = xmlToJson(xml);
      expect(convertedData, isA<Map<String, dynamic>>());
      expect(convertedData['firstName'], originalData['firstName']);
      expect(convertedData['lastName'], originalData['lastName']);
    });

    test('JSON → XML (snakeCase) → JSON round-trip', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final originalData =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

      // Convert to XML with snakeCase
      final xml = jsonToXml(originalData, caseStyle: CaseStyle.snakeCase);
      expect(xml, isNotNull);
      expect(xml, contains('<first_name>'));
      expect(xml, contains('<last_name>'));

      // Convert back to JSON
      final convertedData = xmlToJson(xml);
      expect(convertedData, isA<Map<String, dynamic>>());
      expect(convertedData['first_name'], originalData['firstName']);
      expect(convertedData['last_name'], originalData['lastName']);
    });

    test('JSON → XML (kebabCase) → JSON round-trip', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final originalData =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

      // Convert to XML with kebabCase
      final xml = jsonToXml(originalData, caseStyle: CaseStyle.kebabCase);
      expect(xml, isNotNull);
      expect(xml, contains('<first-name>'));
      expect(xml, contains('<last-name>'));

      // Convert back to JSON
      final convertedData = xmlToJson(xml);
      expect(convertedData, isA<Map<String, dynamic>>());
      expect(convertedData['first-name'], originalData['firstName']);
      expect(convertedData['last-name'], originalData['lastName']);
    });

    test('JSON → XML (none) → JSON round-trip preserves original keys', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final originalData =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

      // Convert to XML with none case style
      final xml = jsonToXml(originalData, caseStyle: CaseStyle.none);
      expect(xml, isNotNull);
      expect(xml, contains('<firstName>'));
      expect(xml, contains('<lastName>'));

      // Convert back to JSON
      final convertedData = xmlToJson(xml);
      expect(convertedData, isA<Map<String, dynamic>>());
      expect(convertedData['firstName'], originalData['firstName']);
      expect(convertedData['lastName'], originalData['lastName']);
    });

    test('Complex nested structure with camelCase', () {
      final jsonFile = File('${inputDir.path}/json/deep_nesting.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

      final xml = jsonToXml(data, caseStyle: CaseStyle.camelCase);
      expect(xml, isNotNull);
      expect(xml, contains('<level1>'));
      expect(xml, contains('<level2>'));
      expect(xml, contains('<level3>'));

      // Verify nested structure is preserved
      final convertedData = xmlToJson(xml);
      expect(
          convertedData['level1']['level2']['level3']['level4']['level5']
              ['level6'],
          data['level1']['level2']['level3']['level4']['level5']['level6']);
    });

    test('Complex nested structure with snakeCase', () {
      final jsonFile = File('${inputDir.path}/json/deep_nesting.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

      final xml = jsonToXml(data, caseStyle: CaseStyle.snakeCase);
      expect(xml, isNotNull);
      expect(xml, contains('<level1>'));
      expect(xml, contains('<level2>'));

      // Verify nested structure is preserved
      final convertedData = xmlToJson(xml);
      expect(
          convertedData['level1']['level2']['level3']['level4']['level5']
              ['level6'],
          data['level1']['level2']['level3']['level4']['level5']['level6']);
    });

    test('YAML → XML (camelCase) → YAML round-trip', () {
      final yamlFile = File('${inputDir.path}/yaml/basic.yaml');
      final yamlContent = yamlFile.readAsStringSync();

      // Convert to XML with camelCase
      final xml = yamlToXml(yamlContent, caseStyle: CaseStyle.camelCase);
      expect(xml, isNotNull);

      // Convert back to YAML
      final convertedYaml = xmlToYaml(xml);
      expect(
          convertedYaml.contains('firstName:') ||
              convertedYaml.contains('name:'),
          isTrue);
      expect(convertedYaml, contains('age:'));
    });

    test('Markdown → XML (PascalCase) → Markdown round-trip', () {
      final markdownFile =
          File('${inputDir.path}/markdown/frontmatter_json.md');
      final markdownContent = markdownFile.readAsStringSync();

      // Convert to XML with PascalCase
      final xml =
          markdownToXml(markdownContent, caseStyle: CaseStyle.pascalCase);
      expect(xml, isNotNull);
      expect(xml, contains('<Root>'));

      // Convert back to Markdown
      final convertedMarkdown = xmlToMarkdown(xml);
      expect(convertedMarkdown, isNotNull);
    });

    test('Case styles with metadata', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final metadata = {'title': 'Test Document', 'version': '1.0'};

      // Test camelCase with metadata
      final camelXml =
          jsonToXml(data, caseStyle: CaseStyle.camelCase, metaData: metadata);
      // Note: '_meta' with leading underscore converts to 'Meta' in camelCase
      expect(camelXml, contains('<Meta>'));
      expect(camelXml, contains('<title>Test Document</title>'));

      // Test snakeCase with metadata
      final snakeXml =
          jsonToXml(data, caseStyle: CaseStyle.snakeCase, metaData: metadata);
      // Note: '_meta' stays as '_meta' in snakeCase
      expect(snakeXml, contains('<_meta>'));
      expect(snakeXml, contains('<title>Test Document</title>'));

      // Test kebabCase with metadata
      final kebabXml =
          jsonToXml(data, caseStyle: CaseStyle.kebabCase, metaData: metadata);
      // Note: '_meta' converts to '-meta' in kebabCase (underscore becomes hyphen)
      expect(kebabXml, contains('<-meta>'));
      expect(kebabXml, contains('<title>Test Document</title>'));
    });

    test('Markdown no extra newline between frontmatter and content', () {
      final jsonFile = File('${inputDir.path}/json/basic.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final metadata = {'title': 'Test'};
      final result = jsonToMarkdown(data, metaData: metadata);

      expect(result, contains('---\n## '));
      expect(result, isNot(contains('---\n\n##')));

      File('${outputDir.path}/markdown_no_extra_newline.md')
          .writeAsStringSync(result);
    });
  });

  group('Cross-format output generation', () {
    test('YAML → Markdown', () {
      final yamlFile = File('${inputDir.path}/yaml/basic.yaml');
      final content = yamlFile.readAsStringSync();
      final result = yamlToMarkdown(content);

      expect(result, contains('## First Name'));
      expect(result, contains('John'));

      File('${outputDir.path}/yaml_to_markdown.md').writeAsStringSync(result);
    });

    test('YAML → XML', () {
      final yamlFile = File('${inputDir.path}/yaml/basic.yaml');
      final content = yamlFile.readAsStringSync();
      final result = yamlToXml(content);

      expect(result, contains('<?xml'));
      expect(result, contains('<firstName>John</firstName>'));

      File('${outputDir.path}/yaml_to_xml.xml').writeAsStringSync(result);
    });

    test('XML → Markdown', () {
      final xmlFile = File('${inputDir.path}/xml/basic.xml');
      final content = xmlFile.readAsStringSync();
      final result = xmlToMarkdown(content);

      expect(result, contains('## First Name'));
      expect(result, contains('John'));

      File('${outputDir.path}/xml_to_markdown.md').writeAsStringSync(result);
    });

    test('XML → YAML', () {
      final xmlFile = File('${inputDir.path}/xml/basic.xml');
      final content = xmlFile.readAsStringSync();
      final result = xmlToYaml(content);

      expect(result, contains('firstName: John'));
      expect(result, contains('age: 30'));

      File('${outputDir.path}/xml_to_yaml.yaml').writeAsStringSync(result);
    });

    test('Markdown → YAML', () {
      final mdFile = File('${inputDir.path}/markdown/frontmatter_json.md');
      final content = mdFile.readAsStringSync();
      final result = markdownToYaml(content);

      expect(result, contains('title: JSON Body Test'));
      expect(result, contains('body:'));

      File('${outputDir.path}/markdown_to_yaml.yaml').writeAsStringSync(result);
    });

    test('Markdown → XML', () {
      final mdFile = File('${inputDir.path}/markdown/frontmatter_json.md');
      final content = mdFile.readAsStringSync();
      final result = markdownToXml(content);

      expect(result, contains('<?xml'));
      expect(result, contains('<title>JSON Body Test</title>'));

      File('${outputDir.path}/markdown_to_xml.xml').writeAsStringSync(result);
    });
  });

  group('Edge case handling', () {
    test('unicode and emoji preserved through JSON → YAML → JSON', () {
      final jsonFile = File('${inputDir.path}/json/edge_values.json');
      final original =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

      final yaml = jsonToYaml(original);
      final roundTripped = yamlToJson(yaml);

      expect(roundTripped['unicode'], original['unicode']);
      expect(roundTripped['emoji'], original['emoji']);
    });

    test('null values handled correctly', () {
      final jsonFile = File('${inputDir.path}/json/edge_values.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

      // With includeNulls=true, null values are included in YAML
      final yaml = jsonToYaml(data, includeNulls: true);
      expect(yaml, contains('nullValue: null'));

      // By default (includeNulls=false), null values are skipped in YAML
      final yamlWithoutNulls = jsonToYaml(data, includeNulls: false);
      expect(yamlWithoutNulls, isNot(contains('nullValue')));

      // By default (includeNulls=false), null values are skipped in XML
      final xml = jsonToXml(data);
      expect(xml, isNot(contains('<nullValue')));

      // With includeNulls=true, empty elements are created
      final xmlWithNulls = jsonToXml(data, includeNulls: true);
      expect(xmlWithNulls, contains('<nullValue>'));

      // With includeNulls=true, null values are included in Markdown
      final markdown = jsonToMarkdown(data, includeNulls: true);
      expect(markdown, contains('## Null Value'));

      // By default (includeNulls=false), null values are skipped in Markdown
      final markdownWithoutNulls = jsonToMarkdown(data, includeNulls: false);
      expect(markdownWithoutNulls, isNot(contains('Null Value')));
    });

    test('empty values become null in YAML round-trip', () {
      // Note: Empty arrays and objects in YAML (key:) are parsed as null
      // This is a limitation of YAML syntax representation
      final jsonFile = File('${inputDir.path}/json/edge_values.json');
      final data =
          jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;

      final yaml = jsonToYaml(data);
      final roundTripped = yamlToJson(yaml);

      // Empty collections become null in YAML round-trip
      expect(roundTripped['emptyArray'], isNull);
      expect(roundTripped['emptyObject'], isNull);
    });

    test('special characters escaped in XML', () {
      final data = {
        'content': '<script>alert("xss")</script>',
        'ampersand': 'Tom & Jerry',
      };
      final xml = jsonToXml(data);

      // XML package automatically escapes special characters
      expect(xml, contains('&lt;'));
      expect(xml, contains('&amp;'));
    });
  });
}
