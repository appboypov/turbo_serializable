import 'package:turbo_serializable/abstracts/turbo_serializable.dart';
import 'package:turbo_serializable/enums/serialization_format.dart';

/// Configuration for [TurboSerializable] instances.
///
/// Specifies callbacks for serialization methods and automatically determines
/// the primary format based on which callbacks are provided.
class TurboSerializableConfig {

  /// Callback for JSON serialization.
  final Map<String, dynamic>? Function(TurboSerializable input)? toJson;

  /// Callback for YAML serialization.
  final String? Function(TurboSerializable input)? toYaml;

  /// Callback for Markdown serialization.
  final String? Function(TurboSerializable input)? toMarkdown;

  /// Callback for XML serialization.
  final String? Function(
      TurboSerializable, {
      String? rootElementName,
      bool includeNulls,
      bool prettyPrint,
      })? toXml;

  /// The primary serialization format, determined from the provided callbacks.
  ///
  /// Computed once during initialization based on which callbacks are non-null.
  /// Priority: json > yaml > markdown > xml
  final SerializationFormat primaryFormat;

  /// Creates a [TurboSerializableConfig] with optional callbacks.
  ///
  /// At least one callback must be provided. The [primaryFormat] is
  /// automatically determined based on which callbacks are non-null.
  TurboSerializableConfig({
    this.toJson,
    this.toYaml,
    this.toMarkdown,
    this.toXml,
  })  : assert(
  toJson != null ||
      toYaml != null ||
      toMarkdown != null ||
      toXml != null,
  'At least one callback must be provided',
  ),
        primaryFormat = _computePrimaryFormat(
          toJson,
          toYaml,
          toMarkdown,
          toXml,
        );

  /// Computes the primary format based on which callbacks are provided.
  ///
  /// Priority order: json > yaml > markdown > xml
  static SerializationFormat _computePrimaryFormat(
      Map<String, dynamic>? Function(TurboSerializable)? toJson,
      String? Function(TurboSerializable)? toYaml,
      String? Function(TurboSerializable)? toMarkdown,
      String? Function(
          TurboSerializable, {
          String? rootElementName,
          bool includeNulls,
          bool prettyPrint,
          })? toXml,
      ) {
    if (toJson != null) {
      return SerializationFormat.json;
    }
    if (toYaml != null) {
      return SerializationFormat.yaml;
    }
    if (toMarkdown != null) {
      return SerializationFormat.markdown;
    }
    if (toXml != null) {
      return SerializationFormat.xml;
    }
    // This should never be reached due to the assertion, but provide a default
    return SerializationFormat.json;
  }
}
