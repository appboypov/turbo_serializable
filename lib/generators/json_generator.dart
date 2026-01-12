import 'package:turbo_serializable/models/key_metadata.dart';

/// Generator for JSON with layout preservation.
///
/// Generates JSON output using key metadata to preserve formatting
/// like indentation style for round-trip fidelity.
class JsonLayoutGenerator {
  /// Creates a [JsonLayoutGenerator] instance.
  const JsonLayoutGenerator();

  /// Generates JSON from data with layout metadata.
  ///
  /// [data] - The data map to serialize
  /// [keyMeta] - Optional key-level metadata for layout preservation
  ///
  /// Returns a formatted JSON string.
  String generate(
    Map<String, dynamic> data, {
    Map<String, dynamic>? keyMeta,
  }) {
    final indentSpaces = _getIndentSpaces(keyMeta);

    if (indentSpaces == 0) {
      return _generateMinified(data);
    }

    return _generatePretty(data, indentSpaces);
  }

  /// Extracts indent spaces from key metadata.
  int _getIndentSpaces(Map<String, dynamic>? keyMeta) {
    if (keyMeta == null) return 2;

    final rootMeta = keyMeta['_root'];
    if (rootMeta == null) return 2;

    final keyMetadata = rootMeta is KeyMetadata
        ? rootMeta
        : KeyMetadata.fromJson(rootMeta as Map<String, dynamic>);

    return keyMetadata.jsonMeta?.indentSpaces ?? 2;
  }

  /// Generates minified JSON.
  String _generateMinified(dynamic value) {
    if (value == null) {
      return 'null';
    } else if (value is String) {
      return '"${_escapeString(value)}"';
    } else if (value is num || value is bool) {
      return value.toString();
    } else if (value is List) {
      if (value.isEmpty) return '[]';
      final items = value.map(_generateMinified).join(',');
      return '[$items]';
    } else if (value is Map<String, dynamic>) {
      if (value.isEmpty) return '{}';
      final entries = value.entries
          .map((e) => '"${e.key}":${_generateMinified(e.value)}')
          .join(',');
      return '{$entries}';
    }
    return value.toString();
  }

  /// Generates pretty-printed JSON with specified indentation.
  String _generatePretty(dynamic value, int indentSpaces, [int depth = 0]) {
    final indent = ' ' * (indentSpaces * depth);
    final nextIndent = ' ' * (indentSpaces * (depth + 1));

    if (value == null) {
      return 'null';
    } else if (value is String) {
      return '"${_escapeString(value)}"';
    } else if (value is num || value is bool) {
      return value.toString();
    } else if (value is List) {
      if (value.isEmpty) return '[]';
      final items = value
          .map((e) =>
              '$nextIndent${_generatePretty(e, indentSpaces, depth + 1)}')
          .join(',\n');
      return '[\n$items\n$indent]';
    } else if (value is Map<String, dynamic>) {
      if (value.isEmpty) return '{}';
      final entries = value.entries
          .map((e) =>
              '$nextIndent"${e.key}": ${_generatePretty(e.value, indentSpaces, depth + 1)}')
          .join(',\n');
      return '{\n$entries\n$indent}';
    }
    return value.toString();
  }

  /// Escapes special characters in a string for JSON.
  String _escapeString(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}
