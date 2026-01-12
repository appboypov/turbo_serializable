import 'dart:convert';

import 'package:turbo_serializable/models/json_meta.dart';
import 'package:turbo_serializable/models/key_metadata.dart';
import 'package:turbo_serializable/models/layout_aware_parse_result.dart';

/// Parser for extracting layout metadata from JSON documents.
///
/// Detects formatting information like indentation style and
/// minified vs pretty-printed format for round-trip fidelity.
class JsonLayoutParser {
  /// Creates a [JsonLayoutParser] instance.
  const JsonLayoutParser();

  /// Parses JSON with layout metadata extraction.
  ///
  /// Returns a [LayoutAwareParseResult] containing both the parsed data
  /// and formatting metadata for layout preservation.
  LayoutAwareParseResult parse(String json) {
    if (json.trim().isEmpty) {
      return const LayoutAwareParseResult(data: {});
    }

    final data = jsonDecode(json);
    if (data is! Map<String, dynamic>) {
      return LayoutAwareParseResult(
        data: {'_value': data},
      );
    }

    final indentSpaces = _detectIndentation(json);
    final isMinified = _isMinified(json);

    final keyMeta = <String, dynamic>{
      '_root': KeyMetadata(
        jsonMeta: JsonMeta(
          indentSpaces: isMinified ? 0 : indentSpaces,
        ),
      ).toJson(),
    };

    return LayoutAwareParseResult(
      data: data,
      keyMeta: keyMeta,
    );
  }

  /// Detects the indentation used in the JSON string.
  ///
  /// Returns the number of spaces used for indentation, or 2 as default.
  int _detectIndentation(String json) {
    // Look for pattern: newline followed by spaces then a quote or brace
    final indentPattern = RegExp(r'\n( +)["{\[]');
    final match = indentPattern.firstMatch(json);

    if (match != null) {
      return match.group(1)!.length;
    }

    // Check for tab indentation
    if (json.contains('\n\t')) {
      return 0; // Use 0 to indicate tabs
    }

    return 2; // Default to 2 spaces
  }

  /// Checks if the JSON is minified (no newlines between elements).
  bool _isMinified(String json) {
    final trimmed = json.trim();
    if (trimmed.isEmpty) return false;

    // Minified JSON has no newlines between structural elements
    // Check if there's a newline after an opening brace/bracket
    final afterBrace = RegExp(r'[\[{]\s*\n');
    return !afterBrace.hasMatch(trimmed);
  }
}
