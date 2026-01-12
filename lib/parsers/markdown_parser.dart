import 'package:change_case/change_case.dart';

import 'package:turbo_serializable/models/callout_meta.dart';
import 'package:turbo_serializable/models/code_block_meta.dart';
import 'package:turbo_serializable/models/divider_meta.dart';
import 'package:turbo_serializable/models/emphasis_meta.dart';
import 'package:turbo_serializable/models/key_metadata.dart';
import 'package:turbo_serializable/models/layout_aware_parse_result.dart';
import 'package:turbo_serializable/models/list_meta.dart';
import 'package:turbo_serializable/models/table_meta.dart';
import 'package:turbo_serializable/models/whitespace_meta.dart';

/// Regular expression patterns for Markdown parsing.
abstract class _MarkdownPatterns {
  _MarkdownPatterns._();

  /// Header pattern: `# ` through `###### `
  static final header = RegExp(r'^(#{1,6})\s+(.+)$');

  /// GitHub/Obsidian style callout pattern: `> [!TYPE]`
  static final calloutStart = RegExp(r'^>\s*\[!(\w+)\]\s*(.*)$');

  /// Continuation of callout content: `> content`
  static final calloutContinuation = RegExp(r'^>\s*(.*)$');

  /// Horizontal rule/divider pattern: `---`, `***`, `___`
  static final divider = RegExp(r'^(\-{3,}|\*{3,}|_{3,})\s*$');

  /// Fenced code block start/end: ``` or ~~~
  static final codeBlockFence = RegExp(r'^(`{3,}|~{3,})(.*)$');

  /// Unordered list item: `- item`, `* item`, `+ item`
  static final unorderedListItem = RegExp(r'^(\s*)([-*+])\s+(.*)$');

  /// Ordered list item: `1. item`, `1) item`
  static final orderedListItem = RegExp(r'^(\s*)(\d+)([.\)])\s+(.*)$');

  /// Task list item: `- [ ] task` or `- [x] task`
  static final taskListItem = RegExp(r'^(\s*)([-*+])\s+\[([ xX])\]\s+(.*)$');

  /// Table row: `| cell | cell |`
  static final tableRow = RegExp(r'^\|(.+)\|$');

  /// Table separator row: `|---|---|`
  static final tableSeparator = RegExp(r'^\|[\s\-:|]+\|$');

  /// Bold text: `**text**` or `__text__`
  static final boldDouble = RegExp(r'\*\*([^*]+)\*\*');
  static final boldUnderscore = RegExp(r'__([^_]+)__');

  /// Italic text: `*text*` or `_text_`
  static final italicSingle = RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)');
  static final italicUnderscore = RegExp(r'(?<!_)_([^_]+)_(?!_)');

  /// Strikethrough: `~~text~~`
  static final strikethrough = RegExp(r'~~([^~]+)~~');

  /// Inline code: `` `code` ``
  static final inlineCode = RegExp(r'`([^`]+)`');

  /// YAML frontmatter delimiter
  static const frontmatterDelimiter = '---';
}

/// Parser for extracting layout metadata from Markdown documents.
///
/// Parses Markdown content and extracts both data and layout metadata
/// for 100% round-trip fidelity during format conversions.
class MarkdownLayoutParser {
  /// Creates a [MarkdownLayoutParser] instance.
  const MarkdownLayoutParser();

  /// Parses Markdown content with layout metadata extraction.
  ///
  /// Returns a [LayoutAwareParseResult] containing both the parsed data map
  /// and key-level metadata for preserving layout information.
  ///
  /// [markdown] - The Markdown string to parse
  LayoutAwareParseResult parse(String markdown) {
    if (markdown.isEmpty) {
      return const LayoutAwareParseResult(data: {});
    }

    final lineEnding = _detectLineEnding(markdown);
    final lines = markdown.split(RegExp(r'\r?\n'));

    final data = <String, dynamic>{};
    final keyMeta = <String, dynamic>{};
    var currentIndex = 0;

    // Parse YAML frontmatter if present
    if (lines.isNotEmpty &&
        lines[0].trim() == _MarkdownPatterns.frontmatterDelimiter) {
      final frontmatterResult =
          _parseFrontmatter(lines, currentIndex, lineEnding);
      currentIndex = frontmatterResult.nextIndex;
      data.addAll(frontmatterResult.data);
      if (frontmatterResult.meta.isNotEmpty) {
        keyMeta.addAll(frontmatterResult.meta);
      }
    }

    // Track leading whitespace for the document
    final leadingNewlines = _countLeadingNewlines(lines, currentIndex);
    if (leadingNewlines > 0) {
      currentIndex += leadingNewlines;
    }

    // Parse body content
    final bodyResult = _parseBody(lines, currentIndex, lineEnding);
    if (bodyResult.data.isNotEmpty) {
      data.addAll(bodyResult.data);
    }
    if (bodyResult.meta.isNotEmpty) {
      keyMeta.addAll(bodyResult.meta);
    }

    // Add document-level whitespace metadata
    keyMeta['_document'] = KeyMetadata(
      whitespace: WhitespaceMeta(
        leadingNewlines: leadingNewlines,
        lineEnding: lineEnding,
      ),
    ).toJson();

    return LayoutAwareParseResult(
      data: data,
      keyMeta: keyMeta.isEmpty ? null : keyMeta,
    );
  }

  /// Detects the line ending style used in the document.
  String _detectLineEnding(String content) {
    if (content.contains('\r\n')) {
      return '\r\n';
    }
    return '\n';
  }

  /// Counts leading blank lines starting from the given index.
  int _countLeadingNewlines(List<String> lines, int startIndex) {
    var count = 0;
    for (var i = startIndex; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// Parses YAML frontmatter.
  _ParseResult _parseFrontmatter(
      List<String> lines, int startIndex, String lineEnding) {
    final data = <String, dynamic>{};
    final meta = <String, dynamic>{};

    // Skip opening delimiter
    final currentIndex = startIndex + 1;

    // Find closing delimiter
    var endIndex = -1;
    for (var i = currentIndex; i < lines.length; i++) {
      if (lines[i].trim() == _MarkdownPatterns.frontmatterDelimiter) {
        endIndex = i;
        break;
      }
    }

    if (endIndex == -1) {
      return _ParseResult(data: data, meta: meta, nextIndex: startIndex);
    }

    // Parse frontmatter content as simple key-value pairs
    for (var i = currentIndex; i < endIndex; i++) {
      final line = lines[i];
      final colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        final key = line.substring(0, colonIndex).trim();
        final value = line.substring(colonIndex + 1).trim();
        data[key] = _parseValue(value);
      }
    }

    return _ParseResult(
      data: data,
      meta: meta,
      nextIndex: endIndex + 1,
    );
  }

  /// Parses a YAML value string to appropriate type.
  dynamic _parseValue(String value) {
    if (value.isEmpty) return null;

    // Handle quoted strings
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1);
    }

    // Handle booleans
    final lower = value.toLowerCase();
    if (lower == 'true') return true;
    if (lower == 'false') return false;
    if (lower == 'null') return null;

    // Handle numbers
    final intVal = int.tryParse(value);
    if (intVal != null) return intVal;
    final doubleVal = double.tryParse(value);
    if (doubleVal != null) return doubleVal;

    return value;
  }

  /// Parses the main body content of the Markdown document.
  _ParseResult _parseBody(
      List<String> lines, int startIndex, String lineEnding) {
    final data = <String, dynamic>{};
    final meta = <String, dynamic>{};

    final headerStack = <_HeaderContext>[];
    var currentIndex = startIndex;

    while (currentIndex < lines.length) {
      final line = lines[currentIndex];
      final trimmedLine = line.trim();

      // Skip empty lines between elements
      if (trimmedLine.isEmpty) {
        currentIndex++;
        continue;
      }

      // Try to parse different Markdown elements
      final headerResult = _tryParseHeader(lines, currentIndex, lineEnding);
      if (headerResult != null) {
        _addToHierarchy(data, meta, headerStack, headerResult.key,
            headerResult.value, headerResult.metadata);
        currentIndex = headerResult.nextIndex;
        continue;
      }

      final dividerResult = _tryParseDivider(lines, currentIndex);
      if (dividerResult != null) {
        final key = '_divider_$currentIndex';
        data[key] = '';
        meta[key] = KeyMetadata(divider: dividerResult.dividerMeta).toJson();
        currentIndex = dividerResult.nextIndex;
        continue;
      }

      final calloutResult = _tryParseCallout(lines, currentIndex, lineEnding);
      if (calloutResult != null) {
        final key = _toCamelCaseKey(calloutResult.type);
        _addToHierarchy(data, meta, headerStack, key, calloutResult.content,
            calloutResult.metadata);
        currentIndex = calloutResult.nextIndex;
        continue;
      }

      final codeBlockResult =
          _tryParseCodeBlock(lines, currentIndex, lineEnding);
      if (codeBlockResult != null) {
        final key = '_code_$currentIndex';
        _addToHierarchy(data, meta, headerStack, key, codeBlockResult.content,
            codeBlockResult.metadata);
        currentIndex = codeBlockResult.nextIndex;
        continue;
      }

      final tableResult = _tryParseTable(lines, currentIndex, lineEnding);
      if (tableResult != null) {
        final key = '_table_$currentIndex';
        _addToHierarchy(data, meta, headerStack, key, tableResult.tableData,
            tableResult.metadata);
        currentIndex = tableResult.nextIndex;
        continue;
      }

      final listResult = _tryParseList(lines, currentIndex, lineEnding);
      if (listResult != null) {
        final key = '_list_$currentIndex';
        _addToHierarchy(data, meta, headerStack, key, listResult.items,
            listResult.metadata);
        currentIndex = listResult.nextIndex;
        continue;
      }

      // Plain text paragraph
      final paragraphResult = _parseParagraph(lines, currentIndex, lineEnding);
      if (headerStack.isNotEmpty) {
        final currentHeader = headerStack.last;
        final existingValue =
            _getFromHierarchy(data, headerStack, currentHeader.key);
        if (existingValue == null || existingValue.toString().isEmpty) {
          _setInHierarchy(
              data, headerStack, currentHeader.key, paragraphResult.content);
        } else {
          _setInHierarchy(data, headerStack, currentHeader.key,
              '$existingValue\n${paragraphResult.content}');
        }
      } else {
        data['body'] = (data['body'] ?? '') +
            (data['body'] != null ? '\n' : '') +
            paragraphResult.content;
      }

      if (paragraphResult.metadata != null) {
        final key = headerStack.isNotEmpty ? headerStack.last.key : 'body';
        meta[key] = paragraphResult.metadata!.toJson();
      }

      currentIndex = paragraphResult.nextIndex;
    }

    return _ParseResult(data: data, meta: meta, nextIndex: currentIndex);
  }

  /// Attempts to parse a header line.
  _HeaderResult? _tryParseHeader(
      List<String> lines, int index, String lineEnding) {
    final match = _MarkdownPatterns.header.firstMatch(lines[index]);
    if (match == null) return null;

    final level = match.group(1)!.length;
    final headerText = match.group(2)!.trim();
    final key = _toCamelCaseKey(headerText);

    // Count trailing whitespace after header
    var trailingNewlines = 0;
    var nextIndex = index + 1;
    while (nextIndex < lines.length && lines[nextIndex].trim().isEmpty) {
      trailingNewlines++;
      nextIndex++;
    }

    final metadata = KeyMetadata(
      headerLevel: level,
      whitespace: trailingNewlines > 0
          ? WhitespaceMeta(
              trailingNewlines: trailingNewlines,
              lineEnding: lineEnding,
            )
          : null,
    );

    // Detect emphasis in the header text
    final emphasisMeta = _detectEmphasis(headerText);

    return _HeaderResult(
      key: key,
      value: '',
      level: level,
      metadata: emphasisMeta != null
          ? metadata.copyWith(emphasis: emphasisMeta)
          : metadata,
      nextIndex: nextIndex,
    );
  }

  /// Attempts to parse a divider line.
  _DividerResult? _tryParseDivider(List<String> lines, int index) {
    final match = _MarkdownPatterns.divider.firstMatch(lines[index]);
    if (match == null) return null;

    final style = match.group(1)!.substring(0, 3);
    return _DividerResult(
      dividerMeta: DividerMeta(before: true, style: style),
      nextIndex: index + 1,
    );
  }

  /// Attempts to parse a callout block.
  _CalloutResult? _tryParseCallout(
      List<String> lines, int index, String lineEnding) {
    final startMatch = _MarkdownPatterns.calloutStart.firstMatch(lines[index]);
    if (startMatch == null) return null;

    final type = startMatch.group(1)!.toLowerCase();
    final contentLines = <String>[];

    // First line content after [!TYPE]
    final firstLineContent = startMatch.group(2)?.trim() ?? '';
    if (firstLineContent.isNotEmpty) {
      contentLines.add(firstLineContent);
    }

    var nextIndex = index + 1;
    while (nextIndex < lines.length) {
      final contMatch =
          _MarkdownPatterns.calloutContinuation.firstMatch(lines[nextIndex]);
      if (contMatch == null) break;
      final lineContent = contMatch.group(1)?.trim() ?? '';
      contentLines.add(lineContent);
      nextIndex++;
    }

    final content = contentLines.join('\n').trim();

    return _CalloutResult(
      type: type,
      content: content,
      metadata: KeyMetadata(
        callout: CalloutMeta(
          type: type,
          content: content,
          position: 'before',
        ),
      ),
      nextIndex: nextIndex,
    );
  }

  /// Attempts to parse a fenced code block.
  _CodeBlockResult? _tryParseCodeBlock(
      List<String> lines, int index, String lineEnding) {
    final startMatch =
        _MarkdownPatterns.codeBlockFence.firstMatch(lines[index]);
    if (startMatch == null) return null;

    final fence = startMatch.group(1)!;
    final infoString = startMatch.group(2)?.trim() ?? '';
    String? language;
    String? filename;

    // Parse info string for language and optional filename
    if (infoString.isNotEmpty) {
      final parts = infoString.split(RegExp(r'\s+'));
      language = parts.first.isNotEmpty ? parts.first : null;
      if (parts.length > 1) {
        filename = parts.skip(1).join(' ');
      }
    }

    final contentLines = <String>[];
    var nextIndex = index + 1;

    // Find closing fence
    while (nextIndex < lines.length) {
      final line = lines[nextIndex];
      if (line.trim().startsWith(fence.substring(0, 1)) &&
          RegExp('^${fence.substring(0, 1)}{${fence.length},}\$')
              .hasMatch(line.trim())) {
        nextIndex++;
        break;
      }
      contentLines.add(line);
      nextIndex++;
    }

    final content = contentLines.join(lineEnding);

    return _CodeBlockResult(
      content: content,
      metadata: KeyMetadata(
        codeBlock: CodeBlockMeta(
          language: language,
          filename: filename,
        ),
      ),
      nextIndex: nextIndex,
    );
  }

  /// Attempts to parse a table.
  _TableResult? _tryParseTable(
      List<String> lines, int index, String lineEnding) {
    // Check if this looks like a table row
    if (!_MarkdownPatterns.tableRow.hasMatch(lines[index])) {
      return null;
    }

    final tableRows = <List<String>>[];
    var alignments = <String>[];
    var hasHeader = false;
    var nextIndex = index;

    // Parse first row
    final firstRow = _parseTableRow(lines[nextIndex]);
    if (firstRow == null) return null;
    tableRows.add(firstRow);
    nextIndex++;

    // Check for separator row
    if (nextIndex < lines.length &&
        _MarkdownPatterns.tableSeparator.hasMatch(lines[nextIndex])) {
      hasHeader = true;
      alignments = _parseTableAlignments(lines[nextIndex]);
      nextIndex++;
    }

    // Parse remaining rows
    while (nextIndex < lines.length &&
        _MarkdownPatterns.tableRow.hasMatch(lines[nextIndex])) {
      final row = _parseTableRow(lines[nextIndex]);
      if (row != null) {
        tableRows.add(row);
      }
      nextIndex++;
    }

    // Convert to map structure
    final tableData = <String, dynamic>{};
    if (hasHeader && tableRows.isNotEmpty) {
      final headers = tableRows.first;
      tableData['headers'] = headers;
      tableData['rows'] = tableRows.skip(1).toList();
    } else {
      tableData['rows'] = tableRows;
    }

    return _TableResult(
      tableData: tableData,
      metadata: KeyMetadata(
        tableMeta: TableMeta(
          alignment: alignments.isEmpty
              ? List.filled(tableRows.first.length, 'left')
              : alignments,
          hasHeader: hasHeader,
        ),
      ),
      nextIndex: nextIndex,
    );
  }

  /// Parses a table row into cells.
  List<String>? _parseTableRow(String line) {
    final match = _MarkdownPatterns.tableRow.firstMatch(line);
    if (match == null) return null;
    final content = match.group(1)!;
    return content.split('|').map((cell) => cell.trim()).toList();
  }

  /// Parses table column alignments from separator row.
  List<String> _parseTableAlignments(String line) {
    final cells = line.substring(1, line.length - 1).split('|');
    return cells.map((cell) {
      final trimmed = cell.trim();
      if (trimmed.startsWith(':') && trimmed.endsWith(':')) {
        return 'center';
      } else if (trimmed.endsWith(':')) {
        return 'right';
      }
      return 'left';
    }).toList();
  }

  /// Attempts to parse a list.
  _ListResult? _tryParseList(List<String> lines, int index, String lineEnding) {
    // Check for task list first
    final taskMatch = _MarkdownPatterns.taskListItem.firstMatch(lines[index]);
    if (taskMatch != null) {
      return _parseTaskList(lines, index, lineEnding);
    }

    // Check for ordered list
    final orderedMatch =
        _MarkdownPatterns.orderedListItem.firstMatch(lines[index]);
    if (orderedMatch != null) {
      return _parseOrderedList(lines, index, lineEnding);
    }

    // Check for unordered list
    final unorderedMatch =
        _MarkdownPatterns.unorderedListItem.firstMatch(lines[index]);
    if (unorderedMatch != null) {
      return _parseUnorderedList(lines, index, lineEnding);
    }

    return null;
  }

  /// Parses an unordered list.
  _ListResult _parseUnorderedList(
      List<String> lines, int index, String lineEnding) {
    final items = <String>[];
    String? marker;
    var nextIndex = index;

    while (nextIndex < lines.length) {
      final match =
          _MarkdownPatterns.unorderedListItem.firstMatch(lines[nextIndex]);
      if (match == null) {
        // Check if it's a continuation or nested list
        if (lines[nextIndex].trim().isEmpty) {
          nextIndex++;
          continue;
        }
        break;
      }
      marker ??= match.group(2);
      items.add(match.group(3)!.trim());
      nextIndex++;
    }

    return _ListResult(
      items: items,
      metadata: KeyMetadata(
        listMeta: ListMeta(
          type: 'unordered',
          marker: marker,
        ),
      ),
      nextIndex: nextIndex,
    );
  }

  /// Parses an ordered list.
  _ListResult _parseOrderedList(
      List<String> lines, int index, String lineEnding) {
    final items = <String>[];
    int? startNumber;
    String? markerStyle;
    var nextIndex = index;

    while (nextIndex < lines.length) {
      final match =
          _MarkdownPatterns.orderedListItem.firstMatch(lines[nextIndex]);
      if (match == null) {
        if (lines[nextIndex].trim().isEmpty) {
          nextIndex++;
          continue;
        }
        break;
      }
      startNumber ??= int.tryParse(match.group(2)!);
      markerStyle ??= match.group(3);
      items.add(match.group(4)!.trim());
      nextIndex++;
    }

    return _ListResult(
      items: items,
      metadata: KeyMetadata(
        listMeta: ListMeta(
          type: 'ordered',
          marker: '${startNumber ?? 1}$markerStyle',
          startNumber: startNumber,
        ),
      ),
      nextIndex: nextIndex,
    );
  }

  /// Parses a task list.
  _ListResult _parseTaskList(List<String> lines, int index, String lineEnding) {
    final items = <Map<String, dynamic>>[];
    String? marker;
    var nextIndex = index;

    while (nextIndex < lines.length) {
      final match = _MarkdownPatterns.taskListItem.firstMatch(lines[nextIndex]);
      if (match == null) {
        if (lines[nextIndex].trim().isEmpty) {
          nextIndex++;
          continue;
        }
        break;
      }
      marker ??= match.group(2);
      final isChecked = match.group(3)!.toLowerCase() == 'x';
      items.add({
        'content': match.group(4)!.trim(),
        'checked': isChecked,
      });
      nextIndex++;
    }

    return _ListResult(
      items: items,
      metadata: KeyMetadata(
        listMeta: ListMeta(
          type: 'task',
          marker: marker,
        ),
      ),
      nextIndex: nextIndex,
    );
  }

  /// Parses a plain text paragraph.
  _ParagraphResult _parseParagraph(
      List<String> lines, int index, String lineEnding) {
    final contentLines = <String>[];
    var nextIndex = index;

    while (nextIndex < lines.length) {
      final line = lines[nextIndex];
      final trimmed = line.trim();

      // Stop at special elements
      if (trimmed.isEmpty) break;
      if (_MarkdownPatterns.header.hasMatch(trimmed)) break;
      if (_MarkdownPatterns.divider.hasMatch(trimmed)) break;
      if (_MarkdownPatterns.codeBlockFence.hasMatch(trimmed)) break;
      if (_MarkdownPatterns.tableRow.hasMatch(trimmed)) break;
      if (_MarkdownPatterns.unorderedListItem.hasMatch(trimmed)) break;
      if (_MarkdownPatterns.orderedListItem.hasMatch(trimmed)) break;
      if (_MarkdownPatterns.taskListItem.hasMatch(trimmed)) break;
      if (_MarkdownPatterns.calloutStart.hasMatch(trimmed)) break;

      contentLines.add(line);
      nextIndex++;
    }

    final content = contentLines.map((l) => l.trim()).join(' ').trim();
    final emphasisMeta = _detectEmphasis(content);

    return _ParagraphResult(
      content: content,
      metadata:
          emphasisMeta != null ? KeyMetadata(emphasis: emphasisMeta) : null,
      nextIndex: nextIndex,
    );
  }

  /// Detects emphasis styles in text.
  EmphasisMeta? _detectEmphasis(String text) {
    if (_MarkdownPatterns.boldDouble.hasMatch(text) ||
        _MarkdownPatterns.boldUnderscore.hasMatch(text)) {
      return const EmphasisMeta(style: 'bold');
    }
    if (_MarkdownPatterns.italicSingle.hasMatch(text) ||
        _MarkdownPatterns.italicUnderscore.hasMatch(text)) {
      return const EmphasisMeta(style: 'italic');
    }
    if (_MarkdownPatterns.strikethrough.hasMatch(text)) {
      return const EmphasisMeta(style: 'strikethrough');
    }
    if (_MarkdownPatterns.inlineCode.hasMatch(text)) {
      return const EmphasisMeta(style: 'code');
    }
    return null;
  }

  /// Converts header text to camelCase key.
  String _toCamelCaseKey(String text) {
    // Remove special characters and convert to camelCase
    final cleaned = text.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    if (cleaned.isEmpty) return 'key';
    return cleaned.toCamelCase();
  }

  /// Adds a key-value pair to the data hierarchy based on header stack.
  void _addToHierarchy(
    Map<String, dynamic> data,
    Map<String, dynamic> meta,
    List<_HeaderContext> headerStack,
    String key,
    dynamic value,
    KeyMetadata? metadata,
  ) {
    // Pop headers from stack that are same level or deeper
    final headerLevel = metadata?.headerLevel;
    if (headerLevel != null) {
      while (headerStack.isNotEmpty && headerStack.last.level >= headerLevel) {
        headerStack.removeLast();
      }
      headerStack.add(_HeaderContext(key: key, level: headerLevel));
    }

    // Navigate to the correct depth in the data structure
    var currentData = data;
    var metaPath = key;

    for (final header in headerStack
        .take(headerStack.isNotEmpty ? headerStack.length - 1 : 0)) {
      final existing = currentData[header.key];
      if (existing is Map<String, dynamic>) {
        currentData = existing;
      } else {
        // If the key exists but is not a map, convert to a map preserving the content
        final newMap = <String, dynamic>{};
        if (existing != null && existing.toString().isNotEmpty) {
          newMap['_content'] = existing;
        }
        currentData[header.key] = newMap;
        currentData = newMap;
      }
      metaPath = '${header.key}.$key';
    }

    currentData[key] = value;

    if (metadata != null) {
      meta[metaPath] = metadata.toJson();
    }
  }

  /// Gets a value from the data hierarchy.
  dynamic _getFromHierarchy(
      Map<String, dynamic> data, List<_HeaderContext> headerStack, String key) {
    var current = data;
    for (var i = 0; i < headerStack.length - 1; i++) {
      final nested = current[headerStack[i].key];
      if (nested is! Map<String, dynamic>) return null;
      current = nested;
    }
    return current[key];
  }

  /// Sets a value in the data hierarchy.
  void _setInHierarchy(Map<String, dynamic> data,
      List<_HeaderContext> headerStack, String key, dynamic value) {
    var current = data;
    for (var i = 0; i < headerStack.length - 1; i++) {
      final headerKey = headerStack[i].key;
      final existing = current[headerKey];
      if (existing is Map<String, dynamic>) {
        current = existing;
      } else {
        final newMap = <String, dynamic>{};
        if (existing != null && existing.toString().isNotEmpty) {
          newMap['_content'] = existing;
        }
        current[headerKey] = newMap;
        current = newMap;
      }
    }
    current[key] = value;
  }
}

/// Internal class for tracking header context.
class _HeaderContext {
  const _HeaderContext({required this.key, required this.level});

  final String key;
  final int level;
}

/// Internal result class for parsing operations.
class _ParseResult {
  const _ParseResult({
    required this.data,
    required this.meta,
    required this.nextIndex,
  });

  final Map<String, dynamic> data;
  final Map<String, dynamic> meta;
  final int nextIndex;
}

/// Internal result class for header parsing.
class _HeaderResult {
  const _HeaderResult({
    required this.key,
    required this.value,
    required this.level,
    required this.metadata,
    required this.nextIndex,
  });

  final String key;
  final dynamic value;
  final int level;
  final KeyMetadata metadata;
  final int nextIndex;
}

/// Internal result class for divider parsing.
class _DividerResult {
  const _DividerResult({
    required this.dividerMeta,
    required this.nextIndex,
  });

  final DividerMeta dividerMeta;
  final int nextIndex;
}

/// Internal result class for callout parsing.
class _CalloutResult {
  const _CalloutResult({
    required this.type,
    required this.content,
    required this.metadata,
    required this.nextIndex,
  });

  final String type;
  final String content;
  final KeyMetadata metadata;
  final int nextIndex;
}

/// Internal result class for code block parsing.
class _CodeBlockResult {
  const _CodeBlockResult({
    required this.content,
    required this.metadata,
    required this.nextIndex,
  });

  final String content;
  final KeyMetadata metadata;
  final int nextIndex;
}

/// Internal result class for table parsing.
class _TableResult {
  const _TableResult({
    required this.tableData,
    required this.metadata,
    required this.nextIndex,
  });

  final Map<String, dynamic> tableData;
  final KeyMetadata metadata;
  final int nextIndex;
}

/// Internal result class for list parsing.
class _ListResult {
  const _ListResult({
    required this.items,
    required this.metadata,
    required this.nextIndex,
  });

  final List<dynamic> items;
  final KeyMetadata metadata;
  final int nextIndex;
}

/// Internal result class for paragraph parsing.
class _ParagraphResult {
  const _ParagraphResult({
    required this.content,
    required this.metadata,
    required this.nextIndex,
  });

  final String content;
  final KeyMetadata? metadata;
  final int nextIndex;
}
