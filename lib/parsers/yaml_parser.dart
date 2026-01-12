import 'package:yaml/yaml.dart';

import 'package:turbo_serializable/constants/turbo_constants.dart';
import 'package:turbo_serializable/models/key_metadata.dart';
import 'package:turbo_serializable/models/layout_aware_parse_result.dart';
import 'package:turbo_serializable/models/yaml_meta.dart';

/// Parser for extracting layout metadata from YAML documents.
///
/// Parses YAML content and extracts both data and layout metadata
/// for 100% round-trip fidelity during format conversions.
class YamlLayoutParser {
  /// Creates a [YamlLayoutParser] instance.
  const YamlLayoutParser();

  /// Parses YAML content with layout metadata extraction.
  ///
  /// Returns a [LayoutAwareParseResult] containing both the parsed data map
  /// and key-level metadata for preserving layout information.
  ///
  /// [yaml] - The YAML string to parse
  LayoutAwareParseResult parse(String yaml) {
    if (yaml.isEmpty) {
      return const LayoutAwareParseResult(data: {});
    }

    try {
      // Check for multi-document YAML
      final documents = _parseMultiDocument(yaml);
      if (documents.length > 1) {
        return _parseMultipleDocuments(yaml, documents);
      }

      // Single document parsing
      final doc = loadYaml(yaml);
      if (doc == null) {
        return const LayoutAwareParseResult(data: {});
      }

      // Get the raw YAML node for metadata extraction
      final yamlDoc = loadYamlDocument(yaml);

      final result = _parseNode(yamlDoc.contents, yaml);

      return LayoutAwareParseResult(
        data: result.data is Map<String, dynamic>
            ? result.data as Map<String, dynamic>
            : {'_value': result.data},
        keyMeta: result.keyMeta.isEmpty ? null : result.keyMeta,
      );
    } catch (e) {
      throw FormatException(TurboConstants.failedToParseYaml(e));
    }
  }

  /// Parses YAML content with multiple documents.
  LayoutAwareParseResult _parseMultipleDocuments(
    String yaml,
    List<YamlDocument> documents,
  ) {
    final data = <String, dynamic>{};
    final keyMeta = <String, dynamic>{};

    for (var i = 0; i < documents.length; i++) {
      final doc = documents[i];
      final result = _parseNode(doc.contents, yaml);

      final docKey = '_document_$i';
      data[docKey] = result.data;

      if (result.keyMeta.isNotEmpty) {
        keyMeta[docKey] = result.keyMeta;
      }
    }

    // Store document metadata
    keyMeta['_document'] = KeyMetadata(
      yamlMeta: YamlMeta(
        comment: 'Multi-document YAML with ${documents.length} documents',
      ),
    ).toJson();

    return LayoutAwareParseResult(
      data: data,
      keyMeta: keyMeta.isEmpty ? null : keyMeta,
    );
  }

  /// Parses multiple YAML documents from a string.
  List<YamlDocument> _parseMultiDocument(String yaml) {
    final documents = <YamlDocument>[];

    try {
      final docs = loadYamlDocuments(yaml);
      for (final doc in docs) {
        documents.add(doc);
      }
    } catch (_) {
      // Fall back to single document parsing
      try {
        documents.add(loadYamlDocument(yaml));
      } catch (_) {
        // Unable to parse
      }
    }

    return documents;
  }

  /// Parses a YAML node recursively, extracting data and metadata.
  _NodeParseResult _parseNode(YamlNode node, String originalYaml) {
    if (node is YamlMap) {
      return _parseMap(node, originalYaml);
    } else if (node is YamlList) {
      return _parseList(node, originalYaml);
    } else if (node is YamlScalar) {
      return _parseScalar(node, originalYaml);
    }

    // Fallback for unknown node types
    return _NodeParseResult(data: node.value, keyMeta: {});
  }

  /// Parses a YAML map node.
  _NodeParseResult _parseMap(YamlMap node, String originalYaml) {
    final data = <String, dynamic>{};
    final keyMeta = <String, dynamic>{};

    for (final entry in node.nodes.entries) {
      final keyNode = entry.key as YamlNode;
      final valueNode = entry.value;

      final keyStr = keyNode.value.toString();
      final childResult = _parseNode(valueNode, originalYaml);

      data[keyStr] = childResult.data;

      // Detect if value uses flow style
      final isFlowStyle = _isFlowStyleValue(valueNode, originalYaml);

      // Extract anchor from the line containing this key-value pair
      final anchor = _extractAnchorFromLine(keyNode, originalYaml);

      // Build metadata for this key
      final metadata = _buildKeyMetadata(
        keyNode: keyNode,
        valueNode: valueNode,
        originalYaml: originalYaml,
        childMeta: childResult.keyMeta.isNotEmpty ? childResult.keyMeta : null,
        isFlowStyle: isFlowStyle,
        anchor: anchor,
      );

      if (metadata != null) {
        keyMeta[keyStr] = metadata.toJson();
      }
    }

    return _NodeParseResult(data: data, keyMeta: keyMeta);
  }

  /// Parses a YAML list node.
  _NodeParseResult _parseList(YamlList node, String originalYaml) {
    final data = <dynamic>[];
    final keyMeta = <String, dynamic>{};

    // Detect if this list uses flow style
    final isFlowStyle = _isFlowStyleList(node, originalYaml);

    for (var i = 0; i < node.nodes.length; i++) {
      final itemNode = node.nodes[i];
      final childResult = _parseNode(itemNode, originalYaml);

      data.add(childResult.data);

      // Build metadata for list items
      if (childResult.keyMeta.isNotEmpty ||
          _hasNodeMetadata(itemNode) ||
          isFlowStyle) {
        final itemMeta = _buildListItemMetadata(
          node: itemNode,
          originalYaml: originalYaml,
          childMeta:
              childResult.keyMeta.isNotEmpty ? childResult.keyMeta : null,
          isFlowStyle: isFlowStyle,
        );
        if (itemMeta != null) {
          keyMeta['$i'] = itemMeta.toJson();
        }
      }
    }

    return _NodeParseResult(data: data, keyMeta: keyMeta);
  }

  /// Parses a YAML scalar node.
  _NodeParseResult _parseScalar(YamlScalar node, String originalYaml) {
    final keyMeta = <String, dynamic>{};

    // Detect scalar style
    final scalarStyle = _detectScalarStyle(node, originalYaml);

    // Check for anchor
    final anchor = _extractAnchor(node, originalYaml);

    // Check for alias
    final alias = _detectAlias(node, originalYaml);

    // Check for comment
    final comment = _extractComment(node, originalYaml);

    if (scalarStyle != null ||
        anchor != null ||
        alias != null ||
        comment != null) {
      final metadata = KeyMetadata(
        yamlMeta: YamlMeta(
          anchor: anchor,
          alias: alias,
          comment: comment,
          scalarStyle: scalarStyle,
        ),
      );
      keyMeta['_scalar'] = metadata.toJson();
    }

    return _NodeParseResult(data: node.value, keyMeta: keyMeta);
  }

  /// Builds metadata for a map key-value pair.
  KeyMetadata? _buildKeyMetadata({
    required YamlNode keyNode,
    required YamlNode valueNode,
    required String originalYaml,
    Map<String, dynamic>? childMeta,
    bool isFlowStyle = false,
    String? anchor,
  }) {
    final alias = _detectAlias(valueNode, originalYaml);
    final comment = _extractComment(keyNode, originalYaml);
    final scalarStyle = valueNode is YamlScalar
        ? _detectScalarStyle(valueNode, originalYaml)
        : null;

    final style = isFlowStyle ? 'flow' : 'block';

    // Only create metadata if there's something to store
    if (anchor == null &&
        alias == null &&
        comment == null &&
        scalarStyle == null &&
        !isFlowStyle &&
        childMeta == null) {
      return null;
    }

    return KeyMetadata(
      yamlMeta: YamlMeta(
        anchor: anchor,
        alias: alias,
        comment: comment,
        style: style,
        scalarStyle: scalarStyle,
      ),
      children: childMeta?.map((key, value) => MapEntry(
            key,
            value is Map<String, dynamic>
                ? KeyMetadata.fromJson(value)
                : const KeyMetadata(),
          )),
    );
  }

  /// Builds metadata for a list item.
  KeyMetadata? _buildListItemMetadata({
    required YamlNode node,
    required String originalYaml,
    Map<String, dynamic>? childMeta,
    bool isFlowStyle = false,
  }) {
    final anchor = _extractAnchor(node, originalYaml);
    final alias = _detectAlias(node, originalYaml);
    final comment = _extractComment(node, originalYaml);
    final scalarStyle =
        node is YamlScalar ? _detectScalarStyle(node, originalYaml) : null;

    final style = isFlowStyle ? 'flow' : 'block';

    // Only create metadata if there's something to store
    if (anchor == null &&
        alias == null &&
        comment == null &&
        scalarStyle == null &&
        !isFlowStyle &&
        childMeta == null) {
      return null;
    }

    return KeyMetadata(
      yamlMeta: YamlMeta(
        anchor: anchor,
        alias: alias,
        comment: comment,
        style: style,
        scalarStyle: scalarStyle,
      ),
      children: childMeta?.map((key, value) => MapEntry(
            key,
            value is Map<String, dynamic>
                ? KeyMetadata.fromJson(value)
                : const KeyMetadata(),
          )),
    );
  }

  /// Checks if a YAML value uses flow style (inline braces or brackets).
  bool _isFlowStyleValue(YamlNode node, String originalYaml) {
    if (node is YamlMap) {
      return _isFlowStyleMap(node, originalYaml);
    } else if (node is YamlList) {
      return _isFlowStyleList(node, originalYaml);
    }
    return false;
  }

  /// Checks if a YAML map uses flow style (inline braces).
  bool _isFlowStyleMap(YamlMap node, String originalYaml) {
    final span = node.span;
    if (span.start.offset >= originalYaml.length) return false;

    // Get the character at the span start
    final startChar = originalYaml[span.start.offset];

    // Flow style maps start with {
    return startChar == '{';
  }

  /// Checks if a YAML list uses flow style (inline brackets).
  bool _isFlowStyleList(YamlList node, String originalYaml) {
    final span = node.span;
    if (span.start.offset >= originalYaml.length) return false;

    // Get the character at the span start
    final startChar = originalYaml[span.start.offset];

    // Flow style lists start with [
    return startChar == '[';
  }

  /// Detects the scalar style of a YAML scalar node.
  String? _detectScalarStyle(YamlScalar node, String originalYaml) {
    final span = node.span;
    if (span.start.offset >= originalYaml.length) return null;

    // Get the character at the start of the scalar
    final startChar = originalYaml[span.start.offset];

    switch (startChar) {
      case '|':
        return 'literal';
      case '>':
        return 'folded';
      case "'":
        return 'single-quoted';
      case '"':
        return 'double-quoted';
      default:
        return null;
    }
  }

  /// Extracts an anchor from a YAML node if present.
  String? _extractAnchor(YamlNode node, String originalYaml) {
    final span = node.span;
    if (span.start.offset <= 0) return null;

    // Look backwards from the node start to find an anchor
    final beforeNode = originalYaml.substring(
      (span.start.offset - 100).clamp(0, originalYaml.length),
      span.start.offset,
    );

    // Look for & followed by anchor name right before the node
    final anchorMatch = RegExp(r'&(\w+)\s*$').firstMatch(beforeNode);
    if (anchorMatch != null) {
      return anchorMatch.group(1);
    }

    return null;
  }

  /// Extracts an anchor from the line containing a key node.
  String? _extractAnchorFromLine(YamlNode keyNode, String originalYaml) {
    final lines = originalYaml.split('\n');
    final lineNumber = keyNode.span.start.line;

    if (lineNumber < 0 || lineNumber >= lines.length) return null;

    final line = lines[lineNumber];

    // Look for anchor pattern &name after the colon on this line
    final anchorMatch = RegExp(r':\s*&(\w+)').firstMatch(line);
    if (anchorMatch != null) {
      return anchorMatch.group(1);
    }

    return null;
  }

  /// Detects if a node is an alias reference.
  String? _detectAlias(YamlNode node, String originalYaml) {
    final span = node.span;
    if (span.start.offset >= originalYaml.length) return null;

    // Get the content at the node position
    final endOffset = span.end.offset.clamp(0, originalYaml.length);
    final content = originalYaml.substring(span.start.offset, endOffset);

    // Check for alias pattern *name
    final aliasMatch = RegExp(r'^\*(\w+)').firstMatch(content.trim());
    if (aliasMatch != null) {
      return aliasMatch.group(1);
    }

    return null;
  }

  /// Extracts a comment associated with a YAML node.
  String? _extractComment(YamlNode node, String originalYaml) {
    final lines = originalYaml.split('\n');
    final nodeLine = node.span.start.line;

    // Look for comment on the same line (inline comment)
    if (nodeLine >= 0 && nodeLine < lines.length) {
      final line = lines[nodeLine];
      final commentIndex = line.indexOf('#');
      if (commentIndex != -1) {
        // Make sure it's not inside a string
        final beforeHash = line.substring(0, commentIndex);
        final singleQuotes = "'".allMatches(beforeHash).length;
        final doubleQuotes = '"'.allMatches(beforeHash).length;

        // If quotes are balanced, this is a real comment
        if (singleQuotes % 2 == 0 && doubleQuotes % 2 == 0) {
          return line.substring(commentIndex + 1).trim();
        }
      }
    }

    // Look for comment on the line before
    if (nodeLine > 0 && nodeLine - 1 < lines.length) {
      final prevLine = lines[nodeLine - 1].trim();
      if (prevLine.startsWith('#')) {
        return prevLine.substring(1).trim();
      }
    }

    return null;
  }

  /// Checks if a node has any metadata worth storing.
  bool _hasNodeMetadata(YamlNode node) {
    return node is YamlScalar;
  }
}

/// Internal result class for node parsing.
class _NodeParseResult {
  const _NodeParseResult({
    required this.data,
    required this.keyMeta,
  });

  final dynamic data;
  final Map<String, dynamic> keyMeta;
}
