---
status: to-do
skill-level: senior
parent-type: change
parent-id: add-key-metadata-support
---

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
