---
status: to-do
skill-level: medior
parent-type: change
parent-id: add-key-metadata-support
---

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
