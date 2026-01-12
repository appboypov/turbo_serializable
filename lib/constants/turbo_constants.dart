/// Constants used throughout the turbo_serializable package.
///
/// Provides centralized access to string literals, numeric values, and
/// error messages used for serialization and format conversion.
abstract class TurboConstants {
  TurboConstants._();

  // ============================================================================
  // Metadata Keys
  // ============================================================================

  /// Key used for metadata in JSON/YAML serialization.
  static const String metaKey = '_meta';

  /// PascalCase version of metadata key for XML serialization.
  static const String metaKeyPascal = '_Meta';

  /// Key used for key-level metadata in JSON/YAML serialization.
  static const String keyMetaKey = '_keyMeta';

  /// Key used for mixed text content in XML parsing.
  static const String textKey = '_text';

  /// Key used for body content in Markdown parsing.
  static const String bodyKey = 'body';

  // ============================================================================
  // XML Constants
  // ============================================================================

  /// Default root element name for XML serialization.
  static const String defaultRootElement = 'root';

  /// Default item element name for XML list serialization (lowercase).
  static const String defaultItemElement = 'item';

  /// Default item element name for XML list serialization (PascalCase).
  static const String defaultItemElementPascal = 'Item';

  /// XML processing instruction name.
  static const String xmlProcessingInstruction = 'xml';

  /// XML declaration string with version and encoding.
  static const String xmlDeclaration = 'version="1.0" encoding="UTF-8"';

  // ============================================================================
  // Markdown Constants
  // ============================================================================

  /// YAML frontmatter delimiter used in Markdown files.
  static const String frontmatterDelimiter = '---';

  /// Markdown header level 2 (##).
  static const int markdownHeaderLevel2 = 2;

  /// Markdown header level 3 (###).
  static const int markdownHeaderLevel3 = 3;

  /// Markdown header level 4 (####).
  static const int markdownHeaderLevel4 = 4;

  /// Markdown header level threshold for bold formatting (5+).
  static const int markdownHeaderLevelBold = 5;

  // ============================================================================
  // Formatting Constants
  // ============================================================================

  /// Two-space indentation string used for formatting.
  static const String indentSpaces = '  ';

  // ============================================================================
  // Error Messages
  // ============================================================================

  /// Error message for YAML parsing failures.
  static String failedToParseYaml(Object error) =>
      'Failed to parse YAML: $error';

  /// Error message for XML parsing failures.
  static String failedToParseXml(Object error) => 'Failed to parse XML: $error';

  /// Error message when no callbacks are provided to TurboSerializableConfig.
  static const String atLeastOneCallbackRequired =
      'At least one callback must be provided';
}
