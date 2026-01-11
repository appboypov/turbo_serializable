import 'package:test/test.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

// Test concrete implementations
class TestModel extends TurboSerializable<Object?> {
  final String name;

  TestModel(this.name, {super.metaData})
      : super(
            config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as TestModel;
            return {'name': self.name};
          },
          toYaml: (instance) {
            final self = instance as TestModel;
            return 'name: ${self.name}';
          },
          toMarkdown: (instance) {
            final self = instance as TestModel;
            return '# ${self.name}';
          },
          toXml: (instance,
              {String? rootElementName,
              bool includeNulls = false,
              bool prettyPrint = true,
              bool includeMetaData = true,
              CaseStyle caseStyle = CaseStyle.none}) {
            final self = instance as TestModel;
            return '<name>${self.name}</name>';
          },
        ));

  @override
  TurboResponse<T>? validate<T>() {
    if (name.isEmpty) {
      return TurboResponse.fail(error: 'Name cannot be empty');
    }
    return null;
  }
}

class TestModelWithId extends TurboSerializableId<String, Object?> {
  final String _id;
  final String name;

  TestModelWithId({
    required String id,
    required this.name,
    super.isLocalDefault,
    super.metaData,
  })  : _id = id,
        super(config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as TestModelWithId;
            return {'id': self.id, 'name': self.name};
          },
        ));

  @override
  String get id => _id;

  @override
  TurboResponse<T>? validate<T>() {
    if (id.isEmpty) {
      return TurboResponse.fail(error: 'ID cannot be empty');
    }
    if (name.isEmpty) {
      return TurboResponse.fail(error: 'Name cannot be empty');
    }
    return null;
  }
}

// Minimal implementation that doesn't override anything
class MinimalModel extends TurboSerializable<Object?> {
  MinimalModel({super.metaData})
      : super(
            config: TurboSerializableConfig(
          toJson: (_) => null,
        ));
}

// Test model with typed metadata
class FrontmatterMeta implements HasToJson {
  final String title;
  final String description;
  final List<String> tags;

  FrontmatterMeta({
    required this.title,
    required this.description,
    required this.tags,
  });

  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'tags': tags,
      };
}

class DocumentModel extends TurboSerializable<FrontmatterMeta> {
  final String content;

  DocumentModel({
    required this.content,
    super.metaData,
  }) : super(
            config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as DocumentModel;
            return {'content': self.content};
          },
          toMarkdown: (instance) {
            final self = instance as DocumentModel;
            return self.content;
          },
        ));
}

class DocumentWithId extends TurboSerializableId<String, FrontmatterMeta> {
  final String _id;
  final String content;

  DocumentWithId({
    required String id,
    required this.content,
    super.metaData,
    super.isLocalDefault,
  })  : _id = id,
        super(config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as DocumentWithId;
            return {'id': self.id, 'content': self.content};
          },
        ));

  @override
  String get id => _id;
}

void main() {
  group('TurboSerializable', () {
    group('default behavior', () {
      late MinimalModel model;

      setUp(() {
        model = MinimalModel();
      });

      test('validate returns null by default', () {
        expect(model.validate(), isNull);
      });

      test('toJson returns null by default', () {
        expect(model.toJson(), isNull);
      });

      test('toYaml returns null by default', () {
        expect(model.toYaml(), isNull);
      });

      test('toMarkdown returns null by default', () {
        expect(model.toMarkdown(), isNull);
      });

      test('toXml returns null by default', () {
        expect(model.toXml(), isNull);
      });

      test('metaData is null by default', () {
        expect(model.metaData, isNull);
      });
    });

    group('metadata', () {
      test('can be set via constructor', () {
        final meta = FrontmatterMeta(
          title: 'Test Document',
          description: 'A test',
          tags: ['test', 'example'],
        );
        final doc = DocumentModel(content: 'Hello', metaData: meta);
        expect(doc.metaData, isNotNull);
        expect(doc.metaData!.title, equals('Test Document'));
        expect(doc.metaData!.description, equals('A test'));
        expect(doc.metaData!.tags, equals(['test', 'example']));
      });

      test('is null when not provided', () {
        final doc = DocumentModel(content: 'Hello');
        expect(doc.metaData, isNull);
      });

      test('is type-safe', () {
        final meta = FrontmatterMeta(
          title: 'Test',
          description: 'Desc',
          tags: [],
        );
        final doc = DocumentModel(content: 'Hello', metaData: meta);
        expect(doc.metaData, isA<FrontmatterMeta>());
      });

      test('Object? metadata type allows any object or null', () {
        final model = TestModel('test');
        expect(model.metaData, isNull);

        final modelWithMeta = TestModel('test', metaData: {'key': 'value'});
        expect(modelWithMeta.metaData, equals({'key': 'value'}));
      });
    });

    group('subclass implementation', () {
      test('can override toJson', () {
        final model = TestModel('John');
        expect(model.toJson(), equals({'name': 'John'}));
      });

      test('can override toYaml', () {
        final model = TestModel('John');
        expect(model.toYaml(), equals('name: John'));
      });

      test('can override toMarkdown', () {
        final model = TestModel('John');
        expect(model.toMarkdown(), equals('# John'));
      });

      test('can override toXml', () {
        final model = TestModel('John');
        expect(model.toXml(), equals('<name>John</name>'));
        expect(model.toXml(rootElementName: 'Custom'),
            equals('<name>John</name>'));
      });

      test('default toXml uses toJson conversion', () {
        final minimal = MinimalModel();
        expect(minimal.toXml(), isNull);

        final jsonModel = _JsonOnlyModel(name: 'Test', age: 25);
        final xml = jsonModel.toXml();
        expect(xml, isNotNull);
        expect(xml, contains('<_JsonOnlyModel>'));
        expect(xml, contains('<name>Test</name>'));
        expect(xml, contains('<age>25</age>'));
      });

      test('toXml handles nested objects', () {
        final model = _NestedModel(
          name: 'Parent',
          child: _JsonOnlyModel(name: 'Child', age: 10),
        );
        final xml = model.toXml();
        expect(xml, isNotNull);
        expect(xml, contains('<_NestedModel>'));
        expect(xml, contains('<name>Parent</name>'));
        expect(xml, contains('<child>'));
        expect(xml, contains('<name>Child</name>'));
        expect(xml, contains('<age>10</age>'));
      });

      test('toXml handles lists', () {
        final model = _ListModel(items: ['item1', 'item2', 'item3']);
        final xml = model.toXml();
        expect(xml, isNotNull);
        expect(xml, contains('<_ListModel>'));
        final itemCount = RegExp(r'<items>').allMatches(xml!).length;
        expect(itemCount, equals(3));
      });

      test('toXml handles null values', () {
        final model = _NullableModel(name: 'Test', value: null);
        final xmlWithoutNulls = model.toXml(includeNulls: false);
        expect(xmlWithoutNulls, isNotNull);
        expect(xmlWithoutNulls, contains('<name>Test</name>'));
        expect(xmlWithoutNulls, isNot(contains('<value>')));

        final xmlWithNulls = model.toXml(includeNulls: true);
        expect(xmlWithNulls, isNotNull);
        expect(xmlWithNulls, contains('<value></value>'));
      });

      test('toXml handles special characters', () {
        final model = _JsonOnlyModel(
          name: 'Test & <example> "quoted"',
          age: 25,
        );
        final xml = model.toXml();
        expect(xml, isNotNull);
        expect(xml, contains('&amp;'));
        expect(xml, contains('&lt;'));
      });

      test('toXml with custom root element name', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final xml = model.toXml(rootElementName: 'CustomRoot');
        expect(xml, isNotNull);
        expect(xml, contains('<CustomRoot>'));
      });

      test('toXml prettyPrint option', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final prettyXml = model.toXml(prettyPrint: true);
        final compactXml = model.toXml(prettyPrint: false);
        expect(prettyXml, isNotNull);
        expect(compactXml, isNotNull);
        expect(prettyXml, contains('\n'));
      });

      test('toXml with camelCase from JSON primary format', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final xml = model.toXml(caseStyle: CaseStyle.camelCase);
        expect(xml, isNotNull);
        expect(xml, contains('<name>Test</name>'));
        expect(xml, contains('<age>25</age>'));
      });

      test('toXml with snakeCase from JSON primary format', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final xml = model.toXml(caseStyle: CaseStyle.snakeCase);
        expect(xml, isNotNull);
        expect(xml, contains('<name>Test</name>'));
        expect(xml, contains('<age>25</age>'));
      });

      test('toXml with kebabCase from JSON primary format', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final xml = model.toXml(caseStyle: CaseStyle.kebabCase);
        expect(xml, isNotNull);
        expect(xml, contains('<name>Test</name>'));
        expect(xml, contains('<age>25</age>'));
      });

      test('toXml with none case style from JSON primary format', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final xml = model.toXml(caseStyle: CaseStyle.none);
        expect(xml, isNotNull);
        expect(xml, contains('<name>Test</name>'));
        expect(xml, contains('<age>25</age>'));
      });

      test('can override validate to return null for valid state', () {
        final model = TestModel('John');
        expect(model.validate(), isNull);
      });

      test(
          'can override validate to return TurboResponse.fail for invalid state',
          () {
        final model = TestModel('');
        final result = model.validate<String>();
        expect(result, isNotNull);
        expect(result!.isSuccess, isFalse);
        expect(result.error, equals('Name cannot be empty'));
      });
    });
  });

  group('TurboSerializableId', () {
    group('default behavior', () {
      test('extends TurboSerializable', () {
        final model = TestModelWithId(id: '123', name: 'John');
        expect(model, isA<TurboSerializable>());
      });

      test('isLocalDefault defaults to false', () {
        final model = TestModelWithId(id: '123', name: 'John');
        expect(model.isLocalDefault, isFalse);
      });

      test('isLocalDefault can be set to true', () {
        final model = TestModelWithId(
          id: '123',
          name: 'John',
          isLocalDefault: true,
        );
        expect(model.isLocalDefault, isTrue);
      });

      test('id getter works correctly', () {
        final model = TestModelWithId(id: '123', name: 'John');
        expect(model.id, equals('123'));
      });

      test('supports different id types', () {
        final intIdModel = _TestIntIdModel(id: 42, name: 'Test');
        expect(intIdModel.id, equals(42));
        expect(intIdModel.id, isA<int>());

        final stringIdModel = TestModelWithId(id: 'abc', name: 'Test');
        expect(stringIdModel.id, equals('abc'));
        expect(stringIdModel.id, isA<String>());
      });

      test('metaData is null by default', () {
        final model = TestModelWithId(id: '123', name: 'John');
        expect(model.metaData, isNull);
      });
    });

    group('metadata', () {
      test('can be set via constructor', () {
        final meta = FrontmatterMeta(
          title: 'Doc Title',
          description: 'Doc desc',
          tags: ['a', 'b'],
        );
        final doc = DocumentWithId(
          id: 'doc-1',
          content: 'Content',
          metaData: meta,
        );
        expect(doc.metaData, isNotNull);
        expect(doc.metaData!.title, equals('Doc Title'));
      });

      test('is inherited from TurboSerializable', () {
        final meta = FrontmatterMeta(
          title: 'Test',
          description: 'Desc',
          tags: [],
        );
        final doc = DocumentWithId(
          id: 'doc-1',
          content: 'Content',
          metaData: meta,
        );
        final TurboSerializable<FrontmatterMeta> asBase = doc;
        expect(asBase.metaData, isNotNull);
        expect(asBase.metaData!.title, equals('Test'));
      });
    });

    group('subclass implementation', () {
      test('can override toJson', () {
        final model = TestModelWithId(id: '123', name: 'John');
        expect(model.toJson(), equals({'id': '123', 'name': 'John'}));
      });

      test('can override validate to return null for valid state', () {
        final model = TestModelWithId(id: '123', name: 'John');
        expect(model.validate(), isNull);
      });

      test('can override validate to return TurboResponse.fail for invalid id',
          () {
        final model = TestModelWithId(id: '', name: 'John');
        final result = model.validate<String>();
        expect(result, isNotNull);
        expect(result!.isSuccess, isFalse);
        expect(result.error, equals('ID cannot be empty'));
      });

      test(
          'can override validate to return TurboResponse.fail for invalid name',
          () {
        final model = TestModelWithId(id: '123', name: '');
        final result = model.validate<String>();
        expect(result, isNotNull);
        expect(result!.isSuccess, isFalse);
        expect(result.error, equals('Name cannot be empty'));
      });

      test('maintains isLocalDefault state when overriding methods', () {
        final model = TestModelWithId(
          id: '123',
          name: 'John',
          isLocalDefault: true,
        );
        expect(model.toJson(), equals({'id': '123', 'name': 'John'}));
        expect(model.isLocalDefault, isTrue);
      });
    });

    group('type safety', () {
      test('enforces id type constraint', () {
        final stringModel = TestModelWithId(id: 'abc', name: 'Test');
        expect(stringModel.id, isA<String>());

        final intModel = _TestIntIdModel(id: 123, name: 'Test');
        expect(intModel.id, isA<int>());

        expect(stringModel, isA<TurboSerializableId<String, Object?>>());
        expect(intModel, isA<TurboSerializableId<int, Object?>>());
      });
    });
  });

  group('Primary Format and Conversions', () {
    group('JSON as primary format', () {
      test('toJson returns actual implementation', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        expect(model.toJson(), equals({'name': 'Test', 'age': 25}));
      });

      test('toYaml converts from JSON', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final yaml = model.toYaml();
        expect(yaml, isNotNull);
        expect(yaml, contains('name: Test'));
        expect(yaml, contains('age: 25'));
      });

      test('toMarkdown converts from JSON', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final markdown = model.toMarkdown();
        expect(markdown, isNotNull);
        expect(markdown, contains('## Name'));
        expect(markdown, contains('Test'));
        expect(markdown, contains('## Age'));
        expect(markdown, contains('25'));
      });

      test('toXml converts from JSON', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final xml = model.toXml();
        expect(xml, isNotNull);
        expect(xml, contains('<name>Test</name>'));
        expect(xml, contains('<age>25</age>'));
      });
    });

    group('YAML as primary format', () {
      test('toYaml returns actual implementation', () {
        final model = _YamlOnlyModel(name: 'Test', age: 25);
        final yaml = model.toYaml();
        expect(yaml, isNotNull);
        expect(yaml, contains('name: Test'));
        expect(yaml, contains('age: 25'));
      });

      test('toJson converts from YAML', () {
        final model = _YamlOnlyModel(name: 'Test', age: 25);
        final json = model.toJson();
        expect(json, isNotNull);
        expect(json!['name'], equals('Test'));
        expect(json['age'], equals(25));
      });

      test('toXml converts from YAML', () {
        final model = _YamlOnlyModel(name: 'Test', age: 25);
        final xml = model.toXml();
        expect(xml, isNotNull);
        expect(xml, contains('<name>Test</name>'));
        expect(xml, contains('<age>25</age>'));
      });

      test('toXml with camelCase from YAML primary format', () {
        final model = _YamlOnlyModel(name: 'Test', age: 25);
        final xml = model.toXml(caseStyle: CaseStyle.camelCase);
        expect(xml, isNotNull);
        expect(xml, contains('<name>Test</name>'));
        expect(xml, contains('<age>25</age>'));
      });

      test('toXml with PascalCase from YAML primary format', () {
        final model = _YamlOnlyModel(name: 'Test', age: 25);
        final xml = model.toXml(caseStyle: CaseStyle.pascalCase);
        expect(xml, isNotNull);
        expect(xml, contains('<Name>Test</Name>'));
        expect(xml, contains('<Age>25</Age>'));
      });

      test('toXml with snakeCase from YAML primary format', () {
        final model = _YamlOnlyModel(name: 'Test', age: 25);
        final xml = model.toXml(caseStyle: CaseStyle.snakeCase);
        expect(xml, isNotNull);
        expect(xml, contains('<name>Test</name>'));
        expect(xml, contains('<age>25</age>'));
      });

      test('toXml with kebabCase from YAML primary format', () {
        final model = _YamlOnlyModel(name: 'Test', age: 25);
        final xml = model.toXml(caseStyle: CaseStyle.kebabCase);
        expect(xml, isNotNull);
        expect(xml, contains('<name>Test</name>'));
        expect(xml, contains('<age>25</age>'));
      });
    });

    group('Markdown as primary format', () {
      test('toMarkdown returns actual implementation', () {
        final model = _MarkdownOnlyModel(content: '# Test\n\nThis is a test.');
        final markdown = model.toMarkdown();
        expect(markdown, isNotNull);
        expect(markdown, contains('# Test'));
        expect(markdown, contains('This is a test'));
      });

      test('toJson converts from Markdown with frontmatter', () {
        final model = _MarkdownWithFrontmatterModel(
          title: 'My Title',
          description: 'A description',
          body: '{"key": "value"}',
        );
        final json = model.toJson();
        expect(json, isNotNull);
        expect(json!['title'], equals('My Title'));
        expect(json['description'], equals('A description'));
        expect(json['body'], isA<Map<String, dynamic>>());
        expect(json['body']['key'], equals('value'));
      });

      test('toXml with camelCase from Markdown primary format', () {
        final model =
            _MarkdownOnlyModel(content: '{"name": "Test", "age": 25}');
        final xml = model.toXml(caseStyle: CaseStyle.camelCase);
        expect(xml, isNotNull);
        expect(xml, contains('<name>Test</name>'));
        expect(xml, contains('<age>25</age>'));
      });

      test('toXml with PascalCase from Markdown primary format', () {
        final model =
            _MarkdownOnlyModel(content: '{"name": "Test", "age": 25}');
        final xml = model.toXml(caseStyle: CaseStyle.pascalCase);
        expect(xml, isNotNull);
        expect(xml, contains('<Name>Test</Name>'));
        expect(xml, contains('<Age>25</Age>'));
      });

      test('toXml with snakeCase from Markdown primary format', () {
        final model =
            _MarkdownOnlyModel(content: '{"name": "Test", "age": 25}');
        final xml = model.toXml(caseStyle: CaseStyle.snakeCase);
        expect(xml, isNotNull);
        expect(xml, contains('<name>Test</name>'));
        expect(xml, contains('<age>25</age>'));
      });

      test('toXml with kebabCase from Markdown primary format', () {
        final model =
            _MarkdownOnlyModel(content: '{"name": "Test", "age": 25}');
        final xml = model.toXml(caseStyle: CaseStyle.kebabCase);
        expect(xml, isNotNull);
        expect(xml, contains('<name>Test</name>'));
        expect(xml, contains('<age>25</age>'));
      });
    });

    group('XML as primary format', () {
      test('toXml returns actual implementation', () {
        final model = _XmlOnlyModel(name: 'Test', age: 25);
        final xml = model.toXml();
        expect(xml, isNotNull);
        expect(xml, contains('<name>Test</name>'));
        expect(xml, contains('<age>25</age>'));
      });

      test('toXml with camelCase from XML primary format', () {
        final model = _XmlOnlyModel(name: 'Test', age: 25);
        final xml = model.toXml(caseStyle: CaseStyle.camelCase);
        expect(xml, isNotNull);
        // XML primary format uses the callback, which may not apply case style
        // This test verifies the method accepts the parameter
      });

      test('toXml with PascalCase from XML primary format', () {
        final model = _XmlOnlyModel(name: 'Test', age: 25);
        final xml = model.toXml(caseStyle: CaseStyle.pascalCase);
        expect(xml, isNotNull);
        // XML primary format uses the callback, which may not apply case style
        // This test verifies the method accepts the parameter
      });

      test('toJson converts from XML', () {
        final model = _XmlOnlyModel(name: 'Test', age: 25);
        final json = model.toJson();
        expect(json, isNotNull);
        expect(json!['name'], equals('Test'));
        expect(json['age'], equals(25));
      });

      test('toYaml converts from XML', () {
        final model = _XmlOnlyModel(name: 'Test', age: 25);
        final yaml = model.toYaml();
        expect(yaml, isNotNull);
        expect(yaml, contains('name: Test'));
        expect(yaml, contains('age: 25'));
      });
    });

    group('edge cases', () {
      test('null primary format returns null for all conversions', () {
        final model = MinimalModel();
        expect(model.toJson(), isNull);
        expect(model.toYaml(), isNull);
        expect(model.toMarkdown(), isNull);
        expect(model.toXml(), isNull);
      });

      test('nested objects convert correctly', () {
        final model = _NestedModel(
          name: 'Parent',
          child: _JsonOnlyModel(name: 'Child', age: 10),
        );
        final yaml = model.toYaml();
        expect(yaml, isNotNull);
        expect(yaml, contains('Parent'));
        expect(yaml, contains('Child'));
      });

      test('lists convert correctly', () {
        final model = _ListModel(items: ['a', 'b', 'c']);
        final yaml = model.toYaml();
        expect(yaml, isNotNull);
        expect(yaml, contains('items:'));
      });
    });
  });

  group('Format Converters', () {
    group('jsonToYaml', () {
      test('converts simple map', () {
        final yaml = jsonToYaml({'name': 'Test', 'age': 25});
        expect(yaml, contains('name: Test'));
        expect(yaml, contains('age: 25'));
      });

      test('converts nested map', () {
        final yaml = jsonToYaml({
          'user': {'name': 'Test', 'age': 25}
        });
        expect(yaml, contains('user:'));
        expect(yaml, contains('name: Test'));
      });

      test('converts list', () {
        final yaml = jsonToYaml({
          'items': ['a', 'b', 'c']
        });
        expect(yaml, contains('items:'));
        expect(yaml, contains('- a'));
        expect(yaml, contains('- b'));
        expect(yaml, contains('- c'));
      });

      test('handles null values', () {
        final yaml =
            jsonToYaml({'name': 'Test', 'value': null}, includeNulls: true);
        expect(yaml, contains('value: null'));

        final yamlWithoutNulls =
            jsonToYaml({'name': 'Test', 'value': null}, includeNulls: false);
        expect(yamlWithoutNulls, contains('name: Test'));
        expect(yamlWithoutNulls, isNot(contains('value')));
      });

      test('escapes special characters in strings', () {
        final yaml = jsonToYaml({'text': 'value: with colon'});
        expect(yaml, contains('"value: with colon"'));
      });
    });

    group('yamlToJson', () {
      test('parses simple YAML', () {
        final json = yamlToJson('name: Test\nage: 25');
        expect(json['name'], equals('Test'));
        expect(json['age'], equals(25));
      });

      test('parses nested YAML', () {
        final json = yamlToJson('user:\n  name: Test\n  age: 25');
        expect(json['user'], isA<Map<String, dynamic>>());
        expect(json['user']['name'], equals('Test'));
      });

      test('parses list YAML', () {
        final json = yamlToJson('items:\n  - a\n  - b\n  - c');
        expect(json['items'], isA<List>());
        expect(json['items'], equals(['a', 'b', 'c']));
      });

      test('throws on invalid YAML', () {
        expect(
          () => yamlToJson('invalid: yaml: content:'),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('jsonToMarkdown', () {
      test('converts JSON to markdown with frontmatter', () {
        final markdown = jsonToMarkdown(
          {'key': 'value'},
          metaData: {'title': 'Test'},
        );
        expect(markdown, contains('---'));
        expect(markdown, contains('title: Test'));
        expect(markdown, contains('## Key'));
        expect(markdown, contains('value'));
      });

      test('converts JSON without frontmatter', () {
        final markdown = jsonToMarkdown({'key': 'value'});
        expect(markdown, isNot(contains('---')));
        expect(markdown, contains('## Key'));
        expect(markdown, contains('value'));
      });

      test('formats nested JSON with headers', () {
        final markdown = jsonToMarkdown({
          'user': {'name': 'Test', 'age': 25}
        });
        expect(markdown, contains('## User'));
        expect(markdown, contains('### Name'));
        expect(markdown, contains('Test'));
      });
    });

    group('markdownToJson', () {
      test('parses frontmatter and JSON body', () {
        final json = markdownToJson('''
---
title: My Title
description: A description
---
{"key": "value"}
''');
        expect(json['title'], equals('My Title'));
        expect(json['description'], equals('A description'));
        expect(json['body'], isA<Map<String, dynamic>>());
        expect(json['body']['key'], equals('value'));
      });

      test('parses frontmatter only', () {
        final json = markdownToJson('''
---
title: My Title
---
''');
        expect(json['title'], equals('My Title'));
      });

      test('parses body without frontmatter', () {
        final json = markdownToJson('{"key": "value"}');
        expect(json['body'], isA<Map<String, dynamic>>());
        expect(json['body']['key'], equals('value'));
      });

      test('stores non-JSON body as string', () {
        final json = markdownToJson('''
---
title: My Title
---
Some regular markdown content
''');
        expect(json['title'], equals('My Title'));
        expect(json['body'], equals('Some regular markdown content'));
      });

      test('handles empty content', () {
        final json = markdownToJson('');
        expect(json, isEmpty);
      });
    });

    group('XML converters', () {
      test('jsonToXml converts simple map', () {
        final xml =
            jsonToXml({'name': 'Test', 'age': 25}, rootElementName: 'root');
        expect(xml, contains('<root>'));
        expect(xml, contains('<name>Test</name>'));
        expect(xml, contains('<age>25</age>'));
      });

      test('xmlToMap parses simple XML', () {
        final map = xmlToMap('<root><name>Test</name><age>25</age></root>');
        expect(map['name'], equals('Test'));
        expect(map['age'], equals(25));
      });

      test('xmlToJson is alias for xmlToMap', () {
        final json = xmlToJson('<root><name>Test</name></root>');
        expect(json['name'], equals('Test'));
      });

      test('handles special characters', () {
        final xml = jsonToXml({'text': 'a & b < c'}, rootElementName: 'root');
        expect(xml, contains('&amp;'));
        expect(xml, contains('&lt;'));
      });
    });
  });

  group('Edge Cases and Error Handling', () {
    test('handles empty strings', () {
      final model = _JsonOnlyModel(name: '', age: 0);
      expect(model.toJson(), equals({'name': '', 'age': 0}));
      expect(model.toYaml(), isNotNull);
      expect(model.toXml(), isNotNull);
    });

    test('handles unicode content', () {
      final model = _JsonOnlyModel(name: '日本語テスト 🎉', age: 25);
      final json = model.toJson();
      expect(json!['name'], equals('日本語テスト 🎉'));

      final yaml = model.toYaml();
      expect(yaml, contains('日本語テスト'));

      final xml = model.toXml();
      expect(xml, contains('日本語テスト'));
    });

    test('handles deeply nested structures', () {
      final model = _DeeplyNestedModel();
      final yaml = model.toYaml();
      expect(yaml, isNotNull);
      expect(yaml, contains('level1'));
      expect(yaml, contains('level2'));
      expect(yaml, contains('level3'));
    });

    test('handles empty collections', () {
      final model = _EmptyCollectionsModel();
      final json = model.toJson();
      expect(json!['emptyList'], equals([]));
      expect(json['emptyMap'], equals({}));

      final yaml = model.toYaml();
      expect(yaml, isNotNull);

      final xml = model.toXml();
      expect(xml, isNotNull);
    });

    test('handles boolean values', () {
      final model = _BooleanModel(active: true, deleted: false);
      final json = model.toJson();
      expect(json!['active'], isTrue);
      expect(json['deleted'], isFalse);

      final yaml = model.toYaml();
      expect(yaml, contains('active: true'));
      expect(yaml, contains('deleted: false'));
    });

    test('handles numeric types', () {
      final model = _NumericModel(
        intValue: 42,
        doubleValue: 3.14159,
        negativeValue: -100,
      );
      final json = model.toJson();
      expect(json!['intValue'], equals(42));
      expect(json['doubleValue'], equals(3.14159));
      expect(json['negativeValue'], equals(-100));
    });

    test('xmlToMap throws on invalid XML', () {
      expect(
        () => xmlToMap('invalid xml <unclosed'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Exposed Internal Methods', () {
    group('metaDataToJson', () {
      test('returns empty map when metadata is null', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        expect(model.metaDataToJsonMap(), isEmpty);
        expect(model.metaDataToJsonMap(), equals({}));
      });

      test('returns JSON map when metadata has toJson()', () {
        final meta = _MetaWithToJson(title: 'Test Doc', version: 1);
        final model = _ModelWithMeta(content: 'Hello', metaData: meta);
        final result = model.metaDataToJsonMap();
        expect(result, isNotNull);
        expect(result['title'], 'Test Doc');
        expect(result['version'], 1);
      });

      test('returns empty map when metadata lacks toJson()', () {
        final meta = _MetaWithoutToJson(title: 'Test');
        final model = _ModelWithBadMeta(content: 'Hello', metaData: meta);
        expect(model.metaDataToJsonMap(), isEmpty);
        expect(model.metaDataToJsonMap(), equals({}));
      });
    });

    group('convertToJson', () {
      test('from JSON primary returns toJson result', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final result = model.convertToJson();
        expect(result, equals({'name': 'Test', 'age': 25}));
      });

      test('from YAML primary converts YAML to JSON', () {
        final model = _YamlOnlyModel(name: 'Test', age: 25);
        final result = model.convertToJson();
        expect(result, isNotNull);
        expect(result!['name'], 'Test');
        expect(result['age'], 25);
      });

      test('from Markdown primary converts Markdown to JSON', () {
        final model = _MarkdownWithFrontmatterModel(
          title: 'My Title',
          description: 'Desc',
          body: '{"key": "value"}',
        );
        final result = model.convertToJson();
        expect(result, isNotNull);
        expect(result!['title'], 'My Title');
      });

      test('from XML primary converts XML to JSON', () {
        final model = _XmlOnlyModel(name: 'Test', age: 25);
        final result = model.convertToJson();
        expect(result, isNotNull);
        expect(result!['name'], 'Test');
        expect(result['age'], 25);
      });

      test('returns null when primary impl returns null', () {
        final model = MinimalModel();
        expect(model.convertToJson(), isNull);
      });
    });

    group('convertToYaml', () {
      test('from JSON primary converts to YAML', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final result = model.convertToYaml();
        expect(result, isNotNull);
        expect(result, contains('name: Test'));
        expect(result, contains('age: 25'));
      });

      test('includes metadata when requested', () {
        final meta = _MetaWithToJson(title: 'Doc Title', version: 2);
        final model = _ModelWithMeta(content: 'Hello', metaData: meta);
        final result = model.convertToYaml(includeMetaData: true);
        expect(result, isNotNull);
        expect(result, contains('_meta:'));
        expect(result, contains('title: Doc Title'));
      });

      test('excludes metadata when not requested', () {
        final meta = _MetaWithToJson(title: 'Doc Title', version: 2);
        final model = _ModelWithMeta(content: 'Hello', metaData: meta);
        final result = model.convertToYaml(includeMetaData: false);
        expect(result, isNotNull);
        expect(result, isNot(contains('_meta:')));
      });

      test('from YAML primary returns toYaml result', () {
        final model = _YamlOnlyModel(name: 'Test', age: 25);
        final result = model.convertToYaml();
        expect(result, contains('name: Test'));
      });

      test('returns null when primary impl returns null', () {
        final model = MinimalModel();
        expect(model.convertToYaml(), isNull);
      });
    });

    group('convertToMarkdown', () {
      test('from JSON primary converts to Markdown', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final result = model.convertToMarkdown();
        expect(result, isNotNull);
        expect(result, contains('## Name'));
        expect(result, contains('Test'));
      });

      test('includes metadata as frontmatter', () {
        final meta = _MetaWithToJson(title: 'Doc', version: 1);
        final model = _ModelWithMeta(content: 'Hello', metaData: meta);
        final result = model.convertToMarkdown(includeMetaData: true);
        expect(result, isNotNull);
        expect(result, contains('---'));
        expect(result, contains('title: Doc'));
      });

      test('generates markdown with headers', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final result = model.convertToMarkdown();
        expect(result, isNotNull);
        expect(result, contains('## Name'));
        expect(result, contains('Test'));
      });

      test('combines metadata and headers', () {
        final meta = _MetaWithToJson(title: 'Doc', version: 1);
        final model = _ModelWithMeta(content: 'Hello', metaData: meta);
        final result = model.convertToMarkdown(
          includeMetaData: true,
        );
        expect(result, isNotNull);
        expect(result, contains('---'));
        expect(result, contains('## Content'));
      });

      test('returns null when primary impl returns null', () {
        final model = MinimalModel();
        expect(model.convertToMarkdown(), isNull);
      });
    });

    group('convertToXml', () {
      test('from JSON primary converts to XML', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final result = model.convertToXml();
        expect(result, isNotNull);
        expect(result, contains('<name>Test</name>'));
        expect(result, contains('<age>25</age>'));
      });

      test('uses custom root element name', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final result = model.convertToXml(rootElementName: 'CustomRoot');
        expect(result, isNotNull);
        expect(result, contains('<CustomRoot>'));
      });

      test('includes metadata when requested', () {
        final meta = _MetaWithToJson(title: 'Doc', version: 1);
        final model = _ModelWithMeta(content: 'Hello', metaData: meta);
        final result = model.convertToXml(includeMetaData: true);
        expect(result, isNotNull);
        expect(result, contains('<_meta>'));
        expect(result, contains('<title>Doc</title>'));
      });

      test('uses PascalCase when requested', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final result = model.convertToXml(caseStyle: CaseStyle.pascalCase);
        expect(result, isNotNull);
        expect(result, contains('<Name>Test</Name>'));
        expect(result, contains('<Age>25</Age>'));
      });

      test('uses camelCase when requested', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final result = model.convertToXml(caseStyle: CaseStyle.camelCase);
        expect(result, isNotNull);
        expect(result, contains('<name>Test</name>'));
        expect(result, contains('<age>25</age>'));
      });

      test('uses snakeCase when requested', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final result = model.convertToXml(caseStyle: CaseStyle.snakeCase);
        expect(result, isNotNull);
        expect(result, contains('<name>Test</name>'));
        expect(result, contains('<age>25</age>'));
      });

      test('uses kebabCase when requested', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final result = model.convertToXml(caseStyle: CaseStyle.kebabCase);
        expect(result, isNotNull);
        expect(result, contains('<name>Test</name>'));
        expect(result, contains('<age>25</age>'));
      });

      test('uses none case style when requested', () {
        final model = _JsonOnlyModel(name: 'Test', age: 25);
        final result = model.convertToXml(caseStyle: CaseStyle.none);
        expect(result, isNotNull);
        expect(result, contains('<name>Test</name>'));
        expect(result, contains('<age>25</age>'));
      });

      test('includes null values when requested', () {
        final model = _NullableModel(name: 'Test', value: null);
        final result = model.convertToXml(includeNulls: true);
        expect(result, isNotNull);
        expect(result, contains('<value>'));
      });

      test('excludes null values by default', () {
        final model = _NullableModel(name: 'Test', value: null);
        final result = model.convertToXml(includeNulls: false);
        expect(result, isNotNull);
        expect(result, isNot(contains('<value>')));
      });

      test('returns null when primary impl returns null', () {
        final model = MinimalModel();
        expect(model.convertToXml(), isNull);
      });
    });
  });
}

// Helper classes for testing

class _YamlOnlyModel extends TurboSerializable<Object?> {
  final String name;
  final int age;

  _YamlOnlyModel({
    required this.name,
    required this.age,
  }) : super(config: TurboSerializableConfig(
          toYaml: (instance) {
            final self = instance as _YamlOnlyModel;
            return 'name: ${self.name}\nage: ${self.age}\n';
          },
        ));
}

class _MarkdownOnlyModel extends TurboSerializable<Object?> {
  final String content;

  _MarkdownOnlyModel({
    required this.content,
  }) : super(config: TurboSerializableConfig(
          toMarkdown: (instance) {
            final self = instance as _MarkdownOnlyModel;
            return self.content;
          },
        ));
}

class _MarkdownWithFrontmatterModel extends TurboSerializable<Object?> {
  final String title;
  final String description;
  final String body;

  _MarkdownWithFrontmatterModel({
    required this.title,
    required this.description,
    required this.body,
  }) : super(config: TurboSerializableConfig(
          toMarkdown: (instance) {
            final self = instance as _MarkdownWithFrontmatterModel;
            return '''
---
title: ${self.title}
description: ${self.description}
---
${self.body}
''';
          },
        ));
}

class _XmlOnlyModel extends TurboSerializable<Object?> {
  final String name;
  final int age;

  _XmlOnlyModel({
    required this.name,
    required this.age,
  }) : super(config: TurboSerializableConfig(
          toXml: (instance,
              {String? rootElementName,
              bool includeNulls = false,
              bool prettyPrint = true,
              bool includeMetaData = true,
              CaseStyle caseStyle = CaseStyle.none}) {
            final self = instance as _XmlOnlyModel;
            final elementName = rootElementName ?? 'XmlOnlyModel';
            return '<?xml version="1.0" encoding="UTF-8"?>\n<$elementName>\n  <name>${self.name}</name>\n  <age>${self.age}</age>\n</$elementName>';
          },
        ));
}

class _TestIntIdModel extends TurboSerializableId<int, Object?> {
  final int _id;
  final String name;

  _TestIntIdModel({
    required int id,
    required this.name,
  })  : _id = id,
        super(
            config: TurboSerializableConfig(
          toJson: (_) => null,
        ));

  @override
  int get id => _id;
}

class _JsonOnlyModel extends TurboSerializable<Object?> {
  final String name;
  final int age;

  _JsonOnlyModel({
    required this.name,
    required this.age,
  }) : super(config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as _JsonOnlyModel;
            return {'name': self.name, 'age': self.age};
          },
        ));
}

class _NestedModel extends TurboSerializable<Object?> {
  final String name;
  final _JsonOnlyModel? child;

  _NestedModel({
    required this.name,
    this.child,
  }) : super(config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as _NestedModel;
            return {
              'name': self.name,
              if (self.child != null) 'child': self.child!.toJson(),
            };
          },
        ));
}

class _ListModel extends TurboSerializable<Object?> {
  final List<String> items;

  _ListModel({required this.items})
      : super(config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as _ListModel;
            return {'items': self.items};
          },
        ));
}

class _NullableModel extends TurboSerializable<Object?> {
  final String name;
  final String? value;

  _NullableModel({
    required this.name,
    this.value,
  }) : super(config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as _NullableModel;
            return {
              'name': self.name,
              'value': self.value,
            };
          },
        ));
}

class _DeeplyNestedModel extends TurboSerializable<Object?> {
  _DeeplyNestedModel()
      : super(
            config: TurboSerializableConfig(
          toJson: (_) => {
            'level1': {
              'level2': {
                'level3': {'value': 'deep'}
              }
            }
          },
        ));
}

class _EmptyCollectionsModel extends TurboSerializable<Object?> {
  _EmptyCollectionsModel()
      : super(
            config: TurboSerializableConfig(
          toJson: (_) => {
            'emptyList': <String>[],
            'emptyMap': <String, dynamic>{},
          },
        ));
}

class _BooleanModel extends TurboSerializable<Object?> {
  final bool active;
  final bool deleted;

  _BooleanModel({required this.active, required this.deleted})
      : super(config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as _BooleanModel;
            return {
              'active': self.active,
              'deleted': self.deleted,
            };
          },
        ));
}

class _NumericModel extends TurboSerializable<Object?> {
  final int intValue;
  final double doubleValue;
  final int negativeValue;

  _NumericModel({
    required this.intValue,
    required this.doubleValue,
    required this.negativeValue,
  }) : super(config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as _NumericModel;
            return {
              'intValue': self.intValue,
              'doubleValue': self.doubleValue,
              'negativeValue': self.negativeValue,
            };
          },
        ));
}

class _MetaWithToJson implements HasToJson {
  final String title;
  final int version;

  _MetaWithToJson({required this.title, required this.version});

  @override
  Map<String, dynamic> toJson() => {'title': title, 'version': version};
}

class _MetaWithoutToJson {
  final String title;

  _MetaWithoutToJson({required this.title});
}

class _ModelWithMeta extends TurboSerializable<_MetaWithToJson> {
  final String content;

  _ModelWithMeta({required this.content, super.metaData})
      : super(config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as _ModelWithMeta;
            return {'content': self.content};
          },
        ));
}

class _ModelWithBadMeta extends TurboSerializable<_MetaWithoutToJson> {
  final String content;

  _ModelWithBadMeta({required this.content, super.metaData})
      : super(config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as _ModelWithBadMeta;
            return {'content': self.content};
          },
        ));
}
