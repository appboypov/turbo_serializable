import 'package:xml/xml.dart';

import 'package:turbo_serializable/constants/turbo_constants.dart';
import 'package:turbo_serializable/models/key_metadata.dart';
import 'package:turbo_serializable/models/layout_aware_parse_result.dart';
import 'package:turbo_serializable/models/xml_meta.dart';

/// Parser for extracting layout metadata from XML documents.
///
/// Parses XML content and extracts both data and layout metadata
/// for 100% round-trip fidelity during format conversions.
class XmlLayoutParser {
  /// Creates an [XmlLayoutParser] instance.
  const XmlLayoutParser();

  /// Parses XML content with layout metadata extraction.
  ///
  /// Returns a [LayoutAwareParseResult] containing both the parsed data map
  /// and key-level metadata for preserving layout information.
  ///
  /// [xml] - The XML string to parse
  LayoutAwareParseResult parse(String xml) {
    if (xml.isEmpty) {
      return const LayoutAwareParseResult(data: {});
    }

    try {
      final document = XmlDocument.parse(xml);
      final rootElement = document.rootElement;

      final result = _parseElement(rootElement);

      return LayoutAwareParseResult(
        data: result.data,
        keyMeta: result.keyMeta.isEmpty ? null : result.keyMeta,
      );
    } catch (e) {
      throw FormatException(TurboConstants.failedToParseXml(e));
    }
  }

  /// Parses an XML element recursively, extracting data and metadata.
  _ElementParseResult _parseElement(XmlElement element) {
    final data = <String, dynamic>{};
    final keyMeta = <String, dynamic>{};
    final children = element.children;

    // Extract attributes
    final attributes = _extractAttributes(element);

    // Extract namespace information
    final namespace = element.name.namespaceUri;
    final prefix = element.name.prefix;

    // Check for comments before this element (siblings)
    final comment = _findPrecedingComment(element);

    // Get child elements and text nodes
    final elementChildren = children.whereType<XmlElement>().toList();
    final textChildren = children.whereType<XmlText>().toList();
    final cdataChildren = children.whereType<XmlCDATA>().toList();

    // Determine if content is CDATA
    final isCdata = cdataChildren.isNotEmpty;

    // Build XmlMeta for the root element
    final rootMeta = _buildXmlMeta(
      attributes: attributes.isNotEmpty ? attributes : null,
      isCdata: isCdata,
      comment: comment,
      namespace: namespace,
      prefix: prefix,
    );

    // Handle different content types
    if (elementChildren.isEmpty) {
      // Leaf element - text or CDATA content only
      String textContent;
      if (isCdata) {
        textContent = cdataChildren.map((c) => c.value).join();
      } else {
        textContent = textChildren.map((t) => t.value).join().trim();
      }

      final parsedValue = _parseValue(textContent);
      data[element.name.local] = parsedValue;

      if (rootMeta != null) {
        keyMeta[element.name.local] = KeyMetadata(xmlMeta: rootMeta).toJson();
      }
    } else {
      // Complex element with child elements
      final childData = <String, dynamic>{};
      final childMeta = <String, dynamic>{};

      // Group elements by name to handle lists
      final groupedElements = <String, List<XmlElement>>{};
      for (final child in elementChildren) {
        final name = child.name.local;
        groupedElements.putIfAbsent(name, () => []).add(child);
      }

      // Parse each group
      for (final entry in groupedElements.entries) {
        final name = entry.key;
        final elements = entry.value;

        if (elements.length == 1) {
          // Single element
          final childResult = _parseElementContent(elements.first);
          childData[name] = childResult.value;
          if (childResult.metadata != null) {
            childMeta[name] = childResult.metadata;
          }
        } else {
          // Multiple elements with same name - treat as list
          final listValues = <dynamic>[];

          for (var i = 0; i < elements.length; i++) {
            final childResult = _parseElementContent(elements[i]);
            listValues.add(childResult.value);
            if (childResult.metadata != null) {
              childMeta['$name.$i'] = childResult.metadata;
            }
          }

          childData[name] = listValues;
        }
      }

      // Handle mixed content (text + elements)
      if (textChildren.isNotEmpty) {
        final textContent = textChildren
            .map((t) => t.value.trim())
            .where((t) => t.isNotEmpty)
            .join(' ');
        if (textContent.isNotEmpty) {
          childData[TurboConstants.textKey] = textContent;
        }
      }

      data[element.name.local] = childData;

      // Build metadata for the complex element
      if (rootMeta != null || childMeta.isNotEmpty) {
        final metadata = KeyMetadata(
          xmlMeta: rootMeta,
          children: childMeta.isNotEmpty
              ? childMeta.map((key, value) => MapEntry(
                  key,
                  value is Map<String, dynamic>
                      ? KeyMetadata.fromJson(value)
                      : const KeyMetadata()))
              : null,
        );
        keyMeta[element.name.local] = metadata.toJson();
      }
    }

    return _ElementParseResult(data: data, keyMeta: keyMeta);
  }

  /// Parses the content of a single element, returning value and metadata.
  _ContentParseResult _parseElementContent(XmlElement element) {
    final children = element.children;
    final elementChildren = children.whereType<XmlElement>().toList();
    final textChildren = children.whereType<XmlText>().toList();
    final cdataChildren = children.whereType<XmlCDATA>().toList();

    // Extract element-specific metadata
    final attributes = _extractAttributes(element);
    final namespace = element.name.namespaceUri;
    final prefix = element.name.prefix;
    final comment = _findPrecedingComment(element);
    final isCdata = cdataChildren.isNotEmpty;

    final xmlMeta = _buildXmlMeta(
      attributes: attributes.isNotEmpty ? attributes : null,
      isCdata: isCdata,
      comment: comment,
      namespace: namespace,
      prefix: prefix,
    );

    if (elementChildren.isEmpty) {
      // Leaf element
      String textContent;
      if (isCdata) {
        textContent = cdataChildren.map((c) => c.value).join();
      } else {
        textContent = textChildren.map((t) => t.value).join().trim();
      }

      final parsedValue = _parseValue(textContent);

      return _ContentParseResult(
        value: parsedValue,
        metadata:
            xmlMeta != null ? KeyMetadata(xmlMeta: xmlMeta).toJson() : null,
      );
    } else {
      // Nested complex element
      final childData = <String, dynamic>{};
      final childMeta = <String, dynamic>{};

      // Group elements by name
      final groupedElements = <String, List<XmlElement>>{};
      for (final child in elementChildren) {
        final name = child.name.local;
        groupedElements.putIfAbsent(name, () => []).add(child);
      }

      // Parse each group
      for (final entry in groupedElements.entries) {
        final name = entry.key;
        final elements = entry.value;

        if (elements.length == 1) {
          final childResult = _parseElementContent(elements.first);
          childData[name] = childResult.value;
          if (childResult.metadata != null) {
            childMeta[name] = childResult.metadata;
          }
        } else {
          final listValues = <dynamic>[];

          for (var i = 0; i < elements.length; i++) {
            final childResult = _parseElementContent(elements[i]);
            listValues.add(childResult.value);
            if (childResult.metadata != null) {
              childMeta['$name.$i'] = childResult.metadata;
            }
          }

          childData[name] = listValues;
        }
      }

      // Handle mixed content
      if (textChildren.isNotEmpty) {
        final textContent = textChildren
            .map((t) => t.value.trim())
            .where((t) => t.isNotEmpty)
            .join(' ');
        if (textContent.isNotEmpty) {
          childData[TurboConstants.textKey] = textContent;
        }
      }

      // Build complete metadata
      final metadata = KeyMetadata(
        xmlMeta: xmlMeta,
        children: childMeta.isNotEmpty
            ? childMeta.map((key, value) => MapEntry(
                key,
                value is Map<String, dynamic>
                    ? KeyMetadata.fromJson(value)
                    : const KeyMetadata()))
            : null,
      );

      return _ContentParseResult(
        value: childData,
        metadata: metadata.toJson().isNotEmpty ? metadata.toJson() : null,
      );
    }
  }

  /// Extracts attributes from an XML element.
  Map<String, String> _extractAttributes(XmlElement element) {
    final attributes = <String, String>{};
    for (final attr in element.attributes) {
      // Skip namespace declarations
      if (attr.name.prefix == 'xmlns' || attr.name.local == 'xmlns') {
        continue;
      }
      attributes[attr.name.qualified] = attr.value;
    }
    return attributes;
  }

  /// Finds a comment that immediately precedes an element.
  String? _findPrecedingComment(XmlElement element) {
    final parent = element.parent;
    if (parent == null) return null;

    final siblings = parent.children.toList();
    final index = siblings.indexOf(element);

    // Look backwards for a comment, skipping whitespace-only text nodes
    for (var i = index - 1; i >= 0; i--) {
      final sibling = siblings[i];
      if (sibling is XmlComment) {
        return sibling.value.trim();
      }
      if (sibling is XmlText && sibling.value.trim().isNotEmpty) {
        break; // Stop if we hit non-whitespace text
      }
      if (sibling is XmlElement) {
        break; // Stop if we hit another element
      }
    }

    return null;
  }

  /// Builds an XmlMeta object if there is any metadata to store.
  XmlMeta? _buildXmlMeta({
    Map<String, String>? attributes,
    bool isCdata = false,
    String? comment,
    String? namespace,
    String? prefix,
  }) {
    // Only create metadata if there's something to store
    if (attributes == null &&
        !isCdata &&
        comment == null &&
        namespace == null &&
        prefix == null) {
      return null;
    }

    return XmlMeta(
      attributes: attributes,
      isCdata: isCdata,
      comment: comment,
      namespace: namespace != null && namespace.isNotEmpty ? namespace : null,
      prefix: prefix != null && prefix.isNotEmpty ? prefix : null,
    );
  }

  /// Parses a string value to its appropriate type.
  dynamic _parseValue(String value) {
    if (value.isEmpty) {
      return null;
    }

    // Try bool
    final lower = value.toLowerCase();
    if (lower == 'true') return true;
    if (lower == 'false') return false;

    // Try int
    final intValue = int.tryParse(value);
    if (intValue != null) return intValue;

    // Try double
    final doubleValue = double.tryParse(value);
    if (doubleValue != null) return doubleValue;

    // Default to string
    return value;
  }
}

/// Internal result class for element parsing.
class _ElementParseResult {
  const _ElementParseResult({
    required this.data,
    required this.keyMeta,
  });

  final Map<String, dynamic> data;
  final Map<String, dynamic> keyMeta;
}

/// Internal result class for content parsing.
class _ContentParseResult {
  const _ContentParseResult({
    required this.value,
    this.metadata,
  });

  final dynamic value;
  final Map<String, dynamic>? metadata;
}
