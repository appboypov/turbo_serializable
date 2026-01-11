---
status: to-do
skill-level: medior
parent-type: change
parent-id: add-key-metadata-support
---

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
