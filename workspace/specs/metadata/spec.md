# metadata Specification

## Purpose
TBD - created by archiving change document-entire-repo. Update Purpose after archive.
## Requirements
### Requirement: Typed Metadata Support
The system SHALL support optional typed metadata through the generic type parameter `M` in `TurboSerializable<M>`.

#### Scenario: Create object with metadata
- **WHEN** a `TurboSerializable<Frontmatter>` instance is created with `metaData: Frontmatter(...)`
- **THEN** the metadata is stored and accessible via `metaData` property
- **AND** type safety is enforced at compile time

#### Scenario: Metadata serialization with HasToJson
- **WHEN** metadata type `M` implements `HasToJson` interface
- **THEN** `metaDataToJsonMap()` calls `toJson()` on the metadata instance
- **AND** metadata can be serialized to JSON format

#### Scenario: Metadata without HasToJson
- **WHEN** metadata type `M` does not implement `HasToJson`
- **THEN** `metaDataToJsonMap()` returns an empty map
- **AND** metadata is not included in serialization output

### Requirement: HasToJson Interface
The system SHALL provide `HasToJson` interface for metadata types that can be serialized.

#### Scenario: Implement HasToJson
- **WHEN** a class implements `HasToJson` interface
- **THEN** it MUST implement `Map<String, dynamic> toJson()` method
- **AND** the method returns a JSON-serializable map

#### Scenario: Use HasToJson metadata
- **WHEN** `TurboSerializable<Frontmatter>` is created where `Frontmatter implements HasToJson`
- **THEN** metadata is automatically serialized when `includeMetaData: true`
- **AND** metadata appears in format-specific locations (frontmatter, `_meta` key/element)

### Requirement: Format-Specific Metadata Integration
The system SHALL integrate metadata into each format according to format conventions.

#### Scenario: Metadata in JSON/YAML
- **WHEN** `toJson({includeMetaData: true})` or `toYaml({includeMetaData: true})` is called
- **THEN** metadata is included under `_meta` key in the output
- **AND** metadata is merged with the main data structure

#### Scenario: Metadata in Markdown
- **WHEN** `toMarkdown({includeMetaData: true})` is called
- **THEN** metadata is included as YAML frontmatter at the top of the document
- **AND** frontmatter is delimited by `---` markers

#### Scenario: Metadata in XML
- **WHEN** `toXml({includeMetaData: true})` is called
- **THEN** metadata is included as `_meta` element in the XML structure
- **AND** metadata element contains serialized metadata content

#### Scenario: Exclude metadata
- **WHEN** any serialization method is called with `includeMetaData: false`
- **THEN** metadata is not included in the output
- **AND** only the main data structure is serialized

