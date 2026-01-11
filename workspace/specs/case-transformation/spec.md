# case-transformation Specification

## Purpose
TBD - created by archiving change document-entire-repo. Update Purpose after archive.
## Requirements
### Requirement: Case Style Enumeration
The system SHALL provide `CaseStyle` enum with supported case transformation styles.

#### Scenario: Available case styles
- **WHEN** `CaseStyle` enum is referenced
- **THEN** it provides values: `none`, `camelCase`, `pascalCase`, `snakeCase`, `kebabCase`
- **AND** each style represents a different naming convention

### Requirement: Case Conversion Function
The system SHALL provide `convertCase()` function for transforming strings between case styles.

#### Scenario: Convert to camelCase
- **WHEN** `convertCase('hello_world', CaseStyle.camelCase)` is called
- **THEN** it returns `'helloWorld'`
- **AND** first word is lowercase, subsequent words capitalized

#### Scenario: Convert to PascalCase
- **WHEN** `convertCase('hello_world', CaseStyle.pascalCase)` is called
- **THEN** it returns `'HelloWorld'`
- **AND** all words are capitalized

#### Scenario: Convert to snake_case
- **WHEN** `convertCase('HelloWorld', CaseStyle.snakeCase)` is called
- **THEN** it returns `'hello_world'`
- **AND** words are lowercase with underscores

#### Scenario: Convert to kebab-case
- **WHEN** `convertCase('HelloWorld', CaseStyle.kebabCase)` is called
- **THEN** it returns `'hello-world'`
- **AND** words are lowercase with hyphens

#### Scenario: No transformation
- **WHEN** `convertCase('HelloWorld', CaseStyle.none)` is called
- **THEN** it returns the original string unchanged
- **AND** no transformation is applied

### Requirement: Case Style in XML Serialization
The system SHALL apply case style transformation to XML element names.

#### Scenario: XML with PascalCase
- **WHEN** `toXml({caseStyle: CaseStyle.pascalCase})` is called
- **THEN** all element names are converted to PascalCase
- **AND** nested elements follow the same transformation

#### Scenario: XML with snake_case
- **WHEN** `toXml({caseStyle: CaseStyle.snakeCase})` is called
- **THEN** all element names are converted to snake_case
- **AND** transformation is consistent throughout the XML structure

#### Scenario: XML case style in conversion
- **WHEN** `jsonToXml(json, {caseStyle: CaseStyle.kebabCase})` is called
- **THEN** JSON keys are converted to kebab-case XML element names
- **AND** nested structures maintain the case style

