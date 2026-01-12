import 'package:meta/meta.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:turbo_serializable/abstracts/has_to_json.dart';
import 'package:turbo_serializable/constants/turbo_constants.dart';
import 'package:turbo_serializable/converters/format_converters.dart';
import 'package:turbo_serializable/enums/case_style.dart';
import 'package:turbo_serializable/enums/serialization_format.dart';
import 'package:turbo_serializable/converters/xml_converter.dart';
import 'package:turbo_serializable/models/turbo_serializable_config.dart';

/// Base abstract class for serializable objects in the turbo ecosystem.
///
/// Requires specification of a [config] that provides callbacks for
/// serialization methods. The primary format is automatically determined
/// from the provided callbacks. All other formats are automatically
/// converted from the primary format.
abstract class TurboSerializable<M> {
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
  Map<String, dynamic> metaDataToJsonMap() {
    if (metaData == null) return {};
    // Try to call toJson() if it's a HasToJson instance
    if (metaData is HasToJson) {
      return (metaData as HasToJson).toJson();
    }
    return {};
  }

  /// Converts this object to a JSON map.
  ///
  /// If the primary format is [SerializationFormat.json], uses the
  /// configured callback. Otherwise, converts from the primary format.
  ///
  /// [includeMetaData] - Whether to include metadata under `_meta` key
  /// [includeNulls] - Whether to include null values (default: false)
  ///
  /// Returns null if the callback is not provided or returns null.
  Map<String, dynamic>? toJson({
    bool includeMetaData = true,
    bool includeNulls = false,
  }) {
    Map<String, dynamic>? result;
    if (config.primaryFormat == SerializationFormat.json) {
      result = config.toJson?.call(this);
    } else {
      result = convertToJson(includeNulls: includeNulls);
    }

    if (result != null && includeMetaData) {
      final meta = metaDataToJsonMap();
      if (meta.isNotEmpty) {
        result = {TurboConstants.metaKey: meta, ...result};
      }
    }

    if (result != null && !includeNulls) {
      result = filterNullsFromMap(result);
    }

    return result;
  }

  /// Converts this object to a YAML string.
  ///
  /// If a YAML callback is provided, uses that. Otherwise, if the primary
  /// format is [SerializationFormat.yaml], uses the configured callback.
  /// Otherwise, converts from the primary format.
  ///
  /// [includeMetaData] - Whether to include metadata under `_meta` key
  /// [includeNulls] - Whether to include null values (default: false)
  /// [prettyPrint] - Whether to format YAML with indentation (default: true)
  ///
  /// Returns null if the callback is not provided or returns null.
  String? toYaml({
    bool includeMetaData = true,
    bool includeNulls = false,
    bool prettyPrint = true,
  }) {
    // Check if YAML callback is provided
    final yamlResult = config.toYaml?.call(this);
    if (yamlResult != null) {
      return yamlResult;
    }
    // If not provided, convert from primary format
    if (config.primaryFormat == SerializationFormat.yaml) {
      return null; // Already checked above
    }
    return convertToYaml(
      includeMetaData: includeMetaData,
      includeNulls: includeNulls,
      prettyPrint: prettyPrint,
    );
  }

  /// Converts this object to a Markdown string with headers for keys.
  ///
  /// If a Markdown callback is provided, uses that. Otherwise, if the primary
  /// format is [SerializationFormat.markdown], uses the configured callback.
  /// Otherwise, converts from the primary format.
  ///
  /// [includeMetaData] - Whether to include metadata as YAML frontmatter
  /// [includeNulls] - Whether to include null values (default: false)
  /// [prettyPrint] - Whether to format Markdown with spacing (default: true)
  ///
  /// Returns null if the callback is not provided or returns null.
  String? toMarkdown({
    bool includeMetaData = true,
    bool includeNulls = false,
    bool prettyPrint = true,
  }) {
    // Check if Markdown callback is provided
    final markdownResult = config.toMarkdown?.call(this);
    if (markdownResult != null) {
      return markdownResult;
    }
    // If not provided, convert from primary format
    if (config.primaryFormat == SerializationFormat.markdown) {
      return null; // Already checked above
    }
    return convertToMarkdown(
      includeMetaData: includeMetaData,
      includeNulls: includeNulls,
      prettyPrint: prettyPrint,
    );
  }

  /// Converts this object to an XML string.
  ///
  /// If an XML callback is provided, uses that. Otherwise, if the primary
  /// format is [SerializationFormat.xml], uses the configured callback.
  /// Otherwise, converts from the primary format.
  ///
  /// The root element name defaults to the class name (runtimeType).
  ///
  /// [includeMetaData] - Whether to include metadata as `_meta` element
  /// [caseStyle] - The case style to apply to element names (default: CaseStyle.none)
  ///
  /// Returns null if the callback is not provided or returns null.
  String? toXml({
    String? rootElementName,
    bool includeNulls = false,
    bool prettyPrint = true,
    bool includeMetaData = true,
    CaseStyle caseStyle = CaseStyle.none,
  }) {
    // Check if XML callback is provided
    final xmlResult = config.toXml?.call(
      this,
      rootElementName: rootElementName,
      includeNulls: includeNulls,
      prettyPrint: prettyPrint,
      includeMetaData: includeMetaData,
      caseStyle: caseStyle,
    );
    if (xmlResult != null) {
      return xmlResult;
    }
    // If not provided, convert from primary format
    if (config.primaryFormat == SerializationFormat.xml) {
      return null; // Already checked above
    }
    return convertToXml(
      rootElementName: rootElementName,
      includeNulls: includeNulls,
      prettyPrint: prettyPrint,
      includeMetaData: includeMetaData,
      caseStyle: caseStyle,
    );
  }

  // Conversion helper methods exposed for testing

  /// Converts from primary format to JSON.
  @visibleForTesting
  Map<String, dynamic>? convertToJson({bool includeNulls = false}) {
    Map<String, dynamic>? result;
    switch (config.primaryFormat) {
      case SerializationFormat.json:
        result = config.toJson?.call(this);
        break;
      case SerializationFormat.yaml:
        final yaml = config.toYaml?.call(this);
        if (yaml == null) return null;
        try {
          result = yamlToJson(yaml) as Map<String, dynamic>?;
        } catch (e) {
          return null;
        }
        break;
      case SerializationFormat.markdown:
        final markdown = config.toMarkdown?.call(this);
        if (markdown == null) return null;
        try {
          result = markdownToJson(markdown) as Map<String, dynamic>?;
        } catch (e) {
          return null;
        }
        break;
      case SerializationFormat.xml:
        final xml = config.toXml?.call(
          this,
          rootElementName: null,
          includeNulls: false,
          prettyPrint: true,
          includeMetaData: true,
          caseStyle: CaseStyle.none,
        );
        if (xml == null) return null;
        try {
          result = xmlToJson(xml) as Map<String, dynamic>?;
        } catch (e) {
          return null;
        }
        break;
    }

    if (result != null && !includeNulls) {
      result = filterNullsFromMap(result);
    }

    return result;
  }

  /// Converts from primary format to YAML.
  @visibleForTesting
  String? convertToYaml({
    bool includeMetaData = true,
    bool includeNulls = false,
    bool prettyPrint = true,
  }) {
    final meta = includeMetaData ? metaDataToJsonMap() : null;
    switch (config.primaryFormat) {
      case SerializationFormat.json:
        final json = config.toJson?.call(this);
        if (json == null) return null;
        return jsonToYaml(
          json,
          metaData: meta,
          includeNulls: includeNulls,
          prettyPrint: prettyPrint,
        );
      case SerializationFormat.yaml:
        return config.toYaml?.call(this);
      case SerializationFormat.markdown:
        final markdown = config.toMarkdown?.call(this);
        if (markdown == null) return null;
        return markdownToYaml(
          markdown,
          metaData: meta,
          includeNulls: includeNulls,
          prettyPrint: prettyPrint,
        );
      case SerializationFormat.xml:
        final xml = config.toXml?.call(
          this,
          rootElementName: null,
          includeNulls: false,
          prettyPrint: true,
          includeMetaData: includeMetaData,
          caseStyle: CaseStyle.none,
        );
        if (xml == null) return null;
        return xmlToYaml(
          xml,
          metaData: meta,
          includeNulls: includeNulls,
          prettyPrint: prettyPrint,
        );
    }
  }

  /// Converts from primary format to Markdown.
  @visibleForTesting
  String? convertToMarkdown({
    bool includeMetaData = true,
    bool includeNulls = false,
    bool prettyPrint = true,
  }) {
    final meta = includeMetaData ? metaDataToJsonMap() : null;
    switch (config.primaryFormat) {
      case SerializationFormat.json:
        final json = config.toJson?.call(this);
        if (json == null) return null;
        return jsonToMarkdown(
          json,
          metaData: meta,
          includeNulls: includeNulls,
          prettyPrint: prettyPrint,
        );
      case SerializationFormat.yaml:
        final yaml = config.toYaml?.call(this);
        if (yaml == null) return null;
        return yamlToMarkdown(
          yaml,
          metaData: meta,
          includeNulls: includeNulls,
          prettyPrint: prettyPrint,
        );
      case SerializationFormat.markdown:
        return config.toMarkdown?.call(this);
      case SerializationFormat.xml:
        final xml = config.toXml?.call(
          this,
          rootElementName: null,
          includeNulls: false,
          prettyPrint: true,
          includeMetaData: includeMetaData,
          caseStyle: CaseStyle.none,
        );
        if (xml == null) return null;
        return xmlToMarkdown(
          xml,
          metaData: meta,
          includeNulls: includeNulls,
          prettyPrint: prettyPrint,
        );
    }
  }

  /// Converts from primary format to XML.
  @visibleForTesting
  String? convertToXml({
    String? rootElementName,
    bool includeNulls = false,
    bool prettyPrint = true,
    bool includeMetaData = true,
    CaseStyle caseStyle = CaseStyle.none,
  }) {
    final meta = includeMetaData ? metaDataToJsonMap() : null;
    switch (config.primaryFormat) {
      case SerializationFormat.json:
        final json = config.toJson?.call(this);
        if (json == null) return null;
        final elementName = rootElementName ??
            runtimeType.toString().replaceAll(RegExp(r'<.*>'), '');
        return jsonToXml(
          json,
          rootElementName: elementName,
          includeNulls: includeNulls,
          prettyPrint: prettyPrint,
          caseStyle: caseStyle,
          metaData: meta,
        );
      case SerializationFormat.yaml:
        final yaml = config.toYaml?.call(this);
        if (yaml == null) return null;
        final elementName = rootElementName ??
            runtimeType.toString().replaceAll(RegExp(r'<.*>'), '');
        return yamlToXml(
          yaml,
          rootElementName: elementName,
          includeNulls: includeNulls,
          prettyPrint: prettyPrint,
          caseStyle: caseStyle,
          metaData: meta,
        );
      case SerializationFormat.markdown:
        final markdown = config.toMarkdown?.call(this);
        if (markdown == null) return null;
        final elementName = rootElementName ??
            runtimeType.toString().replaceAll(RegExp(r'<.*>'), '');
        return markdownToXml(
          markdown,
          rootElementName: elementName,
          includeNulls: includeNulls,
          prettyPrint: prettyPrint,
          caseStyle: caseStyle,
          metaData: meta,
        );
      case SerializationFormat.xml:
        return config.toXml?.call(
          this,
          rootElementName: rootElementName,
          includeNulls: includeNulls,
          prettyPrint: prettyPrint,
          includeMetaData: includeMetaData,
          caseStyle: caseStyle,
        );
    }
  }
}
