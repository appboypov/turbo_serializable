# turbo_serializable

[![pub package](https://img.shields.io/pub/v/turbo_serializable.svg)](https://pub.dev/packages/turbo_serializable)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Dart 3](https://img.shields.io/badge/Dart-%3E%3D3.0.0-blue.svg)](https://dart.dev)

A serialization abstraction for the turbo ecosystem with multi-format support (JSON, YAML, Markdown, XML).

## Features

- **Primary format specification** - Implement one format, get automatic conversion to all others
- **Multi-format support** - JSON, YAML, Markdown, and XML serialization
- **Standalone converters** - 12 format conversion functions for direct use
- **Typed metadata** - Generic `M` parameter for frontmatter and auxiliary data
- **Typed identifiers** - `TurboSerializableId<T, M>` for objects with unique IDs
- **Local state tracking** - Track whether instances are synced to remote
- **Validation integration** - Built-in validation using TurboResponse

## Installation

```yaml
dependencies:
  turbo_serializable: ^0.1.0
```

## Quick Start

```dart
import 'package:turbo_serializable/turbo_serializable.dart';

class User extends TurboSerializable<void> {
  final String name;
  final int age;

  User({required this.name, required this.age});

  @override
  Map<String, dynamic>? toJsonImpl() => {'name': name, 'age': age};
}

void main() {
  final user = User(name: 'Alice', age: 30);

  print(user.toJson());     // {name: Alice, age: 30}
  print(user.toYaml());     // name: Alice\nage: 30
  print(user.toXml());      // <User><name>Alice</name><age>30</age></User>
  print(user.toMarkdown()); // ## Name\nAlice\n\n## Age\n30
}
```

## API Reference

### Classes

| Class                       | Description                                                                   |
|-----------------------------|-------------------------------------------------------------------------------|
| `TurboSerializable<M>`      | Base class for serializable objects with optional metadata type `M`           |
| `TurboSerializableId<T, M>` | Extends TurboSerializable with typed identifier `T` and `isLocalDefault` flag |
| `SerializationFormat`       | Enum: `json`, `yaml`, `markdown`, `xml`                                       |

### TurboSerializable Methods

| Method                                                               | Returns                 | Description                                            |
|----------------------------------------------------------------------|-------------------------|--------------------------------------------------------|
| `toJson({includeMetaData})`                                          | `Map<String, dynamic>?` | Serialize to JSON map                                  |
| `toYaml({includeMetaData})`                                          | `String?`               | Serialize to YAML string                               |
| `toMarkdown({includeMetaData})`                                      | `String?`               | Serialize to Markdown with headers                     |
| `toXml({rootElementName, includeNulls, prettyPrint, usePascalCase})` | `String?`               | Serialize to XML string                                |
| `validate<T>()`                                                      | `TurboResponse<T>?`     | Returns null if valid, `TurboResponse.fail` if invalid |

### Standalone Converters

| Function                                 | Description                                        |
|------------------------------------------|----------------------------------------------------|
| `jsonToYaml(Map)`                        | Convert JSON map to YAML string                    |
| `jsonToMarkdown(Map, {metaData})`        | Convert JSON to Markdown with optional frontmatter |
| `jsonToXml(Map)` / `mapToXml(Map)`       | Convert JSON map to XML string                     |
| `yamlToJson(String)`                     | Parse YAML string to JSON map                      |
| `yamlToMarkdown(String)`                 | Convert YAML to Markdown                           |
| `yamlToXml(String)`                      | Convert YAML to XML                                |
| `markdownToJson(String)`                 | Parse Markdown with frontmatter to JSON            |
| `markdownToYaml(String)`                 | Convert Markdown to YAML                           |
| `markdownToXml(String)`                  | Convert Markdown to XML                            |
| `xmlToJson(String)` / `xmlToMap(String)` | Parse XML to JSON map                              |
| `xmlToYaml(String)`                      | Convert XML to YAML                                |
| `xmlToMarkdown(String)`                  | Convert XML to Markdown                            |

## Examples

### With Typed Identifier

```dart
class Product extends TurboSerializableId<String, void> {
  final String productId;
  final String name;
  final double price;

  Product({
    required this.productId,
    required this.name,
    required this.price,
    super.isLocalDefault = false,
  });

  @override
  String get id => productId;

  @override
  Map<String, dynamic>? toJsonImpl() => {
    'id': id,
    'name': name,
    'price': price,
  };
}
```

### With Typed Metadata

```dart
class Frontmatter {
  final String title;
  final List<String> tags;
  Frontmatter({required this.title, required this.tags});
}

class Document extends TurboSerializable<Frontmatter> {
  final String content;

  Document({
    required this.content,
    super.metaData,
    super.primaryFormat = SerializationFormat.markdown,
  });

  @override
  String? toMarkdownImpl() => content;
}

final doc = Document(
  content: '# Hello World',
  metaData: Frontmatter(title: 'My Doc', tags: ['example']),
);
print(doc.metaData?.title); // 'My Doc'
```

### With Validation

```dart
class User extends TurboSerializable<void> {
  final String name;
  final int age;

  User({required this.name, required this.age});

  @override
  TurboResponse<T>? validate<T>() {
    if (name.isEmpty) return TurboResponse.fail(error: 'Name required');
    if (age < 0) return TurboResponse.fail(error: 'Invalid age');
    return null;
  }

  @override
  Map<String, dynamic>? toJsonImpl() => {'name': name, 'age': age};
}
```

### Standalone Converters

```dart
// JSON to other formats
final yaml = jsonToYaml({'name': 'Test', 'age': 25});
final xml = mapToXml({'name': 'Test'}, rootElementName: 'User');

// Parse YAML/XML back to JSON
final json = yamlToJson('name: Test\nage: 25');
final map = xmlToMap('<User><name>Test</name></User>');

// Markdown with frontmatter
final md = jsonToMarkdown(
  {'content': 'Hello'},
  metaData: {'title': 'Test', 'author': 'Me'},
);
// Output:
// ---
// title: Test
// author: Me
// ---
// ## Content
// Hello
```

## License

MIT
