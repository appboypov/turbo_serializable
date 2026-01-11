# Release Preparation

## Purpose
This file configures release preparation and pre-release consistency verification.
Run `/plx:refine-release` to populate project-specific checklists.
Run `/plx:prepare-release` to execute release preparation.

## Documentation Config
```yaml
changelog_format: keep-a-changelog
readme_style: standard
audience: technical
emoji_level: none
```

## Consistency Checklist

### Primary Sources
<!-- Files that must change first when modifying core behavior -->
- `pubspec.yaml` - Package metadata, version, dependencies
- `lib/turbo_serializable.dart` - Main library export file
- `lib/abstracts/turbo_serializable.dart` - Core `TurboSerializable<M>` abstract class
- `lib/abstracts/turbo_serializable_id.dart` - `TurboSerializableId<T, M>` class
- `lib/abstracts/has_to_json.dart` - `HasToJson` interface
- `lib/models/turbo_serializable_config.dart` - Configuration class for serialization callbacks
- `lib/enums/serialization_format.dart` - Format enum definitions
- `lib/constants/turbo_constants.dart` - Error messages and constants

### Derived Artifacts
<!-- Files generated from primary sources; include regeneration command -->
- None (no code generation in this package)
Regeneration command: ``

### Shared Values
<!-- Values duplicated across files: versions, names, identifiers, URLs -->
- Version: `pubspec.yaml` (line 3) - must match CHANGELOG.md entries
- Package name: `turbo_serializable` appears in:
  - `pubspec.yaml` (name field)
  - `lib/turbo_serializable.dart` (library declaration)
  - `README.md` (package references)
  - Import statements throughout codebase
- Repository URL: `https://github.com/appboypov/turbo_serializable` in:
  - `pubspec.yaml` (repository, homepage, issue_tracker)
  - `README.md` (badges)

### Behavioral Contracts
<!-- Schemas, types, interfaces, API contracts that define expected behavior -->
- `TurboSerializable<M>` - Base abstract class with serialization methods
- `TurboSerializableId<T, M>` - Extends TurboSerializable with typed ID
- `HasToJson` - Interface for metadata types that can serialize to JSON
- `TurboSerializableConfig` - Configuration class with callback signatures
- `SerializationFormat` enum - Defines supported formats (json, yaml, markdown, xml)
- `CaseStyle` enum - Defines case transformation options
- Standalone converter functions in `lib/converters/format_converters.dart`

### Assertion Updates
<!-- Tests that assert on specific outputs, messages, or formats -->
- `test/turbo_serializable_test.dart` - Unit tests with expect() assertions on:
  - Serialization output formats (JSON maps, YAML strings, Markdown strings, XML strings)
  - Metadata handling and validation
  - Format conversion results
- `test/format_converters_test.dart` - Converter function tests with format-specific assertions
- `test/xml_converter_test.dart` - XML-specific conversion tests
- `test/integration/integration_test.dart` - Integration tests with file-based assertions
- `example/main.dart` - Example script with assert() statements validating behavior

### Documentation References
<!-- Docs containing code examples or implementation references -->
- `README.md` - Contains code examples showing API usage, method signatures, and examples
- `ARCHITECTURE.md` - Architecture documentation
- `example/main.dart` - Working example demonstrating all features
- `CHANGELOG.md` - Version history with change descriptions

### External Integrations
<!-- IDE configs, CI/CD, linter rules, third-party service configs -->
- `analysis_options.yaml` - Linter configuration (uses package:lints/recommended.yaml)
- No CI/CD configuration found in repository
- pub.dev package page configuration (via pubspec.yaml metadata)

### Platform Variations
<!-- Target-specific files that must stay synchronized -->
- None (pure Dart package, no platform-specific code)

### Cleanup
<!-- Files to delete when renaming/removing features -->
- When removing serialization formats: update `SerializationFormat` enum, remove converter functions, update tests
- When removing metadata support: update `TurboSerializable<M>` generic parameter, remove `HasToJson` interface

### Verification
<!-- Commands to confirm zero drift -->
```bash
# Search for version number
grep -rn "version:" pubspec.yaml

# Search for package name
grep -rn "turbo_serializable" lib/

# Run tests
dart test

# Run static analysis
dart analyze

# Validate package for pub.dev
dart pub publish --dry-run

# Check pub.dev points
dart pub global activate pana
cp -r . /tmp/turbo_serializable_test
dart pub global run pana /tmp/turbo_serializable_test
```

## Release Checklist
- [ ] Consistency checklist reviewed and complete
- [ ] Changelog updated with new version
- [ ] Version bumped in project config
- [ ] All changes reviewed and confirmed
