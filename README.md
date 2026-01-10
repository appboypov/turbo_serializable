# turbo_serializable

A serialization abstraction for the turbo ecosystem with optional multi-format support (JSON, YAML, Markdown, XML).

## Features

- **Primary format specification**: Specify which serialization method you implement (toJson, toYaml, toMarkdown, or toXml)
- **Automatic format conversion**: All other formats are automatically converted from your primary format
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

**Important**: You must specify a `primaryFormat` when creating a `TurboSerializable` instance. This indicates which serialization method you actually implement. All other formats will be automatically converted from your primary format.

Implement the primary format method using `toJsonImpl()`, `toYamlImpl()`, `toMarkdownImpl()`, or `toXmlImpl()`. Use `void` as the metadata type if you don't need metadata:

```dart
import 'package:turbo_serializable/turbo_serializable.dart';
import 'package:turbo_response/turbo_response.dart';

class User extends TurboSerializable<void> {
  final String name;
  final int age;

  User({
    required this.name,
    required this.age,
    super.primaryFormat = SerializationFormat.json,
  });

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

  // Override toJsonImpl() since primaryFormat is json
  @override
  Map<String, dynamic>? toJsonImpl() => {
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

  // toYaml(), toMarkdown(), and toXml() are automatically available
  // They convert from your primary format (JSON) automatically
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
    super.primaryFormat = SerializationFormat.json,
  });

  @override
  String get id => productId;

  @override
  Map<String, dynamic>? toJsonImpl() => {
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

  Document({
    required this.content,
    super.metaData,
    super.primaryFormat = SerializationFormat.markdown,
  });

  @override
  Map<String, dynamic>? toJsonImpl() => {'content': content};

  @override
  String? toMarkdownImpl() => content;
}

// Usage
final doc = Document(
  content: '# Hello World',
  metaData: Frontmatter(title: 'My Doc', tags: ['example']),
);
print(doc.metaData?.title); // 'My Doc'
```

### XML Serialization

XML serialization is automatically available for any class that implements `toJson()`. The default `toXml()` method converts your JSON representation to XML:

```dart
import 'package:turbo_serializable/turbo_serializable.dart';

class User extends TurboSerializable<void> {
  final String name;
  final int age;

  User({
    required this.name,
    required this.age,
    super.primaryFormat = SerializationFormat.json,
  });

  @override
  Map<String, dynamic>? toJsonImpl() => {
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

// Usage
final user = User(name: 'John', age: 30);
final xml = user.toXml();
// Output: <User><name>John</name><age>30</age></User>
// XML is automatically converted from JSON (the primary format)

final restored = user.fromXml<User>(xml!);
print(restored!.name); // 'John'
```

**XML Serialization Options:**

- `rootElementName`: Override the default root element name (defaults to class name)
- `includeNulls`: Whether to include null values in XML (default: false)
- `prettyPrint`: Whether to format XML with indentation (default: true)

```dart
// Custom root element name
final xml = user.toXml(rootElementName: 'Person');

// Include null values
final xmlWithNulls = user.toXml(includeNulls: true);

// Compact format
final compactXml = user.toXml(prettyPrint: false);
```

**Nested Objects and Lists:**

XML serialization automatically handles nested objects and lists:

```dart
class Address extends TurboSerializable<void> {
  final String street;
  final String city;
  
  Address({required this.street, required this.city});
  
  @override
  Map<String, dynamic>? toJson() => {'street': street, 'city': city};
  
  @override
  T? fromJson<T>(Map<String, dynamic> json) {
    if (T == Address) {
      return Address(
        street: json['street'] as String,
        city: json['city'] as String,
      ) as T;
    }
    return null;
  }
}

class Person extends TurboSerializable<void> {
  final String name;
  final Address address;
  final List<String> hobbies;
  
  Person({required this.name, required this.address, required this.hobbies});
  
  @override
  Map<String, dynamic>? toJson() => {
    'name': name,
    'address': address.toJson(),
    'hobbies': hobbies,
  };
  
  @override
  T? fromJson<T>(Map<String, dynamic> json) {
    if (T == Person) {
      return Person(
        name: json['name'] as String,
        address: Address.fromJson<Address>(json['address'] as Map<String, dynamic>)!,
        hobbies: (json['hobbies'] as List).cast<String>(),
      ) as T;
    }
    return null;
  }
}
```

**Generic Types with Converters:**

For classes with generic type parameters, you can override `toXmlWithConverters()` and `fromXmlWithConverters()`:

```dart
class GenericModel<T> extends TurboSerializable<void> {
  final T value;
  
  GenericModel({required this.value});
  
  @override
  String? toXmlWithConverters({
    String? rootElementName,
    bool includeNulls = false,
    bool prettyPrint = true,
    Map<String, Object? Function(dynamic)>? converters,
  }) {
    // Implement custom XML serialization with converters
    return null;
  }
}
```

### Primary Format and Automatic Conversions

When you specify a `primaryFormat`, you implement the corresponding `*Impl()` method:

- **JSON primary**: Override `toJsonImpl()` → `toYaml()`, `toMarkdown()`, `toXml()` are auto-converted
- **YAML primary**: Override `toYamlImpl()` → `toJson()`, `toMarkdown()`, `toXml()` are auto-converted
- **Markdown primary**: Override `toMarkdownImpl()` → `toJson()`, `toYaml()`, `toXml()` are auto-converted
- **XML primary**: Override `toXmlImpl()` → `toJson()`, `toYaml()`, `toMarkdown()` are auto-converted

### Example: YAML as Primary Format

```dart
class Config extends TurboSerializable<void> {
  final String host;
  final int port;

  Config({
    required this.host,
    required this.port,
    super.primaryFormat = SerializationFormat.yaml,
  });

  @override
  String? toYamlImpl() => 'host: $host\nport: $port\n';

  // toJson(), toMarkdown(), and toXml() automatically convert from YAML
}

final config = Config(host: 'localhost', port: 8080);
final json = config.toJson(); // Automatically converted from YAML
final xml = config.toXml(); // Automatically converted from YAML
```

### Optional Methods

- `validate()` - Validates the object's state
- `toJsonImpl()` / `fromJson()` - JSON serialization (override when primaryFormat is json)
- `toYamlImpl()` / `fromYaml()` - YAML serialization (override when primaryFormat is yaml)
- `toMarkdownImpl()` / `fromMarkdown()` - Markdown serialization (override when primaryFormat is markdown)
- `toXmlImpl()` / `fromXml()` - XML serialization (override when primaryFormat is xml)
- `toXmlWithConverters()` / `fromXmlWithConverters()` - XML serialization with type converters (for generic types)
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
