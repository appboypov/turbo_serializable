# Request: Add Key Metadata Support

## Source Input

> for turbo_serializable: conversion of things currently happen pretty straightforward: key -> key. create a plan to introduce the concept of meta data for keys as well. end goal is to be able to save full layouts of markdown converted to yaml, xml and json and vice versa - where the meta object holds info on how to structure a header and/or section e.g. with callout beneath the header, dividers, etc etc etc. etc.

## Current Understanding

The user wants to extend `turbo_serializable` to support **key-level metadata** that preserves formatting/layout information during format conversions.

**Current State:**
- Conversions are straightforward: `key` in JSON → `key` in YAML/XML/Markdown
- Layout information is lost during conversion (e.g., if a Markdown section has a callout, divider, or specific formatting, this is not preserved when converting to JSON and back)
- Existing `metaData` is **document-level** (frontmatter/`_meta` key), not per-key

**Proposed Enhancement:**
- Add **per-key metadata** that describes how each key/section should be rendered
- This metadata would include formatting hints like:
  - Callouts (info, warning, tip boxes)
  - Dividers (horizontal rules before/after)
  - Header styling (level, emphasis)
  - Section styling (collapsed, expanded)
  - Other formatting attributes

**Use Case Example:**
```markdown
# Title

> [!NOTE]
> This is an important note about the section below

## Description
Content here

---

## Features
- Item 1
- Item 2
```

When converted to JSON with key metadata, it might look like:
```json
{
  "title": "Title",
  "_keyMeta": {
    "description": {
      "callout": { "type": "note", "text": "This is an important note..." }
    },
    "features": {
      "divider": { "before": true }
    }
  },
  "description": "Content here",
  "features": ["Item 1", "Item 2"]
}
```

## Identified Ambiguities

1. **Scope of metadata**: What specific formatting hints should be supported initially? (callouts, dividers, headers, etc.)
2. **Storage format**: How should key metadata be structured? (inline with key, separate `_keyMeta` object, or something else?)
3. **Bidirectional fidelity**: Should round-trip conversion preserve 100% of formatting, or is "best effort" acceptable?
4. **Priority**: Which format conversions are most important? (Markdown ↔ JSON seems primary)
5. **Existing metadata relationship**: Should this integrate with or replace the existing `metaData` system?
6. **Parser complexity**: Should the library parse Markdown callout syntax (e.g., `> [!NOTE]`) or require structured input?

## Decisions

1. **Storage format**: Use separate `_keyMeta` object to keep data and formatting cleanly separated. Data stays as-is, metadata lives in a dedicated object.

2. **Direction**: Bidirectional - full round-trip capability. Parse Markdown to data with metadata, regenerate identical (or near-identical) Markdown from that data.

3. **Scope**: Rich - full structural elements including:
   - Dividers (horizontal rules)
   - Header levels (##, ###, etc.)
   - Callouts (NOTE, WARNING, TIP - GitHub/Obsidian style)
   - Text emphasis hints
   - Fenced code blocks (with language)
   - List types (ordered, unordered, task lists)
   - Table formatting

4. **Integration**: Keep document-level `metaData` (frontmatter) and key-level metadata (`_keyMeta`) as separate concepts. They serve different purposes.

5. **Fidelity**: Exact reproduction (100%) - output Markdown must be byte-for-byte identical to input when doing round-trip conversion. This requires capturing all whitespace, formatting details, and structural information.

6. **Format scope**: All formats equal - each format (Markdown, XML, YAML, JSON) has its own layout metadata schema with full preservation:
   - **Markdown**: callouts, dividers, headers, code blocks, tables, lists, emphasis
   - **XML**: attributes vs elements, CDATA sections, comments, namespaces
   - **YAML**: anchors/aliases, comments, multi-document support, flow vs block style
   - **JSON**: formatting (indentation, spacing) - typically the canonical "data" format

7. **Nesting**: Full path support - metadata can target any nested key using either dot notation (`user.address.city`) or nested structure in the `_keyMeta` object.

8. **Default behavior**: Opt-in parameter but default to `true`. A parameter like `preserveLayout: true` will be added, defaulting to enabled. Users can disable with `preserveLayout: false` for simpler output. This means the new behavior is on by default but backward-compatible code can opt out.

9. **Phasing**: All at once - implement full support for all formats (Markdown, XML, YAML, JSON) in a single change. The task breakdown will organize this appropriately.

10. **Key name**: Fixed `_keyMeta` - simple, consistent, follows existing `_meta` pattern for document-level metadata.

## Final Intent

Add **per-key layout metadata** (`_keyMeta`) to `turbo_serializable` enabling **100% round-trip fidelity** for all supported formats (Markdown, XML, YAML, JSON).

### Core Features

1. **Key-level metadata storage**: A separate `_keyMeta` object that stores formatting/layout information per key, using full path support for nested keys (e.g., `user.address.city` or nested structure).

2. **100% fidelity round-trip**: Converting `Format A → JSON → Format A` produces byte-for-byte identical output to the original input.

3. **Rich structural element support**:
   - **Markdown**: callouts (NOTE, WARNING, TIP), dividers (horizontal rules), header levels, code blocks (with language), tables, lists (ordered, unordered, task), emphasis
   - **XML**: attributes vs elements, CDATA sections, comments, namespaces
   - **YAML**: anchors/aliases, comments, multi-document support, flow vs block style
   - **JSON**: indentation/spacing preservation

4. **Default enabled, opt-out available**: Parameter `preserveLayout: true` (default) captures and uses layout metadata; `preserveLayout: false` for simpler output without layout preservation.

5. **Separate from document metadata**: Existing `metaData` (frontmatter/`_meta`) remains unchanged and serves document-level purposes; `_keyMeta` is exclusively for key-level layout information.

### Example

**Input Markdown:**
```markdown
---
title: My Document
---

# Introduction

> [!NOTE]
> Important information here

## Features

- Item 1
- Item 2

---

## Code Example

\`\`\`dart
void main() {}
\`\`\`
```

**Output JSON with `_keyMeta`:**
```json
{
  "_meta": { "title": "My Document" },
  "_keyMeta": {
    "introduction": {
      "headerLevel": 1,
      "callout": { "type": "note", "content": "Important information here", "position": "after" }
    },
    "features": {
      "headerLevel": 2,
      "listType": "unordered"
    },
    "codeExample": {
      "headerLevel": 2,
      "divider": { "before": true },
      "codeBlock": { "language": "dart" }
    }
  },
  "introduction": "...",
  "features": ["Item 1", "Item 2"],
  "codeExample": "void main() {}"
}
```

Converting this JSON back to Markdown produces the exact original input.
