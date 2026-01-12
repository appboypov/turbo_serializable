import 'package:turbo_serializable/models/key_metadata.dart';

/// Generates YAML output from JSON data using key metadata for layout fidelity.
///
/// Uses extracted metadata from parsing to produce byte-for-byte identical
/// output during round-trip conversions. Supports anchors, aliases, comments,
/// flow/block styles, and scalar presentation styles.
class YamlLayoutGenerator {
  /// Creates a [YamlLayoutGenerator] instance.
  const YamlLayoutGenerator();

  /// Default indentation string (2 spaces).
  static const String _indentUnit = '  ';

  /// Generates YAML from data using key metadata for layout preservation.
  ///
  /// [data] - The JSON data map to convert
  /// [keyMeta] - The key-level metadata for layout information
  /// [metaData] - Optional metadata to include under `_meta` key
  ///
  /// Returns a YAML string with preserved layout from the original document.
  String generate(
    Map<String, dynamic> data, {
    Map<String, dynamic>? keyMeta,
    Map<String, dynamic>? metaData,
  }) {
    final buffer = StringBuffer();

    // Check for multi-document YAML
    final docMeta = keyMeta?['_document'];
    final isMultiDocument = docMeta != null &&
        docMeta is Map<String, dynamic> &&
        docMeta['yamlMeta']?['comment']
                ?.toString()
                .contains('Multi-document') ==
            true;

    if (isMultiDocument) {
      return _generateMultiDocument(data, keyMeta);
    }

    // Add metadata if provided
    Map<String, dynamic> outputData = data;
    if (metaData != null && metaData.isNotEmpty) {
      outputData = <String, dynamic>{
        '_meta': metaData,
        ...data,
      };
    }

    // Generate single document
    _writeMap(buffer, outputData, keyMeta, 0);

    return buffer.toString().trimRight();
  }

  /// Generates multi-document YAML output.
  String _generateMultiDocument(
    Map<String, dynamic> data,
    Map<String, dynamic>? keyMeta,
  ) {
    final buffer = StringBuffer();
    final docKeys = data.keys.where((k) => k.startsWith('_document_')).toList()
      ..sort();

    for (var i = 0; i < docKeys.length; i++) {
      final docKey = docKeys[i];
      final docData = data[docKey];
      final docKeyMeta = keyMeta?[docKey] as Map<String, dynamic>?;

      // Add document start marker
      buffer.writeln('---');

      if (docData is Map<String, dynamic>) {
        _writeMap(buffer, docData, docKeyMeta, 0);
      } else if (docData != null) {
        buffer.writeln(docData);
      }

      // Add document end marker for all but last document
      if (i < docKeys.length - 1) {
        buffer.writeln('...');
      }
    }

    return buffer.toString().trimRight();
  }

  /// Writes a map to the buffer with proper indentation and metadata.
  void _writeMap(
    StringBuffer buffer,
    Map<String, dynamic> map,
    Map<String, dynamic>? keyMeta,
    int indent,
  ) {
    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;
      final meta = _getKeyMetadata(keyMeta, key);
      final yamlMeta = meta?.yamlMeta;

      // Write comment before key if present
      _writeComment(buffer, yamlMeta?.comment, indent, isInline: false);

      // Write the key
      final indentStr = _indentUnit * indent;
      buffer.write('$indentStr$key:');

      // Write anchor if present
      if (yamlMeta?.anchor != null) {
        buffer.write(' &${yamlMeta!.anchor}');
      }

      // Handle alias values
      if (yamlMeta?.alias != null) {
        buffer.writeln(' *${yamlMeta!.alias}');
        continue;
      }

      // Write value based on type and style
      _writeValue(
        buffer,
        value,
        meta,
        keyMeta,
        indent,
      );
    }
  }

  /// Writes a value to the buffer based on its type and metadata.
  void _writeValue(
    StringBuffer buffer,
    dynamic value,
    KeyMetadata? meta,
    Map<String, dynamic>? keyMeta,
    int indent,
  ) {
    final yamlMeta = meta?.yamlMeta;
    final style = yamlMeta?.style ?? 'block';
    final scalarStyle = yamlMeta?.scalarStyle;

    if (value == null) {
      buffer.writeln(' null');
      return;
    }

    if (value is Map<String, dynamic>) {
      _writeMapValue(buffer, value, meta, keyMeta, indent, style);
    } else if (value is List) {
      _writeListValue(buffer, value, meta, keyMeta, indent, style);
    } else {
      _writeScalarValue(buffer, value, scalarStyle, indent);
    }
  }

  /// Writes a map value in block or flow style.
  void _writeMapValue(
    StringBuffer buffer,
    Map<String, dynamic> map,
    KeyMetadata? meta,
    Map<String, dynamic>? keyMeta,
    int indent,
    String style,
  ) {
    // Empty maps always render as flow style
    if (map.isEmpty) {
      buffer.writeln(' {}');
      return;
    }

    if (style == 'flow') {
      buffer.writeln(' ${_mapToFlowStyle(map)}');
    } else {
      buffer.writeln();
      // Use children metadata if available
      final childrenMeta = meta?.children != null
          ? meta!.children!.map((k, v) => MapEntry(k, v.toJson()))
          : <String, dynamic>{};
      _writeMap(buffer, map, childrenMeta, indent + 1);
    }
  }

  /// Writes a list value in block or flow style.
  void _writeListValue(
    StringBuffer buffer,
    List<dynamic> list,
    KeyMetadata? meta,
    Map<String, dynamic>? keyMeta,
    int indent,
    String style,
  ) {
    // Empty lists always render as flow style
    if (list.isEmpty) {
      buffer.writeln(' []');
      return;
    }

    if (style == 'flow') {
      buffer.writeln(' ${_listToFlowStyle(list)}');
    } else {
      buffer.writeln();
      _writeBlockList(buffer, list, meta, keyMeta, indent + 1);
    }
  }

  /// Writes a scalar value with optional style indicator.
  void _writeScalarValue(
    StringBuffer buffer,
    dynamic value,
    String? scalarStyle,
    int indent,
  ) {
    switch (scalarStyle) {
      case 'literal':
        _writeLiteralScalar(buffer, value.toString(), indent);
        break;
      case 'folded':
        _writeFoldedScalar(buffer, value.toString(), indent);
        break;
      case 'single-quoted':
        buffer.writeln(" '$value'");
        break;
      case 'double-quoted':
        buffer.writeln(' "${_escapeDoubleQuoted(value.toString())}"');
        break;
      default:
        final strValue = _formatPlainScalar(value);
        buffer.writeln(' $strValue');
    }
  }

  /// Writes a literal block scalar (|).
  void _writeLiteralScalar(StringBuffer buffer, String value, int indent) {
    buffer.writeln(' |');
    final lines = value.split('\n');
    final indentStr = _indentUnit * (indent + 1);
    for (final line in lines) {
      if (line.isEmpty && lines.last == line) {
        continue; // Skip trailing empty line
      }
      buffer.writeln('$indentStr$line');
    }
  }

  /// Writes a folded block scalar (>).
  void _writeFoldedScalar(StringBuffer buffer, String value, int indent) {
    buffer.writeln(' >');
    final lines = value.split('\n');
    final indentStr = _indentUnit * (indent + 1);
    for (final line in lines) {
      if (line.isEmpty && lines.last == line) {
        continue; // Skip trailing empty line
      }
      buffer.writeln('$indentStr$line');
    }
  }

  /// Writes a block-style list.
  void _writeBlockList(
    StringBuffer buffer,
    List<dynamic> list,
    KeyMetadata? meta,
    Map<String, dynamic>? keyMeta,
    int indent,
  ) {
    final indentStr = _indentUnit * indent;
    final childrenMeta = meta?.children;

    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      final itemMeta = _getListItemMetadata(childrenMeta, i);
      final yamlMeta = itemMeta?.yamlMeta;

      // Write comment before item if present
      _writeComment(buffer, yamlMeta?.comment, indent, isInline: false);

      if (item is Map<String, dynamic>) {
        // Handle anchor for map items
        if (yamlMeta?.anchor != null) {
          buffer.writeln('$indentStr- &${yamlMeta!.anchor}');
        } else {
          buffer.writeln('$indentStr-');
        }

        final itemChildrenMeta = itemMeta?.children != null
            ? itemMeta!.children!.map((k, v) => MapEntry(k, v.toJson()))
            : <String, dynamic>{};
        _writeMap(buffer, item, itemChildrenMeta, indent + 1);
      } else if (item is List) {
        buffer.write('$indentStr-');
        if (yamlMeta?.style == 'flow') {
          buffer.writeln(' ${_listToFlowStyle(item)}');
        } else {
          buffer.writeln();
          _writeBlockList(buffer, item, itemMeta, keyMeta, indent + 1);
        }
      } else {
        // Scalar item
        final scalarStyle = yamlMeta?.scalarStyle;
        buffer.write('$indentStr- ');
        _writeListItemScalar(buffer, item, scalarStyle, indent);
      }
    }
  }

  /// Writes a scalar list item with optional style.
  void _writeListItemScalar(
    StringBuffer buffer,
    dynamic value,
    String? scalarStyle,
    int indent,
  ) {
    switch (scalarStyle) {
      case 'single-quoted':
        buffer.writeln("'$value'");
        break;
      case 'double-quoted':
        buffer.writeln('"${_escapeDoubleQuoted(value.toString())}"');
        break;
      default:
        buffer.writeln(_formatPlainScalar(value));
    }
  }

  /// Converts a map to flow style (inline braces).
  String _mapToFlowStyle(Map<String, dynamic> map) {
    final entries = map.entries.map((e) {
      final value = _valueToFlowStyle(e.value);
      return '${e.key}: $value';
    }).join(', ');
    return '{$entries}';
  }

  /// Converts a list to flow style (inline brackets).
  String _listToFlowStyle(List<dynamic> list) {
    final items = list.map((e) => _valueToFlowStyle(e)).join(', ');
    return '[$items]';
  }

  /// Converts a value to flow style representation.
  String _valueToFlowStyle(dynamic value) {
    if (value == null) {
      return 'null';
    } else if (value is Map<String, dynamic>) {
      return _mapToFlowStyle(value);
    } else if (value is List) {
      return _listToFlowStyle(value);
    } else if (value is String) {
      if (_needsQuoting(value)) {
        return '"${_escapeDoubleQuoted(value)}"';
      }
      return value;
    } else {
      return value.toString();
    }
  }

  /// Formats a plain scalar value for YAML output.
  String _formatPlainScalar(dynamic value) {
    if (value is bool) {
      return value.toString();
    } else if (value is num) {
      return value.toString();
    } else if (value is String) {
      if (_needsQuoting(value)) {
        return '"${_escapeDoubleQuoted(value)}"';
      }
      return value;
    }
    return value.toString();
  }

  /// Checks if a string value needs quoting in YAML.
  bool _needsQuoting(String value) {
    if (value.isEmpty) return true;
    if (value.startsWith(' ') || value.endsWith(' ')) return true;
    if (value.contains(':') || value.contains('#')) return true;
    if (value.contains('\n') || value.contains('\r')) return true;
    if (value.contains('"') || value.contains("'")) return true;

    // Check for YAML special values
    final lower = value.toLowerCase();
    if (lower == 'true' ||
        lower == 'false' ||
        lower == 'null' ||
        lower == 'yes' ||
        lower == 'no' ||
        lower == 'on' ||
        lower == 'off') {
      return true;
    }

    // Check if it looks like a number
    if (num.tryParse(value) != null) {
      return true;
    }

    return false;
  }

  /// Escapes special characters for double-quoted strings.
  String _escapeDoubleQuoted(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }

  /// Writes a comment to the buffer.
  void _writeComment(
    StringBuffer buffer,
    String? comment,
    int indent, {
    required bool isInline,
  }) {
    if (comment == null || comment.isEmpty) return;

    final indentStr = _indentUnit * indent;
    if (isInline) {
      buffer.write(' # $comment');
    } else {
      buffer.writeln('$indentStr# $comment');
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

  /// Gets KeyMetadata for a list item by index.
  KeyMetadata? _getListItemMetadata(
    Map<String, KeyMetadata>? childrenMeta,
    int index,
  ) {
    if (childrenMeta == null) return null;
    return childrenMeta['$index'];
  }
}
