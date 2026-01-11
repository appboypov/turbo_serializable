## ADDED Requirements

### Requirement: Configuration Class
The system SHALL provide `TurboSerializableConfig` class that holds callbacks for serialization methods.

#### Scenario: Create config with JSON callback
- **WHEN** `TurboSerializableConfig(toJson: (instance) => {...})` is created
- **THEN** the primary format is set to JSON
- **AND** at least one callback must be provided (assertion enforced)

#### Scenario: Create config with multiple callbacks
- **WHEN** `TurboSerializableConfig(toJson: ..., toYaml: ...)` is created with multiple callbacks
- **THEN** the primary format is determined by priority (json > yaml > markdown > xml)
- **AND** all provided callbacks are stored for direct use

#### Scenario: Config validation
- **WHEN** `TurboSerializableConfig()` is created without any callbacks
- **THEN** an assertion error is thrown with message indicating at least one callback is required

### Requirement: Callback Signatures
The system SHALL define specific callback signatures for each serialization format.

#### Scenario: JSON callback signature
- **WHEN** a JSON callback is provided
- **THEN** it MUST have signature `Map<String, dynamic>? Function(TurboSerializable)`
- **AND** it can return `null` to indicate "not supported"

#### Scenario: YAML callback signature
- **WHEN** a YAML callback is provided
- **THEN** it MUST have signature `String? Function(TurboSerializable)`
- **AND** it returns the YAML string representation

#### Scenario: Markdown callback signature
- **WHEN** a Markdown callback is provided
- **THEN** it MUST have signature `String? Function(TurboSerializable)`
- **AND** it returns the Markdown string representation

#### Scenario: XML callback signature
- **WHEN** an XML callback is provided
- **THEN** it MUST have signature `String? Function(TurboSerializable, {String? rootElementName, bool includeNulls, bool prettyPrint, bool includeMetaData, CaseStyle caseStyle})`
- **AND** it accepts all XML-specific options as named parameters

### Requirement: Primary Format Computation
The system SHALL automatically compute the primary format from provided callbacks.

#### Scenario: JSON has highest priority
- **WHEN** both `toJson` and `toYaml` callbacks are provided
- **THEN** primary format is JSON (highest priority)

#### Scenario: YAML priority over Markdown
- **WHEN** both `toYaml` and `toMarkdown` callbacks are provided (no JSON)
- **THEN** primary format is YAML

#### Scenario: Markdown priority over XML
- **WHEN** both `toMarkdown` and `toXml` callbacks are provided (no JSON/YAML)
- **THEN** primary format is Markdown

#### Scenario: XML as lowest priority
- **WHEN** only `toXml` callback is provided
- **THEN** primary format is XML
