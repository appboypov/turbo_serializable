# format-features Specification

## Purpose
TBD - created by archiving change document-entire-repo. Update Purpose after archive.
## Requirements
### Requirement: JSON Format Features
The system SHALL support JSON-specific serialization features.

#### Scenario: JSON map output
- **WHEN** `toJson()` is called
- **THEN** it returns `Map<String, dynamic>?`
- **AND** the map represents the object's data structure

#### Scenario: JSON null handling
- **WHEN** `toJson({includeNulls: false})` is called (default)
- **THEN** null values are filtered from the output map
- **AND** empty maps and arrays are preserved

#### Scenario: JSON metadata inclusion
- **WHEN** `toJson({includeMetaData: true})` is called
- **THEN** metadata is included under `_meta` key
- **AND** metadata is merged with main data

### Requirement: YAML Format Features
The system SHALL support YAML-specific serialization features.

#### Scenario: YAML string output
- **WHEN** `toYaml()` is called
- **THEN** it returns `String?` containing YAML representation
- **AND** YAML is properly formatted with indentation

#### Scenario: YAML pretty printing
- **WHEN** `toYaml({prettyPrint: true})` is called (default)
- **THEN** YAML is formatted with consistent indentation
- **AND** nested structures are properly indented

#### Scenario: YAML null handling
- **WHEN** `toYaml({includeNulls: false})` is called (default)
- **THEN** null values are excluded from YAML output
- **AND** empty collections are preserved

#### Scenario: YAML document parsing
- **WHEN** `yamlToJson()` parses a YAML document
- **THEN** it handles YAML anchors, aliases, and multi-document streams
- **AND** converts YAML-specific features to JSON equivalents

### Requirement: Markdown Format Features
The system SHALL support Markdown-specific serialization features.

#### Scenario: Markdown header generation
- **WHEN** `toMarkdown()` is called
- **THEN** keys become headers with appropriate levels (## level 2, ### level 3, #### level 4)
- **AND** deeper nesting uses bold formatting (**key**)

#### Scenario: Markdown frontmatter
- **WHEN** `toMarkdown({includeMetaData: true})` is called
- **THEN** metadata is included as YAML frontmatter delimited by `---`
- **AND** frontmatter appears before content

#### Scenario: Markdown parsing with frontmatter
- **WHEN** `markdownToJson()` parses Markdown with frontmatter
- **THEN** frontmatter is extracted and placed under `_meta` key
- **AND** content is parsed into structured data

#### Scenario: Markdown pretty printing
- **WHEN** `toMarkdown({prettyPrint: true})` is called (default)
- **THEN** spacing is added between sections for readability
- **AND** formatting improves visual structure

#### Scenario: Markdown key title case
- **WHEN** keys are converted to Markdown headers
- **THEN** keys are converted to Title Case
- **AND** readability is improved

### Requirement: XML Format Features
The system SHALL support XML-specific serialization features.

#### Scenario: XML root element naming
- **WHEN** `toXml({rootElementName: 'Custom'})` is called
- **THEN** the root element uses the specified name
- **AND** if not specified, defaults to class name (runtimeType)

#### Scenario: XML case style transformation
- **WHEN** `toXml({caseStyle: CaseStyle.pascalCase})` is called
- **THEN** element names are transformed according to the specified case style
- **AND** nested elements follow the same transformation

#### Scenario: XML attribute handling
- **WHEN** `xmlToJson()` parses XML with attributes
- **THEN** attributes are included in the JSON map
- **AND** attribute names are preserved or prefixed appropriately

#### Scenario: XML CDATA handling
- **WHEN** `xmlToJson()` parses XML with CDATA sections
- **THEN** CDATA content is preserved as text content
- **AND** CDATA markers are removed

#### Scenario: XML declaration handling
- **WHEN** `xmlToJson()` parses XML with declaration (`<?xml ...?>`)
- **THEN** declaration is parsed and can be included in output
- **AND** declaration does not interfere with content parsing

#### Scenario: XML pretty printing
- **WHEN** `toXml({prettyPrint: true})` is called (default)
- **THEN** XML is formatted with indentation
- **AND** nested elements are properly indented

#### Scenario: XML mixed content
- **WHEN** `xmlToJson()` parses XML with mixed text and element content
- **THEN** text content is preserved
- **AND** structure is maintained in JSON representation

