---
status: done
skill-level: senior
parent-type: change
parent-id: add-key-metadata-support
---

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

- [x] 6.1 Create `lib/parsers/yaml_parser.dart` with `YamlLayoutParser` class
- [x] 6.2 Implement anchor extraction
- [x] 6.3 Implement alias extraction
- [x] 6.4 Implement comment extraction with line association
- [x] 6.5 Implement flow vs block style detection
- [x] 6.6 Implement scalar style detection (literal, folded, quoted)
- [x] 6.7 Implement multi-document handling
- [x] 6.8 Update `yamlToJson()` to use new parser when `preserveLayout: true`
- [x] 6.9 Return `LayoutAwareParseResult` or add `_keyMeta` to result
- [x] 6.10 Maintain backward compatibility when `preserveLayout: false`
- [x] 6.11 Write unit tests in `test/parsers/yaml_parser_test.dart`
- [x] 6.12 Write integration tests for round-trip fidelity

## Notes

- The `yaml` package provides `YamlNode` types that may expose some style information
- Comments are typically lost in most YAML parsers; may need lower-level parsing
- Consider using `yaml` package's `YamlDocument` for multi-document support
- Test with complex YAML documents including all features
