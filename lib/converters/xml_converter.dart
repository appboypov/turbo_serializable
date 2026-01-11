import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

/// Converts a JSON map to an XML string.
///
/// [json] - The JSON map to convert
/// [rootElementName] - Optional root element name. If not provided, uses 'root'
/// [includeNulls] - Whether to include null values in XML (default: false)
/// [prettyPrint] - Whether to format XML with indentation (default: true)
/// [usePascalCase] - Whether to convert element names to PascalCase (default: false)
/// [metaData] - Optional metadata to include as a `_meta` element
///
/// Returns the XML string representation of the JSON map.
String mapToXml(
  Map<String, dynamic> json, {
  String? rootElementName,
  bool includeNulls = false,
  bool prettyPrint = true,
  bool usePascalCase = false,
  Map<String, dynamic>? metaData,
}) {
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0" encoding="UTF-8"');
  final rootName = usePascalCase
      ? convertToPascalCase(rootElementName ?? 'root')
      : (rootElementName ?? 'root');
  builder.element(rootName, nest: () {
    if (metaData != null && metaData.isNotEmpty) {
      final metaElementName = usePascalCase ? '_Meta' : '_meta';
      builder.element(metaElementName, nest: () {
        buildXmlElement(
          builder,
          metaData,
          includeNulls: includeNulls,
          usePascalCase: usePascalCase,
        );
      });
    }
    buildXmlElement(
      builder,
      json,
      includeNulls: includeNulls,
      usePascalCase: usePascalCase,
    );
  });

  final document = builder.buildDocument();
  return prettyPrint
      ? document.toXmlString(pretty: true)
      : document.toXmlString();
}

/// Converts a string to PascalCase.
///
/// Handles:
/// - camelCase → PascalCase (userName → UserName)
/// - snake_case → PascalCase (user_name → UserName)
/// - kebab-case → PascalCase (user-name → UserName)
/// - Already PascalCase → unchanged (UserName → UserName)
@visibleForTesting
String convertToPascalCase(String input) {
  if (input.isEmpty) return input;

  // Split by underscores, hyphens, or uppercase letters (for camelCase)
  final words = <String>[];
  final buffer = StringBuffer();

  for (var i = 0; i < input.length; i++) {
    final char = input[i];

    if (char == '_' || char == '-') {
      if (buffer.isNotEmpty) {
        words.add(buffer.toString());
        buffer.clear();
      }
    } else if (i > 0 &&
        char.toUpperCase() == char &&
        char.toLowerCase() != char &&
        input[i - 1].toUpperCase() != input[i - 1]) {
      // Uppercase letter after lowercase = new word (camelCase split)
      if (buffer.isNotEmpty) {
        words.add(buffer.toString());
        buffer.clear();
      }
      buffer.write(char);
    } else {
      buffer.write(char);
    }
  }

  if (buffer.isNotEmpty) {
    words.add(buffer.toString());
  }

  // Capitalize first letter of each word
  return words.map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join();
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
    return parseXmlElement(rootElement);
  } catch (e) {
    throw FormatException('Failed to parse XML: $e');
  }
}

/// Recursively builds XML elements from a JSON value.
@visibleForTesting
void buildXmlElement(
  XmlBuilder builder,
  dynamic value, {
  bool includeNulls = false,
  bool usePascalCase = false,
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
      final elementName = usePascalCase ? convertToPascalCase(key) : key;
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
              usePascalCase: usePascalCase,
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
            usePascalCase: usePascalCase,
          );
        });
      }
    });
  } else if (value is List) {
    // This case handles lists that are direct values (shouldn't happen in normal flow)
    // but we handle it for completeness
    final itemName = usePascalCase ? 'Item' : 'item';
    for (final item in value) {
      if (item == null && !includeNulls) {
        continue;
      }
      builder.element(itemName, nest: () {
        buildXmlElement(
          builder,
          item,
          includeNulls: includeNulls,
          usePascalCase: usePascalCase,
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
    final text = textChildren.map((e) => e.value).join('');
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
    final text = textChildren.map((e) => e.value.trim()).where((t) => t.isNotEmpty).join(' ');
    if (text.isNotEmpty) {
      result['_text'] = text;
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
