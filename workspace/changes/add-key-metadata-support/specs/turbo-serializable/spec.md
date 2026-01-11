## ADDED Requirements

### Requirement: Key-Level Layout Metadata

The `turbo_serializable` package SHALL provide per-key layout metadata storage via a `_keyMeta` object that is separate from document-level metadata (`_meta`) and data content.

#### Scenario: Separate storage from data
- **WHEN** a document is parsed with `preserveLayout: true`
- **THEN** the result contains a `data` map with key-value content
- **AND** a separate `keyMeta` map with layout information per key
- **AND** the `_keyMeta` key is reserved and not mixed with data

#### Scenario: Nested key support
- **WHEN** metadata exists for a nested key path (e.g., `user.address.city`)
- **THEN** the metadata is stored in a nested structure: `keyMeta.user.children.address.children.city`
- **AND** each level can have its own metadata alongside `children`

#### Scenario: Document metadata separation
- **WHEN** both document-level `_meta` and key-level `_keyMeta` exist
- **THEN** they remain distinct objects serving different purposes
- **AND** `_meta` contains frontmatter/document properties
- **AND** `_keyMeta` contains per-key layout/formatting information

### Requirement: KeyMetadata Model

The `turbo_serializable` package SHALL provide a `KeyMetadata` class that captures format-specific layout information for each key.

#### Scenario: Common metadata properties
- **WHEN** a `KeyMetadata` instance is created
- **THEN** it supports common properties: `headerLevel`, `divider`, `callout`, `codeBlock`, `listMeta`, `tableMeta`, `emphasis`, `whitespace`
- **AND** all properties are optional (nullable)

#### Scenario: Format-specific metadata
- **WHEN** metadata is captured for format-specific features
- **THEN** `xmlMeta` contains XML-specific data (attributes, CDATA, comments, namespaces)
- **AND** `yamlMeta` contains YAML-specific data (anchors, aliases, comments, flow/block style)
- **AND** `jsonMeta` contains JSON-specific data (indentation, spacing)

#### Scenario: Nested children support
- **WHEN** a key has nested child keys
- **THEN** `KeyMetadata.children` contains a `Map<String, KeyMetadata>` for child metadata
- **AND** the structure mirrors the data nesting

### Requirement: Markdown Layout Preservation

The `turbo_serializable` package SHALL parse and generate Markdown with full layout preservation when `preserveLayout: true`.

#### Scenario: Header level preservation
- **WHEN** Markdown with headers (`#`, `##`, `###`, etc.) is parsed
- **THEN** the header level (1-6) is captured in `keyMeta[key].headerLevel`
- **AND** regenerating the Markdown produces headers with the exact same level

#### Scenario: Callout preservation
- **WHEN** Markdown contains GitHub/Obsidian-style callouts (`> [!NOTE]`, `> [!WARNING]`, `> [!TIP]`)
- **THEN** the callout type, content, and position (before/after key) are captured
- **AND** regenerating the Markdown produces identical callout syntax

#### Scenario: Divider preservation
- **WHEN** Markdown contains horizontal rules (`---`, `***`, `___`)
- **THEN** the divider position (before/after key) and style are captured
- **AND** regenerating the Markdown produces identical divider syntax

#### Scenario: Code block preservation
- **WHEN** Markdown contains fenced code blocks with language specifiers
- **THEN** the language, filename (if present), and content are captured
- **AND** regenerating the Markdown produces identical code block syntax

#### Scenario: List type preservation
- **WHEN** Markdown contains lists (unordered `-`/`*`/`+`, ordered `1.`/`1)`, task `- [ ]`/`- [x]`)
- **THEN** the list type, marker style, and structure are captured
- **AND** regenerating the Markdown produces identical list syntax

#### Scenario: Table preservation
- **WHEN** Markdown contains tables with alignment
- **THEN** the column alignment (left/center/right), header presence, and structure are captured
- **AND** regenerating the Markdown produces identical table syntax

#### Scenario: Emphasis preservation
- **WHEN** Markdown contains emphasis (`**bold**`, `*italic*`, `~~strikethrough~~`, `` `code` ``)
- **THEN** the emphasis style and markers are captured
- **AND** regenerating the Markdown produces identical emphasis syntax

### Requirement: XML Layout Preservation

The `turbo_serializable` package SHALL parse and generate XML with full layout preservation when `preserveLayout: true`.

#### Scenario: Attribute vs element preservation
- **WHEN** XML contains attributes on elements
- **THEN** the distinction between attributes and child elements is captured in `xmlMeta.attributes`
- **AND** regenerating the XML produces identical attribute/element structure

#### Scenario: CDATA preservation
- **WHEN** XML contains CDATA sections
- **THEN** the CDATA status is captured in `xmlMeta.isCdata`
- **AND** regenerating the XML produces identical CDATA syntax

#### Scenario: Comment preservation
- **WHEN** XML contains comments
- **THEN** the comment content and position are captured in `xmlMeta.comment`
- **AND** regenerating the XML produces identical comments

#### Scenario: Namespace preservation
- **WHEN** XML contains namespace declarations
- **THEN** the namespace URI and prefix are captured in `xmlMeta.namespace` and `xmlMeta.prefix`
- **AND** regenerating the XML produces identical namespace declarations

### Requirement: YAML Layout Preservation

The `turbo_serializable` package SHALL parse and generate YAML with full layout preservation when `preserveLayout: true`.

#### Scenario: Anchor and alias preservation
- **WHEN** YAML contains anchors (`&name`) and aliases (`*name`)
- **THEN** the anchor and alias names are captured in `yamlMeta.anchor` and `yamlMeta.alias`
- **AND** regenerating the YAML produces identical anchor/alias references

#### Scenario: Comment preservation
- **WHEN** YAML contains inline or block comments
- **THEN** the comment content and association are captured in `yamlMeta.comment`
- **AND** regenerating the YAML produces identical comments

#### Scenario: Flow vs block style preservation
- **WHEN** YAML uses flow style (`{key: value}`) or block style
- **THEN** the style is captured in `yamlMeta.style`
- **AND** regenerating the YAML produces identical flow/block structure

#### Scenario: Scalar style preservation
- **WHEN** YAML uses literal (`|`), folded (`>`), single-quoted, or double-quoted scalars
- **THEN** the scalar style is captured in `yamlMeta.scalarStyle`
- **AND** regenerating the YAML produces identical scalar presentation

### Requirement: JSON Layout Preservation

The `turbo_serializable` package SHALL parse and generate JSON with formatting preservation when `preserveLayout: true`.

#### Scenario: Indentation preservation
- **WHEN** JSON is parsed with specific indentation
- **THEN** the indent level (spaces) is captured in `jsonMeta.indentSpaces`
- **AND** regenerating the JSON produces identical indentation

#### Scenario: Spacing preservation
- **WHEN** JSON has specific spacing patterns
- **THEN** the spacing is captured and regenerating produces identical whitespace

### Requirement: Whitespace Fidelity

The `turbo_serializable` package SHALL preserve exact whitespace to achieve 100% byte-for-byte round-trip fidelity.

#### Scenario: Leading/trailing newlines
- **WHEN** content has leading or trailing newlines
- **THEN** the exact count is captured in `whitespace.leadingNewlines` and `whitespace.trailingNewlines`
- **AND** regenerating produces identical newline counts

#### Scenario: Line ending preservation
- **WHEN** content uses `\n` (Unix) or `\r\n` (Windows) line endings
- **THEN** the line ending style is captured in `whitespace.lineEnding`
- **AND** regenerating produces identical line endings

#### Scenario: Raw whitespace preservation
- **WHEN** whitespace differs from defaults
- **THEN** the exact raw whitespace is stored in `whitespace.rawLeading` and `whitespace.rawTrailing`
- **AND** regenerating produces byte-for-byte identical output

### Requirement: PreserveLayout Parameter

All converter functions SHALL support a `preserveLayout` parameter that defaults to `true`.

#### Scenario: PreserveLayout enabled (default)
- **WHEN** a converter function is called without specifying `preserveLayout`
- **THEN** it defaults to `true`
- **AND** layout metadata is captured during parsing
- **AND** layout metadata is used during generation

#### Scenario: PreserveLayout disabled
- **WHEN** a converter function is called with `preserveLayout: false`
- **THEN** no layout metadata is captured or used
- **AND** the function behaves as it did before this feature (backward compatible)
- **AND** output may differ from input in formatting but not data

#### Scenario: Parsing with preserveLayout
- **WHEN** `markdownToJson`, `yamlToJson`, `xmlToJson` are called with `preserveLayout: true`
- **THEN** they return a `LayoutAwareParseResult` with `data` and `keyMeta`
- **OR** they add `_keyMeta` to the returned map (API choice)

#### Scenario: Generation with preserveLayout
- **WHEN** `jsonToMarkdown`, `jsonToYaml`, `jsonToXml` are called with `preserveLayout: true`
- **THEN** they accept an optional `keyMeta` parameter
- **AND** they use the metadata to generate format-specific layout

## MODIFIED Requirements

### Requirement: Multi-Format Serialization Methods

The `TurboSerializable` class SHALL provide optional methods for JSON, YAML, Markdown, and XML serialization formats with automatic cross-format conversion.

#### Scenario: JSON serialization
- **WHEN** toJson() is called
- **THEN** it returns Map<String, dynamic> from toJsonImpl() if primaryFormat is json
- **OR** it converts from the primary format if primaryFormat is not json
- **WHEN** includeMetaData is true
- **THEN** metadata is included under the `_meta` key
- **WHEN** preserveLayout is true (default)
- **THEN** key metadata is included under the `_keyMeta` key

#### Scenario: YAML serialization
- **WHEN** toYaml() is called
- **THEN** it returns String from toYamlImpl() if overridden
- **OR** it converts from the primary format via jsonToYaml or yamlToJson
- **WHEN** includeMetaData is true
- **THEN** metadata is included under the `_meta` key
- **WHEN** preserveLayout is true (default)
- **THEN** key metadata is used to format YAML output (anchors, comments, flow/block)

#### Scenario: Markdown serialization
- **WHEN** toMarkdown() is called
- **THEN** it returns String from toMarkdownImpl() if overridden
- **OR** it converts from the primary format via jsonToMarkdown
- **WHEN** includeMetaData is true
- **THEN** metadata is included as YAML frontmatter
- **WHEN** preserveLayout is true (default)
- **THEN** key metadata is used to format Markdown output (headers, callouts, dividers, etc.)

#### Scenario: XML serialization
- **WHEN** toXml() is called
- **THEN** it returns String from toXmlImpl() if overridden
- **OR** it converts from the primary format via jsonToXml
- **WHEN** includeMetaData is true
- **THEN** metadata is included as `_meta` element
- **WHEN** preserveLayout is true (default)
- **THEN** key metadata is used to format XML output (attributes, CDATA, comments)
