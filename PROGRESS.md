# Implementation Progress: add-key-metadata-support

## Tasks Overview

- [ ] Task 1: models
- [ ] Task 2: parser
- [ ] Task 3: generator
- [ ] Task 4: parser
- [ ] Task 5: generator
- [ ] Task 6: parser
- [ ] Task 7: generator
- [ ] Task 8: layout
- [ ] Task 9: integration
- [ ] Task 10: review
- [ ] Task 11: test

---

## Task 1: models

**Status:** to-do
**Task ID:** 001-add-key-metadata-support-models

### Context

<details>
<summary>Proposal Context (click to expand)</summary>

## Why

Currently, `turbo_serializable` performs straightforward key-to-key conversions between formats (JSON, YAML, XML, Markdown). Layout and formatting information is lost during conversion - a Markdown document with callouts, dividers, and specific header levels cannot be converted to JSON and back without losing its visual structure. This prevents use cases where documents need to be stored/processed as data while preserving their original presentation.

## What Changes

- **ADDED**: `_keyMeta` object to store per-key layout metadata separate from data
- **ADDED**: `KeyMetadata` model class with format-specific layout properties
- **ADDED**: `preserveLayout` parameter (default: `true`) to all conversion functions
- **ADDED**: Markdown layout parsing (callouts, dividers, code blocks, tables, lists, headers, emphasis)
- **ADDED**: XML layout parsing (attributes vs elements, CDATA, comments, namespaces)
- **ADDED**: YAML layout parsing (anchors/aliases, comments, flow vs block style)
- **ADDED**: JSON layout parsing (indentation/spacing preservation)
- **ADDED**: Full path support for nested key metadata (dot notation or nested structure)
- **ADDED**: Layout-aware generation for all formats (bidirectional fidelity)
- **MODIFIED**: All 12 converter functions to support `preserveLayout` parameter
- **MODIFIED**: `TurboSerializable` class to support key metadata in serialization
</details>

### Task Details

# Task: Implement KeyMetadata Models

## End Goal

Create all model classes for key-level layout metadata that will support 100% round-trip fidelity across all formats.

## Currently

The `turbo_serializable` package has no per-key metadata support. Only document-level `metaData` exists.

## Should

The package has a complete set of model classes in `lib/models/` that can represent all layout information for Markdown, XML, YAML, and JSON formats.

## Constraints

- [ ] All model classes must be immutable (final fields)
- [ ] All properties must be optional (nullable) since not every key needs every metadata type
- [ ] Must support JSON serialization (toJson/fromJson) for storage
- [ ] Must follow existing code style and naming conventions
- [ ] Must include dartdoc comments for all public APIs

## Acceptance Criteria

- [ ] `KeyMetadata` class exists with all common properties
- [ ] `DividerMeta` class exists with `before`, `after`, `style` properties
- [ ] `CalloutMeta` class exists with `type`, `content`, `position` properties
- [ ] `CodeBlockMeta` class exists with `language`, `filename`, `isInline` properties
- [ ] `ListMeta` class exists with `type`, `marker`, `startNumber` properties
- [ ] `TableMeta` class exists with `alignment`, `hasHeader` properties
- [ ] `EmphasisMeta` class exists with `style` property
- [ ] `XmlMeta` class exists with `attributes`, `isCdata`, `comment`, `namespace`, `prefix` properties
- [ ] `YamlMeta` class exists with `anchor`, `alias`, `comment`, `style`, `scalarStyle` properties
- [ ] `JsonMeta` class exists with `indentSpaces`, `trailingComma` properties
- [ ] `WhitespaceMeta` class exists with `leadingNewlines`, `trailingNewlines`, `rawLeading`, `rawTrailing`, `lineEnding` properties
- [ ] `LayoutAwareParseResult` class exists with `data` and `keyMeta` properties
- [ ] All models have `toJson()` and `fromJson()` methods
- [ ] All models have `copyWith()` methods
- [ ] Unit tests pass for all model serialization/deserialization

## Implementation Checklist

- [ ] 1.1 Create `lib/models/key_metadata.dart` with `KeyMetadata` class
- [ ] 1.2 Create `lib/models/divider_meta.dart` with `DividerMeta` class
- [ ] 1.3 Create `lib/models/callout_meta.dart` with `CalloutMeta` class
- [ ] 1.4 Create `lib/models/code_block_meta.dart` with `CodeBlockMeta` class
- [ ] 1.5 Create `lib/models/list_meta.dart` with `ListMeta` class
- [ ] 1.6 Create `lib/models/table_meta.dart` with `TableMeta` class
- [ ] 1.7 Create `lib/models/emphasis_meta.dart` with `EmphasisMeta` class
- [ ] 1.8 Create `lib/models/xml_meta.dart` with `XmlMeta` class
- [ ] 1.9 Create `lib/models/yaml_meta.dart` with `YamlMeta` class
- [ ] 1.10 Create `lib/models/json_meta.dart` with `JsonMeta` class
- [ ] 1.11 Create `lib/models/whitespace_meta.dart` with `WhitespaceMeta` class
- [ ] 1.12 Create `lib/models/layout_aware_parse_result.dart` with `LayoutAwareParseResult` class
- [ ] 1.13 Export all models from `lib/turbo_serializable.dart`
- [ ] 1.14 Add `keyMetaKey` constant to `TurboConstants`
- [ ] 1.15 Write unit tests for all model classes in `test/models/`

## Notes

- Use the `KeyMetadata.children` property for nested key metadata support
- Consider using `@JsonKey` annotations if using json_serializable, or manual toJson/fromJson
- The `lineEnding` property should default to `'\n'`

### Agent Instructions

Pick up this task and implement it according to the specifications above.
Focus on the Constraints and Acceptance Criteria sections.
When complete, mark the task as done:

```bash
plx complete task --id 001-add-key-metadata-support-models
```

---

## Task 2: parser

**Status:** to-do
**Task ID:** 002-add-key-metadata-support-markdown-parser

### Context

<details>
<summary>Proposal Context (click to expand)</summary>

## Why

Currently, `turbo_serializable` performs straightforward key-to-key conversions between formats (JSON, YAML, XML, Markdown). Layout and formatting information is lost during conversion - a Markdown document with callouts, dividers, and specific header levels cannot be converted to JSON and back without losing its visual structure. This prevents use cases where documents need to be stored/processed as data while preserving their original presentation.

## What Changes

- **ADDED**: `_keyMeta` object to store per-key layout metadata separate from data
- **ADDED**: `KeyMetadata` model class with format-specific layout properties
- **ADDED**: `preserveLayout` parameter (default: `true`) to all conversion functions
- **ADDED**: Markdown layout parsing (callouts, dividers, code blocks, tables, lists, headers, emphasis)
- **ADDED**: XML layout parsing (attributes vs elements, CDATA, comments, namespaces)
- **ADDED**: YAML layout parsing (anchors/aliases, comments, flow vs block style)
- **ADDED**: JSON layout parsing (indentation/spacing preservation)
- **ADDED**: Full path support for nested key metadata (dot notation or nested structure)
- **ADDED**: Layout-aware generation for all formats (bidirectional fidelity)
- **MODIFIED**: All 12 converter functions to support `preserveLayout` parameter
- **MODIFIED**: `TurboSerializable` class to support key metadata in serialization
</details>

### Task Details

# Task: Implement Markdown Layout Parser

## End Goal

Create a Markdown parser that extracts both data and layout metadata, enabling 100% round-trip fidelity.

## Currently

`markdownToJson()` extracts frontmatter and body content but loses all layout information (headers, callouts, dividers, code blocks, lists, tables, emphasis, whitespace).

## Should

`markdownToJson()` returns a `LayoutAwareParseResult` with complete `keyMeta` that captures all Markdown structural elements when `preserveLayout: true`.

## Constraints

- [ ] Must parse GitHub/Obsidian-style callouts: `> [!NOTE]`, `> [!WARNING]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!CAUTION]`
- [ ] Must handle nested structures (lists within lists, code within callouts)
- [ ] Must preserve exact whitespace for 100% fidelity
- [ ] Must be backward compatible when `preserveLayout: false`
- [ ] Must handle edge cases (empty documents, malformed Markdown)

## Acceptance Criteria

- [ ] Headers (`#` through `######`) are parsed with level captured in `keyMeta`
- [ ] Callouts are parsed with type, content, and position captured
- [ ] Dividers (`---`, `***`, `___`) are parsed with style and position captured
- [ ] Fenced code blocks are parsed with language and content captured
- [ ] Unordered lists (`-`, `*`, `+`) are parsed with marker style captured
- [ ] Ordered lists (`1.`, `1)`) are parsed with start number and style captured
- [ ] Task lists (`- [ ]`, `- [x]`) are parsed with checked state captured
- [ ] Tables are parsed with alignment and header presence captured
- [ ] Inline emphasis is parsed with style markers captured
- [ ] Exact whitespace (newlines, indentation) is captured
- [ ] Line endings (`\n` vs `\r\n`) are detected and captured
- [ ] Round-trip test: `markdownToJson → jsonToMarkdown` produces identical output

## Implementation Checklist

- [ ] 2.1 Create `lib/parsers/markdown_parser.dart` with `MarkdownLayoutParser` class
- [ ] 2.2 Implement header parsing with level extraction
- [ ] 2.3 Implement callout parsing with GitHub/Obsidian syntax support
- [ ] 2.4 Implement divider parsing with style detection
- [ ] 2.5 Implement fenced code block parsing with language detection
- [ ] 2.6 Implement unordered list parsing with marker style detection
- [ ] 2.7 Implement ordered list parsing with numbering style detection
- [ ] 2.8 Implement task list parsing with checked state detection
- [ ] 2.9 Implement table parsing with alignment detection
- [ ] 2.10 Implement emphasis parsing (bold, italic, strikethrough, inline code)
- [ ] 2.11 Implement whitespace preservation (newlines, raw whitespace)
- [ ] 2.12 Implement line ending detection (`\n` vs `\r\n`)
- [ ] 2.13 Update `markdownToJson()` to use new parser when `preserveLayout: true`
- [ ] 2.14 Maintain backward compatibility when `preserveLayout: false`
- [ ] 2.15 Write comprehensive unit tests in `test/parsers/markdown_parser_test.dart`
- [ ] 2.16 Write integration tests for round-trip fidelity

## Notes

- Consider using regex for simple patterns and stateful parsing for nested structures
- Header text should be converted to camelCase for the key name
- Position tracking is crucial for associating metadata with the correct key
- Test with real-world Markdown documents from various sources

### Agent Instructions

Pick up this task and implement it according to the specifications above.
Focus on the Constraints and Acceptance Criteria sections.
When complete, mark the task as done:

```bash
plx complete task --id 002-add-key-metadata-support-markdown-parser
```

---

## Task 3: generator

**Status:** to-do
**Task ID:** 003-add-key-metadata-support-markdown-generator

### Context

<details>
<summary>Proposal Context (click to expand)</summary>

## Why

Currently, `turbo_serializable` performs straightforward key-to-key conversions between formats (JSON, YAML, XML, Markdown). Layout and formatting information is lost during conversion - a Markdown document with callouts, dividers, and specific header levels cannot be converted to JSON and back without losing its visual structure. This prevents use cases where documents need to be stored/processed as data while preserving their original presentation.

## What Changes

- **ADDED**: `_keyMeta` object to store per-key layout metadata separate from data
- **ADDED**: `KeyMetadata` model class with format-specific layout properties
- **ADDED**: `preserveLayout` parameter (default: `true`) to all conversion functions
- **ADDED**: Markdown layout parsing (callouts, dividers, code blocks, tables, lists, headers, emphasis)
- **ADDED**: XML layout parsing (attributes vs elements, CDATA, comments, namespaces)
- **ADDED**: YAML layout parsing (anchors/aliases, comments, flow vs block style)
- **ADDED**: JSON layout parsing (indentation/spacing preservation)
- **ADDED**: Full path support for nested key metadata (dot notation or nested structure)
- **ADDED**: Layout-aware generation for all formats (bidirectional fidelity)
- **MODIFIED**: All 12 converter functions to support `preserveLayout` parameter
- **MODIFIED**: `TurboSerializable` class to support key metadata in serialization
</details>

### Task Details

# Task: Implement Markdown Layout Generator

## End Goal

Create a Markdown generator that uses key metadata to produce byte-for-byte identical output to the original parsed Markdown.

## Currently

`jsonToMarkdown()` generates Markdown using simple conventions (## headers, basic lists) without any layout customization.

## Should

`jsonToMarkdown()` uses provided `keyMeta` to generate Markdown with exact layout matching (headers, callouts, dividers, code blocks, lists, tables, emphasis, whitespace) when `preserveLayout: true`.

## Constraints

- [ ] Must produce byte-for-byte identical output when using metadata from parsing
- [ ] Must handle missing metadata gracefully (fall back to defaults)
- [ ] Must preserve exact whitespace from `WhitespaceMeta`
- [ ] Must be backward compatible when `preserveLayout: false` or `keyMeta` is null
- [ ] Must handle nested key metadata correctly

## Acceptance Criteria

- [ ] Headers are generated with exact level from `keyMeta.headerLevel`
- [ ] Callouts are generated at correct position with exact syntax
- [ ] Dividers are generated with exact style (`---`, `***`, `___`) at correct position
- [ ] Code blocks are generated with language specifier
- [ ] Lists are generated with correct marker style (`-`, `*`, `+`, `1.`, `1)`)
- [ ] Task lists are generated with correct checked state
- [ ] Tables are generated with correct alignment markers
- [ ] Emphasis is generated with correct markers (`**`, `*`, `~~`, `` ` ``)
- [ ] Whitespace is generated exactly as specified
- [ ] Line endings match the captured style
- [ ] Nested structures are generated correctly
- [ ] Without metadata, generates sensible defaults (current behavior)

## Implementation Checklist

- [ ] 3.1 Create `lib/generators/markdown_generator.dart` with `MarkdownLayoutGenerator` class
- [ ] 3.2 Implement header generation with level support
- [ ] 3.3 Implement callout generation with position awareness
- [ ] 3.4 Implement divider generation with style support
- [ ] 3.5 Implement code block generation with language support
- [ ] 3.6 Implement list generation with marker style support
- [ ] 3.7 Implement task list generation with checked state
- [ ] 3.8 Implement table generation with alignment support
- [ ] 3.9 Implement emphasis generation with marker preservation
- [ ] 3.10 Implement whitespace generation with exact preservation
- [ ] 3.11 Implement line ending handling
- [ ] 3.12 Implement nested key metadata traversal
- [ ] 3.13 Update `jsonToMarkdown()` to accept `keyMeta` parameter
- [ ] 3.14 Update `jsonToMarkdown()` to use generator when `preserveLayout: true`
- [ ] 3.15 Maintain backward compatibility for existing calls
- [ ] 3.16 Write unit tests in `test/generators/markdown_generator_test.dart`
- [ ] 3.17 Write byte-for-byte fidelity tests

## Notes

- The generator should build output incrementally using StringBuffer
- Order of elements matters: dividers before headers, callouts at correct positions
- Test with the same documents used in parser tests to verify round-trip

### Agent Instructions

Pick up this task and implement it according to the specifications above.
Focus on the Constraints and Acceptance Criteria sections.
When complete, mark the task as done:

```bash
plx complete task --id 003-add-key-metadata-support-markdown-generator
```

---

## Task 4: parser

**Status:** to-do
**Task ID:** 004-add-key-metadata-support-xml-parser

### Context

<details>
<summary>Proposal Context (click to expand)</summary>

## Why

Currently, `turbo_serializable` performs straightforward key-to-key conversions between formats (JSON, YAML, XML, Markdown). Layout and formatting information is lost during conversion - a Markdown document with callouts, dividers, and specific header levels cannot be converted to JSON and back without losing its visual structure. This prevents use cases where documents need to be stored/processed as data while preserving their original presentation.

## What Changes

- **ADDED**: `_keyMeta` object to store per-key layout metadata separate from data
- **ADDED**: `KeyMetadata` model class with format-specific layout properties
- **ADDED**: `preserveLayout` parameter (default: `true`) to all conversion functions
- **ADDED**: Markdown layout parsing (callouts, dividers, code blocks, tables, lists, headers, emphasis)
- **ADDED**: XML layout parsing (attributes vs elements, CDATA, comments, namespaces)
- **ADDED**: YAML layout parsing (anchors/aliases, comments, flow vs block style)
- **ADDED**: JSON layout parsing (indentation/spacing preservation)
- **ADDED**: Full path support for nested key metadata (dot notation or nested structure)
- **ADDED**: Layout-aware generation for all formats (bidirectional fidelity)
- **MODIFIED**: All 12 converter functions to support `preserveLayout` parameter
- **MODIFIED**: `TurboSerializable` class to support key metadata in serialization
</details>

### Task Details

# Task: Implement XML Layout Parser

## End Goal

Create an XML parser that extracts both data and layout metadata (attributes, CDATA, comments, namespaces), enabling 100% round-trip fidelity.

## Currently

`xmlToMap()` converts XML elements to a map but loses attributes, CDATA distinctions, comments, and namespace information.

## Should

`xmlToJson()` returns data with associated `keyMeta` that captures all XML structural elements when `preserveLayout: true`.

## Constraints

- [ ] Must distinguish between attributes and child elements
- [ ] Must preserve CDATA sections vs regular text content
- [ ] Must capture XML comments with their positions
- [ ] Must preserve namespace declarations and prefixes
- [ ] Must handle mixed content (text + elements)
- [ ] Must be backward compatible when `preserveLayout: false`

## Acceptance Criteria

- [ ] Attributes are captured in `xmlMeta.attributes` as a map
- [ ] CDATA sections are marked with `xmlMeta.isCdata: true`
- [ ] Comments are captured in `xmlMeta.comment` with position
- [ ] Namespace URIs are captured in `xmlMeta.namespace`
- [ ] Namespace prefixes are captured in `xmlMeta.prefix`
- [ ] Element order is preserved for round-trip
- [ ] Mixed content is handled appropriately
- [ ] Round-trip test: `xmlToJson → jsonToXml` produces identical output

## Implementation Checklist

- [ ] 4.1 Create `lib/parsers/xml_parser.dart` with `XmlLayoutParser` class
- [ ] 4.2 Implement attribute extraction into `XmlMeta`
- [ ] 4.3 Implement CDATA section detection
- [ ] 4.4 Implement comment extraction with position tracking
- [ ] 4.5 Implement namespace declaration extraction
- [ ] 4.6 Implement namespace prefix extraction
- [ ] 4.7 Implement mixed content handling
- [ ] 4.8 Implement element order preservation
- [ ] 4.9 Update `xmlToMap()` / `xmlToJson()` to use new parser when `preserveLayout: true`
- [ ] 4.10 Return `LayoutAwareParseResult` or add `_keyMeta` to result
- [ ] 4.11 Maintain backward compatibility when `preserveLayout: false`
- [ ] 4.12 Write unit tests in `test/parsers/xml_parser_test.dart`
- [ ] 4.13 Write integration tests for round-trip fidelity

## Notes

- Use the existing `xml` package's DOM capabilities for parsing
- Attributes like `id="123"` should go to `xmlMeta.attributes`, not the data value
- Consider how to handle elements that have both attributes and text content
- Test with complex XML documents including namespaces and CDATA

### Agent Instructions

Pick up this task and implement it according to the specifications above.
Focus on the Constraints and Acceptance Criteria sections.
When complete, mark the task as done:

```bash
plx complete task --id 004-add-key-metadata-support-xml-parser
```

---

## Task 5: generator

**Status:** to-do
**Task ID:** 005-add-key-metadata-support-xml-generator

### Context

<details>
<summary>Proposal Context (click to expand)</summary>

## Why

Currently, `turbo_serializable` performs straightforward key-to-key conversions between formats (JSON, YAML, XML, Markdown). Layout and formatting information is lost during conversion - a Markdown document with callouts, dividers, and specific header levels cannot be converted to JSON and back without losing its visual structure. This prevents use cases where documents need to be stored/processed as data while preserving their original presentation.

## What Changes

- **ADDED**: `_keyMeta` object to store per-key layout metadata separate from data
- **ADDED**: `KeyMetadata` model class with format-specific layout properties
- **ADDED**: `preserveLayout` parameter (default: `true`) to all conversion functions
- **ADDED**: Markdown layout parsing (callouts, dividers, code blocks, tables, lists, headers, emphasis)
- **ADDED**: XML layout parsing (attributes vs elements, CDATA, comments, namespaces)
- **ADDED**: YAML layout parsing (anchors/aliases, comments, flow vs block style)
- **ADDED**: JSON layout parsing (indentation/spacing preservation)
- **ADDED**: Full path support for nested key metadata (dot notation or nested structure)
- **ADDED**: Layout-aware generation for all formats (bidirectional fidelity)
- **MODIFIED**: All 12 converter functions to support `preserveLayout` parameter
- **MODIFIED**: `TurboSerializable` class to support key metadata in serialization
</details>

### Task Details

# Task: Implement XML Layout Generator

## End Goal

Create an XML generator that uses key metadata to produce byte-for-byte identical output to the original parsed XML.

## Currently

`jsonToXml()` generates XML elements from map keys but cannot restore attributes, CDATA sections, comments, or namespaces.

## Should

`jsonToXml()` uses provided `keyMeta` to generate XML with exact layout matching (attributes, CDATA, comments, namespaces) when `preserveLayout: true`.

## Constraints

- [ ] Must produce byte-for-byte identical output when using metadata from parsing
- [ ] Must handle missing metadata gracefully (default to element-only output)
- [ ] Must correctly format namespace declarations
- [ ] Must be backward compatible when `preserveLayout: false` or `keyMeta` is null
- [ ] Must handle nested key metadata correctly

## Acceptance Criteria

- [ ] Attributes are restored from `xmlMeta.attributes`
- [ ] CDATA sections are generated when `xmlMeta.isCdata: true`
- [ ] Comments are generated at correct positions from `xmlMeta.comment`
- [ ] Namespace declarations are generated from `xmlMeta.namespace`
- [ ] Namespace prefixes are applied from `xmlMeta.prefix`
- [ ] Element order matches original
- [ ] Mixed content is generated correctly
- [ ] Without metadata, generates standard elements (current behavior)

## Implementation Checklist

- [ ] 5.1 Create `lib/generators/xml_generator.dart` with `XmlLayoutGenerator` class
- [ ] 5.2 Implement attribute generation from `XmlMeta`
- [ ] 5.3 Implement CDATA section generation
- [ ] 5.4 Implement comment generation with position support
- [ ] 5.5 Implement namespace declaration generation
- [ ] 5.6 Implement namespace prefix application
- [ ] 5.7 Implement mixed content generation
- [ ] 5.8 Implement element order preservation
- [ ] 5.9 Update `jsonToXml()` to accept `keyMeta` parameter
- [ ] 5.10 Update `jsonToXml()` to use generator when `preserveLayout: true`
- [ ] 5.11 Maintain backward compatibility for existing calls
- [ ] 5.12 Write unit tests in `test/generators/xml_generator_test.dart`
- [ ] 5.13 Write byte-for-byte fidelity tests

## Notes

- Use the existing `xml` package's XmlBuilder for generation
- Attribute order should match the original (may require LinkedHashMap)
- Test with the same XML documents used in parser tests

### Agent Instructions

Pick up this task and implement it according to the specifications above.
Focus on the Constraints and Acceptance Criteria sections.
When complete, mark the task as done:

```bash
plx complete task --id 005-add-key-metadata-support-xml-generator
```

---

## Task 6: parser

**Status:** to-do
**Task ID:** 006-add-key-metadata-support-yaml-parser

### Context

<details>
<summary>Proposal Context (click to expand)</summary>

## Why

Currently, `turbo_serializable` performs straightforward key-to-key conversions between formats (JSON, YAML, XML, Markdown). Layout and formatting information is lost during conversion - a Markdown document with callouts, dividers, and specific header levels cannot be converted to JSON and back without losing its visual structure. This prevents use cases where documents need to be stored/processed as data while preserving their original presentation.

## What Changes

- **ADDED**: `_keyMeta` object to store per-key layout metadata separate from data
- **ADDED**: `KeyMetadata` model class with format-specific layout properties
- **ADDED**: `preserveLayout` parameter (default: `true`) to all conversion functions
- **ADDED**: Markdown layout parsing (callouts, dividers, code blocks, tables, lists, headers, emphasis)
- **ADDED**: XML layout parsing (attributes vs elements, CDATA, comments, namespaces)
- **ADDED**: YAML layout parsing (anchors/aliases, comments, flow vs block style)
- **ADDED**: JSON layout parsing (indentation/spacing preservation)
- **ADDED**: Full path support for nested key metadata (dot notation or nested structure)
- **ADDED**: Layout-aware generation for all formats (bidirectional fidelity)
- **MODIFIED**: All 12 converter functions to support `preserveLayout` parameter
- **MODIFIED**: `TurboSerializable` class to support key metadata in serialization
</details>

### Task Details

# Task: Implement YAML Layout Parser

## End Goal

Create a YAML parser that extracts both data and layout metadata (anchors, aliases, comments, flow/block style), enabling 100% round-trip fidelity.

## Currently

`yamlToJson()` parses YAML values but loses anchors, aliases, comments, and style information (flow vs block, scalar presentation).

## Should

`yamlToJson()` returns data with associated `keyMeta` that captures all YAML structural elements when `preserveLayout: true`.

## Constraints

- [ ] Must capture anchor definitions (`&name`) and alias references (`*name`)
- [ ] Must preserve inline and block comments
- [ ] Must detect flow style (`{key: value}`) vs block style
- [ ] Must detect scalar presentation styles (literal `|`, folded `>`, quoted)
- [ ] Must handle multi-document YAML
- [ ] Must be backward compatible when `preserveLayout: false`

## Acceptance Criteria

- [ ] Anchors are captured in `yamlMeta.anchor`
- [ ] Aliases are captured in `yamlMeta.alias`
- [ ] Comments are captured in `yamlMeta.comment` with association
- [ ] Flow vs block style is captured in `yamlMeta.style`
- [ ] Scalar styles (literal, folded, single-quoted, double-quoted) are captured in `yamlMeta.scalarStyle`
- [ ] Multi-document markers (`---`, `...`) are handled
- [ ] Round-trip test: `yamlToJson → jsonToYaml` produces identical output

## Implementation Checklist

- [ ] 6.1 Create `lib/parsers/yaml_parser.dart` with `YamlLayoutParser` class
- [ ] 6.2 Implement anchor extraction
- [ ] 6.3 Implement alias extraction
- [ ] 6.4 Implement comment extraction with line association
- [ ] 6.5 Implement flow vs block style detection
- [ ] 6.6 Implement scalar style detection (literal, folded, quoted)
- [ ] 6.7 Implement multi-document handling
- [ ] 6.8 Update `yamlToJson()` to use new parser when `preserveLayout: true`
- [ ] 6.9 Return `LayoutAwareParseResult` or add `_keyMeta` to result
- [ ] 6.10 Maintain backward compatibility when `preserveLayout: false`
- [ ] 6.11 Write unit tests in `test/parsers/yaml_parser_test.dart`
- [ ] 6.12 Write integration tests for round-trip fidelity

## Notes

- The `yaml` package provides `YamlNode` types that may expose some style information
- Comments are typically lost in most YAML parsers; may need lower-level parsing
- Consider using `yaml` package's `YamlDocument` for multi-document support
- Test with complex YAML documents including all features

### Agent Instructions

Pick up this task and implement it according to the specifications above.
Focus on the Constraints and Acceptance Criteria sections.
When complete, mark the task as done:

```bash
plx complete task --id 006-add-key-metadata-support-yaml-parser
```

---

## Task 7: generator

**Status:** to-do
**Task ID:** 007-add-key-metadata-support-yaml-generator

### Context

<details>
<summary>Proposal Context (click to expand)</summary>

## Why

Currently, `turbo_serializable` performs straightforward key-to-key conversions between formats (JSON, YAML, XML, Markdown). Layout and formatting information is lost during conversion - a Markdown document with callouts, dividers, and specific header levels cannot be converted to JSON and back without losing its visual structure. This prevents use cases where documents need to be stored/processed as data while preserving their original presentation.

## What Changes

- **ADDED**: `_keyMeta` object to store per-key layout metadata separate from data
- **ADDED**: `KeyMetadata` model class with format-specific layout properties
- **ADDED**: `preserveLayout` parameter (default: `true`) to all conversion functions
- **ADDED**: Markdown layout parsing (callouts, dividers, code blocks, tables, lists, headers, emphasis)
- **ADDED**: XML layout parsing (attributes vs elements, CDATA, comments, namespaces)
- **ADDED**: YAML layout parsing (anchors/aliases, comments, flow vs block style)
- **ADDED**: JSON layout parsing (indentation/spacing preservation)
- **ADDED**: Full path support for nested key metadata (dot notation or nested structure)
- **ADDED**: Layout-aware generation for all formats (bidirectional fidelity)
- **MODIFIED**: All 12 converter functions to support `preserveLayout` parameter
- **MODIFIED**: `TurboSerializable` class to support key metadata in serialization
</details>

### Task Details

# Task: Implement YAML Layout Generator

## End Goal

Create a YAML generator that uses key metadata to produce byte-for-byte identical output to the original parsed YAML.

## Currently

`jsonToYaml()` generates YAML using block style without anchors, aliases, comments, or scalar style control.

## Should

`jsonToYaml()` uses provided `keyMeta` to generate YAML with exact layout matching (anchors, aliases, comments, styles) when `preserveLayout: true`.

## Constraints

- [ ] Must produce byte-for-byte identical output when using metadata from parsing
- [ ] Must handle missing metadata gracefully (default to block style)
- [ ] Must correctly link aliases to their anchors
- [ ] Must be backward compatible when `preserveLayout: false` or `keyMeta` is null
- [ ] Must handle nested key metadata correctly

## Acceptance Criteria

- [ ] Anchors are generated from `yamlMeta.anchor`
- [ ] Aliases are generated from `yamlMeta.alias` (referencing anchors)
- [ ] Comments are generated at correct positions from `yamlMeta.comment`
- [ ] Flow style is generated when `yamlMeta.style: 'flow'`
- [ ] Scalar styles are applied from `yamlMeta.scalarStyle`
- [ ] Multi-document markers are generated as needed
- [ ] Without metadata, generates standard block YAML (current behavior)

## Implementation Checklist

- [ ] 7.1 Create `lib/generators/yaml_generator.dart` with `YamlLayoutGenerator` class
- [ ] 7.2 Implement anchor generation
- [ ] 7.3 Implement alias generation with anchor linking
- [ ] 7.4 Implement comment generation with line association
- [ ] 7.5 Implement flow vs block style generation
- [ ] 7.6 Implement scalar style application (literal, folded, quoted)
- [ ] 7.7 Implement multi-document generation
- [ ] 7.8 Update `jsonToYaml()` to accept `keyMeta` parameter
- [ ] 7.9 Update `jsonToYaml()` to use generator when `preserveLayout: true`
- [ ] 7.10 Maintain backward compatibility for existing calls
- [ ] 7.11 Write unit tests in `test/generators/yaml_generator_test.dart`
- [ ] 7.12 Write byte-for-byte fidelity tests

## Notes

- YAML generation may require custom serialization rather than using a library
- Anchors must be defined before aliases that reference them
- Flow style affects child elements too: `{a: 1, b: 2}` vs block
- Test with the same YAML documents used in parser tests

### Agent Instructions

Pick up this task and implement it according to the specifications above.
Focus on the Constraints and Acceptance Criteria sections.
When complete, mark the task as done:

```bash
plx complete task --id 007-add-key-metadata-support-yaml-generator
```

---

## Task 8: layout

**Status:** to-do
**Task ID:** 008-add-key-metadata-support-json-layout

### Context

<details>
<summary>Proposal Context (click to expand)</summary>

## Why

Currently, `turbo_serializable` performs straightforward key-to-key conversions between formats (JSON, YAML, XML, Markdown). Layout and formatting information is lost during conversion - a Markdown document with callouts, dividers, and specific header levels cannot be converted to JSON and back without losing its visual structure. This prevents use cases where documents need to be stored/processed as data while preserving their original presentation.

## What Changes

- **ADDED**: `_keyMeta` object to store per-key layout metadata separate from data
- **ADDED**: `KeyMetadata` model class with format-specific layout properties
- **ADDED**: `preserveLayout` parameter (default: `true`) to all conversion functions
- **ADDED**: Markdown layout parsing (callouts, dividers, code blocks, tables, lists, headers, emphasis)
- **ADDED**: XML layout parsing (attributes vs elements, CDATA, comments, namespaces)
- **ADDED**: YAML layout parsing (anchors/aliases, comments, flow vs block style)
- **ADDED**: JSON layout parsing (indentation/spacing preservation)
- **ADDED**: Full path support for nested key metadata (dot notation or nested structure)
- **ADDED**: Layout-aware generation for all formats (bidirectional fidelity)
- **MODIFIED**: All 12 converter functions to support `preserveLayout` parameter
- **MODIFIED**: `TurboSerializable` class to support key metadata in serialization
</details>

### Task Details

# Task: Implement JSON Layout Preservation

## End Goal

Add JSON formatting preservation (indentation, spacing) to enable round-trip fidelity for JSON documents.

## Currently

JSON is typically the canonical data format. `jsonEncodeFormatted()` uses fixed indentation without preserving original formatting.

## Should

JSON parsing captures formatting metadata and generation respects it when `preserveLayout: true`.

## Constraints

- [ ] Must detect original indentation (2 spaces, 4 spaces, tabs)
- [ ] Must preserve spacing patterns
- [ ] Must be backward compatible
- [ ] JSON is often the intermediate format, so this may have lower priority

## Acceptance Criteria

- [ ] Indentation style (spaces count or tabs) is captured in `jsonMeta.indentSpaces`
- [ ] Pretty print vs minified is detected
- [ ] Round-trip maintains formatting style
- [ ] Default behavior unchanged when `preserveLayout: false`

## Implementation Checklist

- [ ] 8.1 Create `lib/parsers/json_parser.dart` with `JsonLayoutParser` class
- [ ] 8.2 Implement indentation detection (count leading spaces)
- [ ] 8.3 Implement pretty vs minified detection
- [ ] 8.4 Create `lib/generators/json_generator.dart` with `JsonLayoutGenerator` class
- [ ] 8.5 Implement formatted output with configurable indentation
- [ ] 8.6 Update JSON-related functions to support `preserveLayout`
- [ ] 8.7 Write unit tests in `test/parsers/json_parser_test.dart`
- [ ] 8.8 Write unit tests in `test/generators/json_generator_test.dart`

## Notes

- JSON parsing in Dart uses `jsonDecode` which doesn't expose formatting
- May need regex-based detection on the raw string before parsing
- Lower priority since JSON is often just the data carrier

### Agent Instructions

Pick up this task and implement it according to the specifications above.
Focus on the Constraints and Acceptance Criteria sections.
When complete, mark the task as done:

```bash
plx complete task --id 008-add-key-metadata-support-json-layout
```

---

## Task 9: integration

**Status:** to-do
**Task ID:** 009-add-key-metadata-support-api-integration

### Context

<details>
<summary>Proposal Context (click to expand)</summary>

## Why

Currently, `turbo_serializable` performs straightforward key-to-key conversions between formats (JSON, YAML, XML, Markdown). Layout and formatting information is lost during conversion - a Markdown document with callouts, dividers, and specific header levels cannot be converted to JSON and back without losing its visual structure. This prevents use cases where documents need to be stored/processed as data while preserving their original presentation.

## What Changes

- **ADDED**: `_keyMeta` object to store per-key layout metadata separate from data
- **ADDED**: `KeyMetadata` model class with format-specific layout properties
- **ADDED**: `preserveLayout` parameter (default: `true`) to all conversion functions
- **ADDED**: Markdown layout parsing (callouts, dividers, code blocks, tables, lists, headers, emphasis)
- **ADDED**: XML layout parsing (attributes vs elements, CDATA, comments, namespaces)
- **ADDED**: YAML layout parsing (anchors/aliases, comments, flow vs block style)
- **ADDED**: JSON layout parsing (indentation/spacing preservation)
- **ADDED**: Full path support for nested key metadata (dot notation or nested structure)
- **ADDED**: Layout-aware generation for all formats (bidirectional fidelity)
- **MODIFIED**: All 12 converter functions to support `preserveLayout` parameter
- **MODIFIED**: `TurboSerializable` class to support key metadata in serialization
</details>

### Task Details

# Task: Integrate Key Metadata into Converter APIs

## End Goal

Update all 12 converter functions and `TurboSerializable` class to support the `preserveLayout` parameter and `keyMeta` handling.

## Currently

Converter functions have no `preserveLayout` parameter or `keyMeta` support. `TurboSerializable` doesn't handle key-level metadata.

## Should

All converter functions accept `preserveLayout` (default: `true`) and `keyMeta` parameters. `TurboSerializable` methods pass through key metadata.

## Constraints

- [ ] Must maintain full backward compatibility
- [ ] Must update function signatures without breaking existing code
- [ ] Must coordinate between parsers and generators
- [ ] Must handle cross-format conversions (e.g., `markdownToXml` needs to pass metadata through)

## Acceptance Criteria

- [ ] All 12 converter functions have `preserveLayout` parameter (default: `true`)
- [ ] Parsing functions (`*ToJson`) return or provide `keyMeta`
- [ ] Generation functions (`jsonTo*`) accept `keyMeta` parameter
- [ ] Cross-format converters pass metadata through intermediate formats
- [ ] `TurboSerializable.toJson/toYaml/toMarkdown/toXml` support `preserveLayout`
- [ ] Existing code works without modification
- [ ] Documentation is updated with new parameters

## Implementation Checklist

- [ ] 9.1 Update `jsonToYaml()` signature with `keyMeta` and `preserveLayout`
- [ ] 9.2 Update `jsonToMarkdown()` signature with `keyMeta` and `preserveLayout`
- [ ] 9.3 Update `jsonToXml()` signature with `keyMeta` and `preserveLayout`
- [ ] 9.4 Update `yamlToJson()` to return/provide `keyMeta`
- [ ] 9.5 Update `yamlToMarkdown()` to pass `keyMeta` through
- [ ] 9.6 Update `yamlToXml()` to pass `keyMeta` through
- [ ] 9.7 Update `markdownToJson()` to return/provide `keyMeta`
- [ ] 9.8 Update `markdownToYaml()` to pass `keyMeta` through
- [ ] 9.9 Update `markdownToXml()` to pass `keyMeta` through
- [ ] 9.10 Update `xmlToJson()` to return/provide `keyMeta`
- [ ] 9.11 Update `xmlToYaml()` to pass `keyMeta` through
- [ ] 9.12 Update `xmlToMarkdown()` to pass `keyMeta` through
- [ ] 9.13 Update `TurboSerializable.toJson()` with `preserveLayout`
- [ ] 9.14 Update `TurboSerializable.toYaml()` with `preserveLayout`
- [ ] 9.15 Update `TurboSerializable.toMarkdown()` with `preserveLayout`
- [ ] 9.16 Update `TurboSerializable.toXml()` with `preserveLayout`
- [ ] 9.17 Update `TurboSerializableConfig` if needed
- [ ] 9.18 Update dartdoc comments for all modified functions
- [ ] 9.19 Update README with new parameters
- [ ] 9.20 Write integration tests for cross-format metadata preservation

## Notes

- Consider whether to use `LayoutAwareParseResult` return type or add `_keyMeta` to returned map
- Cross-format conversions go through JSON as intermediate; metadata must survive
- Think about how `keyMeta` for Markdown (headers, callouts) maps to XML or YAML

### Agent Instructions

Pick up this task and implement it according to the specifications above.
Focus on the Constraints and Acceptance Criteria sections.
When complete, mark the task as done:

```bash
plx complete task --id 009-add-key-metadata-support-api-integration
```

---

## Task 10: review

**Status:** to-do
**Task ID:** 010-add-key-metadata-support-review

### Context

<details>
<summary>Proposal Context (click to expand)</summary>

## Why

Currently, `turbo_serializable` performs straightforward key-to-key conversions between formats (JSON, YAML, XML, Markdown). Layout and formatting information is lost during conversion - a Markdown document with callouts, dividers, and specific header levels cannot be converted to JSON and back without losing its visual structure. This prevents use cases where documents need to be stored/processed as data while preserving their original presentation.

## What Changes

- **ADDED**: `_keyMeta` object to store per-key layout metadata separate from data
- **ADDED**: `KeyMetadata` model class with format-specific layout properties
- **ADDED**: `preserveLayout` parameter (default: `true`) to all conversion functions
- **ADDED**: Markdown layout parsing (callouts, dividers, code blocks, tables, lists, headers, emphasis)
- **ADDED**: XML layout parsing (attributes vs elements, CDATA, comments, namespaces)
- **ADDED**: YAML layout parsing (anchors/aliases, comments, flow vs block style)
- **ADDED**: JSON layout parsing (indentation/spacing preservation)
- **ADDED**: Full path support for nested key metadata (dot notation or nested structure)
- **ADDED**: Layout-aware generation for all formats (bidirectional fidelity)
- **MODIFIED**: All 12 converter functions to support `preserveLayout` parameter
- **MODIFIED**: `TurboSerializable` class to support key metadata in serialization
</details>

### Task Details

# Task: Review Implementation Completeness

## End Goal

Verify all implementation tasks are complete, consistent, and meet the acceptance criteria for 100% round-trip fidelity.

## Currently

Individual tasks have been implemented separately.

## Should

All components work together correctly, code is consistent, and the feature is ready for testing.

## Constraints

- [ ] Must verify all acceptance criteria from spec are met
- [ ] Must check code consistency across all new files
- [ ] Must ensure documentation is complete
- [ ] Must verify no breaking changes to existing API

## Acceptance Criteria

- [ ] All model classes exist and are properly exported
- [ ] All parsers extract complete metadata
- [ ] All generators use metadata correctly
- [ ] All converter APIs are updated
- [ ] Code style is consistent
- [ ] Dartdoc comments are complete
- [ ] No compiler warnings or errors
- [ ] Static analysis passes

## Implementation Checklist

- [ ] 10.1 Review `KeyMetadata` and related model classes
- [ ] 10.2 Review Markdown parser implementation
- [ ] 10.3 Review Markdown generator implementation
- [ ] 10.4 Review XML parser implementation
- [ ] 10.5 Review XML generator implementation
- [ ] 10.6 Review YAML parser implementation
- [ ] 10.7 Review YAML generator implementation
- [ ] 10.8 Review JSON layout implementation
- [ ] 10.9 Review API integration completeness
- [ ] 10.10 Verify all exports in `lib/turbo_serializable.dart`
- [ ] 10.11 Run `dart analyze` and fix any issues
- [ ] 10.12 Verify README documentation is updated
- [ ] 10.13 Verify CHANGELOG entry is prepared
- [ ] 10.14 Cross-check against spec requirements

## Notes

- This is a checkpoint task before comprehensive testing
- Focus on completeness and consistency rather than correctness (tests will verify)

### Agent Instructions

Pick up this task and implement it according to the specifications above.
Focus on the Constraints and Acceptance Criteria sections.
When complete, mark the task as done:

```bash
plx complete task --id 010-add-key-metadata-support-review
```

---

## Task 11: test

**Status:** to-do
**Task ID:** 011-add-key-metadata-support-test

### Context

<details>
<summary>Proposal Context (click to expand)</summary>

## Why

Currently, `turbo_serializable` performs straightforward key-to-key conversions between formats (JSON, YAML, XML, Markdown). Layout and formatting information is lost during conversion - a Markdown document with callouts, dividers, and specific header levels cannot be converted to JSON and back without losing its visual structure. This prevents use cases where documents need to be stored/processed as data while preserving their original presentation.

## What Changes

- **ADDED**: `_keyMeta` object to store per-key layout metadata separate from data
- **ADDED**: `KeyMetadata` model class with format-specific layout properties
- **ADDED**: `preserveLayout` parameter (default: `true`) to all conversion functions
- **ADDED**: Markdown layout parsing (callouts, dividers, code blocks, tables, lists, headers, emphasis)
- **ADDED**: XML layout parsing (attributes vs elements, CDATA, comments, namespaces)
- **ADDED**: YAML layout parsing (anchors/aliases, comments, flow vs block style)
- **ADDED**: JSON layout parsing (indentation/spacing preservation)
- **ADDED**: Full path support for nested key metadata (dot notation or nested structure)
- **ADDED**: Layout-aware generation for all formats (bidirectional fidelity)
- **MODIFIED**: All 12 converter functions to support `preserveLayout` parameter
- **MODIFIED**: `TurboSerializable` class to support key metadata in serialization
</details>

### Task Details

# Task: Comprehensive Testing and Round-Trip Validation

## End Goal

Verify 100% round-trip fidelity through comprehensive tests for all formats and structural elements.

## Currently

Existing tests cover basic format conversion but not layout preservation.

## Should

Comprehensive test suite validates byte-for-byte round-trip fidelity for all formats with various structural elements.

## Constraints

- [ ] Must test all Markdown structural elements (headers, callouts, dividers, code blocks, lists, tables, emphasis)
- [ ] Must test all XML structural elements (attributes, CDATA, comments, namespaces)
- [ ] Must test all YAML structural elements (anchors, aliases, comments, styles)
- [ ] Must test nested structures
- [ ] Must test edge cases and error handling
- [ ] Must achieve high code coverage

## Acceptance Criteria

- [ ] Markdown round-trip tests pass for all structural elements
- [ ] XML round-trip tests pass for all structural elements
- [ ] YAML round-trip tests pass for all structural elements
- [ ] JSON formatting tests pass
- [ ] Cross-format conversion tests pass
- [ ] Nested key metadata tests pass
- [ ] `preserveLayout: false` backward compatibility tests pass
- [ ] Edge case tests pass (empty documents, malformed input)
- [ ] Code coverage is at least 80%
- [ ] All existing tests continue to pass

## Implementation Checklist

- [ ] 11.1 Create `test/round_trip/markdown_round_trip_test.dart`
- [ ] 11.2 Add tests for each Markdown structural element
- [ ] 11.3 Create `test/round_trip/xml_round_trip_test.dart`
- [ ] 11.4 Add tests for each XML structural element
- [ ] 11.5 Create `test/round_trip/yaml_round_trip_test.dart`
- [ ] 11.6 Add tests for each YAML structural element
- [ ] 11.7 Create `test/round_trip/json_round_trip_test.dart`
- [ ] 11.8 Create `test/round_trip/cross_format_test.dart`
- [ ] 11.9 Add tests for nested key metadata
- [ ] 11.10 Add backward compatibility tests
- [ ] 11.11 Add edge case tests
- [ ] 11.12 Create real-world document test fixtures
- [ ] 11.13 Add byte-for-byte comparison utility
- [ ] 11.14 Run all tests and fix failures
- [ ] 11.15 Generate and review code coverage report
- [ ] 11.16 Verify all existing tests still pass

## Notes

- Use real-world documents from various sources (GitHub READMEs, config files, etc.)
- The byte-for-byte comparison should report exactly where differences occur
- Consider property-based testing for comprehensive coverage
- Document any known limitations discovered during testing

### Agent Instructions

Pick up this task and implement it according to the specifications above.
Focus on the Constraints and Acceptance Criteria sections.
When complete, mark the task as done:

```bash
plx complete task --id 011-add-key-metadata-support-test
```

---
