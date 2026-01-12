# turbo_serializable

[![pub package](https://img.shields.io/pub/v/turbo_serializable.svg)](https://pub.dev/packages/turbo_serializable)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Dart 3](https://img.shields.io/badge/Dart-%3E%3D3.0.0-blue.svg)](https://dart.dev)

A serialization abstraction for the turbo ecosystem with multi-format support (JSON, YAML, Markdown, XML).

## Features

- **Primary format specification** - Provide callbacks for one format, get automatic conversion to all others. Primary format is determined by priority: json > yaml > markdown > xml
- **Multi-format support** - JSON, YAML, Markdown, and XML serialization
- **Standalone converters** - 12 format conversion functions for direct use
- **Typed metadata** - Generic `M` parameter for frontmatter and auxiliary data (implements `HasToJson` for serialization)
- **Typed identifiers** - `TurboSerializableId<T, M>` for objects with unique IDs
- **Local state tracking** - Track whether instances are synced to remote via `isLocalDefault` flag
- **Validation integration** - Built-in validation using TurboResponse
- **Case transformation** - Support for camelCase, PascalCase, snake_case, and kebab-case in XML serialization
- **Layout preservation** - Round-trip fidelity with `preserveLayout` parameter preserves formatting metadata (YAML anchors, comments, XML attributes, Markdown header levels)

## Installation

```yaml
dependencies:
  turbo_serializable: ^0.2.0
```

## Quick Start

```dart
import 'package:turbo_serializable/turbo_serializable.dart';

class User extends TurboSerializable<void> {
  final String name;
  final int age;

  User({required this.name, required this.age})
      : super(
            config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as User;
            return {'name': self.name, 'age': self.age};
          },
        ));
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
| `TurboSerializableConfig`   | Configuration class with callbacks for serialization methods                  |
| `HasToJson`                 | Interface for metadata types that can be serialized to JSON                   |
| `SerializationFormat`       | Enum: `json`, `yaml`, `markdown`, `xml`                                       |
| `CaseStyle`                 | Enum: `none`, `camelCase`, `pascalCase`, `snakeCase`, `kebabCase`            |
| `TurboConstants`            | Constants class for metadata keys, XML defaults, and error messages           |

### TurboSerializable Methods

| Method                                                                                | Returns                 | Description                                            |
|---------------------------------------------------------------------------------------|-------------------------|--------------------------------------------------------|
| `toJson({includeMetaData, includeNulls})`                                             | `Map<String, dynamic>?` | Serialize to JSON map. Returns null if callback not provided or returns null |
| `toYaml({includeMetaData, includeNulls, prettyPrint})`                                 | `String?`               | Serialize to YAML string. Returns null if callback not provided or returns null |
| `toMarkdown({includeMetaData, includeNulls, prettyPrint})`                             | `String?`               | Serialize to Markdown with headers. Returns null if callback not provided or returns null |
| `toXml({rootElementName, includeNulls, prettyPrint, includeMetaData, caseStyle})`      | `String?`               | Serialize to XML string. Returns null if callback not provided or returns null |
| `validate<T>()`                                                                       | `TurboResponse<T>?`     | Returns null if valid, `TurboResponse.fail` if invalid |

**Parameter Details:**
- `includeMetaData` (default: `true`) - Whether to include metadata in serialization
- `includeNulls` (default: `false`) - Whether to include null values in output
- `prettyPrint` (default: `true`) - Whether to format output with indentation/spacing
- `rootElementName` (optional) - Root element name for XML (defaults to class name)
- `caseStyle` (default: `CaseStyle.none`) - Case transformation for XML element names

### Standalone Converters

| Function                                 | Signature                                                                      | Description                                        |
|------------------------------------------|-------------------------------------------------------------------------------|----------------------------------------------------|
| `jsonToYaml`                             | `(Map, {metaData, includeNulls, prettyPrint})`                                | Convert JSON map to YAML string                    |
| `jsonToMarkdown`                          | `(Map, {metaData, includeNulls, prettyPrint})`                                | Convert JSON to Markdown with optional frontmatter |
| `jsonToXml`                               | `(Map, {rootElementName, includeNulls, prettyPrint, caseStyle, metaData})`    | Convert JSON map to XML string                     |
| `yamlToJson`                              | `(String)`                                                                     | Parse YAML string to JSON map. Throws `FormatException` if invalid |
| `yamlToMarkdown`                          | `(String, {metaData, includeNulls, prettyPrint})`                              | Convert YAML to Markdown                           |
| `yamlToXml`                               | `(String, {rootElementName, includeNulls, prettyPrint, caseStyle, metaData})` | Convert YAML to XML                                |
| `markdownToJson`                          | `(String)`                                                                     | Parse Markdown with frontmatter to JSON            |
| `markdownToYaml`                          | `(String, {metaData, includeNulls, prettyPrint})`                             | Convert Markdown to YAML                           |
| `markdownToXml`                           | `(String, {rootElementName, includeNulls, prettyPrint, caseStyle, metaData})`   | Convert Markdown to XML                            |
| `xmlToJson` / `xmlToMap`                  | `(String)`                                                                     | Parse XML to JSON map. Throws `FormatException` if invalid |
| `xmlToYaml`                               | `(String, {metaData, includeNulls, prettyPrint})`                              | Convert XML to YAML                                |
| `xmlToMarkdown`                           | `(String, {metaData, includeNulls, prettyPrint})`                              | Convert XML to Markdown                            |

**Common Parameters:**
- `metaData` (optional) - Map to include as metadata (`_meta` key in JSON/YAML, frontmatter in Markdown, `_meta` element in XML)
- `includeNulls` (default: `false`) - Whether to include null values
- `prettyPrint` (default: `true`) - Whether to format output
- `rootElementName` (optional) - Root element name for XML (defaults to `'root'`)
- `caseStyle` (default: `CaseStyle.none`) - Case transformation for XML element names
- `preserveLayout` (default: `false` for parsing) - Extract layout metadata for round-trip fidelity

### Utility Functions

| Function          | Signature                          | Description                                    |
|-------------------|------------------------------------|------------------------------------------------|
| `convertCase`     | `(String, CaseStyle)`              | Convert string to specified case style         |

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
    super.isLocalDefault = false, // Track if this is a local-only instance
  })
      : super(
            config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as Product;
            return {
              'id': self.id,
              'name': self.name,
              'price': self.price,
            };
          },
        ));

  @override
  String get id => productId;
}

// Usage
final product = Product(
  productId: 'prod-123',
  name: 'Widget',
  price: 29.99,
  isLocalDefault: true, // Not yet synced to remote
);
print(product.isLocalDefault); // true
```

### With Typed Metadata

```dart
class Frontmatter implements HasToJson {
  final String title;
  final List<String> tags;
  Frontmatter({required this.title, required this.tags});

  @override
  Map<String, dynamic> toJson() => {'title': title, 'tags': tags};
}

class Document extends TurboSerializable<Frontmatter> {
  final String content;

  Document({
    required this.content,
    super.metaData,
  })
      : super(
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

  User({required this.name, required this.age})
      : super(
            config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as User;
            return {'name': self.name, 'age': self.age};
          },
        ));

  @override
  TurboResponse<T>? validate<T>() {
    if (name.isEmpty) return TurboResponse.fail(error: 'Name required');
    if (age < 0) return TurboResponse.fail(error: 'Invalid age');
    return null;
  }
}
```

### Standalone Converters

```dart
// JSON to other formats
final yaml = jsonToYaml(
  {'name': 'Test', 'age': 25},
  prettyPrint: true,
  includeNulls: false,
);

final xml = jsonToXml(
  {'name': 'Test', 'age': 25},
  rootElementName: 'User',
  caseStyle: CaseStyle.pascalCase, // Converts to PascalCase
  prettyPrint: true,
);

// Parse YAML/XML back to JSON (may throw FormatException)
try {
  final json = yamlToJson('name: Test\nage: 25');
  final map = xmlToMap('<User><name>Test</name></User>');
} on FormatException catch (e) {
  print('Parse error: $e');
}

// Markdown with frontmatter
final md = jsonToMarkdown(
  {'content': 'Hello'},
  metaData: {'title': 'Test', 'author': 'Me'},
  prettyPrint: true,
);
// Output:
// ---
// title: Test
// author: Me
// ---
// ## Content
// Hello

// XML with case transformation
final xmlSnake = jsonToXml(
  {'userName': 'John', 'firstName': 'John'},
  rootElementName: 'user',
  caseStyle: CaseStyle.snakeCase, // Converts to snake_case
);
// Output: <user><user_name>John</user_name><first_name>John</first_name></user>
```

### Primary Format Determination

The primary format is automatically determined based on which callbacks you provide in `TurboSerializableConfig`. Priority order:

1. **JSON** - If `toJson` callback is provided
2. **YAML** - If `toYaml` callback is provided (and `toJson` is not)
3. **Markdown** - If `toMarkdown` callback is provided (and `toJson`/`toYaml` are not)
4. **XML** - If `toXml` callback is provided (and others are not)

You only need to provide **one** callback - all other formats are automatically converted from the primary format:

```dart
// Only provide JSON callback - get all formats automatically
class User extends TurboSerializable<void> {
  User() : super(config: TurboSerializableConfig(
    toJson: (instance) => {'name': 'Alice'}, // Primary format: JSON
  ));
  
  // All these work automatically:
  // - toJson() uses the callback directly
  // - toYaml() converts from JSON
  // - toMarkdown() converts from JSON
  // - toXml() converts from JSON
}
```

### Error Handling

- **Serialization methods** (`toJson`, `toYaml`, `toMarkdown`, `toXml`) return `null` if:
  - The callback is not provided in the config
  - The callback returns `null`
  
- **Parsing functions** (`yamlToJson`, `xmlToMap`, `markdownToJson`) throw `FormatException` if:
  - The input format is invalid
  - The input cannot be parsed

Always wrap parsing calls in try-catch blocks:

```dart
try {
  final json = yamlToJson(invalidYaml);
} on FormatException catch (e) {
  // Handle parsing error
}
```

## Additional Information

- [API Documentation](https://pub.dev/documentation/turbo_serializable/latest/)
- [GitHub Repository](https://github.com/appboypov/turbo_serializable)
- [Issue Tracker](https://github.com/appboypov/turbo_serializable/issues)

## License

MIT
