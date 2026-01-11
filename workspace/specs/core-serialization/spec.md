# core-serialization Specification

## Purpose
TBD - created by archiving change document-entire-repo. Update Purpose after archive.
## Requirements
### Requirement: Core Serialization Abstraction
The system SHALL provide an abstract base class `TurboSerializable<M>` that enables multi-format serialization through a primary format pattern.

#### Scenario: Extend TurboSerializable with JSON callback
- **WHEN** a class extends `TurboSerializable<M>` and provides a `toJson` callback in `TurboSerializableConfig`
- **THEN** the primary format is automatically set to JSON
- **AND** the class can serialize to JSON, YAML, Markdown, and XML formats
- **AND** all non-primary formats are automatically converted from JSON

#### Scenario: Primary format priority determination
- **WHEN** multiple callbacks are provided in `TurboSerializableConfig`
- **THEN** the primary format is determined by priority: json > yaml > markdown > xml
- **AND** the highest priority callback becomes the primary format

#### Scenario: Format-specific callback precedence
- **WHEN** a format-specific callback is provided (e.g., `toYaml`)
- **THEN** that callback takes precedence over automatic conversion from primary format
- **AND** the callback result is returned directly without conversion

#### Scenario: Local state tracking
- **WHEN** a `TurboSerializable` instance is created
- **THEN** it SHALL support an `isLocalDefault` flag to track whether the instance is synced to remote
- **AND** the flag defaults to `false`

### Requirement: Serialization Methods
The system SHALL provide four serialization methods: `toJson()`, `toYaml()`, `toMarkdown()`, and `toXml()`.

#### Scenario: JSON serialization with metadata
- **WHEN** `toJson({includeMetaData: true})` is called
- **THEN** the result includes metadata under `_meta` key if metadata exists
- **AND** null values are excluded by default unless `includeNulls: true` is specified

#### Scenario: YAML serialization with formatting
- **WHEN** `toYaml({prettyPrint: true, includeNulls: false})` is called
- **THEN** the result is a formatted YAML string with indentation
- **AND** null values are excluded unless `includeNulls: true` is specified

#### Scenario: Markdown serialization with frontmatter
- **WHEN** `toMarkdown({includeMetaData: true})` is called
- **THEN** metadata is included as YAML frontmatter if present
- **AND** content is formatted with headers (## level 2, ### level 3, etc.)
- **AND** keys are converted to Title Case

#### Scenario: XML serialization with options
- **WHEN** `toXml({rootElementName: 'Custom', caseStyle: CaseStyle.pascalCase})` is called
- **THEN** the root element uses the specified name or defaults to class name
- **AND** element names are transformed according to the specified case style
- **AND** formatting is applied if `prettyPrint: true`

### Requirement: Automatic Format Conversion
The system SHALL automatically convert between formats when a format-specific callback is not provided.

#### Scenario: Convert JSON to YAML
- **WHEN** primary format is JSON and `toYaml()` is called without a YAML callback
- **THEN** the system converts JSON to YAML using `jsonToYaml()` converter
- **AND** metadata is merged if `includeMetaData: true`

#### Scenario: Convert YAML to XML
- **WHEN** primary format is YAML and `toXml()` is called without an XML callback
- **THEN** the system converts YAML to JSON, then JSON to XML
- **AND** the root element name defaults to the class name

#### Scenario: Convert Markdown to JSON
- **WHEN** primary format is Markdown and `toJson()` is called without a JSON callback
- **THEN** the system parses Markdown frontmatter and content to JSON
- **AND** frontmatter is extracted as metadata if present

#### Scenario: Convert XML to Markdown
- **WHEN** primary format is XML and `toMarkdown()` is called without a Markdown callback
- **THEN** the system converts XML to JSON, then JSON to Markdown
- **AND** metadata from `_meta` element is included as frontmatter

### Requirement: Null Handling
The system SHALL provide configurable null value handling across all serialization methods.

#### Scenario: Exclude nulls by default
- **WHEN** any serialization method is called without `includeNulls: true`
- **THEN** null values are filtered from the output
- **AND** empty maps and arrays are preserved

#### Scenario: Include nulls when requested
- **WHEN** `includeNulls: true` is specified
- **THEN** null values are included in the serialized output
- **AND** the output accurately represents the data structure including nulls

