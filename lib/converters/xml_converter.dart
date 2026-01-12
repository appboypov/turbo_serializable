import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import 'package:turbo_serializable/constants/turbo_constants.dart';
import 'package:turbo_serializable/enums/case_style.dart';
import 'package:turbo_serializable/converters/case_converter.dart';
import 'package:turbo_serializable/generators/xml_generator.dart';

/// Converts a JSON map to an XML string.
///
/// [json] - The JSON map to convert
/// [rootElementName] - Optional root element name. If not provided, uses 'root'
/// [includeNulls] - Whether to include null values in XML (default: false)
/// [prettyPrint] - Whether to format XML with indentation (default: true)
/// [caseStyle] - The case style to apply to element names (default: CaseStyle.none)
/// [metaData] - Optional metadata to include as a `_meta` element
/// [keyMeta] - Optional key-level metadata for layout preservation
/// [preserveLayout] - Whether to use key metadata for layout preservation
///   (default: true). When true and [keyMeta] is provided, uses the
///   [XmlLayoutGenerator] for byte-for-byte fidelity.
///
/// Returns the XML string representation of the JSON map.
String jsonToXml(
  Map<String, dynamic> json, {
  String? rootElementName,
  bool includeNulls = false,
  bool prettyPrint = true,
  CaseStyle caseStyle = CaseStyle.none,
  Map<String, dynamic>? metaData,
  Map<String, dynamic>? keyMeta,
  bool preserveLayout = true,
}) {
  // Use layout generator when metadata is available and layout preservation is enabled
  if (preserveLayout && keyMeta != null) {
    const generator = XmlLayoutGenerator();
    return generator.generate(
      json,
      keyMeta: keyMeta,
      prettyPrint: prettyPrint,
    );
  }

  final builder = XmlBuilder();
  builder.processing(
      TurboConstants.xmlProcessingInstruction, TurboConstants.xmlDeclaration);
  final rootName = convertCase(
    rootElementName ?? TurboConstants.defaultRootElement,
    caseStyle,
  );
  builder.element(rootName, nest: () {
    if (metaData != null && metaData.isNotEmpty) {
      final metaElementName = convertCase(TurboConstants.metaKey, caseStyle);
      builder.element(metaElementName, nest: () {
        buildXmlElement(
          builder,
          metaData,
          includeNulls: includeNulls,
          caseStyle: caseStyle,
        );
      });
    }
    buildXmlElement(
      builder,
      json,
      includeNulls: includeNulls,
      caseStyle: caseStyle,
    );
  });

  final document = builder.buildDocument();
  return prettyPrint
      ? document.toXmlString(pretty: true)
      : document.toXmlString();
}

/// Converts an XML string to a JSON map.
///
/// [xml] - The XML string to parse
///
/// Returns a `Map<String, dynamic>` representation of the XML.
/// Throws [FormatException] if the XML is invalid.
Map<String, dynamic> xmlToMap(String xml) {
  try {
    final document = XmlDocument.parse(xml);
    final rootElement = document.rootElement;
    return parseXmlElement(rootElement) as Map<String, dynamic>;
  } catch (e) {
    throw FormatException(TurboConstants.failedToParseXml(e));
  }
}

/// Recursively builds XML elements from a JSON value.
@visibleForTesting
void buildXmlElement(
  XmlBuilder builder,
  dynamic value, {
  bool includeNulls = false,
  CaseStyle caseStyle = CaseStyle.none,
}) {
  if (value == null) {
    if (includeNulls) {
      builder.text('');
    }
    return;
  }

  if (value is Map<String, dynamic>) {
    value.forEach((key, val) {
      if (val == null && !includeNulls) {
        return;
      }
      final elementName = convertCase(key, caseStyle);
      if (val is List) {
        // For lists, create multiple elements with the same key name
        for (final item in val) {
          if (item == null && !includeNulls) {
            continue;
          }
          builder.element(elementName, nest: () {
            buildXmlElement(
              builder,
              item,
              includeNulls: includeNulls,
              caseStyle: caseStyle,
            );
          });
        }
      } else {
        // Single value - create one element
        builder.element(elementName, nest: () {
          buildXmlElement(
            builder,
            val,
            includeNulls: includeNulls,
            caseStyle: caseStyle,
          );
        });
      }
    });
  } else if (value is List) {
    // This case handles lists that are direct values (shouldn't happen in normal flow)
    // but we handle it for completeness
    final itemName = convertCase(TurboConstants.defaultItemElement, caseStyle);
    for (final item in value) {
      if (item == null && !includeNulls) {
        continue;
      }
      builder.element(itemName, nest: () {
        buildXmlElement(
          builder,
          item,
          includeNulls: includeNulls,
          caseStyle: caseStyle,
        );
      });
    }
  } else {
    // Primitive value (String, int, double, bool)
    builder.text(convertValueToXmlString(value));
  }
}

/// Converts a primitive value to its string representation.
@visibleForTesting
String convertValueToXmlString(dynamic value) {
  if (value is bool) {
    return value.toString();
  } else if (value is num) {
    return value.toString();
  } else {
    return value.toString();
  }
}

/// Recursively parses an XML element into a JSON value.
@visibleForTesting
dynamic parseXmlElement(XmlElement element) {
  final children = element.children;

  // Check if element has only text content (no nested elements)
  final textChildren = children.whereType<XmlText>().toList();
  final elementChildren = children.whereType<XmlElement>().toList();

  if (elementChildren.isEmpty && textChildren.isNotEmpty) {
    // Simple text content
    final text = textChildren.map((e) => e.value).join();
    return parseXmlValue(text);
  }

  if (elementChildren.isEmpty && textChildren.isEmpty) {
    // Empty element
    return null;
  }

  // Has nested elements - build a map
  final Map<String, dynamic> result = {};

  // Group elements by name to handle lists
  final Map<String, List<XmlElement>> groupedElements = {};
  for (final child in elementChildren) {
    final name = child.name.local;
    groupedElements.putIfAbsent(name, () => []).add(child);
  }

  groupedElements.forEach((name, elements) {
    if (elements.length == 1) {
      // Single element - parse as object or value
      final parsed = parseXmlElement(elements.first);
      if (parsed != null) {
        result[name] = parsed;
      }
    } else {
      // Multiple elements with same name - parse as list
      final list = elements
          .map((e) => parseXmlElement(e))
          .where((v) => v != null)
          .toList();
      result[name] = list;
    }
  });

  // Handle mixed content (text + elements) - store text in a special key
  if (textChildren.isNotEmpty && elementChildren.isNotEmpty) {
    final text = textChildren
        .map((e) => e.value.trim())
        .where((t) => t.isNotEmpty)
        .join(' ');
    if (text.isNotEmpty) {
      result[TurboConstants.textKey] = text;
    }
  }

  return result.isEmpty ? null : result;
}

/// Parses a string value to its appropriate type (int, double, bool, or String).
@visibleForTesting
dynamic parseXmlValue(String value) {
  if (value.isEmpty) {
    return null;
  }

  // Try bool
  if (value.toLowerCase() == 'true') {
    return true;
  }
  if (value.toLowerCase() == 'false') {
    return false;
  }

  // Try int
  final intValue = int.tryParse(value);
  if (intValue != null) {
    return intValue;
  }

  // Try double
  final doubleValue = double.tryParse(value);
  if (doubleValue != null) {
    return doubleValue;
  }

  // Default to string
  return value;
}
