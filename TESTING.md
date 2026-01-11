# Testing Configuration

## Purpose
This file configures testing workflow for the project.
Run `/plx:refine-testing` to populate project-specific test scope.

## Test Config
```yaml
test_types: [unit, integration]
coverage_threshold: 80%
runner: flutter_test
patterns: ["**/*_test.dart"]
```

## Test Scope

### Unit Tests
**Location:** `test/`
**Pattern:** `*_test.dart`
**Files:** 5 unit test files
- `test/turbo_serializable_test.dart` - Core TurboSerializable and TurboSerializableId functionality
- `test/format_converters_test.dart` - Format conversion utilities (JSON, YAML, Markdown, XML)
- `test/xml_converter_test.dart` - XML-specific conversion and case handling
- `test/import_test.dart` - Import and extension verification tests

**Naming Convention:** `*_test.dart` suffix
**Structure:** Tests use `package:test/test.dart` with `group()` and `test()` functions

### Integration Tests
**Location:** `test/integration/`
**File:** `test/integration/integration_test.dart`
**Purpose:** Format conversion integration tests that verify round-trip conversions between JSON, YAML, XML, and Markdown formats

**Test Structure:**
- Uses file-based testing with input/output directories
- Input files: `test/integration/input/{json,yaml,xml,markdown}/`
- Output files: `test/integration/output/` (generated during tests)
- Tests verify format conversions and edge cases (deep nesting, case styles, metadata, etc.)

**Coverage Areas:**
- JSON parsing (camelCase, snake_case, arrays, deep nesting, edge values)
- YAML parsing (basic, boolean variants, multiline, edge values)
- XML parsing (attributes, CDATA, mixed content, declarations, PascalCase)
- Markdown parsing (frontmatter, headers, rich content, edge cases)
- Cross-format conversions (all format pairs)

### E2E Tests
**Status:** Not currently implemented
**Note:** This is a library package focused on serialization, so E2E tests would be application-level and not appropriate for this package.

### Test Utilities
**Location:** Inline test classes within test files

**Test Models:**
- `TestModel` - Basic TurboSerializable implementation (in `turbo_serializable_test.dart`)
- `TestModelWithId` - TurboSerializableId implementation with validation
- `MinimalModel` - Minimal implementation for default behavior testing
- `DocumentModel` - Model with FrontmatterMeta for metadata testing
- `TestSerializable` - Simple test implementation (in `import_test.dart`)
- `TestSerializableId` - ID-based test implementation (in `import_test.dart`)

**Pattern:** Test classes are defined inline within test files rather than in separate utility files. This keeps tests self-contained and easy to understand.

### Test Data
**Location:** `test/integration/input/`

**Input Test Files:**
- **JSON:** `test/integration/input/json/` (5 files)
  - `basic.json` - Basic camelCase structure
  - `snake_case.json` - Snake case variant
  - `arrays.json` - Array handling
  - `deep_nesting.json` - 6-level nested structure
  - `edge_values.json` - Edge case values

- **YAML:** `test/integration/input/yaml/` (4 files)
  - `basic.yaml` - Basic YAML structure
  - `boolean_variants.yaml` - Boolean representation variants
  - `multiline.yaml` - Multiline string handling
  - `edge_values.yaml` - Edge case values

- **XML:** `test/integration/input/xml/` (6 files)
  - `basic.xml` - Basic XML structure
  - `attributes.xml` - XML attributes
  - `cdata.xml` - CDATA sections
  - `mixed_content.xml` - Mixed text and element content
  - `pascal_case.xml` - PascalCase element names
  - `with_declaration.xml` - XML declaration

- **Markdown:** `test/integration/input/markdown/` (5 files)
  - `edge_cases.md` - Edge case scenarios
  - `frontmatter_json.md` - JSON frontmatter
  - `frontmatter_text.md` - Text frontmatter
  - `headers_only.md` - Header-only document
  - `rich_content.md` - Rich markdown content

**Output Files:** `test/integration/output/` (generated during integration tests, 25+ files covering all conversion combinations)

### Mocking Patterns
**Approach:** Inline test implementations rather than external mocks

**Pattern:** Test classes extend `TurboSerializable` or `TurboSerializableId` with minimal implementations:
- Test classes define their own `TurboSerializableConfig` with conversion functions
- No external mocking libraries used
- Dependencies (like `turbo_response`) are real dependencies, not mocked

**Rationale:** Since this is a serialization library, test implementations provide concrete examples of how the library is used, making tests both verification and documentation.

### Coverage Reporting
**Tool:** Dart's built-in coverage (via `dart test --coverage`)
**Command:** `dart test --coverage=coverage/`
**Report Location:** `coverage/` directory (generated)
**Format:** LCOV format (compatible with most coverage tools)

**Note:** Coverage threshold is set to 80% in test config. Coverage is mentioned in `ARCHITECTURE.md` as a quality metric but not explicitly enforced in CI yet.

### CI Integration
**Status:** CI configuration not found in this package directory
**Note:** CI may be configured at the monorepo level (`flutter-turbo-packages/`)

**Expected Test Commands:**
- Unit tests: `dart test test/`
- Integration tests: `dart test test/integration/integration_test.dart`
- All tests: `dart test`
- With coverage: `dart test --coverage=coverage/`

**Parallelization:** Dart test runner supports parallel execution by default. Tests can run concurrently unless explicitly marked with `@TestOn('vm')` or other constraints.

## Test Checklist
- [ ] All tests pass locally
- [ ] Coverage meets threshold
- [ ] No skipped tests in CI
- [ ] New code has corresponding tests
- [ ] Mocks are up to date
- [ ] E2E tests verified
