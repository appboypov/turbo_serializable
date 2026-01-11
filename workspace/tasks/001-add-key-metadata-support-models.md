---
status: done
skill-level: medior
parent-type: change
parent-id: add-key-metadata-support
---

# Task: Implement KeyMetadata Models

## End Goal

Create all model classes for key-level layout metadata that will support 100% round-trip fidelity across all formats.

## Currently

The `turbo_serializable` package has no per-key metadata support. Only document-level `metaData` exists.

## Should

The package has a complete set of model classes in `lib/models/` that can represent all layout information for Markdown, XML, YAML, and JSON formats.

## Constraints

- [ ] All model classes must be immutable (final fields)
- [ ] All properties must be optional (nullable) since not every key needs every metadata type
- [ ] Must support JSON serialization (toJson/fromJson) for storage
- [ ] Must follow existing code style and naming conventions
- [ ] Must include dartdoc comments for all public APIs

## Acceptance Criteria

- [ ] `KeyMetadata` class exists with all common properties
- [ ] `DividerMeta` class exists with `before`, `after`, `style` properties
- [ ] `CalloutMeta` class exists with `type`, `content`, `position` properties
- [ ] `CodeBlockMeta` class exists with `language`, `filename`, `isInline` properties
- [ ] `ListMeta` class exists with `type`, `marker`, `startNumber` properties
- [ ] `TableMeta` class exists with `alignment`, `hasHeader` properties
- [ ] `EmphasisMeta` class exists with `style` property
- [ ] `XmlMeta` class exists with `attributes`, `isCdata`, `comment`, `namespace`, `prefix` properties
- [ ] `YamlMeta` class exists with `anchor`, `alias`, `comment`, `style`, `scalarStyle` properties
- [ ] `JsonMeta` class exists with `indentSpaces`, `trailingComma` properties
- [ ] `WhitespaceMeta` class exists with `leadingNewlines`, `trailingNewlines`, `rawLeading`, `rawTrailing`, `lineEnding` properties
- [ ] `LayoutAwareParseResult` class exists with `data` and `keyMeta` properties
- [ ] All models have `toJson()` and `fromJson()` methods
- [ ] All models have `copyWith()` methods
- [ ] Unit tests pass for all model serialization/deserialization

## Implementation Checklist

- [x] 1.1 Create `lib/models/key_metadata.dart` with `KeyMetadata` class
- [x] 1.2 Create `lib/models/divider_meta.dart` with `DividerMeta` class
- [x] 1.3 Create `lib/models/callout_meta.dart` with `CalloutMeta` class
- [x] 1.4 Create `lib/models/code_block_meta.dart` with `CodeBlockMeta` class
- [x] 1.5 Create `lib/models/list_meta.dart` with `ListMeta` class
- [x] 1.6 Create `lib/models/table_meta.dart` with `TableMeta` class
- [x] 1.7 Create `lib/models/emphasis_meta.dart` with `EmphasisMeta` class
- [x] 1.8 Create `lib/models/xml_meta.dart` with `XmlMeta` class
- [x] 1.9 Create `lib/models/yaml_meta.dart` with `YamlMeta` class
- [x] 1.10 Create `lib/models/json_meta.dart` with `JsonMeta` class
- [x] 1.11 Create `lib/models/whitespace_meta.dart` with `WhitespaceMeta` class
- [x] 1.12 Create `lib/models/layout_aware_parse_result.dart` with `LayoutAwareParseResult` class
- [x] 1.13 Export all models from `lib/turbo_serializable.dart`
- [x] 1.14 Add `keyMetaKey` constant to `TurboConstants`
- [x] 1.15 Write unit tests for all model classes in `test/models/`

## Notes

- Use the `KeyMetadata.children` property for nested key metadata support
- Consider using `@JsonKey` annotations if using json_serializable, or manual toJson/fromJson
- The `lineEnding` property should default to `'\n'`
