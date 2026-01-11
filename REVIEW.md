# Review Guidelines

## Purpose
This file defines how code reviews should be conducted in this project.
Run `/plx:refine-review` to populate project-specific review scope.

## Review Config
```yaml
review_types: [implementation, architecture]
feedback_format: marker
checklist_level: standard
```

## Feedback Format
```
#FEEDBACK #TODO | {feedback}
#FEEDBACK #TODO | {feedback} (spec:<spec-id>)
```

## Review Scope

### Architecture Patterns
<!-- Core architectural patterns; deviations need justification -->

**Primary Format Pattern**
- Implement one format, get automatic conversion to others
- Primary format priority: json > yaml > markdown > xml
- See: `lib/models/turbo_serializable_config.dart` (primaryFormat computation)
- See: `lib/abstracts/turbo_serializable.dart` (conversion methods)

**Callback-Based Configuration**
- Serialization logic provided via callbacks in `TurboSerializableConfig`
- At least one callback must be provided (assertion enforced)
- See: `lib/models/turbo_serializable_config.dart`

**Format Conversion Pipeline**
- Direct callback → Primary format → Conversion → Target format
- Metadata merging (frontmatter for Markdown, `_meta` element for XML)
- See: `lib/abstracts/turbo_serializable.dart` (toJson, toYaml, toMarkdown, toXml methods)
- See: `lib/converters/format_converters.dart` (12 standalone converters)

**Type Safety with Generics**
- `TurboSerializable<M>`: Generic metadata type
- `TurboSerializableId<T, M>`: Generic ID and metadata types
- `HasToJson`: Interface constraint for metadata serialization
- See: `lib/abstracts/turbo_serializable.dart`, `lib/abstracts/turbo_serializable_id.dart`

### Project Conventions
<!-- Style guides, naming conventions, file organization rules -->

**Naming Conventions**
- Classes: PascalCase (e.g., `TurboSerializable`, `TurboSerializableConfig`)
- Interfaces: PascalCase (e.g., `HasToJson`)
- Enums: PascalCase (e.g., `SerializationFormat`, `CaseStyle`)
- Functions: camelCase (e.g., `jsonToYaml`, `convertCase`)
- Constants: camelCase in `TurboConstants` class (e.g., `metaKey`, `defaultRootElement`)
- See: `ARCHITECTURE.md` (Conventions section)

**Code Organization**
- Abstracts: Base classes and interfaces in `lib/abstracts/`
- Models: Data classes and configuration in `lib/models/`
- Converters: Format conversion utilities in `lib/converters/`
- Enums: Enumerations in `lib/enums/`
- Constants: Centralized constants in `lib/constants/`
- Exports: Main library file re-exports all public APIs
- See: `lib/turbo_serializable.dart` (export structure)

**Error Handling**
- Format parsing: Throws `FormatException` for invalid YAML/XML
- Validation: Returns `TurboResponse.fail()` for invalid objects (null = valid)
- Null safety: Callbacks can return `null` to indicate "not supported"
- Graceful degradation: If conversion fails, returns `null` rather than throwing
- See: `lib/abstracts/turbo_serializable.dart` (validate method, conversion error handling)

**Documentation Standards**
- All public APIs have dartdoc comments
- Type parameters documented with purpose
- Function parameters documented with types and descriptions
- See: `ARCHITECTURE.md` (Documentation section)

**Linting**
- Uses `package:lints/recommended.yaml`
- See: `analysis_options.yaml`

### Critical Paths
<!-- Files that affect many others; changes here need careful review -->

**Main Library Export**
- `lib/turbo_serializable.dart` - All public APIs exported here
- Changes affect all consumers of the library

**Base Classes**
- `lib/abstracts/turbo_serializable.dart` - Core serialization logic
- `lib/abstracts/turbo_serializable_id.dart` - Typed ID variant
- Changes affect all classes extending these bases

**Format Converters**
- `lib/converters/format_converters.dart` - 12 standalone format converters
- Used by base classes for automatic format conversion
- Changes affect all format conversion behavior

**Configuration Model**
- `lib/models/turbo_serializable_config.dart` - Callback configuration
- Primary format determination logic
- Changes affect how serialization is configured

**Constants**
- `lib/constants/turbo_constants.dart` - Centralized constants
- Used throughout converters and base classes
- Changes affect metadata keys, XML defaults, Markdown formatting

### Security-Sensitive
<!-- Authentication, authorization, input validation, data handling -->

**Input Validation**
- Format parsing (YAML/XML) can throw on malformed input
- See: `lib/converters/format_converters.dart` (yamlToJson, xmlToJson functions)
- See: `lib/converters/xml_converter.dart` (xmlToMap function)

**Metadata Handling**
- Metadata serialization via `HasToJson` interface
- Metadata included in output formats (`_meta` key, frontmatter, XML element)
- See: `lib/abstracts/turbo_serializable.dart` (metaDataToJsonMap method)

**Error Message Exposure**
- Error messages exposed via `TurboResponse.fail()`
- Format parsing errors include error details
- See: `lib/constants/turbo_constants.dart` (error message factories)

**No Authentication/Authorization**
- This is a serialization library, no auth concerns
- No secrets handling or sensitive data storage

### Performance-Critical
<!-- Hot paths, frequently called code, resource-intensive operations -->

**Format Conversion Functions**
- 12 standalone converters in `lib/converters/format_converters.dart`
- Called frequently during serialization operations
- Performance impact: Parsing/generation of YAML/XML/Markdown

**Null Filtering**
- `filterNullsFromMap()` called in multiple conversion paths
- See: `lib/converters/format_converters.dart`

**Pretty Printing**
- YAML/Markdown/XML formatting with indentation
- See: `lib/converters/format_converters.dart` (convertMapToYaml, convertMapToMarkdown)
- See: `lib/converters/xml_converter.dart` (jsonToXml with prettyPrint)

**Case Conversion**
- `convertCase()` function called during XML conversion
- See: `lib/converters/case_converter.dart`

**Primary Format Determination**
- Computed once during `TurboSerializableConfig` initialization
- See: `lib/models/turbo_serializable_config.dart` (_computePrimaryFormat)

### Public API Surface
<!-- Exported interfaces, public methods, external contracts -->

**Main Library Exports** (`lib/turbo_serializable.dart`)
- `abstracts/has_to_json.dart` - HasToJson interface
- `abstracts/turbo_serializable.dart` - TurboSerializable base class
- `abstracts/turbo_serializable_id.dart` - TurboSerializableId class
- `constants/turbo_constants.dart` - TurboConstants class
- `converters/format_converters.dart` - 12 format converter functions
- `converters/xml_converter.dart` - XML-specific converters
- `enums/case_style.dart` - CaseStyle enum
- `enums/serialization_format.dart` - SerializationFormat enum
- `models/turbo_serializable_config.dart` - TurboSerializableConfig class
- `converters/case_converter.dart` - convertCase function (show export)

**Public Methods** (TurboSerializable)
- `toJson()`, `toYaml()`, `toMarkdown()`, `toXml()` - Format serialization
- `validate()` - Object validation
- See: `lib/abstracts/turbo_serializable.dart`

**Public Methods** (TurboSerializableId)
- Inherits all TurboSerializable methods
- `id` getter - Typed identifier
- See: `lib/abstracts/turbo_serializable_id.dart`

**Standalone Converter Functions**
- `jsonToYaml`, `jsonToMarkdown`, `jsonToXml`
- `yamlToJson`, `yamlToMarkdown`, `yamlToXml`
- `markdownToJson`, `markdownToYaml`, `markdownToXml`
- `xmlToJson`, `xmlToYaml`, `xmlToMarkdown`
- See: `lib/converters/format_converters.dart`

### State Management
<!-- Global state, caches, session handling, data persistence -->

**No Global State**
- This is a serialization library with no global state
- All state is instance-based (config, metaData, isLocalDefault)
- No caching, session handling, or data persistence

**Instance State**
- `TurboSerializable.config` - Callback configuration (immutable)
- `TurboSerializable.metaData` - Optional metadata (immutable)
- `TurboSerializable.isLocalDefault` - Local sync flag (immutable)
- `TurboSerializableId.id` - Typed identifier (immutable)

### Configuration
<!-- Environment configs, feature flags, secrets handling -->

**TurboSerializableConfig**
- Callback-based configuration for serialization methods
- Primary format automatically determined
- See: `lib/models/turbo_serializable_config.dart`

**TurboConstants**
- Centralized constants for metadata keys, XML defaults, Markdown formatting
- Error message factories
- See: `lib/constants/turbo_constants.dart`

**No Environment Configs**
- No environment variables or feature flags
- No secrets handling (serialization library only)

**Build Configuration**
- `pubspec.yaml` - Package dependencies and metadata
- `analysis_options.yaml` - Linting configuration

### Package Adherence
<!-- Installed packages that must be used; no custom alternatives -->

**Required Packages** (from `pubspec.yaml`)
- `yaml` (^3.1.0) - YAML parsing and document handling (MUST use, no custom parser)
- `xml` (^6.3.0) - XML parsing, building, and document manipulation (MUST use, no custom parser)
- `change_case` (^1.0.0) - String case transformation utilities (MUST use, no custom implementation)
- `turbo_response` (^1.0.1) - Validation response types (MUST use for TurboResponse)
- `meta` (^1.9.0) - Dart annotations and metadata utilities (MUST use for @visibleForTesting)

**Usage Locations**
- `yaml`: `lib/converters/format_converters.dart` (yamlToJson, jsonToYaml, etc.)
- `xml`: `lib/converters/xml_converter.dart`, `lib/converters/format_converters.dart`
- `change_case`: `lib/converters/case_converter.dart` (convertCase function)
- `turbo_response`: `lib/abstracts/turbo_serializable.dart` (validate method return type)
- `meta`: `lib/abstracts/turbo_serializable.dart` (@visibleForTesting annotations)

### External Dependencies
<!-- Third-party integrations, API clients, SDK usage -->

**Third-Party Libraries** (same as Package Adherence)
- `yaml` - YAML parsing library
- `xml` - XML parsing library
- `change_case` - Case transformation library
- `turbo_response` - Response type library (turbo ecosystem)
- `meta` - Dart annotations library

**No External APIs**
- No HTTP clients or API integrations
- No external service dependencies
- Pure serialization/deserialization library

## Review Checklist
- [ ] Code follows project conventions
- [ ] Changes match spec requirements
- [ ] Tests cover new functionality
- [ ] Error handling is appropriate
- [ ] Documentation updated
- [ ] No security vulnerabilities introduced
- [ ] Performance impact considered
