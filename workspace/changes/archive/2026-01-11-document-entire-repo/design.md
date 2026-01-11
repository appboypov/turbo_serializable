## Context

This document captures the architectural decisions and design patterns implemented in the `turbo_serializable` library. The library provides a serialization abstraction for the turbo ecosystem with multi-format support (JSON, YAML, Markdown, XML).

## Goals / Non-Goals

### Goals
- Provide a unified serialization interface for multiple formats
- Enable automatic format conversion from a single primary format implementation
- Support typed metadata and identifiers for type safety
- Offer standalone converter functions for direct use
- Maintain consistency across format conversions
- Support format-specific features (frontmatter, XML attributes, etc.)

### Non-Goals
- Binary serialization formats (protobuf, msgpack, etc.)
- Schema validation or generation
- Deserialization from formats (only serialization)
- Streaming serialization
- Custom format support beyond JSON, YAML, Markdown, XML

## Decisions

### Decision: Primary Format Pattern
**What**: Implement serialization for one format, automatically convert to others.

**Why**: Reduces implementation burden - developers only need to implement one format callback and get automatic conversion to all other formats. This follows the DRY principle and reduces maintenance overhead.

**Alternatives considered**:
- Require implementation of all formats: Too much boilerplate
- Default to JSON only: Too limiting for use cases preferring YAML/Markdown/XML
- Format-agnostic intermediate representation: Adds complexity without clear benefit

### Decision: Callback-Based Configuration
**What**: Use callbacks in `TurboSerializableConfig` rather than abstract methods.

**Why**: Provides flexibility - callbacks can be closures, function references, or methods. Separates configuration from class definition, making testing easier and allowing dynamic configuration.

**Alternatives considered**:
- Abstract methods: Less flexible, harder to test
- Builder pattern: More verbose, adds complexity
- Annotations: Less flexible, requires code generation

### Decision: Priority-Based Primary Format Selection
**What**: Determine primary format by priority: json > yaml > markdown > xml.

**Why**: JSON is the most common format in web APIs and Dart serialization, so it gets highest priority. Priority order reflects common usage patterns.

**Alternatives considered**:
- Explicit primary format parameter: More verbose, requires user decision
- First callback provided: Unpredictable, depends on order
- Format-specific class hierarchy: Too rigid, prevents format switching

### Decision: Format-Specific Callback Precedence
**What**: If a format-specific callback is provided, use it directly instead of converting from primary format.

**Why**: Allows optimization - if a class has native YAML implementation, use it directly rather than converting from JSON. Provides escape hatch for performance-critical paths.

**Alternatives considered**:
- Always convert from primary: Less flexible, may be slower
- No format-specific callbacks: Too restrictive, prevents optimization

### Decision: Generic Metadata Type Parameter
**What**: Use generic type parameter `M` for metadata with `HasToJson` constraint.

**Why**: Provides type safety while allowing flexible metadata types. `HasToJson` constraint ensures metadata can be serialized when needed.

**Alternatives considered**:
- Untyped metadata (`dynamic`): Loses type safety
- Fixed metadata type: Too restrictive
- No metadata support: Too limiting for frontmatter use cases

### Decision: Standalone Converter Functions
**What**: Provide 12 format conversion functions that can be used without class inheritance.

**Why**: Enables use cases where class inheritance is not desired or possible. Allows direct format-to-format conversion without creating class instances.

**Alternatives considered**:
- Class-based only: Too restrictive
- Extension methods: Less discoverable, harder to import
- Separate package: Unnecessary fragmentation

### Decision: Null Filtering by Default
**What**: Exclude null values from serialization by default, with `includeNulls` option.

**Why**: Most serialization use cases don't need null values, and excluding them reduces output size. Optional inclusion provides flexibility when needed.

**Alternatives considered**:
- Always include nulls: Larger output, less common use case
- No null handling: Inconsistent behavior across formats
- Format-specific defaults: Confusing, harder to reason about

### Decision: Format-Specific Metadata Integration
**What**: Integrate metadata differently per format: `_meta` key for JSON/YAML, frontmatter for Markdown, `_meta` element for XML.

**Why**: Follows format conventions - Markdown uses frontmatter, XML uses elements, JSON/YAML use keys. This makes output more idiomatic for each format.

**Alternatives considered**:
- Uniform metadata location: Less idiomatic, violates format conventions
- No metadata support: Too limiting
- Metadata-only formats: Doesn't solve the use case

## Risks / Trade-offs

### Risk: Conversion Accuracy
**Mitigation**: Comprehensive integration tests verify round-trip conversions and edge cases. Format-specific features are preserved where possible.

### Risk: Performance Overhead
**Mitigation**: Format-specific callbacks allow bypassing conversion when performance is critical. Conversion functions are optimized for common cases.

### Risk: Format Feature Loss
**Mitigation**: Document format-specific features and limitations. Provide format-specific callbacks for cases where automatic conversion loses information.

### Trade-off: Type Safety vs Flexibility
**Decision**: Use generics for type safety while allowing `void` for no metadata. Provides safety where needed, flexibility where not.

### Trade-off: Simplicity vs Completeness
**Decision**: Focus on common use cases (4 formats) rather than supporting every possible format. Keeps API surface manageable.

## Migration Plan

N/A - This is a retrospective documentation change. No migration needed.

## Open Questions

None - all architectural decisions have been made and implemented.
