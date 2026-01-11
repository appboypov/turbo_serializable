import 'package:xml/xml.dart';

import 'package:turbo_serializable/constants/turbo_constants.dart';
import 'package:turbo_serializable/models/key_metadata.dart';
import 'package:turbo_serializable/models/xml_meta.dart';

/// Generates XML output from JSON data using key metadata for layout fidelity.
///
/// Uses extracted metadata from parsing to produce byte-for-byte identical
/// output during round-trip conversions.
class XmlLayoutGenerator {
  /// Creates an [XmlLayoutGenerator] instance.
  const XmlLayoutGenerator();

  /// Generates XML from data using key metadata for layout preservation.
  ///
  /// [data] - The JSON data map to convert. Expected to contain a single
  ///   root element key with its content as the value.
  /// [keyMeta] - The key-level metadata for layout information
  /// [prettyPrint] - Whether to format XML with indentation (default: true)
  ///
  /// Returns an XML string with preserved layout from the original document.
  String generate(
    Map<String, dynamic> data, {
    Map<String, dynamic>? keyMeta,
    bool prettyPrint = true,
  }) {
    if (data.isEmpty) {
      return '';
    }

    final builder = XmlBuilder();
    builder.processing(
      TurboConstants.xmlProcessingInstruction,
      TurboConstants.xmlDeclaration,
    );

    // Data should have a single root element key
    for (final entry in data.entries) {
      final rootKey = entry.key;
      final rootValue = entry.value;
      final rootMeta = _getKeyMetadata(keyMeta, rootKey);

      _buildElement(
        builder,
        rootKey,
        rootValue,
        rootMeta,
        keyMeta,
      );
    }

    final document = builder.buildDocument();
    return prettyPrint
        ? document.toXmlString(pretty: true)
        : document.toXmlString();
  }

  /// Builds an XML element with metadata-guided attributes and content.
  void _buildElement(
    XmlBuilder builder,
    String elementName,
    dynamic value,
    KeyMetadata? meta,
    Map<String, dynamic>? keyMeta,
  ) {
    final xmlMeta = meta?.xmlMeta;
    final prefix = xmlMeta?.prefix;
    final namespace = xmlMeta?.namespace;
    final attributes = xmlMeta?.attributes;
    final isCdata = xmlMeta?.isCdata ?? false;
    final comment = xmlMeta?.comment;

    // Add comment before element if present
    if (comment != null && comment.isNotEmpty) {
      builder.comment(comment);
    }

    // Build qualified name with prefix
    final qualifiedName = prefix != null && prefix.isNotEmpty
        ? '$prefix:$elementName'
        : elementName;

    builder.element(
      qualifiedName,
      namespace: namespace,
      namespaces: _buildNamespaces(xmlMeta),
      attributes: _buildAttributes(attributes),
      nest: () {
        _buildElementContent(
          builder,
          value,
          meta,
          keyMeta,
          isCdata,
        );
      },
    );
  }

  /// Builds namespace declarations for an element.
  Map<String, String> _buildNamespaces(XmlMeta? xmlMeta) {
    if (xmlMeta == null) return {};

    final namespaces = <String, String>{};
    final namespace = xmlMeta.namespace;
    final prefix = xmlMeta.prefix;

    if (namespace != null && namespace.isNotEmpty) {
      if (prefix != null && prefix.isNotEmpty) {
        // Prefixed namespace: xmlns:prefix="uri"
        namespaces[namespace] = prefix;
      } else {
        // Default namespace: xmlns="uri"
        namespaces[namespace] = '';
      }
    }

    return namespaces;
  }

  /// Builds attributes map for an element.
  Map<String, String> _buildAttributes(Map<String, String>? attributes) {
    if (attributes == null) return {};
    return Map<String, String>.from(attributes);
  }

  /// Builds the content of an element based on value type and metadata.
  void _buildElementContent(
    XmlBuilder builder,
    dynamic value,
    KeyMetadata? meta,
    Map<String, dynamic>? keyMeta,
    bool isCdata,
  ) {
    if (value == null) {
      return;
    }

    if (value is Map<String, dynamic>) {
      _buildMapContent(builder, value, meta, keyMeta);
    } else if (value is List) {
      _buildListContent(builder, value, meta, keyMeta);
    } else {
      // Primitive value
      _buildTextContent(builder, value, isCdata);
    }
  }

  /// Builds content from a Map value.
  void _buildMapContent(
    XmlBuilder builder,
    Map<String, dynamic> map,
    KeyMetadata? parentMeta,
    Map<String, dynamic>? keyMeta,
  ) {
    // Handle mixed content - text alongside elements
    final textContent = map[TurboConstants.textKey];
    if (textContent != null) {
      builder.text(textContent.toString());
    }

    // Get children metadata from parent
    final childrenMeta = parentMeta?.children;

    for (final entry in map.entries) {
      if (entry.key == TurboConstants.textKey) {
        continue; // Already handled above
      }

      final childKey = entry.key;
      final childValue = entry.value;

      if (childValue is List) {
        // Handle repeated elements
        _buildRepeatedElements(
          builder,
          childKey,
          childValue,
          childrenMeta,
          keyMeta,
        );
      } else {
        // Single element
        final childMeta = _getChildMetadata(childrenMeta, childKey);
        _buildElement(
          builder,
          childKey,
          childValue,
          childMeta,
          keyMeta,
        );
      }
    }
  }

  /// Builds repeated elements for a list value.
  void _buildRepeatedElements(
    XmlBuilder builder,
    String elementName,
    List<dynamic> items,
    Map<String, KeyMetadata>? childrenMeta,
    Map<String, dynamic>? keyMeta,
  ) {
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      // Try indexed key first (e.g., "item.0"), then fall back to element name
      final indexedKey = '$elementName.$i';
      final itemMeta = _getChildMetadata(childrenMeta, indexedKey) ??
          _getChildMetadata(childrenMeta, elementName);

      _buildElement(
        builder,
        elementName,
        item,
        itemMeta,
        keyMeta,
      );
    }
  }

  /// Builds content from a List value (for direct list values, not repeated elements).
  void _buildListContent(
    XmlBuilder builder,
    List<dynamic> list,
    KeyMetadata? meta,
    Map<String, dynamic>? keyMeta,
  ) {
    // Direct list content - create item elements
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      builder.element(TurboConstants.defaultItemElement, nest: () {
        if (item is Map<String, dynamic>) {
          _buildMapContent(builder, item, meta, keyMeta);
        } else if (item != null) {
          builder.text(_convertValue(item));
        }
      });
    }
  }

  /// Builds text content for a primitive value.
  void _buildTextContent(
    XmlBuilder builder,
    dynamic value,
    bool isCdata,
  ) {
    final textValue = _convertValue(value);
    if (isCdata) {
      builder.cdata(textValue);
    } else {
      builder.text(textValue);
    }
  }

  /// Gets KeyMetadata for a given key from the metadata map.
  KeyMetadata? _getKeyMetadata(Map<String, dynamic>? keyMeta, String key) {
    if (keyMeta == null) return null;
    final metaJson = keyMeta[key];
    if (metaJson == null) return null;
    if (metaJson is Map<String, dynamic>) {
      return KeyMetadata.fromJson(metaJson);
    }
    return null;
  }

  /// Gets child KeyMetadata from a children map.
  KeyMetadata? _getChildMetadata(
    Map<String, KeyMetadata>? childrenMeta,
    String key,
  ) {
    if (childrenMeta == null) return null;
    return childrenMeta[key];
  }

  /// Converts a value to its string representation for XML.
  String _convertValue(dynamic value) {
    if (value is bool) {
      return value.toString();
    } else if (value is num) {
      return value.toString();
    } else {
      return value.toString();
    }
  }
}
