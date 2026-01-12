import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart' as yaml;

import 'package:turbo_serializable/constants/turbo_constants.dart';
import 'package:turbo_serializable/enums/case_style.dart';
import 'package:turbo_serializable/converters/xml_converter.dart'
    show jsonToXml, xmlToMap;
import 'package:turbo_serializable/generators/markdown_generator.dart';
import 'package:turbo_serializable/generators/yaml_generator.dart';
import 'package:turbo_serializable/models/layout_aware_parse_result.dart';
import 'package:turbo_serializable/parsers/markdown_parser.dart';
import 'package:turbo_serializable/parsers/xml_parser.dart';
import 'package:turbo_serializable/parsers/yaml_parser.dart';

/// Converts JSON to YAML string.
///
/// [json] - The JSON map to convert
/// [metaData] - Optional metadata to include under `_meta` key
/// [keyMeta] - Optional key-level metadata for layout preservation
/// [includeNulls] - Whether to include null values (default: false)
/// [prettyPrint] - Whether to format YAML with indentation (default: true)
/// [preserveLayout] - Whether to use key metadata for layout preservation
///   (default: true). When true and [keyMeta] is provided, uses the
///   [YamlLayoutGenerator] for byte-for-byte fidelity.
///
/// Returns a YAML string representation of the JSON map.
String jsonToYaml(
  Map<String, dynamic> json, {
  Map<String, dynamic>? metaData,
  Map<String, dynamic>? keyMeta,
  bool includeNulls = false,
  bool prettyPrint = true,
  bool preserveLayout = true,
}) {
  Map<String, dynamic> processedJson = json;
  if (!includeNulls) {
    processedJson = filterNullsFromMap(json);
  }

  // Use layout generator when metadata is available and layout preservation is enabled
  if (preserveLayout && keyMeta != null) {
    const generator = YamlLayoutGenerator();
    return generator.generate(
      processedJson,
      keyMeta: keyMeta,
      metaData: metaData,
    );
  }

  if (metaData != null && metaData.isNotEmpty) {
    final withMeta = <String, dynamic>{
      TurboConstants.metaKey: metaData,
      ...processedJson
    };
    return convertMapToYaml(withMeta, 0, prettyPrint: prettyPrint);
  }
  return convertMapToYaml(processedJson, 0, prettyPrint: prettyPrint);
}

/// Converts JSON to Markdown string with headers for keys.
///
/// [json] - The JSON map to convert
/// [metaData] - Optional metadata to include as YAML frontmatter
/// [keyMeta] - Optional key-level metadata for layout preservation
/// [includeNulls] - Whether to include null values (default: false)
/// [prettyPrint] - Whether to format Markdown with spacing (default: true)
/// [preserveLayout] - Whether to use key metadata for layout preservation
///   (default: true). When true and [keyMeta] is provided, uses the
///   [MarkdownLayoutGenerator] for byte-for-byte fidelity.
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
  Map<String, dynamic>? keyMeta,
  bool includeNulls = false,
  bool prettyPrint = true,
  bool preserveLayout = true,
}) {
  Map<String, dynamic> processedJson = json;
  if (!includeNulls) {
    processedJson = filterNullsFromMap(json);
  }

  // Use layout generator when metadata is available and layout preservation is enabled
  if (preserveLayout && keyMeta != null) {
    const generator = MarkdownLayoutGenerator();
    return generator.generate(
      processedJson,
      keyMeta: keyMeta,
      metaData: metaData,
    );
  }

  final buffer = StringBuffer();

  // Add frontmatter if metadata is provided
  if (metaData != null && metaData.isNotEmpty) {
    buffer.writeln(TurboConstants.frontmatterDelimiter);
    buffer.write(convertMapToYaml(metaData, 0));
    buffer.writeln(TurboConstants.frontmatterDelimiter);
  }

  // Add content with headers
  buffer.write(convertMapToMarkdownHeaders(
      processedJson, TurboConstants.markdownHeaderLevel2,
      prettyPrint: prettyPrint));

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
    final items = value
        .map((e) => '$nextIndent${formatJsonValue(e, indent + 1)}')
        .join(',\n');
    return '[\n$items\n$indentStr]';
  } else if (value is Map<String, dynamic>) {
    if (value.isEmpty) return '{}';
    final entries = value.entries
        .map((e) =>
            '$nextIndent"${e.key}": ${formatJsonValue(e.value, indent + 1)}')
        .join(',\n');
    return '{\n$entries\n$indentStr}';
  }
  return value.toString();
}

/// Converts YAML string to JSON map.
///
/// [yamlString] - The YAML string to parse
/// [preserveLayout] - Whether to extract layout metadata for round-trip fidelity
///   (default: false). When true, returns a [LayoutAwareParseResult] containing
///   both data and key-level metadata. When false, returns a plain Map.
///
/// Returns a `Map<String, dynamic>` representation of the YAML when
/// [preserveLayout] is false, or a [LayoutAwareParseResult] when true.
/// Throws [FormatException] if the YAML is invalid.
dynamic yamlToJson(String yamlString, {bool preserveLayout = false}) {
  if (preserveLayout) {
    return _yamlToJsonWithLayout(yamlString);
  }
  return _yamlToJsonBasic(yamlString);
}

/// Basic YAML to JSON conversion without layout preservation.
Map<String, dynamic> _yamlToJsonBasic(String yamlString) {
  try {
    final doc = yaml.loadYaml(yamlString);
    return convertYamlToMap(doc) as Map<String, dynamic>;
  } catch (e) {
    throw FormatException(TurboConstants.failedToParseYaml(e));
  }
}

/// YAML to JSON conversion with layout metadata extraction.
LayoutAwareParseResult _yamlToJsonWithLayout(String yamlString) {
  const parser = YamlLayoutParser();
  return parser.parse(yamlString);
}

/// Converts YAML string to Markdown string.
///
/// [yamlString] - The YAML string to convert
/// [metaData] - Optional metadata to include as YAML frontmatter
/// [includeNulls] - Whether to include null values (default: false)
/// [prettyPrint] - Whether to format Markdown with spacing (default: true)
/// [preserveLayout] - Whether to preserve YAML layout metadata (default: false)
///
/// Returns a Markdown string representation of the YAML.
String yamlToMarkdown(
  String yamlString, {
  Map<String, dynamic>? metaData,
  bool includeNulls = false,
  bool prettyPrint = true,
  bool preserveLayout = false,
}) {
  final result = yamlToJson(yamlString, preserveLayout: preserveLayout);
  final json = preserveLayout
      ? (result as LayoutAwareParseResult).data
      : result as Map<String, dynamic>;
  final keyMeta =
      preserveLayout ? (result as LayoutAwareParseResult).keyMeta : null;
  return jsonToMarkdown(
    json,
    metaData: metaData,
    keyMeta: keyMeta,
    includeNulls: includeNulls,
    prettyPrint: prettyPrint,
    preserveLayout: preserveLayout,
  );
}

/// Converts YAML string to XML string.
///
/// [yamlString] - The YAML string to convert
/// [rootElementName] - Optional root element name
/// [includeNulls] - Whether to include null values
/// [prettyPrint] - Whether to format XML with indentation
/// [caseStyle] - The case style to apply to element names
/// [metaData] - Optional metadata to include as `_meta` element
/// [preserveLayout] - Whether to preserve YAML layout metadata (default: false)
///
/// Returns an XML string representation of the YAML.
String yamlToXml(
  String yamlString, {
  String? rootElementName,
  bool includeNulls = false,
  bool prettyPrint = true,
  CaseStyle caseStyle = CaseStyle.none,
  Map<String, dynamic>? metaData,
  bool preserveLayout = false,
}) {
  final result = yamlToJson(yamlString, preserveLayout: preserveLayout);
  final json = preserveLayout
      ? (result as LayoutAwareParseResult).data
      : result as Map<String, dynamic>;
  final keyMeta =
      preserveLayout ? (result as LayoutAwareParseResult).keyMeta : null;
  return jsonToXml(
    json,
    rootElementName: rootElementName,
    includeNulls: includeNulls,
    prettyPrint: prettyPrint,
    caseStyle: caseStyle,
    metaData: metaData,
    keyMeta: keyMeta,
    preserveLayout: preserveLayout,
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
/// [preserveLayout] - Whether to extract layout metadata for round-trip fidelity
///   (default: false). When true, returns a [LayoutAwareParseResult] containing
///   both data and key-level metadata. When false, returns a plain Map.
///
/// Returns a `Map<String, dynamic>` representation of the Markdown when
/// [preserveLayout] is false, or a [LayoutAwareParseResult] when true.
dynamic markdownToJson(String markdown, {bool preserveLayout = false}) {
  if (preserveLayout) {
    return _markdownToJsonWithLayout(markdown);
  }
  return _markdownToJsonBasic(markdown);
}

/// Basic Markdown to JSON conversion without layout preservation.
Map<String, dynamic> _markdownToJsonBasic(String markdown) {
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
          final frontmatter =
              yamlToJson(frontmatterYaml) as Map<String, dynamic>;
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

/// Markdown to JSON conversion with layout metadata extraction.
LayoutAwareParseResult _markdownToJsonWithLayout(String markdown) {
  const parser = MarkdownLayoutParser();
  return parser.parse(markdown);
}

/// Converts Markdown string to YAML string.
///
/// [markdown] - The Markdown string to convert
/// [metaData] - Optional metadata to include under `_meta` key
/// [includeNulls] - Whether to include null values (default: false)
/// [prettyPrint] - Whether to format YAML with indentation (default: true)
/// [preserveLayout] - Whether to preserve Markdown layout metadata (default: false)
///
/// Returns a YAML string representation of the Markdown.
String markdownToYaml(
  String markdown, {
  Map<String, dynamic>? metaData,
  bool includeNulls = false,
  bool prettyPrint = true,
  bool preserveLayout = false,
}) {
  final result = markdownToJson(markdown, preserveLayout: preserveLayout);
  final json = preserveLayout
      ? (result as LayoutAwareParseResult).data
      : result as Map<String, dynamic>;
  final keyMeta =
      preserveLayout ? (result as LayoutAwareParseResult).keyMeta : null;
  return jsonToYaml(
    json,
    metaData: metaData,
    keyMeta: keyMeta,
    includeNulls: includeNulls,
    prettyPrint: prettyPrint,
    preserveLayout: preserveLayout,
  );
}

/// Converts Markdown string to XML string.
///
/// [markdown] - The Markdown string to convert
/// [rootElementName] - Optional root element name
/// [includeNulls] - Whether to include null values
/// [prettyPrint] - Whether to format XML with indentation
/// [caseStyle] - The case style to apply to element names
/// [metaData] - Optional metadata to include as a `_meta` element
/// [preserveLayout] - Whether to preserve Markdown layout metadata (default: false)
///
/// Returns an XML string representation of the Markdown.
String markdownToXml(
  String markdown, {
  String? rootElementName,
  bool includeNulls = false,
  bool prettyPrint = true,
  CaseStyle caseStyle = CaseStyle.none,
  Map<String, dynamic>? metaData,
  bool preserveLayout = false,
}) {
  final result = markdownToJson(markdown, preserveLayout: preserveLayout);
  final json = preserveLayout
      ? (result as LayoutAwareParseResult).data
      : result as Map<String, dynamic>;
  final keyMeta =
      preserveLayout ? (result as LayoutAwareParseResult).keyMeta : null;
  return jsonToXml(
    json,
    rootElementName: rootElementName,
    includeNulls: includeNulls,
    prettyPrint: prettyPrint,
    caseStyle: caseStyle,
    metaData: metaData,
    keyMeta: keyMeta,
    preserveLayout: preserveLayout,
  );
}

/// Converts XML string to JSON map.
///
/// This is a convenience function that uses the existing xmlToMap function.
///
/// [xml] - The XML string to convert
/// [preserveLayout] - Whether to extract layout metadata for round-trip fidelity
///   (default: false). When true, returns a [LayoutAwareParseResult] containing
///   both data and key-level metadata. When false, returns a plain Map.
///
/// Returns a `Map<String, dynamic>` representation of the XML when
/// [preserveLayout] is false, or a [LayoutAwareParseResult] when true.
dynamic xmlToJson(String xml, {bool preserveLayout = false}) {
  if (preserveLayout) {
    return _xmlToJsonWithLayout(xml);
  }
  return xmlToMap(xml);
}

/// XML to JSON conversion with layout metadata extraction.
LayoutAwareParseResult _xmlToJsonWithLayout(String xml) {
  const parser = XmlLayoutParser();
  return parser.parse(xml);
}

/// Converts XML string to YAML string.
///
/// [xml] - The XML string to convert
/// [metaData] - Optional metadata to include under `_meta` key
/// [includeNulls] - Whether to include null values (default: false)
/// [prettyPrint] - Whether to format YAML with indentation (default: true)
/// [preserveLayout] - Whether to preserve XML layout metadata (default: false)
///
/// Returns a YAML string representation of the XML.
String xmlToYaml(
  String xml, {
  Map<String, dynamic>? metaData,
  bool includeNulls = false,
  bool prettyPrint = true,
  bool preserveLayout = false,
}) {
  final result = xmlToJson(xml, preserveLayout: preserveLayout);
  final json = preserveLayout
      ? (result as LayoutAwareParseResult).data
      : result as Map<String, dynamic>;
  final keyMeta =
      preserveLayout ? (result as LayoutAwareParseResult).keyMeta : null;
  return jsonToYaml(
    json,
    metaData: metaData,
    keyMeta: keyMeta,
    includeNulls: includeNulls,
    prettyPrint: prettyPrint,
    preserveLayout: preserveLayout,
  );
}

/// Converts XML string to Markdown string.
///
/// [xml] - The XML string to convert
/// [metaData] - Optional metadata to include as YAML frontmatter
/// [includeNulls] - Whether to include null values (default: false)
/// [prettyPrint] - Whether to format Markdown with spacing (default: true)
/// [preserveLayout] - Whether to preserve XML layout metadata (default: false)
///
/// Returns a Markdown string representation of the XML.
String xmlToMarkdown(
  String xml, {
  Map<String, dynamic>? metaData,
  bool includeNulls = false,
  bool prettyPrint = true,
  bool preserveLayout = false,
}) {
  final result = xmlToJson(xml, preserveLayout: preserveLayout);
  final json = preserveLayout
      ? (result as LayoutAwareParseResult).data
      : result as Map<String, dynamic>;
  final keyMeta =
      preserveLayout ? (result as LayoutAwareParseResult).keyMeta : null;
  return jsonToMarkdown(
    json,
    metaData: metaData,
    keyMeta: keyMeta,
    includeNulls: includeNulls,
    prettyPrint: prettyPrint,
    preserveLayout: preserveLayout,
  );
}

// Helper functions exposed for testing

/// Recursively filters null values from a map and lists.
///
/// [map] - The map to filter
///
/// Returns a new map with all null values removed recursively.
Map<String, dynamic> filterNullsFromMap(Map<String, dynamic> map) {
  final result = <String, dynamic>{};

  map.forEach((key, value) {
    if (value == null) {
      // Skip null values
      return;
    } else if (value is Map<String, dynamic>) {
      // Always include maps, even if empty after filtering
      result[key] = filterNullsFromMap(value);
    } else if (value is List) {
      final filteredList = <dynamic>[];
      for (final item in value) {
        if (item == null) {
          continue;
        } else if (item is Map<String, dynamic>) {
          // Always include maps, even if empty after filtering
          filteredList.add(filterNullsFromMap(item));
        } else {
          filteredList.add(item);
        }
      }
      // Always include lists, even if empty after filtering
      result[key] = filteredList;
    } else {
      result[key] = value;
    }
  });

  return result;
}

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
/// [prettyPrint] - Whether to add spacing between sections (default: true)
@visibleForTesting
String convertMapToMarkdownHeaders(Map<String, dynamic> map, int level,
    {bool prettyPrint = true}) {
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
      if (prettyPrint) buffer.writeln();
    } else if (value is Map<String, dynamic>) {
      if (prettyPrint) buffer.writeln();
      buffer.write(convertMapToMarkdownHeaders(value, level + 1,
          prettyPrint: prettyPrint));
    } else if (value is List) {
      if (value.isEmpty) {
        if (prettyPrint) buffer.writeln();
      } else if (value.first is Map<String, dynamic>) {
        // List of objects - flatten with repeated headers
        if (prettyPrint) buffer.writeln();
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            buffer.write(convertMapToMarkdownHeaders(item, level + 1,
                prettyPrint: prettyPrint));
          } else {
            buffer.writeln('- $item');
          }
        }
      } else {
        // List of primitives - markdown list
        for (final item in value) {
          buffer.writeln('- $item');
        }
        if (prettyPrint) buffer.writeln();
      }
    } else {
      buffer.writeln(value);
      if (prettyPrint) buffer.writeln();
    }
  });

  return buffer.toString();
}

/// Recursively converts a Map to YAML string with indentation.
///
/// [map] - The map to convert
/// [indent] - The current indentation level
/// [prettyPrint] - Whether to format with indentation (default: true)
@visibleForTesting
String convertMapToYaml(Map<String, dynamic> map, int indent,
    {bool prettyPrint = true}) {
  final buffer = StringBuffer();
  final indentStr = prettyPrint ? (TurboConstants.indentSpaces * indent) : '';
  final separator = prettyPrint ? '\n' : '';

  map.forEach((key, value) {
    if (value == null) {
      buffer.write('$indentStr$key: null$separator');
    } else if (value is Map<String, dynamic>) {
      buffer.write('$indentStr$key:$separator');
      if (prettyPrint) buffer.writeln();
      buffer
          .write(convertMapToYaml(value, indent + 1, prettyPrint: prettyPrint));
    } else if (value is List) {
      buffer.write('$indentStr$key:$separator');
      if (prettyPrint) buffer.writeln();
      for (final item in value) {
        if (item is Map<String, dynamic>) {
          buffer.write('$indentStr  -');
          if (prettyPrint) buffer.writeln();
          buffer.write(
              convertMapToYaml(item, indent + 2, prettyPrint: prettyPrint));
        } else {
          buffer.write(
              '$indentStr  - ${convertValueToYamlString(item)}$separator');
        }
      }
    } else {
      buffer.write(
          '$indentStr$key: ${convertValueToYamlString(value)}$separator');
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
