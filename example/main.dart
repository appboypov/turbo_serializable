// ignore_for_file: avoid_print
import 'package:turbo_serializable/turbo_serializable.dart';
import 'package:turbo_response/turbo_response.dart';

/// Full implementation with all serialization methods
class FullModel extends TurboSerializable<Object?> {
  final String name;
  final int age;

  FullModel({
    required this.name,
    required this.age,
  }) : super(
            config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as FullModel;
            return {'name': self.name, 'age': self.age};
          },
          toYaml: (instance) {
            final self = instance as FullModel;
            return 'name: ${self.name}\nage: ${self.age}';
          },
          toMarkdown: (instance) {
            final self = instance as FullModel;
            return '# ${self.name}\n\nAge: ${self.age}';
          },
        ));

  @override
  TurboResponse<T>? validate<T>() {
    if (name.isEmpty) {
      return TurboResponse.fail(error: 'Name cannot be empty');
    }
    if (age < 0) {
      return TurboResponse.fail(error: 'Age cannot be negative');
    }
    return null;
  }
}

/// Partial implementation with only toJson
class PartialModel extends TurboSerializable<Object?> {
  final String name;

  PartialModel(this.name)
      : super(config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as PartialModel;
            return {'name': self.name};
          },
        ));
}

/// Empty implementation - all methods return null
class EmptyModel extends TurboSerializable<Object?> {
  EmptyModel({super.metaData})
      : super(
            config: TurboSerializableConfig(
          toJson: (_) => null,
        ));
}

/// Full implementation with ID
class FullModelWithId extends TurboSerializableId<String, Object?> {
  final String _id;
  final String name;

  FullModelWithId({
    required String id,
    required this.name,
    super.isLocalDefault,
  })  : _id = id,
        super(config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as FullModelWithId;
            return {'id': self.id, 'name': self.name};
          },
        ));

  @override
  String get id => _id;
}

/// Custom ID type implementation
class CustomId {
  final int value;
  const CustomId(this.value);
  @override
  String toString() => 'CustomId($value)';
}

class CustomIdModel extends TurboSerializableId<CustomId, Object?> {
  final CustomId _id;

  CustomIdModel(int idValue)
      : _id = CustomId(idValue),
        super(
            config: TurboSerializableConfig(
          toJson: (_) => null,
        ));

  @override
  CustomId get id => _id;
}

/// Frontmatter metadata example
class Frontmatter {
  final String title;
  final String description;
  final List<String> tags;
  final DateTime? publishedAt;

  Frontmatter({
    required this.title,
    required this.description,
    required this.tags,
    this.publishedAt,
  });
}

/// Document with frontmatter metadata
class Document extends TurboSerializable<Frontmatter> {
  final String content;

  Document({
    required this.content,
    super.metaData,
  }) : super(
            config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as Document;
            return {'content': self.content};
          },
          toMarkdown: (instance) {
            final self = instance as Document;
            return self.content;
          },
        ));
}

/// Document with ID and frontmatter metadata
class DocumentWithId extends TurboSerializableId<String, Frontmatter> {
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
  print('=== turbo_serializable Validation Script ===\n');

  // Test 1: Full implementation
  print('Test 1: Full implementation');
  final full = FullModel(name: 'Alice', age: 30);
  assert(full.validate() == null, 'Valid model should have null validate');
  assert(full.toJson() != null, 'toJson should return a map');
  assert(full.toJson()!['name'] == 'Alice', 'toJson should contain name');
  assert(full.toYaml() != null, 'toYaml should return a string');
  assert(full.toMarkdown() != null, 'toMarkdown should return a string');
  print('  ✓ All full model methods work correctly');

  // Test 2: Full implementation with invalid data
  print('\nTest 2: Validation with invalid data');
  final invalid = FullModel(name: '', age: 30);
  assert(invalid.validate() is Fail, 'Invalid model should fail validation');
  print('  ✓ Validation correctly rejects empty name');

  // Test 3: Partial implementation with auto-conversion
  print('\nTest 3: Partial implementation with auto-conversion');
  final partial = PartialModel('Bob');
  assert(partial.validate() == null, 'Default validate returns null');
  assert(partial.toJson() != null, 'toJson should work');
  // Auto-conversion from JSON to other formats
  assert(partial.toYaml() != null, 'toYaml converts from JSON');
  assert(partial.toMarkdown() != null, 'toMarkdown converts from JSON');
  assert(partial.toXml() != null, 'toXml converts from JSON');
  print('  ✓ Partial implementation auto-converts to other formats');

  // Test 4: Empty implementation
  print('\nTest 4: Empty implementation (all null)');
  final empty = EmptyModel();
  assert(empty.validate() == null, 'Default validate returns null');
  assert(empty.toJson() == null, 'Default toJson returns null');
  assert(empty.toYaml() == null, 'Default toYaml returns null');
  assert(empty.toMarkdown() == null, 'Default toMarkdown returns null');
  assert(empty.metaData == null, 'Default metaData is null');
  print('  ✓ Empty implementation returns null for all methods');

  // Test 5: TurboSerializableId with String ID
  print('\nTest 5: TurboSerializableId with String ID');
  final withId = FullModelWithId(id: 'user-123', name: 'Charlie');
  assert(withId.id == 'user-123', 'ID getter should work');
  assert(withId.isLocalDefault == false, 'isLocalDefault defaults to false');
  assert(withId.toJson()!['id'] == 'user-123', 'toJson should include id');
  print('  ✓ TurboSerializableId works with String ID');

  // Test 6: TurboSerializableId with isLocalDefault
  print('\nTest 6: TurboSerializableId with isLocalDefault=true');
  final localDefault =
      FullModelWithId(id: 'temp-id', name: 'Temp', isLocalDefault: true);
  assert(localDefault.isLocalDefault == true, 'isLocalDefault should be true');
  print('  ✓ isLocalDefault can be set to true');

  // Test 7: Custom ID type
  print('\nTest 7: Custom ID type');
  final customId = CustomIdModel(42);
  assert(customId.id.value == 42, 'Custom ID value should work');
  print('  ✓ Custom ID types work correctly');

  // Test 8: Type inheritance verification
  print('\nTest 8: Type inheritance verification');
  assert(full.toJson() != null, 'FullModel inherits TurboSerializable methods');
  assert(withId.toJson() != null,
      'TurboSerializableId inherits TurboSerializable methods');
  assert(withId.id.isNotEmpty, 'TurboSerializableId provides typed id getter');
  print('  ✓ Type inheritance is correct');

  // Test 9: Metadata with TurboSerializable
  print('\nTest 9: Metadata with TurboSerializable');
  final docMeta = Frontmatter(
    title: 'My Document',
    description: 'A sample document with frontmatter',
    tags: ['example', 'test', 'demo'],
    publishedAt: DateTime(2026, 1, 9),
  );
  final doc =
      Document(content: '# Hello World\n\nThis is content.', metaData: docMeta);
  assert(doc.metaData != null, 'metaData should be set');
  assert(doc.metaData!.title == 'My Document', 'metaData title should match');
  assert(doc.metaData!.tags.length == 3, 'metaData tags should have 3 items');
  assert(doc.toMarkdown() == '# Hello World\n\nThis is content.',
      'toMarkdown should return content');
  print('  ✓ Metadata works with TurboSerializable');

  // Test 10: Metadata with TurboSerializableId
  print('\nTest 10: Metadata with TurboSerializableId');
  final docWithIdMeta = Frontmatter(
    title: 'Document With ID',
    description: 'Has both ID and metadata',
    tags: ['id', 'meta'],
  );
  final docWithId = DocumentWithId(
    id: 'doc-001',
    content: 'Content here',
    metaData: docWithIdMeta,
    isLocalDefault: false,
  );
  assert(docWithId.id == 'doc-001', 'ID should be set');
  assert(docWithId.metaData != null, 'metaData should be set');
  assert(docWithId.metaData!.title == 'Document With ID',
      'metaData title should match');
  assert(docWithId.isLocalDefault == false, 'isLocalDefault should be false');
  print('  ✓ Metadata works with TurboSerializableId');

  // Test 11: Null metadata is valid
  print('\nTest 11: Null metadata is valid');
  final docNoMeta = Document(content: 'No meta');
  assert(
      docNoMeta.metaData == null, 'metaData should be null when not provided');
  assert(docNoMeta.toJson() != null, 'toJson should still work');
  print('  ✓ Null metadata is handled correctly');

  // Test 12: Format converters
  print('\nTest 12: Format converters');
  final yaml = jsonToYaml({'name': 'Test', 'age': 25});
  assert(yaml.contains('name: Test'), 'YAML should contain name');
  final json = yamlToJson('name: Test\nage: 25');
  assert(json['name'] == 'Test', 'JSON should contain name');
  print('  ✓ Format converters work correctly');

  // Test 13: Markdown with frontmatter
  print('\nTest 13: Markdown with frontmatter');
  final mdWithFrontmatter = jsonToMarkdown(
    {'content': 'Hello'},
    metaData: {'title': 'Test', 'author': 'Me'},
  );
  assert(
      mdWithFrontmatter.contains('---'), 'Should have frontmatter delimiters');
  assert(mdWithFrontmatter.contains('title: Test'),
      'Should have frontmatter content');
  final parsedMd = markdownToJson('---\ntitle: Test\n---\n{"key": "value"}');
  assert(parsedMd['title'] == 'Test', 'Should parse frontmatter');
  assert(parsedMd['body']['key'] == 'value', 'Should parse JSON body');
  print('  ✓ Markdown frontmatter works correctly');

  print('\n=== All validations passed! ===');
}
