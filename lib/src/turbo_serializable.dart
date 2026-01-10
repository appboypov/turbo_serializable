import 'package:turbo_response/turbo_response.dart';

import 'format_converters.dart';
import 'serialization_format.dart';
import 'xml_converter.dart';

/// Base abstract class for serializable objects in the turbo ecosystem.
///
/// Requires specification of a [primaryFormat] that indicates which
/// serialization method is actually implemented. All other formats are
/// automatically converted from the primary format.
///
/// The type parameter [M] represents optional metadata (e.g., frontmatter).
/// Defaults to [dynamic] when not specified.
abstract class TurboSerializable<M> {
  /// Creates a [TurboSerializable] instance with required [primaryFormat]
  /// and optional [metaData].
  ///
  /// [primaryFormat] specifies which serialization method is actually
  /// implemented (toJson, toYaml, toMarkdown, or toXml). All other formats
  /// will be automatically converted from the primary format.
  TurboSerializable({
    this.primaryFormat = SerializationFormat.json,
    this.metaData,
  });

  /// The primary serialization format for this object.
  ///
  /// This indicates which serialization method (toJson, toYaml, toMarkdown,
  /// or toXml) is actually implemented. All other formats are automatically
  /// converted from this primary format.
  final SerializationFormat primaryFormat;

  /// Optional metadata associated with this object.
  ///
  /// Useful for frontmatter, annotations, or other auxiliary data
  /// that should travel with the serializable object.
  final M? metaData;

  /// Validates the object's state.
  ///
  /// Returns null if valid, or a [TurboResponse.fail] if invalid.
  TurboResponse<T>? validate<T>() => null;

  /// Converts this object to a JSON map.
  ///
  /// If [primaryFormat] is [SerializationFormat.json], returns the
  /// overridden implementation. Otherwise, converts from the primary format.
  ///
  /// Returns null if the primary format method is not implemented.
  Map<String, dynamic>? toJson() {
    if (primaryFormat == SerializationFormat.json) {
      return toJsonImpl();
    }
    return _convertToJson();
  }

  /// Internal implementation of toJson for subclasses to override.
  ///
  /// Returns null by default. Subclasses should override this method
  /// when [primaryFormat] is [SerializationFormat.json].
  Map<String, dynamic>? toJsonImpl() => null;

  /// Converts this object to a YAML string.
  ///
  /// If [toYamlImpl()] is overridden and returns non-null, uses that implementation.
  /// Otherwise, if [primaryFormat] is [SerializationFormat.yaml], returns the
  /// overridden implementation. Otherwise, converts from the primary format.
  ///
  /// Returns null if the primary format method is not implemented.
  String? toYaml() {
    // Check if toYamlImpl() is overridden (returns non-null)
    final yamlImpl = toYamlImpl();
    if (yamlImpl != null) {
      return yamlImpl;
    }
    // If not overridden, convert from primary format
    if (primaryFormat == SerializationFormat.yaml) {
      return null; // Already checked above
    }
    return _convertToYaml();
  }

  /// Internal implementation of toYaml for subclasses to override.
  ///
  /// Returns null by default. Subclasses should override this method
  /// when [primaryFormat] is [SerializationFormat.yaml].
  String? toYamlImpl() => null;

  /// Converts this object to a Markdown string.
  ///
  /// If [toMarkdownImpl()] is overridden and returns non-null, uses that implementation.
  /// Otherwise, if [primaryFormat] is [SerializationFormat.markdown], returns the
  /// overridden implementation. Otherwise, converts from the primary format.
  ///
  /// Returns null if the primary format method is not implemented.
  String? toMarkdown() {
    // Check if toMarkdownImpl() is overridden (returns non-null)
    final markdownImpl = toMarkdownImpl();
    if (markdownImpl != null) {
      return markdownImpl;
    }
    // If not overridden, convert from primary format
    if (primaryFormat == SerializationFormat.markdown) {
      return null; // Already checked above
    }
    return _convertToMarkdown();
  }

  /// Internal implementation of toMarkdown for subclasses to override.
  ///
  /// Returns null by default. Subclasses should override this method
  /// when [primaryFormat] is [SerializationFormat.markdown].
  String? toMarkdownImpl() => null;

  /// Converts this object to an XML string.
  ///
  /// If [toXmlImpl()] is overridden and returns non-null, uses that implementation.
  /// Otherwise, if [primaryFormat] is [SerializationFormat.xml], returns the
  /// overridden implementation. Otherwise, converts from the primary format.
  ///
  /// The root element name defaults to the class name (runtimeType).
  /// Override [toXmlImpl] for custom XML serialization behavior.
  ///
  /// Returns null if the primary format method is not implemented.
  String? toXml({
    String? rootElementName,
    bool includeNulls = false,
    bool prettyPrint = true,
  }) {
    // Check if toXmlImpl() is overridden (returns non-null)
    final xmlImpl = toXmlImpl(
      rootElementName: rootElementName,
      includeNulls: includeNulls,
      prettyPrint: prettyPrint,
    );
    if (xmlImpl != null) {
      return xmlImpl;
    }
    // If not overridden, convert from primary format
    if (primaryFormat == SerializationFormat.xml) {
      return null; // Already checked above
    }
    return _convertToXml(
      rootElementName: rootElementName,
      includeNulls: includeNulls,
      prettyPrint: prettyPrint,
    );
  }

  /// Internal implementation of toXml for subclasses to override.
  ///
  /// Returns null by default. Subclasses should override this method
  /// when [primaryFormat] is [SerializationFormat.xml].
  String? toXmlImpl({
    String? rootElementName,
    bool includeNulls = false,
    bool prettyPrint = true,
  }) {
    // Default implementation uses JSON conversion for backward compatibility
    final json = toJsonImpl();
    if (json == null) {
      return null;
    }

    final elementName = rootElementName ?? runtimeType.toString().replaceAll(RegExp(r'<.*>'), '');
    return mapToXml(
      json,
      rootElementName: elementName,
      includeNulls: includeNulls,
      prettyPrint: prettyPrint,
    );
  }

  // Private conversion helper methods

  /// Converts from primary format to JSON.
  Map<String, dynamic>? _convertToJson() {
    switch (primaryFormat) {
      case SerializationFormat.json:
        return toJsonImpl();
      case SerializationFormat.yaml:
        final yaml = toYamlImpl();
        if (yaml == null) return null;
        try {
          return yamlToJson(yaml);
        } catch (e) {
          return null;
        }
      case SerializationFormat.markdown:
        final markdown = toMarkdownImpl();
        if (markdown == null) return null;
        try {
          return markdownToJson(markdown);
        } catch (e) {
          return null;
        }
      case SerializationFormat.xml:
        final xml = toXmlImpl();
        if (xml == null) return null;
        try {
          return xmlToJson(xml);
        } catch (e) {
          return null;
        }
    }
  }

  /// Converts from primary format to YAML.
  String? _convertToYaml() {
    switch (primaryFormat) {
      case SerializationFormat.json:
        final json = toJsonImpl();
        if (json == null) return null;
        return jsonToYaml(json);
      case SerializationFormat.yaml:
        return toYamlImpl();
      case SerializationFormat.markdown:
        final markdown = toMarkdownImpl();
        if (markdown == null) return null;
        return markdownToYaml(markdown);
      case SerializationFormat.xml:
        final xml = toXmlImpl();
        if (xml == null) return null;
        return xmlToYaml(xml);
    }
  }

  /// Converts from primary format to Markdown.
  String? _convertToMarkdown() {
    switch (primaryFormat) {
      case SerializationFormat.json:
        final json = toJsonImpl();
        if (json == null) return null;
        return jsonToMarkdown(json);
      case SerializationFormat.yaml:
        final yaml = toYamlImpl();
        if (yaml == null) return null;
        return yamlToMarkdown(yaml);
      case SerializationFormat.markdown:
        return toMarkdownImpl();
      case SerializationFormat.xml:
        final xml = toXmlImpl();
        if (xml == null) return null;
        return xmlToMarkdown(xml);
    }
  }

  /// Converts from primary format to XML.
  String? _convertToXml({
    String? rootElementName,
    bool includeNulls = false,
    bool prettyPrint = true,
  }) {
    switch (primaryFormat) {
      case SerializationFormat.json:
        final json = toJsonImpl();
        if (json == null) return null;
        final elementName =
            rootElementName ?? runtimeType.toString().replaceAll(RegExp(r'<.*>'), '');
        return mapToXml(
          json,
          rootElementName: elementName,
          includeNulls: includeNulls,
          prettyPrint: prettyPrint,
        );
      case SerializationFormat.yaml:
        final yaml = toYamlImpl();
        if (yaml == null) return null;
        final elementName =
            rootElementName ?? runtimeType.toString().replaceAll(RegExp(r'<.*>'), '');
        return yamlToXml(
          yaml,
          rootElementName: elementName,
          includeNulls: includeNulls,
          prettyPrint: prettyPrint,
        );
      case SerializationFormat.markdown:
        final markdown = toMarkdownImpl();
        if (markdown == null) return null;
        final elementName =
            rootElementName ?? runtimeType.toString().replaceAll(RegExp(r'<.*>'), '');
        return markdownToXml(
          markdown,
          rootElementName: elementName,
          includeNulls: includeNulls,
          prettyPrint: prettyPrint,
        );
      case SerializationFormat.xml:
        return toXmlImpl(
          rootElementName: rootElementName,
          includeNulls: includeNulls,
          prettyPrint: prettyPrint,
        );
    }
  }
}
