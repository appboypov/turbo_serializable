import 'package:meta/meta.dart';
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

  /// Converts metadata to a JSON map.
  ///
  /// The metadata object must have a `toJson()` method that returns
  /// `Map<String, dynamic>`. Returns null if metadata is null or
  /// doesn't have a toJson method.
  @visibleForTesting
  Map<String, dynamic>? metaDataToJson() {
    final meta = metaData;
    if (meta == null) return null;

    // Try to call toJson() on the metadata object
    try {
      // ignore: avoid_dynamic_calls
      final result = (meta as dynamic).toJson();
      if (result is Map<String, dynamic>) {
        return result;
      }
    } catch (_) {
      // Metadata doesn't have toJson() method
    }
    return null;
  }

  /// Converts this object to a JSON map.
  ///
  /// If [primaryFormat] is [SerializationFormat.json], returns the
  /// overridden implementation. Otherwise, converts from the primary format.
  ///
  /// [includeMetaData] - Whether to include metadata under `_meta` key
  ///
  /// Returns null if the primary format method is not implemented.
  Map<String, dynamic>? toJson({bool includeMetaData = false}) {
    Map<String, dynamic>? result;
    if (primaryFormat == SerializationFormat.json) {
      result = toJsonImpl();
    } else {
      result = convertToJson();
    }

    if (result != null && includeMetaData) {
      final meta = metaDataToJson();
      if (meta != null) {
        return {'_meta': meta, ...result};
      }
    }
    return result;
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
  /// [includeMetaData] - Whether to include metadata under `_meta` key
  ///
  /// Returns null if the primary format method is not implemented.
  String? toYaml({bool includeMetaData = false}) {
    // Check if toYamlImpl() is overridden (returns non-null)
    final yamlImpl = toYamlImpl();
    if (yamlImpl != null) {
      return yamlImpl;
    }
    // If not overridden, convert from primary format
    if (primaryFormat == SerializationFormat.yaml) {
      return null; // Already checked above
    }
    return convertToYaml(includeMetaData: includeMetaData);
  }

  /// Internal implementation of toYaml for subclasses to override.
  ///
  /// Returns null by default. Subclasses should override this method
  /// when [primaryFormat] is [SerializationFormat.yaml].
  String? toYamlImpl() => null;

  /// Converts this object to a Markdown string with headers for keys.
  ///
  /// If [toMarkdownImpl()] is overridden and returns non-null, uses that implementation.
  /// Otherwise, if [primaryFormat] is [SerializationFormat.markdown], returns the
  /// overridden implementation. Otherwise, converts from the primary format.
  ///
  /// [includeMetaData] - Whether to include metadata as YAML frontmatter
  ///
  /// Returns null if the primary format method is not implemented.
  String? toMarkdown({
    bool includeMetaData = false,
  }) {
    // Check if toMarkdownImpl() is overridden (returns non-null)
    final markdownImpl = toMarkdownImpl();
    if (markdownImpl != null) {
      return markdownImpl;
    }
    // If not overridden, convert from primary format
    if (primaryFormat == SerializationFormat.markdown) {
      return null; // Already checked above
    }
    return convertToMarkdown(
      includeMetaData: includeMetaData,
    );
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
  /// [includeMetaData] - Whether to include metadata as `_meta` element
  /// [usePascalCase] - Whether to convert element names to PascalCase
  ///
  /// Returns null if the primary format method is not implemented.
  String? toXml({
    String? rootElementName,
    bool includeNulls = false,
    bool prettyPrint = true,
    bool includeMetaData = false,
    bool usePascalCase = false,
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
    return convertToXml(
      rootElementName: rootElementName,
      includeNulls: includeNulls,
      prettyPrint: prettyPrint,
      includeMetaData: includeMetaData,
      usePascalCase: usePascalCase,
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

  // Conversion helper methods exposed for testing

  /// Converts from primary format to JSON.
  @visibleForTesting
  Map<String, dynamic>? convertToJson() {
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
  @visibleForTesting
  String? convertToYaml({bool includeMetaData = false}) {
    final meta = includeMetaData ? metaDataToJson() : null;
    switch (primaryFormat) {
      case SerializationFormat.json:
        final json = toJsonImpl();
        if (json == null) return null;
        return jsonToYaml(json, metaData: meta);
      case SerializationFormat.yaml:
        return toYamlImpl();
      case SerializationFormat.markdown:
        final markdown = toMarkdownImpl();
        if (markdown == null) return null;
        return markdownToYaml(markdown);
      case SerializationFormat.xml:
        final xml = toXmlImpl();
        if (xml == null) return null;
        return xmlToYaml(xml, metaData: meta);
    }
  }

  /// Converts from primary format to Markdown.
  @visibleForTesting
  String? convertToMarkdown({
    bool includeMetaData = false,
  }) {
    final meta = includeMetaData ? metaDataToJson() : null;
    switch (primaryFormat) {
      case SerializationFormat.json:
        final json = toJsonImpl();
        if (json == null) return null;
        return jsonToMarkdown(json, metaData: meta);
      case SerializationFormat.yaml:
        final yaml = toYamlImpl();
        if (yaml == null) return null;
        return yamlToMarkdown(yaml, metaData: meta);
      case SerializationFormat.markdown:
        return toMarkdownImpl();
      case SerializationFormat.xml:
        final xml = toXmlImpl();
        if (xml == null) return null;
        return xmlToMarkdown(xml, metaData: meta);
    }
  }

  /// Converts from primary format to XML.
  @visibleForTesting
  String? convertToXml({
    String? rootElementName,
    bool includeNulls = false,
    bool prettyPrint = true,
    bool includeMetaData = false,
    bool usePascalCase = false,
  }) {
    final meta = includeMetaData ? metaDataToJson() : null;
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
          usePascalCase: usePascalCase,
          metaData: meta,
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
          usePascalCase: usePascalCase,
          metaData: meta,
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
          usePascalCase: usePascalCase,
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
