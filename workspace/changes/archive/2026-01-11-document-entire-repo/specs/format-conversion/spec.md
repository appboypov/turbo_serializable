## ADDED Requirements

### Requirement: Standalone Format Converters
The system SHALL provide 12 standalone format conversion functions that can be used independently without class inheritance.

#### Scenario: JSON to YAML conversion
- **WHEN** `jsonToYaml(Map<String, dynamic> json)` is called
- **THEN** it returns a YAML string representation of the JSON map
- **AND** metadata can be optionally included under `_meta` key

#### Scenario: JSON to Markdown conversion
- **WHEN** `jsonToMarkdown(Map<String, dynamic> json, {metaData: {...}})` is called
- **THEN** it returns Markdown with YAML frontmatter (if metadata provided)
- **AND** keys become headers (## level 2, ### level 3, etc.)
- **AND** keys are converted to Title Case

#### Scenario: JSON to XML conversion
- **WHEN** `jsonToXml(Map<String, dynamic> json, {rootElementName: 'Root'})` is called
- **THEN** it returns an XML string with the specified root element
- **AND** nested objects become child elements
- **AND** arrays become repeated elements

#### Scenario: YAML to JSON conversion
- **WHEN** `yamlToJson(String yamlString)` is called
- **THEN** it parses the YAML string and returns a `Map<String, dynamic>`
- **AND** throws `FormatException` if YAML is invalid

#### Scenario: YAML to Markdown conversion
- **WHEN** `yamlToMarkdown(String yamlString)` is called
- **THEN** it converts YAML to JSON, then JSON to Markdown
- **AND** preserves YAML structure in Markdown format

#### Scenario: YAML to XML conversion
- **WHEN** `yamlToXml(String yamlString, {rootElementName: 'Root'})` is called
- **THEN** it converts YAML to JSON, then JSON to XML
- **AND** uses the specified root element name

#### Scenario: Markdown to JSON conversion
- **WHEN** `markdownToJson(String markdownString)` is called
- **THEN** it parses YAML frontmatter (if present) and content
- **AND** returns a JSON map with frontmatter under `_meta` key
- **AND** content is parsed into structured data

#### Scenario: Markdown to YAML conversion
- **WHEN** `markdownToYaml(String markdownString)` is called
- **THEN** it converts Markdown to JSON, then JSON to YAML
- **AND** frontmatter is preserved in YAML format

#### Scenario: Markdown to XML conversion
- **WHEN** `markdownToXml(String markdownString)` is called
- **THEN** it converts Markdown to JSON, then JSON to XML
- **AND** frontmatter becomes `_meta` element in XML

#### Scenario: XML to JSON conversion
- **WHEN** `xmlToJson(String xmlString)` or `xmlToMap(String xmlString)` is called
- **THEN** it parses the XML string and returns a `Map<String, dynamic>`
- **AND** attributes become keys prefixed with `@` or included in element data
- **AND** throws `FormatException` if XML is invalid

#### Scenario: XML to YAML conversion
- **WHEN** `xmlToYaml(String xmlString)` is called
- **THEN** it converts XML to JSON, then JSON to YAML
- **AND** preserves XML structure in YAML format

#### Scenario: XML to Markdown conversion
- **WHEN** `xmlToMarkdown(String xmlString)` is called
- **THEN** it converts XML to JSON, then JSON to Markdown
- **AND** `_meta` element becomes frontmatter if present

### Requirement: Conversion Options
All conversion functions SHALL support consistent options for null handling, formatting, and metadata.

#### Scenario: Null filtering in conversions
- **WHEN** a conversion function is called with `includeNulls: false` (default)
- **THEN** null values are filtered from the output
- **AND** empty collections are preserved

#### Scenario: Pretty printing in conversions
- **WHEN** a conversion function is called with `prettyPrint: true` (default)
- **THEN** the output is formatted with indentation and spacing
- **AND** readability is improved

#### Scenario: Metadata merging in conversions
- **WHEN** a conversion function is called with `metaData: {...}`
- **THEN** metadata is merged into the output according to format conventions
- **AND** JSON/YAML use `_meta` key, Markdown uses frontmatter, XML uses `_meta` element
