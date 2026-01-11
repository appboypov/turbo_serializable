# Change: Add Key-Level Layout Metadata Support

## Why

Currently, `turbo_serializable` performs straightforward key-to-key conversions between formats (JSON, YAML, XML, Markdown). Layout and formatting information is lost during conversion - a Markdown document with callouts, dividers, and specific header levels cannot be converted to JSON and back without losing its visual structure. This prevents use cases where documents need to be stored/processed as data while preserving their original presentation.

## What Changes

- **ADDED**: `_keyMeta` object to store per-key layout metadata separate from data
- **ADDED**: `KeyMetadata` model class with format-specific layout properties
- **ADDED**: `preserveLayout` parameter (default: `true`) to all conversion functions
- **ADDED**: Markdown layout parsing (callouts, dividers, code blocks, tables, lists, headers, emphasis)
- **ADDED**: XML layout parsing (attributes vs elements, CDATA, comments, namespaces)
- **ADDED**: YAML layout parsing (anchors/aliases, comments, flow vs block style)
- **ADDED**: JSON layout parsing (indentation/spacing preservation)
- **ADDED**: Full path support for nested key metadata (dot notation or nested structure)
- **ADDED**: Layout-aware generation for all formats (bidirectional fidelity)
- **MODIFIED**: All 12 converter functions to support `preserveLayout` parameter
- **MODIFIED**: `TurboSerializable` class to support key metadata in serialization

## Impact

- **Affected specs**: `turbo-serializable`
- **Affected code**:
  - `lib/converters/format_converters.dart` - all converter functions
  - `lib/converters/xml_converter.dart` - XML-specific converters
  - `lib/abstracts/turbo_serializable.dart` - base class
  - `lib/models/` - new `KeyMetadata` and related models
  - `lib/constants/turbo_constants.dart` - new constants for `_keyMeta`
  - `test/` - extensive new test coverage for round-trip fidelity
