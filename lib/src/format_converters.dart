import 'dart:convert';

import 'package:yaml/yaml.dart' as yaml;

import 'xml_converter.dart';

/// Converts JSON to YAML string.
///
/// [json] - The JSON map to convert
///
/// Returns a YAML string representation of the JSON map.
String jsonToYaml(Map<String, dynamic> json) {
  return _mapToYaml(json, 0);
}

/// Converts JSON to Markdown string with YAML frontmatter.
///
/// [json] - The JSON map to convert
/// [metaData] - Optional metadata to include as YAML frontmatter
///
/// Returns a Markdown string with optional YAML frontmatter and JSON content.
/// Format:
/// ```
/// ---
/// key: value
/// ---
/// {json content}
/// ```
String jsonToMarkdown(Map<String, dynamic> json, {Map<String, dynamic>? metaData}) {
  final buffer = StringBuffer();

  // Add frontmatter if metadata is provided
  if (metaData != null && metaData.isNotEmpty) {
    buffer.writeln('---');
    buffer.write(jsonToYaml(metaData));
    buffer.writeln('---');
    buffer.writeln();
  }

  // Add JSON content as the body
  buffer.write(_jsonEncode(json));

  return buffer.toString();
}

/// Encodes a JSON map to a formatted JSON string.
String _jsonEncode(Map<String, dynamic> json) {
  return _formatJson(json, 0);
}

/// Formats JSON with proper indentation.
String _formatJson(dynamic value, int indent) {
  final indentStr = '  ' * indent;
  final nextIndent = '  ' * (indent + 1);

  if (value == null) {
    return 'null';
  } else if (value is String) {
    return '"${value.replaceAll('"', '\\"').replaceAll('\n', '\\n')}"';
  } else if (value is num || value is bool) {
    return value.toString();
  } else if (value is List) {
    if (value.isEmpty) return '[]';
    final items = value.map((e) => '$nextIndent${_formatJson(e, indent + 1)}').join(',\n');
    return '[\n$items\n$indentStr]';
  } else if (value is Map<String, dynamic>) {
    if (value.isEmpty) return '{}';
    final entries = value.entries.map((e) => '$nextIndent"${e.key}": ${_formatJson(e.value, indent + 1)}').join(',\n');
    return '{\n$entries\n$indentStr}';
  }
  return value.toString();
}

/// Converts YAML string to JSON map.
///
/// [yamlString] - The YAML string to parse
///
/// Returns a Map<String, dynamic> representation of the YAML.
/// Throws [FormatException] if the YAML is invalid.
Map<String, dynamic> yamlToJson(String yamlString) {
  try {
    final doc = yaml.loadYaml(yamlString);
    return _yamlToMap(doc);
  } catch (e) {
    throw FormatException('Failed to parse YAML: $e');
  }
}

/// Converts YAML string to Markdown string.
///
/// [yamlString] - The YAML string to convert
///
/// Returns a Markdown string representation of the YAML.
String yamlToMarkdown(String yamlString) {
  final json = yamlToJson(yamlString);
  return jsonToMarkdown(json);
}

/// Converts YAML string to XML string.
///
/// [yamlString] - The YAML string to convert
/// [rootElementName] - Optional root element name
/// [includeNulls] - Whether to include null values
/// [prettyPrint] - Whether to format XML with indentation
///
/// Returns an XML string representation of the YAML.
String yamlToXml(
  String yamlString, {
  String? rootElementName,
  bool includeNulls = false,
  bool prettyPrint = true,
}) {
  final json = yamlToJson(yamlString);
  return mapToXml(
    json,
    rootElementName: rootElementName,
    includeNulls: includeNulls,
    prettyPrint: prettyPrint,
  );
}

/// Converts Markdown string with optional YAML frontmatter to JSON map.
///
/// Parses Markdown with YAML frontmatter format:
/// ```
/// ---
/// title: My Title
/// description: A description
/// ---
/// {"key": "value"}
/// ```
///
/// Returns a Map containing:
/// - All frontmatter fields (if present)
/// - 'body' key containing the parsed JSON content (if valid JSON)
/// - 'body' key containing the raw string content (if not valid JSON)
///
/// [markdown] - The Markdown string to parse
///
/// Returns a Map<String, dynamic> representation of the Markdown.
Map<String, dynamic> markdownToJson(String markdown) {
  final result = <String, dynamic>{};

  final trimmed = markdown.trim();
  String body = trimmed;

  // Check for YAML frontmatter (starts with ---)
  if (trimmed.startsWith('---')) {
    final endIndex = trimmed.indexOf('---', 3);
    if (endIndex != -1) {
      // Extract frontmatter YAML
      final frontmatterYaml = trimmed.substring(3, endIndex).trim();
      if (frontmatterYaml.isNotEmpty) {
        try {
          final frontmatter = yamlToJson(frontmatterYaml);
          result.addAll(frontmatter);
        } catch (_) {
          // Ignore frontmatter parsing errors
        }
      }
      // Extract body (everything after the closing ---)
      body = trimmed.substring(endIndex + 3).trim();
    }
  }

  // Parse body as JSON if possible, otherwise store as string
  if (body.isNotEmpty) {
    try {
      final jsonBody = jsonDecode(body);
      if (jsonBody is Map<String, dynamic>) {
        result['body'] = jsonBody;
      } else {
        result['body'] = jsonBody;
      }
    } catch (_) {
      // Not valid JSON, store as string
      result['body'] = body;
    }
  }

  return result;
}

/// Converts Markdown string to YAML string.
///
/// [markdown] - The Markdown string to convert
///
/// Returns a YAML string representation of the Markdown.
String markdownToYaml(String markdown) {
  final json = markdownToJson(markdown);
  return jsonToYaml(json);
}

/// Converts Markdown string to XML string.
///
/// [markdown] - The Markdown string to convert
/// [rootElementName] - Optional root element name
/// [includeNulls] - Whether to include null values
/// [prettyPrint] - Whether to format XML with indentation
///
/// Returns an XML string representation of the Markdown.
String markdownToXml(
  String markdown, {
  String? rootElementName,
  bool includeNulls = false,
  bool prettyPrint = true,
}) {
  final json = markdownToJson(markdown);
  return mapToXml(
    json,
    rootElementName: rootElementName,
    includeNulls: includeNulls,
    prettyPrint: prettyPrint,
  );
}

/// Converts XML string to JSON map.
///
/// This is a convenience function that uses the existing xmlToMap function.
///
/// [xml] - The XML string to convert
///
/// Returns a Map<String, dynamic> representation of the XML.
Map<String, dynamic> xmlToJson(String xml) {
  return xmlToMap(xml);
}

/// Converts XML string to YAML string.
///
/// [xml] - The XML string to convert
///
/// Returns a YAML string representation of the XML.
String xmlToYaml(String xml) {
  final json = xmlToMap(xml);
  return jsonToYaml(json);
}

/// Converts XML string to Markdown string.
///
/// [xml] - The XML string to convert
///
/// Returns a Markdown string representation of the XML.
String xmlToMarkdown(String xml) {
  final json = xmlToMap(xml);
  return jsonToMarkdown(json);
}

// Private helper functions

/// Recursively converts a Map to YAML string with indentation.
String _mapToYaml(Map<String, dynamic> map, int indent) {
  final buffer = StringBuffer();
  final indentStr = '  ' * indent;
  
  map.forEach((key, value) {
    if (value == null) {
      buffer.writeln('$indentStr$key: null');
    } else if (value is Map<String, dynamic>) {
      buffer.writeln('$indentStr$key:');
      buffer.write(_mapToYaml(value, indent + 1));
    } else if (value is List) {
      buffer.writeln('$indentStr$key:');
      for (final item in value) {
        if (item is Map<String, dynamic>) {
          buffer.writeln('$indentStr  -');
          buffer.write(_mapToYaml(item, indent + 2));
        } else {
          buffer.writeln('$indentStr  - ${_yamlValueToString(item)}');
        }
      }
    } else {
      buffer.writeln('$indentStr$key: ${_yamlValueToString(value)}');
    }
  });
  
  return buffer.toString();
}

/// Converts a value to its YAML string representation.
String _yamlValueToString(dynamic value) {
  if (value is String) {
    // Escape strings if needed
    if (value.contains(':') || value.contains('\n') || value.startsWith(' ')) {
      return '"${value.replaceAll('"', '\\"')}"';
    }
    return value;
  } else if (value is bool) {
    return value.toString();
  } else if (value is num) {
    return value.toString();
  } else {
    return value.toString();
  }
}

/// Recursively converts a YAML document to a Map.
dynamic _yamlToMap(dynamic yamlDoc) {
  if (yamlDoc is Map) {
    final result = <String, dynamic>{};
    yamlDoc.forEach((key, value) {
      final keyStr = key.toString();
      result[keyStr] = _yamlToMap(value);
    });
    return result;
  } else if (yamlDoc is List) {
    return yamlDoc.map((e) => _yamlToMap(e)).toList();
  } else {
    return yamlDoc;
  }
}
