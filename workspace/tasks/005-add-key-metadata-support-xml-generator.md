---
status: done
skill-level: senior
parent-type: change
parent-id: add-key-metadata-support
---

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

- [x] 5.1 Create `lib/generators/xml_generator.dart` with `XmlLayoutGenerator` class
- [x] 5.2 Implement attribute generation from `XmlMeta`
- [x] 5.3 Implement CDATA section generation
- [x] 5.4 Implement comment generation with position support
- [x] 5.5 Implement namespace declaration generation
- [x] 5.6 Implement namespace prefix application
- [x] 5.7 Implement mixed content generation
- [x] 5.8 Implement element order preservation
- [x] 5.9 Update `jsonToXml()` to accept `keyMeta` parameter
- [x] 5.10 Update `jsonToXml()` to use generator when `preserveLayout: true`
- [x] 5.11 Maintain backward compatibility for existing calls
- [x] 5.12 Write unit tests in `test/generators/xml_generator_test.dart`
- [x] 5.13 Write byte-for-byte fidelity tests

## Notes

- Use the existing `xml` package's XmlBuilder for generation
- Attribute order should match the original (may require LinkedHashMap)
- Test with the same XML documents used in parser tests
