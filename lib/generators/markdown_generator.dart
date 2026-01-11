import 'package:turbo_serializable/models/callout_meta.dart';
import 'package:turbo_serializable/models/key_metadata.dart';

/// Generates Markdown output from JSON data using key metadata for layout fidelity.
///
/// Uses extracted metadata from parsing to produce byte-for-byte identical
/// output during round-trip conversions.
class MarkdownLayoutGenerator {
  /// Creates a [MarkdownLayoutGenerator] instance.
  const MarkdownLayoutGenerator();

  /// Generates Markdown from data using key metadata for layout preservation.
  ///
  /// [data] - The JSON data map to convert
  /// [keyMeta] - The key-level metadata for layout information
  /// [metaData] - Optional frontmatter metadata
  ///
  /// Returns a Markdown string with preserved layout from the original document.
  String generate(
    Map<String, dynamic> data, {
    Map<String, dynamic>? keyMeta,
    Map<String, dynamic>? metaData,
  }) {
    final buffer = StringBuffer();
    final lineEnding = _getLineEnding(keyMeta);
    final leadingNewlines = _getLeadingNewlines(keyMeta);

    // Add frontmatter if metadata is provided
    if (metaData != null && metaData.isNotEmpty) {
      buffer.write('---');
      buffer.write(lineEnding);
      _writeFrontmatter(buffer, metaData, lineEnding);
      buffer.write('---');
      buffer.write(lineEnding);
    }

    // Add leading whitespace
    for (var i = 0; i < leadingNewlines; i++) {
      buffer.write(lineEnding);
    }

    // Generate body content
    _writeDataContent(buffer, data, keyMeta, lineEnding, 0);

    final result = buffer.toString();
    // Trim trailing whitespace while preserving line ending style
    return result.trimRight();
  }

  /// Gets the line ending style from document metadata.
  String _getLineEnding(Map<String, dynamic>? keyMeta) {
    if (keyMeta == null) return '\n';
    final docMeta = keyMeta['_document'];
    if (docMeta == null) return '\n';
    final whitespace = docMeta['whitespace'];
    if (whitespace == null) return '\n';
    return whitespace['lineEnding'] as String? ?? '\n';
  }

  /// Gets the number of leading newlines from document metadata.
  int _getLeadingNewlines(Map<String, dynamic>? keyMeta) {
    if (keyMeta == null) return 0;
    final docMeta = keyMeta['_document'];
    if (docMeta == null) return 0;
    final whitespace = docMeta['whitespace'];
    if (whitespace == null) return 0;
    return whitespace['leadingNewlines'] as int? ?? 0;
  }

  /// Writes YAML frontmatter content.
  void _writeFrontmatter(
    StringBuffer buffer,
    Map<String, dynamic> metaData,
    String lineEnding,
  ) {
    for (final entry in metaData.entries) {
      final value = entry.value;
      if (value is String && (value.contains(':') || value.contains('\n'))) {
        buffer.write('${entry.key}: "$value"');
      } else {
        buffer.write('${entry.key}: $value');
      }
      buffer.write(lineEnding);
    }
  }

  /// Writes data content with metadata-guided layout.
  void _writeDataContent(
    StringBuffer buffer,
    Map<String, dynamic> data,
    Map<String, dynamic>? keyMeta,
    String lineEnding,
    int depth,
  ) {
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      final meta = _getKeyMetadata(keyMeta, key);

      // Handle dividers
      if (key.startsWith('_divider')) {
        _writeDivider(buffer, meta, lineEnding);
        continue;
      }

      // Handle code blocks
      if (key.startsWith('_code')) {
        _writeCodeBlock(buffer, value, meta, lineEnding);
        continue;
      }

      // Handle tables
      if (key.startsWith('_table')) {
        _writeTable(buffer, value, meta, lineEnding);
        continue;
      }

      // Handle lists
      if (key.startsWith('_list')) {
        _writeList(buffer, value, meta, lineEnding);
        continue;
      }

      // Handle callouts (stored under type as key)
      if (meta?.callout != null) {
        _writeCallout(buffer, value, meta!.callout!, lineEnding);
        continue;
      }

      // Handle headers
      if (meta?.headerLevel != null) {
        _writeHeader(buffer, key, value, meta!, keyMeta, lineEnding);
        continue;
      }

      // Handle body content
      if (key == 'body') {
        _writeBodyContent(buffer, value, lineEnding);
        continue;
      }

      // Handle nested maps without header level (frontmatter values)
      if (value is Map<String, dynamic>) {
        _writeDataContent(buffer, value, keyMeta, lineEnding, depth);
        continue;
      }

      // Handle remaining plain values
      if (value != null && value.toString().isNotEmpty) {
        buffer.write(value.toString());
        buffer.write(lineEnding);
      }
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

  /// Writes a header with its content.
  void _writeHeader(
    StringBuffer buffer,
    String key,
    dynamic value,
    KeyMetadata meta,
    Map<String, dynamic>? keyMeta,
    String lineEnding,
  ) {
    final level = meta.headerLevel!;
    final headerText = _keyToTitleCase(key);
    final headerPrefix = '#' * level;

    buffer.write('$headerPrefix $headerText');
    buffer.write(lineEnding);

    // Add trailing whitespace after header
    final trailingNewlines = meta.whitespace?.trailingNewlines ?? 1;
    for (var i = 0; i < trailingNewlines; i++) {
      buffer.write(lineEnding);
    }

    // Write content
    if (value is Map<String, dynamic>) {
      _writeDataContent(buffer, value, keyMeta, lineEnding, level);
    } else if (value != null && value.toString().isNotEmpty) {
      buffer.write(value.toString());
      buffer.write(lineEnding);
      buffer.write(lineEnding);
    }
  }

  /// Writes a callout block.
  void _writeCallout(
    StringBuffer buffer,
    dynamic value,
    CalloutMeta callout,
    String lineEnding,
  ) {
    final type = callout.type.toUpperCase();
    final content = value?.toString() ?? callout.content;
    final lines = content.split('\n');

    buffer.write('> [!$type]');
    buffer.write(lineEnding);

    for (final line in lines) {
      buffer.write('> $line');
      buffer.write(lineEnding);
    }
  }

  /// Writes a divider.
  void _writeDivider(
    StringBuffer buffer,
    KeyMetadata? meta,
    String lineEnding,
  ) {
    final style = meta?.divider?.style ?? '---';
    buffer.write(style);
    buffer.write(lineEnding);
  }

  /// Writes a code block.
  void _writeCodeBlock(
    StringBuffer buffer,
    dynamic value,
    KeyMetadata? meta,
    String lineEnding,
  ) {
    final language = meta?.codeBlock?.language ?? '';
    final filename = meta?.codeBlock?.filename;
    final content = value?.toString() ?? '';

    buffer.write('```');
    if (language.isNotEmpty) {
      buffer.write(language);
      if (filename != null && filename.isNotEmpty) {
        buffer.write(' $filename');
      }
    }
    buffer.write(lineEnding);
    buffer.write(content);
    buffer.write(lineEnding);
    buffer.write('```');
    buffer.write(lineEnding);
  }

  /// Writes a list.
  void _writeList(
    StringBuffer buffer,
    dynamic value,
    KeyMetadata? meta,
    String lineEnding,
  ) {
    if (value is! List) return;

    final listMeta = meta?.listMeta;
    final type = listMeta?.type ?? 'unordered';
    final marker = listMeta?.marker ?? '-';
    final startNumber = listMeta?.startNumber ?? 1;

    if (type == 'task') {
      _writeTaskList(buffer, value, marker, lineEnding);
    } else if (type == 'ordered') {
      _writeOrderedList(buffer, value, marker, startNumber, lineEnding);
    } else {
      _writeUnorderedList(buffer, value, marker, lineEnding);
    }
  }

  /// Writes an unordered list.
  void _writeUnorderedList(
    StringBuffer buffer,
    List<dynamic> items,
    String marker,
    String lineEnding,
  ) {
    for (final item in items) {
      buffer.write('$marker $item');
      buffer.write(lineEnding);
    }
  }

  /// Writes an ordered list.
  void _writeOrderedList(
    StringBuffer buffer,
    List<dynamic> items,
    String marker,
    int startNumber,
    String lineEnding,
  ) {
    // Extract the punctuation from marker (e.g., "1." -> ".", "1)" -> ")")
    final punct = marker.replaceAll(RegExp(r'\d+'), '');

    for (var i = 0; i < items.length; i++) {
      final number = startNumber + i;
      buffer.write('$number$punct ${items[i]}');
      buffer.write(lineEnding);
    }
  }

  /// Writes a task list.
  void _writeTaskList(
    StringBuffer buffer,
    List<dynamic> items,
    String marker,
    String lineEnding,
  ) {
    for (final item in items) {
      if (item is Map<String, dynamic>) {
        final content = item['content'] ?? '';
        final checked = item['checked'] as bool? ?? false;
        final checkMark = checked ? 'x' : ' ';
        buffer.write('$marker [$checkMark] $content');
      } else {
        buffer.write('$marker [ ] $item');
      }
      buffer.write(lineEnding);
    }
  }

  /// Writes a table.
  void _writeTable(
    StringBuffer buffer,
    dynamic value,
    KeyMetadata? meta,
    String lineEnding,
  ) {
    if (value is! Map<String, dynamic>) return;

    final tableMeta = meta?.tableMeta;
    final hasHeader = tableMeta?.hasHeader ?? true;
    final alignments = tableMeta?.alignment ?? [];

    final headers = value['headers'] as List<dynamic>?;
    final rows = value['rows'] as List<dynamic>?;

    if (hasHeader && headers != null) {
      _writeTableRow(buffer, headers, lineEnding);
      _writeTableSeparator(buffer, headers.length, alignments, lineEnding);
    }

    if (rows != null) {
      for (final row in rows) {
        if (row is List<dynamic>) {
          _writeTableRow(buffer, row, lineEnding);
        }
      }
    }
  }

  /// Writes a single table row.
  void _writeTableRow(
    StringBuffer buffer,
    List<dynamic> cells,
    String lineEnding,
  ) {
    buffer.write('|');
    for (final cell in cells) {
      buffer.write(' $cell |');
    }
    buffer.write(lineEnding);
  }

  /// Writes a table separator row with alignment markers.
  void _writeTableSeparator(
    StringBuffer buffer,
    int columnCount,
    List<String> alignments,
    String lineEnding,
  ) {
    buffer.write('|');
    for (var i = 0; i < columnCount; i++) {
      final alignment = i < alignments.length ? alignments[i] : 'left';
      final separator = _getAlignmentSeparator(alignment);
      buffer.write(separator);
    }
    buffer.write(lineEnding);
  }

  /// Gets the separator string for a column alignment.
  String _getAlignmentSeparator(String alignment) {
    switch (alignment) {
      case 'center':
        return ':---:|';
      case 'right':
        return '---:|';
      case 'left':
      default:
        return '---|';
    }
  }

  /// Writes body content without a header.
  void _writeBodyContent(
    StringBuffer buffer,
    dynamic value,
    String lineEnding,
  ) {
    if (value == null) return;
    buffer.write(value.toString());
    buffer.write(lineEnding);
  }

  /// Converts a camelCase key to Title Case.
  String _keyToTitleCase(String key) {
    // Handle special prefixes
    if (key.startsWith('_')) {
      key = key.substring(1);
    }

    // Convert camelCase to space-separated words
    final words = <String>[];
    final buffer = StringBuffer();

    for (var i = 0; i < key.length; i++) {
      final char = key[i];
      if (char.toUpperCase() == char && char.toLowerCase() != char) {
        // Uppercase letter - start new word
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
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
