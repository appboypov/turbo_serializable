# Changelog

## 0.1.2 - 2026-01-11

### Added
- `TurboSerializableConfig` class for configuring serialization callbacks
- Export of `TurboSerializableConfig` from main library for easier imports

### Changed
- Refactored `TurboSerializable` to use `TurboSerializableConfig` for serialization method configuration
- Standardized callback names in `TurboSerializableConfig`:
  - `toJsonCallback` → `toJson`
  - `toYamlString` → `toYaml`
  - `toMarkdownString` → `toMarkdown`
- Primary format is now automatically determined from provided callbacks (priority: json > yaml > markdown > xml)
- Updated `toXml` method to include `includeMetaData` parameter

### Technical Details
- Introduced `HasToJson` interface for metadata types that can be serialized to JSON
- Removed deprecated `toJsonImpl` methods in favor of callback-based implementations
- Enhanced documentation to guide users on the new configuration setup
- Ensured backward compatibility with existing serialization methods where applicable

## 0.1.1 - 2026-01-11

### Changed
- Rewrote README with Library/Package format: badges, features list, API reference tables, focused examples
- Reduced README from 329 to 90 lines (73% reduction)

## 0.1.0 - 2026-01-11

### Added
- Standalone format converter functions: `jsonToYaml`, `jsonToMarkdown`, `jsonToXml`, `yamlToJson`, `yamlToMarkdown`, `yamlToXml`, `markdownToJson`, `markdownToYaml`, `markdownToXml`, `xmlToJson`, `xmlToYaml`, `xmlToMarkdown`
- `mapToXml` and `xmlToMap` functions for direct JSON/XML conversion
- Markdown-to-JSON parsing with YAML frontmatter support
- JSON-to-Markdown conversion with header-based format (keys become `##`, `###`, `####`, `**bold**` at level 5+)
- Title Case conversion for markdown headers
- PascalCase option for XML element names
- Metadata support for all format conversions
- Comprehensive integration test suite with 284 tests
- Edge case sample files covering: deep nesting, unicode/emoji, empty collections, YAML anchors/aliases, XML declarations, and format-specific features

### Changed
- Removed deprecated `from*` instance methods (use standalone converter functions instead)

### Fixed
- XML converter uses `XmlText.value` instead of deprecated `XmlData.text`

## 0.0.1

- Initial release
- `TurboSerializable<M>` abstract class with optional serialization methods and typed metadata support
- `TurboSerializableId<T, M>` with typed identifier and metadata support
- Optional `metaData` field for frontmatter and auxiliary data
- Supported formats: JSON, YAML, Markdown, XML
