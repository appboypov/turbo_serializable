import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

// Test concrete implementations - use Object? when no typed metadata needed
class TestModel extends TurboSerializable<Object?> {
  final String name;

  TestModel(this.name, {super.metaData});

  @override
  Map<String, dynamic>? toJson() => {'name': name};

  @override
  String? toYaml() => 'name: $name';

  @override
  String? toMarkdown() => '# $name';

  @override
  T? fromJson<T>(Map<String, dynamic> json) {
    if (T == TestModel) {
      return TestModel(json['name'] as String) as T;
    }
    return null;
  }

  @override
  T? fromYaml<T>(String yaml) {
    if (T == TestModel) {
      final name = yaml.replaceFirst('name: ', '');
      return TestModel(name) as T;
    }
    return null;
  }

  @override
  T? fromMarkdown<T>(String markdown) {
    if (T == TestModel) {
      final name = markdown.replaceFirst('# ', '');
      return TestModel(name) as T;
    }
    return null;
  }

  @override
  String? toXml() => '<name>$name</name>';

  @override
  T? fromXml<T>(String xml) {
    if (T == TestModel) {
      final name = xml.replaceAll('<name>', '').replaceAll('</name>', '');
      return TestModel(name) as T;
    }
    return null;
  }

  @override
  TurboResponse<T>? validate<T>() {
    if (name.isEmpty) {
      return TurboResponse.fail(
        error: 'Name cannot be empty',
      );
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
  }) : _id = id;

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? toJson() => {'id': id, 'name': name};

  @override
  TurboResponse<T>? validate<T>() {
    if (id.isEmpty) {
      return TurboResponse.fail(
        error: 'ID cannot be empty',
      );
    }
    if (name.isEmpty) {
      return TurboResponse.fail(
        error: 'Name cannot be empty',
      );
    }
    return null;
  }
}

// Minimal implementation that doesn't override anything
class MinimalModel extends TurboSerializable<Object?> {}

// Test model with typed metadata
class FrontmatterMeta {
  final String title;
  final String description;
  final List<String> tags;

  FrontmatterMeta({
    required this.title,
    required this.description,
    required this.tags,
  });
}

class DocumentModel extends TurboSerializable<FrontmatterMeta> {
  final String content;

  DocumentModel({
    required this.content,
    super.metaData,
  });

  @override
  Map<String, dynamic>? toJson() => {'content': content};

  @override
  String? toMarkdown() => content;
}

class DocumentWithId extends TurboSerializableId<String, FrontmatterMeta> {
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

      test('fromJson returns null by default', () {
        expect(model.fromJson<MinimalModel>({'test': 'data'}), isNull);
      });

      test('toYaml returns null by default', () {
        expect(model.toYaml(), isNull);
      });

      test('fromYaml returns null by default', () {
        expect(model.fromYaml<MinimalModel>('test: data'), isNull);
      });

      test('toMarkdown returns null by default', () {
        expect(model.toMarkdown(), isNull);
      });

      test('fromMarkdown returns null by default', () {
        expect(model.fromMarkdown<MinimalModel>('# Test'), isNull);
      });

      test('toXml returns null by default', () {
        expect(model.toXml(), isNull);
      });

      test('fromXml returns null by default', () {
        expect(model.fromXml<MinimalModel>('<test>data</test>'), isNull);
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

      test('can override fromJson', () {
        final model = TestModel('');
        final result = model.fromJson<TestModel>({'name': 'Jane'});
        expect(result, isNotNull);
        expect(result!.name, equals('Jane'));
      });

      test('fromJson returns null for wrong type', () {
        final model = TestModel('');
        final result = model.fromJson<MinimalModel>({'name': 'Jane'});
        expect(result, isNull);
      });

      test('can override toYaml', () {
        final model = TestModel('John');
        expect(model.toYaml(), equals('name: John'));
      });

      test('can override fromYaml', () {
        final model = TestModel('');
        final result = model.fromYaml<TestModel>('name: Jane');
        expect(result, isNotNull);
        expect(result!.name, equals('Jane'));
      });

      test('fromYaml returns null for wrong type', () {
        final model = TestModel('');
        final result = model.fromYaml<MinimalModel>('name: Jane');
        expect(result, isNull);
      });

      test('can override toMarkdown', () {
        final model = TestModel('John');
        expect(model.toMarkdown(), equals('# John'));
      });

      test('can override fromMarkdown', () {
        final model = TestModel('');
        final result = model.fromMarkdown<TestModel>('# Jane');
        expect(result, isNotNull);
        expect(result!.name, equals('Jane'));
      });

      test('fromMarkdown returns null for wrong type', () {
        final model = TestModel('');
        final result = model.fromMarkdown<MinimalModel>('# Jane');
        expect(result, isNull);
      });

      test('can override toXml', () {
        final model = TestModel('John');
        expect(model.toXml(), equals('<name>John</name>'));
      });

      test('can override fromXml', () {
        final model = TestModel('');
        final result = model.fromXml<TestModel>('<name>Jane</name>');
        expect(result, isNotNull);
        expect(result!.name, equals('Jane'));
      });

      test('fromXml returns null for wrong type', () {
        final model = TestModel('');
        final result = model.fromXml<MinimalModel>('<name>Jane</name>');
        expect(result, isNull);
      });

      test('can override validate to return null for valid state', () {
        final model = TestModel('John');
        expect(model.validate(), isNull);
      });

      test('can override validate to return TurboResponse.fail for invalid state', () {
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
        // Test with int id type
        final intIdModel = _TestIntIdModel(id: 42, name: 'Test');
        expect(intIdModel.id, equals(42));
        expect(intIdModel.id, isA<int>());

        // Test with String id type (already tested above)
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
        // Verify metadata is accessible through TurboSerializable type
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

      test('can override validate to return TurboResponse.fail for invalid id', () {
        final model = TestModelWithId(id: '', name: 'John');
        final result = model.validate<String>();
        expect(result, isNotNull);
        expect(result!.isSuccess, isFalse);
        expect(result.error, equals('ID cannot be empty'));
      });

      test('can override validate to return TurboResponse.fail for invalid name', () {
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
        // This test verifies that the generic type parameter works correctly
        final stringModel = TestModelWithId(id: 'abc', name: 'Test');
        expect(stringModel.id, isA<String>());

        final intModel = _TestIntIdModel(id: 123, name: 'Test');
        expect(intModel.id, isA<int>());

        // Verify they are both TurboSerializableId but with different types
        expect(stringModel, isA<TurboSerializableId<String, Object?>>());
        expect(intModel, isA<TurboSerializableId<int, Object?>>());
      });
    });
  });
}

// Helper class for testing different id types
class _TestIntIdModel extends TurboSerializableId<int, Object?> {
  final int _id;
  final String name;

  _TestIntIdModel({required int id, required this.name}) : _id = id;

  @override
  int get id => _id;
}
