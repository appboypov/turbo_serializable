# Architecture

## Overview

`turbo_serializable` is a serialization abstraction library for the turbo ecosystem that provides multi-format support (JSON, YAML, Markdown, XML). The library enables developers to specify serialization logic for one primary format and automatically converts to all other supported formats. It also provides standalone converter functions for direct format-to-format transformations.

**Key Design Principles:**
- **Primary Format Pattern**: Implement one format, get automatic conversion to others
- **Callback-Based Configuration**: Serialization logic provided via callbacks in `TurboSerializableConfig`
- **Type Safety**: Generic type parameters for metadata (`M`) and identifiers (`T`)
- **Standalone Utilities**: Format converters can be used independently without class inheritance
- **Metadata Support**: Optional typed metadata for frontmatter and auxiliary data

## Technology Stack

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| Language | Dart | >=3.0.0 <4.0.0 | Core language |
| Serialization | `yaml` | ^3.1.0 | YAML parsing and generation |
| Serialization | `xml` | ^6.3.0 | XML parsing and generation |
| Utilities | `change_case` | ^1.0.0 | String case transformation |
| Utilities | `meta` | ^1.9.0 | Annotations and metadata |
| Response | `turbo_response` | ^1.0.1 | Validation response types |
| Testing | `test` | ^1.24.0 | Unit and integration testing |
| Linting | `lints` | ^3.0.0 | Code quality checks |

## Project Structure

```
turbo_serializable/
├── lib/
│   ├── abstracts/              # Abstract base classes and interfaces
│   │   ├── has_to_json.dart           # HasToJson interface
│   │   ├── turbo_serializable.dart    # TurboSerializable base class
│   │   └── turbo_serializable_id.dart # TurboSerializableId with typed ID
│   ├── constants/
│   │   └── turbo_constants.dart       # Centralized constants
│   ├── converters/              # Format conversion utilities
│   │   ├── case_converter.dart        # Case style transformation
│   │   ├── format_converters.dart     # 12 standalone format converters
│   │   └── xml_converter.dart         # XML-specific conversion functions
│   ├── enums/
│   │   ├── case_style.dart            # CaseStyle enumeration
│   │   └── serialization_format.dart  # SerializationFormat enumeration
│   ├── generators/             # Layout-aware output generators
│   │   ├── json_generator.dart        # JSON generation with formatting
│   │   ├── markdown_generator.dart    # Markdown generation with layout
│   │   ├── xml_generator.dart         # XML generation with metadata
│   │   └── yaml_generator.dart        # YAML generation with style preservation
│   ├── models/
│   │   ├── turbo_serializable_config.dart # Configuration class
│   │   ├── key_metadata.dart          # Per-key layout metadata
│   │   ├── layout_aware_parse_result.dart # Parse result with metadata
│   │   ├── json_meta.dart             # JSON formatting metadata
│   │   ├── yaml_meta.dart             # YAML style metadata
│   │   ├── xml_meta.dart              # XML attribute/namespace metadata
│   │   └── ...                        # Additional metadata models
│   ├── parsers/                # Layout-aware input parsers
│   │   ├── json_parser.dart           # JSON parsing with format detection
│   │   ├── markdown_parser.dart       # Markdown parsing with structure
│   │   ├── xml_parser.dart            # XML parsing with attribute extraction
│   │   └── yaml_parser.dart           # YAML parsing with anchor/style detection
│   └── turbo_serializable.dart        # Main library export file
├── test/
│   ├── format_converters_test.dart    # Unit tests for converters
│   ├── import_test.dart               # Import/export verification
│   ├── turbo_serializable_test.dart   # Unit tests for base classes
│   ├── xml_converter_test.dart        # Unit tests for XML converter
│   └── integration/
│       ├── input/                     # Test input files (JSON, YAML, XML, Markdown)
│       ├── output/                    # Expected output files
│       └── integration_test.dart      # Integration test suite
├── example/
│   └── main.dart                      # Usage examples
└── pubspec.yaml                       # Package dependencies and metadata
```

## Component Inventory

### Abstracts / Interfaces

| Name | Path | Purpose | Type Parameters |
|------|------|---------|----------------|
| `HasToJson` | `lib/abstracts/has_to_json.dart` | Interface for objects that can serialize to JSON. Used to constrain metadata types. | None |
| `TurboSerializable<M>` | `lib/abstracts/turbo_serializable.dart` | Base abstract class for serializable objects. Provides automatic format conversion from primary format. | `M` - Metadata type |
| `TurboSerializableId<T, M>` | `lib/abstracts/turbo_serializable_id.dart` | Extends `TurboSerializable` with typed identifier and local state tracking. | `T` - ID type, `M` - Metadata type |

**Key Methods:**
- `TurboSerializable`: `toJson()`, `toYaml()`, `toMarkdown()`, `toXml()`, `validate()`
- `TurboSerializableId`: Inherits all methods, adds `id` getter

### Models / DTOs

| Name | Path | Purpose | Properties |
|------|------|---------|------------|
| `TurboSerializableConfig` | `lib/models/turbo_serializable_config.dart` | Configuration class that holds callbacks for serialization methods. Automatically determines primary format from provided callbacks. | `toJson`, `toYaml`, `toMarkdown`, `toXml` (callbacks), `primaryFormat` (computed) |
| `LayoutAwareParseResult` | `lib/models/layout_aware_parse_result.dart` | Parse result containing both data and layout metadata for round-trip fidelity. | `data`, `keyMeta` |
| `KeyMetadata` | `lib/models/key_metadata.dart` | Per-key layout metadata containing format-specific information. | `yamlMeta`, `markdownMeta`, `xmlMeta`, `jsonMeta`, `children` |
| `YamlMeta` | `lib/models/yaml_meta.dart` | YAML-specific metadata for style preservation. | `anchor`, `alias`, `style`, `scalarStyle`, `comment` |
| `XmlMeta` | `lib/models/xml_meta.dart` | XML-specific metadata for attribute/namespace preservation. | `attributes`, `isCdata`, `comment`, `namespace`, `prefix` |
| `JsonMeta` | `lib/models/json_meta.dart` | JSON formatting metadata. | `indentSpaces`, `useTabs`, `trailingComma` |

**Primary Format Priority:** json > yaml > markdown > xml

### Enums

| Name | Path | Purpose | Values |
|------|------|---------|--------|
| `SerializationFormat` | `lib/enums/serialization_format.dart` | Enumeration of supported serialization formats | `json`, `yaml`, `markdown`, `xml` |
| `CaseStyle` | `lib/enums/case_style.dart` | Enumeration of string casing styles for transformation | `none`, `camelCase`, `pascalCase`, `snakeCase`, `kebabCase` |

### Converters / Utilities

| Name | Path | Purpose | Dependencies |
|------|------|---------|---------------|
| `format_converters.dart` | `lib/converters/format_converters.dart` | Contains 12 standalone format conversion functions: `jsonToYaml`, `jsonToMarkdown`, `jsonToXml`, `yamlToJson`, `yamlToMarkdown`, `yamlToXml`, `markdownToJson`, `markdownToYaml`, `markdownToXml`, `xmlToJson`, `xmlToYaml`, `xmlToMarkdown`. Also includes helper functions for filtering nulls, converting maps to YAML/Markdown, and parsing YAML documents. | `yaml`, `xml`, `turbo_constants`, `case_converter`, `xml_converter` |
| `xml_converter.dart` | `lib/converters/xml_converter.dart` | XML-specific conversion functions: `jsonToXml`, `xmlToMap`. Includes XML building and parsing utilities. | `xml`, `turbo_constants`, `case_converter` |
| `case_converter.dart` | `lib/converters/case_converter.dart` | Utility function `convertCase()` for transforming strings between case styles using `change_case` package. | `change_case`, `case_style` |

**Standalone Converter Functions:**
- JSON → YAML, Markdown, XML
- YAML → JSON, Markdown, XML
- Markdown → JSON, YAML, XML
- XML → JSON, YAML, Markdown

### Parsers

| Name | Path | Purpose | Extracts |
|------|------|---------|----------|
| `YamlLayoutParser` | `lib/parsers/yaml_parser.dart` | Parses YAML with layout metadata extraction | Anchors, aliases, comments, scalar styles, block/flow indicators |
| `MarkdownLayoutParser` | `lib/parsers/markdown_parser.dart` | Parses Markdown with structure metadata | Header levels, list styles, frontmatter boundaries |
| `XmlLayoutParser` | `lib/parsers/xml_parser.dart` | Parses XML with attribute/namespace extraction | Attributes, CDATA, namespaces, prefixes, comments |
| `JsonLayoutParser` | `lib/parsers/json_parser.dart` | Parses JSON with formatting detection | Indentation style, minification detection |

### Generators

| Name | Path | Purpose | Preserves |
|------|------|---------|-----------|
| `YamlLayoutGenerator` | `lib/generators/yaml_generator.dart` | Generates YAML using layout metadata | Anchors, aliases, comments, scalar/collection styles |
| `MarkdownLayoutGenerator` | `lib/generators/markdown_generator.dart` | Generates Markdown using layout metadata | Header levels, list styles, frontmatter |
| `XmlLayoutGenerator` | `lib/generators/xml_generator.dart` | Generates XML using layout metadata | Attributes, CDATA, namespaces |
| `JsonLayoutGenerator` | `lib/generators/json_generator.dart` | Generates JSON with formatting options | Indentation, spacing |

### Constants

| Name | Path | Purpose | Key Constants |
|------|------|---------|---------------|
| `TurboConstants` | `lib/constants/turbo_constants.dart` | Centralized constants for metadata keys, XML defaults, Markdown formatting, and error messages | `metaKey`, `textKey`, `bodyKey`, `defaultRootElement`, `frontmatterDelimiter`, `markdownHeaderLevel*`, `indentSpaces`, error message factories |

## Architecture Patterns

### Primary Format Pattern

The library uses a "primary format" pattern where:
1. Users provide callbacks for one or more serialization formats
2. The primary format is automatically determined (priority: json > yaml > markdown > xml)
3. All other formats are automatically converted from the primary format
4. If a specific format callback is provided, it takes precedence over conversion

**Example:**
```dart
// User provides only toJson callback
config: TurboSerializableConfig(
  toJson: (instance) => {...},
)
// Primary format = json
// toYaml(), toMarkdown(), toXml() automatically convert from JSON
```

### Callback-Based Configuration

Serialization logic is provided via callbacks rather than requiring method overrides:
- **Flexibility**: Can use closures or function references
- **Separation**: Configuration separated from class definition
- **Testing**: Easier to mock and test serialization logic

### Format Conversion Pipeline

All format conversions follow this pattern:
1. **Direct Callback**: If format-specific callback exists, use it
2. **Primary Format**: Otherwise, get data from primary format callback
3. **Conversion**: Convert primary format to target format using standalone converters
4. **Metadata**: Optionally merge metadata (frontmatter for Markdown, `_meta` element for XML, etc.)

### Type Safety with Generics

- `TurboSerializable<M>`: Generic metadata type `M` for frontmatter/auxiliary data
- `TurboSerializableId<T, M>`: Generic ID type `T` and metadata type `M`
- `HasToJson`: Interface constraint for metadata that can serialize to JSON

## Data Flow

### Serialization Flow

```
User Object (extends TurboSerializable)
    ↓
TurboSerializableConfig (callbacks)
    ↓
Primary Format Callback (e.g., toJson)
    ↓
Format Conversion (if needed)
    ↓
Target Format Output (JSON/YAML/Markdown/XML)
```

### Format Conversion Flow

```
Source Format (JSON/YAML/Markdown/XML)
    ↓
Parse to Intermediate Format (Map<String, dynamic>)
    ↓
Apply Transformations (case style, null filtering, metadata merging)
    ↓
Serialize to Target Format
    ↓
Target Format Output
```

### Metadata Flow

```
TurboSerializable.metaData (M?)
    ↓
metaDataToJsonMap() (if M implements HasToJson)
    ↓
Format-Specific Integration:
  - JSON/YAML: Added as `_meta` key
  - Markdown: Added as YAML frontmatter
  - XML: Added as `_meta` element
```

## Dependency Graph

### Core Dependencies

```
TurboSerializable
    ├── TurboSerializableConfig (configuration)
    ├── TurboConstants (constants)
    ├── SerializationFormat (enum)
    ├── format_converters (conversion utilities)
    └── xml_converter (XML utilities)

format_converters
    ├── yaml (YAML parsing)
    ├── xml_converter (XML conversion)
    ├── case_converter (case transformation)
    └── TurboConstants (constants)

xml_converter
    ├── xml (XML parsing/generation)
    ├── case_converter (case transformation)
    └── TurboConstants (constants)

case_converter
    └── change_case (case transformation library)
```

### External Dependencies

- `yaml` (^3.1.0): YAML parsing and document handling
- `xml` (^6.3.0): XML parsing, building, and document manipulation
- `change_case` (^1.0.0): String case transformation utilities
- `turbo_response` (^1.0.1): Validation response types
- `meta` (^1.9.0): Dart annotations and metadata utilities

## Configuration

### TurboSerializableConfig

Configuration is provided via constructor callbacks:

```dart
TurboSerializableConfig({
  Map<String, dynamic>? Function(TurboSerializable)? toJson,
  String? Function(TurboSerializable)? toYaml,
  String? Function(TurboSerializable)? toMarkdown,
  String? Function(TurboSerializable, {...})? toXml,
})
```

**Constraints:**
- At least one callback must be provided (assertion enforced)
- Primary format determined automatically from callback availability
- Callbacks can return `null` to indicate "not supported"

### Format-Specific Options

**JSON:**
- `includeMetaData`: Include metadata under `_meta` key
- `includeNulls`: Include null values in output

**YAML:**
- `includeMetaData`: Include metadata under `_meta` key
- `includeNulls`: Include null values
- `prettyPrint`: Format with indentation

**Markdown:**
- `includeMetaData`: Include metadata as YAML frontmatter
- `includeNulls`: Include null values
- `prettyPrint`: Add spacing between sections

**XML:**
- `rootElementName`: Root element name (defaults to class name)
- `includeNulls`: Include null values
- `prettyPrint`: Format with indentation
- `includeMetaData`: Include metadata as `_meta` element
- `caseStyle`: Case transformation for element names

## Testing Structure

### Unit Tests

| Test File | Path | Purpose |
|-----------|------|---------|
| `turbo_serializable_test.dart` | `test/turbo_serializable_test.dart` | Tests for `TurboSerializable` and `TurboSerializableId` classes, including format conversion, metadata handling, and validation |
| `format_converters_test.dart` | `test/format_converters_test.dart` | Tests for all 12 standalone format converter functions, edge cases, and helper utilities |
| `xml_converter_test.dart` | `test/xml_converter_test.dart` | Tests for XML-specific conversion functions, parsing, and building |
| `import_test.dart` | `test/import_test.dart` | Verifies all exports are accessible from main library file |

### Integration Tests

| Test File | Path | Purpose |
|-----------|------|---------|
| `integration_test.dart` | `test/integration/integration_test.dart` | Comprehensive integration tests that read input files from `test/integration/input/` and verify output matches expected files in `test/integration/output/`. Tests all format combinations and edge cases. |

**Test Input Files:**
- `input/json/`: Basic JSON, arrays, deep nesting, edge values, snake_case
- `input/yaml/`: Basic YAML, boolean variants, edge values, multiline
- `input/xml/`: Basic XML, attributes, CDATA, mixed content, PascalCase, declarations
- `input/markdown/`: Edge cases, frontmatter (JSON/text), headers only, rich content

**Test Output Files:**
- `output/`: Expected output files for all format conversion combinations (284+ tests)

### Test Coverage

- **Unit Tests**: Cover all public APIs, edge cases, null handling, error conditions
- **Integration Tests**: Verify round-trip conversions, format-specific features, metadata handling
- **Edge Cases**: Deep nesting (6 levels), unicode/emoji, empty collections, YAML anchors/aliases, XML declarations

## Conventions

### Naming Conventions

- **Classes**: PascalCase (e.g., `TurboSerializable`, `TurboSerializableConfig`)
- **Interfaces**: PascalCase with descriptive names (e.g., `HasToJson`)
- **Enums**: PascalCase (e.g., `SerializationFormat`, `CaseStyle`)
- **Functions**: camelCase (e.g., `jsonToYaml`, `convertCase`)
- **Constants**: camelCase in `TurboConstants` class (e.g., `metaKey`, `defaultRootElement`)

### Code Organization

- **Abstracts**: Base classes and interfaces in `abstracts/`
- **Models**: Data classes and configuration in `models/`
- **Converters**: Format conversion utilities in `converters/`
- **Enums**: Enumerations in `enums/`
- **Constants**: Centralized constants in `constants/`
- **Exports**: Main library file re-exports all public APIs

### Error Handling

- **Format Parsing**: Throws `FormatException` for invalid YAML/XML
- **Validation**: Returns `TurboResponse.fail()` for invalid objects (null = valid)
- **Null Safety**: Callbacks can return `null` to indicate "not supported"
- **Graceful Degradation**: If conversion fails, returns `null` rather than throwing

### Documentation

- **Public APIs**: All public classes, methods, and functions have dartdoc comments
- **Examples**: Usage examples in `example/main.dart` and README.md
- **Type Safety**: Generic type parameters documented with purpose
- **Parameters**: All function parameters documented with types and descriptions
