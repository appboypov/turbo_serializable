// ignore_for_file: avoid_print
import 'package:turbo_serializable/turbo_serializable.dart';
import 'package:turbo_response/turbo_response.dart';

/// Full implementation with all serialization methods
class FullModel extends TurboSerializable<Object?> {
  final String name;
  final int age;

  FullModel({required this.name, required this.age});

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

  @override
  Map<String, dynamic>? toJson() => {'name': name, 'age': age};

  @override
  String? toYaml() => 'name: $name\nage: $age';

  @override
  String? toMarkdown() => '# $name\n\nAge: $age';
}

/// Partial implementation with only toJson
class PartialModel extends TurboSerializable<Object?> {
  final String name;

  PartialModel(this.name);

  @override
  Map<String, dynamic>? toJson() => {'name': name};
}

/// Empty implementation - all methods return null
class EmptyModel extends TurboSerializable<Object?> {}

/// Full implementation with ID
class FullModelWithId extends TurboSerializableId<String, Object?> {
  final String _id;
  final String name;

  FullModelWithId({required String id, required this.name, super.isLocalDefault}) : _id = id;

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? toJson() => {'id': id, 'name': name};
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

  CustomIdModel(int idValue) : _id = CustomId(idValue);

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

  Document({required this.content, super.metaData});

  @override
  Map<String, dynamic>? toJson() => {'content': content};

  @override
  String? toMarkdown() => content;
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
  }) : _id = id;

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? toJson() => {'id': id, 'content': content};
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

  // Test 3: Partial implementation
  print('\nTest 3: Partial implementation (only toJson)');
  final partial = PartialModel('Bob');
  assert(partial.validate() == null, 'Default validate returns null');
  assert(partial.toJson() != null, 'toJson should work');
  assert(partial.toYaml() == null, 'Unimplemented toYaml returns null');
  assert(partial.toMarkdown() == null, 'Unimplemented toMarkdown returns null');
  print('  ✓ Partial implementation works correctly');

  // Test 4: Empty implementation
  print('\nTest 4: Empty implementation (all null)');
  final empty = EmptyModel();
  assert(empty.validate() == null, 'Default validate returns null');
  assert(empty.toJson() == null, 'Default toJson returns null');
  assert(empty.toYaml() == null, 'Default toYaml returns null');
  assert(empty.toMarkdown() == null, 'Default toMarkdown returns null');
  assert(empty.fromJson({}) == null, 'Default fromJson returns null');
  assert(empty.fromYaml('') == null, 'Default fromYaml returns null');
  assert(empty.fromMarkdown('') == null, 'Default fromMarkdown returns null');
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
  final localDefault = FullModelWithId(id: 'temp-id', name: 'Temp', isLocalDefault: true);
  assert(localDefault.isLocalDefault == true, 'isLocalDefault should be true');
  print('  ✓ isLocalDefault can be set to true');

  // Test 7: Custom ID type
  print('\nTest 7: Custom ID type');
  final customId = CustomIdModel(42);
  assert(customId.id.value == 42, 'Custom ID value should work');
  print('  ✓ Custom ID types work correctly');

  // Test 8: Type inheritance verification
  print('\nTest 8: Type inheritance verification');
  // Inheritance is verified by successful compilation - FullModel extends TurboSerializable,
  // FullModelWithId extends TurboSerializableId<String> which extends TurboSerializable
  assert(full.toJson() != null, 'FullModel inherits TurboSerializable methods');
  assert(withId.toJson() != null, 'TurboSerializableId inherits TurboSerializable methods');
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
  final doc = Document(content: '# Hello World\n\nThis is content.', metaData: docMeta);
  assert(doc.metaData != null, 'metaData should be set');
  assert(doc.metaData!.title == 'My Document', 'metaData title should match');
  assert(doc.metaData!.tags.length == 3, 'metaData tags should have 3 items');
  assert(doc.toMarkdown() == '# Hello World\n\nThis is content.', 'toMarkdown should return content');
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
  assert(docWithId.metaData!.title == 'Document With ID', 'metaData title should match');
  assert(docWithId.isLocalDefault == false, 'isLocalDefault should be false');
  print('  ✓ Metadata works with TurboSerializableId');

  // Test 11: Null metadata is valid
  print('\nTest 11: Null metadata is valid');
  final docNoMeta = Document(content: 'No meta');
  assert(docNoMeta.metaData == null, 'metaData should be null when not provided');
  assert(docNoMeta.toJson() != null, 'toJson should still work');
  print('  ✓ Null metadata is handled correctly');

  print('\n=== All validations passed! ===');
}
