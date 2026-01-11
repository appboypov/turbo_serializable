import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart' as yaml;

import '../constants/turbo_constants.dart';
import 'xml_converter.dart';

/// Converts JSON to YAML string.
///
/// [json] - The JSON map to convert
/// [metaData] - Optional metadata to include under `_meta` key
///
/// Returns a YAML string representation of the JSON map.
String jsonToYaml(
  Map<String, dynamic> json, {
  Map<String, dynamic>? metaData,
}) {
  if (metaData != null && metaData.isNotEmpty) {
    final withMeta = <String, dynamic>{TurboConstants.metaKey: metaData, ...json};
    return convertMapToYaml(withMeta, 0);
  }
  return convertMapToYaml(json, 0);
}

/// Converts JSON to Markdown string with headers for keys.
///
/// [json] - The JSON map to convert
/// [metaData] - Optional metadata to include as YAML frontmatter
///
/// Returns a Markdown string with optional YAML frontmatter and header-based content.
/// Keys become headers (## level 2, ### level 3, #### level 4, **bold** for deeper).
/// Keys are converted to Title Case.
///
/// Format:
/// ```
/// ---
/// key: value
/// ---
/// ## Key Name
/// value
/// ```
String jsonToMarkdown(
  Map<String, dynamic> json, {
  Map<String, dynamic>? metaData,
}) {
  final buffer = StringBuffer();

  // Add frontmatter if metadata is provided
  if (metaData != null && metaData.isNotEmpty) {
    buffer.writeln(TurboConstants.frontmatterDelimiter);
    buffer.write(convertMapToYaml(metaData, 0));
    buffer.writeln(TurboConstants.frontmatterDelimiter);
  }

  // Add content with headers
  buffer.write(convertMapToMarkdownHeaders(json, TurboConstants.markdownHeaderLevel2));

  return buffer.toString().trimRight();
}

/// Encodes a JSON map to a formatted JSON string.
@visibleForTesting
String jsonEncodeFormatted(Map<String, dynamic> json) {
  return formatJsonValue(json, 0);
}

/// Formats JSON with proper indentation.
@visibleForTesting
String formatJsonValue(dynamic value, int indent) {
  final indentStr = TurboConstants.indentSpaces * indent;
  final nextIndent = TurboConstants.indentSpaces * (indent + 1);

  if (value == null) {
    return 'null';
  } else if (value is String) {
    return '"${value.replaceAll('"', '\\"').replaceAll('\n', '\\n')}"';
  } else if (value is num || value is bool) {
    return value.toString();
  } else if (value is List) {
    if (value.isEmpty) return '[]';
    final items = value.map((e) => '$nextIndent${formatJsonValue(e, indent + 1)}').join(',\n');
    return '[\n$items\n$indentStr]';
  } else if (value is Map<String, dynamic>) {
    if (value.isEmpty) return '{}';
    final entries = value.entries.map((e) => '$nextIndent"${e.key}": ${formatJsonValue(e.value, indent + 1)}').join(',\n');
    return '{\n$entries\n$indentStr}';
  }
  return value.toString();
}

/// Converts YAML string to JSON map.
///
/// [yamlString] - The YAML string to parse
///
/// Returns a `Map<String, dynamic>` representation of the YAML.
/// Throws [FormatException] if the YAML is invalid.
Map<String, dynamic> yamlToJson(String yamlString) {
  try {
    final doc = yaml.loadYaml(yamlString);
    return convertYamlToMap(doc);
  } catch (e) {
    throw FormatException(TurboConstants.failedToParseYaml(e));
  }
}

/// Converts YAML string to Markdown string.
///
/// [yamlString] - The YAML string to convert
/// [metaData] - Optional metadata to include as YAML frontmatter
///
/// Returns a Markdown string representation of the YAML.
String yamlToMarkdown(
  String yamlString, {
  Map<String, dynamic>? metaData,
}) {
  final json = yamlToJson(yamlString);
  return jsonToMarkdown(json, metaData: metaData);
}

/// Converts YAML string to XML string.
///
/// [yamlString] - The YAML string to convert
/// [rootElementName] - Optional root element name
/// [includeNulls] - Whether to include null values
/// [prettyPrint] - Whether to format XML with indentation
/// [usePascalCase] - Whether to convert element names to PascalCase
/// [metaData] - Optional metadata to include as `_meta` element
///
/// Returns an XML string representation of the YAML.
String yamlToXml(
  String yamlString, {
  String? rootElementName,
  bool includeNulls = false,
  bool prettyPrint = true,
  bool usePascalCase = false,
  Map<String, dynamic>? metaData,
}) {
  final json = yamlToJson(yamlString);
  return mapToXml(
    json,
    rootElementName: rootElementName,
    includeNulls: includeNulls,
    prettyPrint: prettyPrint,
    usePascalCase: usePascalCase,
    metaData: metaData,
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
/// Returns a `Map<String, dynamic>` representation of the Markdown.
Map<String, dynamic> markdownToJson(String markdown) {
  final result = <String, dynamic>{};

  final trimmed = markdown.trim();
  String body = trimmed;

  // Check for YAML frontmatter (starts with ---)
  if (trimmed.startsWith(TurboConstants.frontmatterDelimiter)) {
    final endIndex = trimmed.indexOf(TurboConstants.frontmatterDelimiter, 3);
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
        result[TurboConstants.bodyKey] = jsonBody;
      } else {
        result[TurboConstants.bodyKey] = jsonBody;
      }
    } catch (_) {
      // Not valid JSON, store as string
      result[TurboConstants.bodyKey] = body;
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
/// [usePascalCase] - Whether to convert element names to PascalCase
///
/// Returns an XML string representation of the Markdown.
String markdownToXml(
  String markdown, {
  String? rootElementName,
  bool includeNulls = false,
  bool prettyPrint = true,
  bool usePascalCase = false,
}) {
  final json = markdownToJson(markdown);
  return mapToXml(
    json,
    rootElementName: rootElementName,
    includeNulls: includeNulls,
    prettyPrint: prettyPrint,
    usePascalCase: usePascalCase,
  );
}

/// Converts XML string to JSON map.
///
/// This is a convenience function that uses the existing xmlToMap function.
///
/// [xml] - The XML string to convert
///
/// Returns a `Map<String, dynamic>` representation of the XML.
Map<String, dynamic> xmlToJson(String xml) {
  return xmlToMap(xml);
}

/// Converts XML string to YAML string.
///
/// [xml] - The XML string to convert
/// [metaData] - Optional metadata to include under `_meta` key
///
/// Returns a YAML string representation of the XML.
String xmlToYaml(
  String xml, {
  Map<String, dynamic>? metaData,
}) {
  final json = xmlToMap(xml);
  return jsonToYaml(json, metaData: metaData);
}

/// Converts XML string to Markdown string.
///
/// [xml] - The XML string to convert
/// [metaData] - Optional metadata to include as YAML frontmatter
///
/// Returns a Markdown string representation of the XML.
String xmlToMarkdown(
  String xml, {
  Map<String, dynamic>? metaData,
}) {
  final json = xmlToMap(xml);
  return jsonToMarkdown(json, metaData: metaData);
}

// Helper functions exposed for testing

/// Converts a string from various casings to Title Case with spaces.
///
/// Handles camelCase, snake_case, kebab-case, and PascalCase.
/// Example: 'userName' → 'User Name', 'first_name' → 'First Name'
@visibleForTesting
String convertToTitleCase(String input) {
  if (input.isEmpty) return input;

  // Split on underscores, hyphens, and before uppercase letters
  final words = <String>[];
  final buffer = StringBuffer();

  for (var i = 0; i < input.length; i++) {
    final char = input[i];

    if (char == '_' || char == '-') {
      if (buffer.isNotEmpty) {
        words.add(buffer.toString());
        buffer.clear();
      }
    } else if (char.toUpperCase() == char &&
        char.toLowerCase() != char &&
        buffer.isNotEmpty) {
      // Uppercase letter - start new word
      words.add(buffer.toString());
      buffer.clear();
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
  }).join(' ');
}

/// Converts a Map to Markdown with headers for keys.
///
/// [map] - The map to convert
/// [level] - The header level (2 = ##, 3 = ###, 4 = ####, 5+ = bold)
@visibleForTesting
String convertMapToMarkdownHeaders(Map<String, dynamic> map, int level) {
  final buffer = StringBuffer();

  map.forEach((key, value) {
    final titleKey = convertToTitleCase(key);

    // Write header or bold based on level
    if (level <= TurboConstants.markdownHeaderLevel4) {
      buffer.writeln('${'#' * level} $titleKey');
    } else {
      buffer.writeln('**$titleKey**');
    }

    if (value == null) {
      buffer.writeln();
    } else if (value is Map<String, dynamic>) {
      buffer.writeln();
      buffer.write(convertMapToMarkdownHeaders(value, level + 1));
    } else if (value is List) {
      if (value.isEmpty) {
        buffer.writeln();
      } else if (value.first is Map<String, dynamic>) {
        // List of objects - flatten with repeated headers
        buffer.writeln();
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            buffer.write(convertMapToMarkdownHeaders(item, level + 1));
          } else {
            buffer.writeln('- $item');
          }
        }
      } else {
        // List of primitives - markdown list
        for (final item in value) {
          buffer.writeln('- $item');
        }
        buffer.writeln();
      }
    } else {
      buffer.writeln(value);
      buffer.writeln();
    }
  });

  return buffer.toString();
}

/// Recursively converts a Map to YAML string with indentation.
@visibleForTesting
String convertMapToYaml(Map<String, dynamic> map, int indent) {
  final buffer = StringBuffer();
  final indentStr = TurboConstants.indentSpaces * indent;

  map.forEach((key, value) {
    if (value == null) {
      buffer.writeln('$indentStr$key: null');
    } else if (value is Map<String, dynamic>) {
      buffer.writeln('$indentStr$key:');
      buffer.write(convertMapToYaml(value, indent + 1));
    } else if (value is List) {
      buffer.writeln('$indentStr$key:');
      for (final item in value) {
        if (item is Map<String, dynamic>) {
          buffer.writeln('$indentStr  -');
          buffer.write(convertMapToYaml(item, indent + 2));
        } else {
          buffer.writeln('$indentStr  - ${convertValueToYamlString(item)}');
        }
      }
    } else {
      buffer.writeln('$indentStr$key: ${convertValueToYamlString(value)}');
    }
  });

  return buffer.toString();
}

/// Converts a value to its YAML string representation.
@visibleForTesting
String convertValueToYamlString(dynamic value) {
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
@visibleForTesting
dynamic convertYamlToMap(dynamic yamlDoc) {
  if (yamlDoc is Map) {
    final result = <String, dynamic>{};
    yamlDoc.forEach((key, value) {
      final keyStr = key.toString();
      result[keyStr] = convertYamlToMap(value);
    });
    return result;
  } else if (yamlDoc is List) {
    return yamlDoc.map((e) => convertYamlToMap(e)).toList();
  } else {
    return yamlDoc;
  }
}
