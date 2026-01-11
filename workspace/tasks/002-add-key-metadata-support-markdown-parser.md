---
status: done
skill-level: senior
parent-type: change
parent-id: add-key-metadata-support
---

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

- [x] 2.1 Create `lib/parsers/markdown_parser.dart` with `MarkdownLayoutParser` class
- [x] 2.2 Implement header parsing with level extraction
- [x] 2.3 Implement callout parsing with GitHub/Obsidian syntax support
- [x] 2.4 Implement divider parsing with style detection
- [x] 2.5 Implement fenced code block parsing with language detection
- [x] 2.6 Implement unordered list parsing with marker style detection
- [x] 2.7 Implement ordered list parsing with numbering style detection
- [x] 2.8 Implement task list parsing with checked state detection
- [x] 2.9 Implement table parsing with alignment detection
- [x] 2.10 Implement emphasis parsing (bold, italic, strikethrough, inline code)
- [x] 2.11 Implement whitespace preservation (newlines, raw whitespace)
- [x] 2.12 Implement line ending detection (`\n` vs `\r\n`)
- [x] 2.13 Update `markdownToJson()` to use new parser when `preserveLayout: true`
- [x] 2.14 Maintain backward compatibility when `preserveLayout: false`
- [x] 2.15 Write comprehensive unit tests in `test/parsers/markdown_parser_test.dart`
- [x] 2.16 Write integration tests for round-trip fidelity

## Notes

- Consider using regex for simple patterns and stateful parsing for nested structures
- Header text should be converted to camelCase for the key name
- Position tracking is crucial for associating metadata with the correct key
- Test with real-world Markdown documents from various sources
