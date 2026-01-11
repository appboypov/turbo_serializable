import 'package:meta/meta.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:turbo_serializable/abstracts/has_to_json.dart';
import 'package:turbo_serializable/converters/format_converters.dart';
import 'package:turbo_serializable/enums/serialization_format.dart';
import 'package:turbo_serializable/converters/xml_converter.dart';

/// Configuration for [TurboSerializable] instances.
///
/// Specifies callbacks for serialization methods and automatically determines
/// the primary format based on which callbacks are provided.
class TurboSerializableConfig {

  /// Callback for JSON serialization.
  final Map<String, dynamic>? Function(TurboSerializable input)? toJsonMap;

  /// Callback for YAML serialization.
  final String? Function(TurboSerializable input)? toYamlString;

  /// Callback for Markdown serialization.
  final String? Function(TurboSerializable input)? toMarkdownString;

  /// Callback for XML serialization.
  final String? Function(
    TurboSerializable, {
    String? rootElementName,
    bool includeNulls,
    bool prettyPrint,
  })? toXmlCallback;

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
    this.toJsonMap,
    this.toYamlString,
    this.toMarkdownString,
    this.toXmlCallback,
  })  : assert(
          toJsonMap != null ||
              toYamlString != null ||
              toMarkdownString != null ||
              toXmlCallback != null,
          'At least one callback must be provided',
        ),
        primaryFormat = _computePrimaryFormat(
          toJsonMap,
          toYamlString,
          toMarkdownString,
          toXmlCallback,
        );

  /// Computes the primary format based on which callbacks are provided.
  ///
  /// Priority order: json > yaml > markdown > xml
  static SerializationFormat _computePrimaryFormat(
    Map<String, dynamic>? Function(TurboSerializable)? toJsonCallback,
    String? Function(TurboSerializable)? toYamlCallback,
    String? Function(TurboSerializable)? toMarkdownCallback,
    String? Function(
      TurboSerializable, {
      String? rootElementName,
      bool includeNulls,
      bool prettyPrint,
    })? toXmlCallback,
  ) {
    if (toJsonCallback != null) {
      return SerializationFormat.jsonMap;
    }
    if (toYamlCallback != null) {
      return SerializationFormat.yamlString;
    }
    if (toMarkdownCallback != null) {
      return SerializationFormat.markdownString;
    }
    if (toXmlCallback != null) {
      return SerializationFormat.xmlString;
    }
    // This should never be reached due to the assertion, but provide a default
    return SerializationFormat.jsonMap;
  }
}

/// Base abstract class for serializable objects in the turbo ecosystem.
///
/// Requires specification of a [config] that provides callbacks for
/// serialization methods. The primary format is automatically determined
/// from the provided callbacks. All other formats are automatically
/// converted from the primary format.
abstract class TurboSerializable<M extends HasToJson> {
  /// Creates a [TurboSerializable] instance with required [config]
  /// and optional [metaData].
  ///
  /// [config] specifies callbacks for serialization methods. At least one
  /// callback must be provided. The primary format is automatically
  /// determined from the provided callbacks.
  TurboSerializable({
    required this.config,
    this.isLocalDefault = false,
    this.metaData,
  });

  /// The configuration for this serializable object.
  ///
  /// Contains callbacks for serialization methods and the primary format.
  final TurboSerializableConfig config;

  /// Whether this instance represents a local default (not yet synced to remote).
  final bool isLocalDefault;

  /// Optional metadata associated with this object.
  ///
  /// Useful for frontmatter, annotations, or other auxiliary data
  /// that should travel with the serializable object.
  ///
  /// If M extends [HasToJson], the metadata can be serialized to JSON.
  final M? metaData;

  /// Validates the object's state.
  ///
  /// Returns null if valid, or a [TurboResponse.fail] if invalid.
  TurboResponse<T>? validate<T>() => null;

  /// Converts metadata to a JSON map.
  @visibleForTesting
  Map<String, dynamic> metaDataToJsonMap() => metaData?.toJson() ?? {};

  /// Converts this object to a JSON map.
  ///
  /// If the primary format is [SerializationFormat.jsonMap], uses the
  /// configured callback. Otherwise, converts from the primary format.
  ///
  /// [includeMetaData] - Whether to include metadata under `_meta` key
  ///
  /// Returns null if the callback is not provided or returns null.
  Map<String, dynamic>? toJson({bool includeMetaData = true}) {
    Map<String, dynamic>? result;
    if (config.primaryFormat == SerializationFormat.jsonMap) {
      result = config.toJsonMap?.call(this);
    } else {
      result = convertToJson();
    }

    if (result != null && includeMetaData) {
      final meta = metaDataToJsonMap();
      return {'_meta': meta, ...result};
    }
    return result;
  }

  /// Converts this object to a YAML string.
  ///
  /// If a YAML callback is provided, uses that. Otherwise, if the primary
  /// format is [SerializationFormat.yamlString], uses the configured callback.
  /// Otherwise, converts from the primary format.
  ///
  /// [includeMetaData] - Whether to include metadata under `_meta` key
  ///
  /// Returns null if the callback is not provided or returns null.
  String? toYaml({bool includeMetaData = true}) {
    // Check if YAML callback is provided
    final yamlResult = config.toYamlString?.call(this);
    if (yamlResult != null) {
      return yamlResult;
    }
    // If not provided, convert from primary format
    if (config.primaryFormat == SerializationFormat.yamlString) {
      return null; // Already checked above
    }
    return convertToYaml(includeMetaData: includeMetaData);
  }

  /// Converts this object to a Markdown string with headers for keys.
  ///
  /// If a Markdown callback is provided, uses that. Otherwise, if the primary
  /// format is [SerializationFormat.markdownString], uses the configured callback.
  /// Otherwise, converts from the primary format.
  ///
  /// [includeMetaData] - Whether to include metadata as YAML frontmatter
  ///
  /// Returns null if the callback is not provided or returns null.
  String? toMarkdown({
    bool includeMetaData = true,
  }) {
    // Check if Markdown callback is provided
    final markdownResult = config.toMarkdownString?.call(this);
    if (markdownResult != null) {
      return markdownResult;
    }
    // If not provided, convert from primary format
    if (config.primaryFormat == SerializationFormat.markdownString) {
      return null; // Already checked above
    }
    return convertToMarkdown(
      includeMetaData: includeMetaData,
    );
  }

  /// Converts this object to an XML string.
  ///
  /// If an XML callback is provided, uses that. Otherwise, if the primary
  /// format is [SerializationFormat.xmlString], uses the configured callback.
  /// Otherwise, converts from the primary format.
  ///
  /// The root element name defaults to the class name (runtimeType).
  ///
  /// [includeMetaData] - Whether to include metadata as `_meta` element
  /// [usePascalCase] - Whether to convert element names to PascalCase
  ///
  /// Returns null if the callback is not provided or returns null.
  String? toXml({
    String? rootElementName,
    bool includeNulls = false,
    bool prettyPrint = true,
    bool includeMetaData = true,
    bool usePascalCase = false,
  }) {
    // Check if XML callback is provided
    final xmlResult = config.toXmlCallback?.call(
      this,
      rootElementName: rootElementName,
      includeNulls: includeNulls,
      prettyPrint: prettyPrint,
    );
    if (xmlResult != null) {
      return xmlResult;
    }
    // If not provided, convert from primary format
    if (config.primaryFormat == SerializationFormat.xmlString) {
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

  // Conversion helper methods exposed for testing

  /// Converts from primary format to JSON.
  @visibleForTesting
  Map<String, dynamic>? convertToJson() {
    switch (config.primaryFormat) {
      case SerializationFormat.jsonMap:
        return config.toJsonMap?.call(this);
      case SerializationFormat.yamlString:
        final yaml = config.toYamlString?.call(this);
        if (yaml == null) return null;
        try {
          return yamlToJson(yaml);
        } catch (e) {
          return null;
        }
      case SerializationFormat.markdownString:
        final markdown = config.toMarkdownString?.call(this);
        if (markdown == null) return null;
        try {
          return markdownToJson(markdown);
        } catch (e) {
          return null;
        }
      case SerializationFormat.xmlString:
        final xml = config.toXmlCallback?.call(
          this,
          rootElementName: null,
          includeNulls: false,
          prettyPrint: true,
        );
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
  String? convertToYaml({bool includeMetaData = true}) {
    final meta = includeMetaData ? metaDataToJsonMap() : null;
    switch (config.primaryFormat) {
      case SerializationFormat.jsonMap:
        final json = config.toJsonMap?.call(this);
        if (json == null) return null;
        return jsonToYaml(json, metaData: meta);
      case SerializationFormat.yamlString:
        return config.toYamlString?.call(this);
      case SerializationFormat.markdownString:
        final markdown = config.toMarkdownString?.call(this);
        if (markdown == null) return null;
        return markdownToYaml(markdown);
      case SerializationFormat.xmlString:
        final xml = config.toXmlCallback?.call(
          this,
          rootElementName: null,
          includeNulls: false,
          prettyPrint: true,
        );
        if (xml == null) return null;
        return xmlToYaml(xml, metaData: meta);
    }
  }

  /// Converts from primary format to Markdown.
  @visibleForTesting
  String? convertToMarkdown({
    bool includeMetaData = true,
  }) {
    final meta = includeMetaData ? metaDataToJsonMap() : null;
    switch (config.primaryFormat) {
      case SerializationFormat.jsonMap:
        final json = config.toJsonMap?.call(this);
        if (json == null) return null;
        return jsonToMarkdown(json, metaData: meta);
      case SerializationFormat.yamlString:
        final yaml = config.toYamlString?.call(this);
        if (yaml == null) return null;
        return yamlToMarkdown(yaml, metaData: meta);
      case SerializationFormat.markdownString:
        return config.toMarkdownString?.call(this);
      case SerializationFormat.xmlString:
        final xml = config.toXmlCallback?.call(
          this,
          rootElementName: null,
          includeNulls: false,
          prettyPrint: true,
        );
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
    bool includeMetaData = true,
    bool usePascalCase = false,
  }) {
    final meta = includeMetaData ? metaDataToJsonMap() : null;
    switch (config.primaryFormat) {
      case SerializationFormat.jsonMap:
        final json = config.toJsonMap?.call(this);
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
      case SerializationFormat.yamlString:
        final yaml = config.toYamlString?.call(this);
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
      case SerializationFormat.markdownString:
        final markdown = config.toMarkdownString?.call(this);
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
      case SerializationFormat.xmlString:
        return config.toXmlCallback?.call(
          this,
          rootElementName: rootElementName,
          includeNulls: includeNulls,
          prettyPrint: prettyPrint,
        );
    }
  }
}
