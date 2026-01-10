# turbo_serializable

A serialization abstraction for the turbo ecosystem with optional multi-format support (JSON, YAML, Markdown).

## Features

- **Optional serialization methods**: All methods return null by default, implement only what you need
- **Multi-format support**: JSON, YAML, Markdown, and XML serialization
- **Validation integration**: Built-in validation using TurboResponse
- **Typed identifiers**: TurboSerializableId provides type-safe ID management
- **Local state tracking**: Track whether instances are local defaults or synced to remote
- **Typed metadata**: Optional `metaData` field for frontmatter, annotations, or auxiliary data

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  turbo_serializable: ^0.0.1
```

## Usage

### Basic TurboSerializable

Implement only the serialization methods you need. Use `void` as the metadata type if you don't need metadata:

```dart
import 'package:turbo_serializable/turbo_serializable.dart';
import 'package:turbo_response/turbo_response.dart';

class User extends TurboSerializable<void> {
  final String name;
  final int age;

  User({required this.name, required this.age});

  @override
  TurboResponse<T>? validate<T>() {
    if (name.isEmpty) {
      return TurboResponse.fail(error: 'Name cannot be empty');
    }
    if (age < 0) {
      return TurboResponse.fail(error: 'Age cannot be negative');
    }
    return null; // Valid
  }

  @override
  Map<String, dynamic>? toJson() => {
    'name': name,
    'age': age,
  };

  @override
  T? fromJson<T>(Map<String, dynamic> json) {
    if (T == User) {
      return User(
        name: json['name'] as String,
        age: json['age'] as int,
      ) as T;
    }
    return null;
  }
}
```

### TurboSerializableId with Typed Identifier

For objects that need a unique identifier. The second type parameter is for metadata:

```dart
import 'package:turbo_serializable/turbo_serializable.dart';

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
  Map<String, dynamic>? toJson() => {
    'id': id,
    'name': name,
    'price': price,
  };

  @override
  T? fromJson<T>(Map<String, dynamic> json) {
    if (T == Product) {
      return Product(
        productId: json['id'] as String,
        name: json['name'] as String,
        price: json['price'] as double,
        isLocalDefault: json['isLocalDefault'] as bool? ?? false,
      ) as T;
    }
    return null;
  }
}
```

### Typed Metadata

Use the type parameter `M` for typed metadata like frontmatter:

```dart
import 'package:turbo_serializable/turbo_serializable.dart';

class Frontmatter {
  final String title;
  final List<String> tags;

  Frontmatter({required this.title, required this.tags});
}

class Document extends TurboSerializable<Frontmatter> {
  final String content;

  Document({required this.content, super.metaData});

  @override
  String? toMarkdown() => content;
}

// Usage
final doc = Document(
  content: '# Hello World',
  metaData: Frontmatter(title: 'My Doc', tags: ['example']),
);
print(doc.metaData?.title); // 'My Doc'
```

### Optional Methods

All serialization methods are optional and return null by default. You only implement what you need:

- `validate()` - Validates the object's state
- `toJson()` / `fromJson()` - JSON serialization
- `toYaml()` / `fromYaml()` - YAML serialization
- `toMarkdown()` / `fromMarkdown()` - Markdown serialization
- `toXml()` / `fromXml()` - XML serialization
- `metaData` - Optional typed metadata (set via constructor)

## Turbo Ecosystem Integration

This package is part of the turbo ecosystem and integrates with:
- [turbo_response](https://pub.dev/packages/turbo_response) - For validation and result handling
- [turbo_firestore_api](https://pub.dev/packages/turbo_firestore_api) - Re-exports as `TurboWriteable`/`TurboWriteableId` for backwards compatibility

### Using with turbo_firestore_api

If you're using `turbo_firestore_api`, you can continue using `TurboWriteable` - it's a type alias for `TurboSerializable`:

```dart
import 'package:turbo_firestore_api/abstracts/turbo_writeable.dart';

class User extends TurboWriteable {
  final String name;

  User({required this.name});

  @override
  Map<String, dynamic>? toJson() => {'name': name};
}
```

## Additional Information

For issues and feature requests, visit the [issue tracker](https://github.com/appboypov/turbo_serializable/issues).
