## Context

`turbo_serializable` provides multi-format serialization (JSON, YAML, XML, Markdown) with automatic cross-format conversion. Current conversions are data-focused: keys map directly to keys, and format-specific presentation (Markdown headers, callouts, dividers; XML attributes; YAML anchors) is lost.

Users need to store documents as structured data while preserving their visual layout for faithful regeneration. This requires capturing layout metadata per key, separate from the data itself.

**Stakeholders**: Developers using turbo_serializable for document storage/processing where presentation matters.

**Constraints**:
- Must maintain backward compatibility (existing code works unchanged)
- Must achieve 100% round-trip fidelity (byte-for-byte identical output)
- Must keep document-level `_meta` and key-level `_keyMeta` separate
- Must support nested key paths

## Goals / Non-Goals

**Goals:**
- 100% round-trip fidelity for all formats (Markdown, XML, YAML, JSON)
- Per-key layout metadata storage in `_keyMeta` object
- Support for rich structural elements (callouts, dividers, code blocks, tables, lists, headers, emphasis, attributes, CDATA, comments, anchors/aliases)
- Full nested key path support
- Enabled by default with opt-out

**Non-Goals:**
- Custom `_keyMeta` key name (fixed)
- Inline metadata storage (always separate object)
- Semantic interpretation of content (only layout/presentation)

## Decisions

### Decision 1: KeyMetadata Model Structure

```dart
/// Base metadata that applies to any format
class KeyMetadata {
  final int? headerLevel;           // 1-6 for Markdown headers
  final DividerMeta? divider;       // Horizontal rule before/after
  final CalloutMeta? callout;       // NOTE/WARNING/TIP callout
  final CodeBlockMeta? codeBlock;   // Fenced code block info
  final ListMeta? listMeta;         // List type and style
  final TableMeta? tableMeta;       // Table formatting
  final EmphasisMeta? emphasis;     // Bold/italic/strikethrough
  final XmlMeta? xmlMeta;           // XML-specific (attributes, CDATA, comments)
  final YamlMeta? yamlMeta;         // YAML-specific (anchors, aliases, flow/block)
  final JsonMeta? jsonMeta;         // JSON-specific (indentation, spacing)
  final WhitespaceMeta? whitespace; // Exact whitespace preservation
  final Map<String, KeyMetadata>? children; // Nested key metadata
}

class DividerMeta {
  final bool before;
  final bool after;
  final String? style; // '---', '***', '___'
}

class CalloutMeta {
  final String type;     // 'note', 'warning', 'tip', 'important', 'caution'
  final String content;
  final String position; // 'before', 'after'
}

class CodeBlockMeta {
  final String? language;
  final String? filename;
  final bool isInline;
}

class ListMeta {
  final String type;        // 'unordered', 'ordered', 'task'
  final String? marker;     // '-', '*', '+', '1.', '1)'
  final int? startNumber;
}

class TableMeta {
  final List<String> alignment; // 'left', 'center', 'right'
  final bool hasHeader;
}

class EmphasisMeta {
  final String? style; // 'bold', 'italic', 'strikethrough', 'code'
}

class XmlMeta {
  final Map<String, String>? attributes;
  final bool isCdata;
  final String? comment;
  final String? namespace;
  final String? prefix;
}

class YamlMeta {
  final String? anchor;
  final String? alias;
  final String? comment;
  final String style; // 'block', 'flow'
  final String? scalarStyle; // 'literal', 'folded', 'single-quoted', 'double-quoted'
}

class JsonMeta {
  final int? indentSpaces;
  final bool? trailingComma;
}

class WhitespaceMeta {
  final int leadingNewlines;
  final int trailingNewlines;
  final String? rawLeading;
  final String? rawTrailing;
}
```

**Rationale**: Separate meta classes per concern enable format-specific features while sharing common concepts (headers, dividers). Nested `children` map enables full path support without requiring dot notation.

### Decision 2: Storage Structure

```dart
// Option: Nested structure (chosen)
{
  "_keyMeta": {
    "user": {
      "headerLevel": 2,
      "children": {
        "address": {
          "headerLevel": 3,
          "children": {
            "city": { "emphasis": { "style": "bold" } }
          }
        }
      }
    }
  },
  "user": { "address": { "city": "NYC" } }
}
```

**Rationale**: Nested structure mirrors the data structure, making it intuitive and allowing partial metadata (not every key needs metadata). Avoids dot-notation string parsing issues with keys containing dots.

### Decision 3: API Changes

```dart
// All converter functions gain preserveLayout parameter
String jsonToMarkdown(
  Map<String, dynamic> json, {
  Map<String, dynamic>? metaData,       // Document-level (unchanged)
  Map<String, dynamic>? keyMeta,        // Key-level (NEW)
  bool includeNulls = false,
  bool prettyPrint = true,
  bool preserveLayout = true,           // NEW - default enabled
});

// Parse functions return structured result with metadata
LayoutAwareParseResult markdownToJson(
  String markdown, {
  bool preserveLayout = true,
});

class LayoutAwareParseResult {
  final Map<String, dynamic> data;
  final Map<String, dynamic>? keyMeta;
}
```

**Alternatives considered**:
- Single return with `_keyMeta` inline: Simpler but mixes concerns in return value
- Separate metadata extraction function: More flexible but requires two calls

**Chosen**: Structured result class for parsing; separate `keyMeta` parameter for generation.

### Decision 4: Parsing Strategy

**Markdown Parsing:**
1. Parse document into AST (abstract syntax tree) using regex patterns
2. Identify structural elements: headers, callouts, dividers, code blocks, lists, tables
3. Build data map (key-value) and keyMeta map simultaneously
4. Track exact whitespace for 100% fidelity

**Key extraction from Markdown headers:**
```dart
// "## User Name" → key: "userName", headerLevel: 2
// "### Address" → key: "address", headerLevel: 3
String extractKeyFromHeader(String header) {
  final text = header.replaceFirst(RegExp(r'^#+\s*'), '');
  return convertToCamelCase(text);
}
```

**XML Parsing:**
- Detect attributes vs elements
- Capture CDATA sections
- Preserve comments with position
- Track namespace declarations

**YAML Parsing:**
- Detect anchors (`&name`) and aliases (`*name`)
- Preserve comments with line association
- Track flow vs block style per node
- Capture scalar presentation style

### Decision 5: Round-Trip Fidelity Implementation

To achieve 100% byte-for-byte fidelity:

1. **Whitespace preservation**: Store exact leading/trailing whitespace per section
2. **Original text caching**: For complex elements (callouts, code blocks), store original raw text
3. **Marker style preservation**: Remember if list used `-` vs `*` vs `+`
4. **Header style preservation**: Remember `#` count and spacing
5. **Line ending preservation**: Store `\n` vs `\r\n`

```dart
class WhitespaceMeta {
  final int leadingNewlines;
  final int trailingNewlines;
  final String? rawLeading;   // Exact original whitespace
  final String? rawTrailing;  // Exact original whitespace
  final String lineEnding;    // '\n' or '\r\n'
}
```

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Performance overhead from metadata tracking | `preserveLayout: false` opt-out for performance-sensitive code |
| Memory increase from storing raw whitespace | Lazy loading; only store when different from defaults |
| Complex Markdown parsing edge cases | Extensive test suite with real-world document samples |
| Breaking changes if `_keyMeta` key conflicts | `_keyMeta` is reserved; document clearly; rare collision |

## Migration Plan

1. **Phase 1 (This change)**: Add all models and update all converters with backward-compatible defaults
2. **No migration needed**: `preserveLayout: true` is default but existing code without metadata works unchanged
3. **Rollback**: Set `preserveLayout: false` globally to restore original behavior

## Open Questions

None - all ambiguities resolved during request clarification.
