import 'package:xml/xml.dart';

/// Converts a JSON map to an XML string.
///
/// [json] - The JSON map to convert
/// [rootElementName] - Optional root element name. If not provided, uses 'root'
/// [includeNulls] - Whether to include null values in XML (default: false)
/// [prettyPrint] - Whether to format XML with indentation (default: true)
///
/// Returns the XML string representation of the JSON map.
String mapToXml(
  Map<String, dynamic> json, {
  String? rootElementName,
  bool includeNulls = false,
  bool prettyPrint = true,
}) {
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="UTF-8"');
  builder.element(rootElementName ?? 'root', nest: () {
    _buildXmlElement(builder, json, includeNulls: includeNulls);
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
/// Returns a Map<String, dynamic> representation of the XML.
/// Throws [FormatException] if the XML is invalid.
Map<String, dynamic> xmlToMap(String xml) {
  try {
    final document = XmlDocument.parse(xml);
    final rootElement = document.rootElement;
    return _parseXmlElement(rootElement);
  } catch (e) {
    throw FormatException('Failed to parse XML: $e');
  }
}

/// Recursively builds XML elements from a JSON value.
void _buildXmlElement(
  XmlBuilder builder,
  dynamic value, {
  bool includeNulls = false,
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
      if (val is List) {
        // For lists, create multiple elements with the same key name
        for (final item in val) {
          if (item == null && !includeNulls) {
            continue;
          }
          builder.element(key, nest: () {
            _buildXmlElement(builder, item, includeNulls: includeNulls);
          });
        }
      } else {
        // Single value - create one element
        builder.element(key, nest: () {
          _buildXmlElement(builder, val, includeNulls: includeNulls);
        });
      }
    });
  } else if (value is List) {
    // This case handles lists that are direct values (shouldn't happen in normal flow)
    // but we handle it for completeness
    for (final item in value) {
      if (item == null && !includeNulls) {
        continue;
      }
      builder.element('item', nest: () {
        _buildXmlElement(builder, item, includeNulls: includeNulls);
      });
    }
  } else {
    // Primitive value (String, int, double, bool)
    builder.text(_valueToString(value));
  }
}

/// Converts a primitive value to its string representation.
String _valueToString(dynamic value) {
  if (value is bool) {
    return value.toString();
  } else if (value is num) {
    return value.toString();
  } else {
    return value.toString();
  }
}

/// Recursively parses an XML element into a JSON value.
dynamic _parseXmlElement(XmlElement element) {
  final children = element.children;
  
  // Check if element has only text content (no nested elements)
  final textChildren = children.whereType<XmlText>().toList();
  final elementChildren = children.whereType<XmlElement>().toList();

  if (elementChildren.isEmpty && textChildren.isNotEmpty) {
    // Simple text content
    final text = textChildren.map((e) => e.value).join('');
    return _parseValue(text);
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
      final parsed = _parseXmlElement(elements.first);
      if (parsed != null) {
        result[name] = parsed;
      }
    } else {
      // Multiple elements with same name - parse as list
      final list = elements
          .map((e) => _parseXmlElement(e))
          .where((v) => v != null)
          .toList();
      result[name] = list;
    }
  });
  
  // Handle mixed content (text + elements) - store text in a special key
  if (textChildren.isNotEmpty && elementChildren.isNotEmpty) {
    final text = textChildren.map((e) => e.value.trim()).where((t) => t.isNotEmpty).join(' ');
    if (text.isNotEmpty) {
      result['_text'] = text;
    }
  }
  
  return result.isEmpty ? null : result;
}

/// Parses a string value to its appropriate type (int, double, bool, or String).
dynamic _parseValue(String value) {
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
