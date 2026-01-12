---
status: done
skill-level: senior
parent-type: change
parent-id: add-key-metadata-support
---

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

- [x] 7.1 Create `lib/generators/yaml_generator.dart` with `YamlLayoutGenerator` class
- [x] 7.2 Implement anchor generation
- [x] 7.3 Implement alias generation with anchor linking
- [x] 7.4 Implement comment generation with line association
- [x] 7.5 Implement flow vs block style generation
- [x] 7.6 Implement scalar style application (literal, folded, quoted)
- [x] 7.7 Implement multi-document generation
- [x] 7.8 Update `jsonToYaml()` to accept `keyMeta` parameter
- [x] 7.9 Update `jsonToYaml()` to use generator when `preserveLayout: true`
- [x] 7.10 Maintain backward compatibility for existing calls
- [x] 7.11 Write unit tests in `test/generators/yaml_generator_test.dart`
- [x] 7.12 Write byte-for-byte fidelity tests

## Notes

- YAML generation may require custom serialization rather than using a library
- Anchors must be defined before aliases that reference them
- Flow style affects child elements too: `{a: 1, b: 2}` vs block
- Test with the same YAML documents used in parser tests
