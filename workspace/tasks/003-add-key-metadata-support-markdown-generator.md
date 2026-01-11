---
status: done
skill-level: senior
parent-type: change
parent-id: add-key-metadata-support
---

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

- [x] 3.1 Create `lib/generators/markdown_generator.dart` with `MarkdownLayoutGenerator` class
- [x] 3.2 Implement header generation with level support
- [x] 3.3 Implement callout generation with position awareness
- [x] 3.4 Implement divider generation with style support
- [x] 3.5 Implement code block generation with language support
- [x] 3.6 Implement list generation with marker style support
- [x] 3.7 Implement task list generation with checked state
- [x] 3.8 Implement table generation with alignment support
- [x] 3.9 Implement emphasis generation with marker preservation
- [x] 3.10 Implement whitespace generation with exact preservation
- [x] 3.11 Implement line ending handling
- [x] 3.12 Implement nested key metadata traversal
- [x] 3.13 Update `jsonToMarkdown()` to accept `keyMeta` parameter
- [x] 3.14 Update `jsonToMarkdown()` to use generator when `preserveLayout: true`
- [x] 3.15 Maintain backward compatibility for existing calls
- [x] 3.16 Write unit tests in `test/generators/markdown_generator_test.dart`
- [x] 3.17 Write byte-for-byte fidelity tests

## Notes

- The generator should build output incrementally using StringBuffer
- Order of elements matters: dividers before headers, callouts at correct positions
- Test with the same documents used in parser tests to verify round-trip
