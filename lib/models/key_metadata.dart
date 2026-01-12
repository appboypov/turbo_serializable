import 'package:turbo_serializable/models/callout_meta.dart';
import 'package:turbo_serializable/models/code_block_meta.dart';
import 'package:turbo_serializable/models/divider_meta.dart';
import 'package:turbo_serializable/models/emphasis_meta.dart';
import 'package:turbo_serializable/models/json_meta.dart';
import 'package:turbo_serializable/models/list_meta.dart';
import 'package:turbo_serializable/models/table_meta.dart';
import 'package:turbo_serializable/models/whitespace_meta.dart';
import 'package:turbo_serializable/models/xml_meta.dart';
import 'package:turbo_serializable/models/yaml_meta.dart';

/// Metadata for key-level layout information.
///
/// Stores per-key layout and formatting metadata separate from the data itself,
/// enabling 100% round-trip fidelity across format conversions. Supports
/// nested key metadata through the [children] map.
class KeyMetadata {
  /// Creates a [KeyMetadata] instance.
  const KeyMetadata({
    this.headerLevel,
    this.divider,
    this.callout,
    this.codeBlock,
    this.listMeta,
    this.tableMeta,
    this.emphasis,
    this.xmlMeta,
    this.yamlMeta,
    this.jsonMeta,
    this.whitespace,
    this.children,
  });

  /// Creates from JSON map.
  factory KeyMetadata.fromJson(Map<String, dynamic> json) {
    return KeyMetadata(
      headerLevel: json['headerLevel'] as int?,
      divider: json['divider'] != null
          ? DividerMeta.fromJson(json['divider'] as Map<String, dynamic>)
          : null,
      callout: json['callout'] != null
          ? CalloutMeta.fromJson(json['callout'] as Map<String, dynamic>)
          : null,
      codeBlock: json['codeBlock'] != null
          ? CodeBlockMeta.fromJson(json['codeBlock'] as Map<String, dynamic>)
          : null,
      listMeta: json['listMeta'] != null
          ? ListMeta.fromJson(json['listMeta'] as Map<String, dynamic>)
          : null,
      tableMeta: json['tableMeta'] != null
          ? TableMeta.fromJson(json['tableMeta'] as Map<String, dynamic>)
          : null,
      emphasis: json['emphasis'] != null
          ? EmphasisMeta.fromJson(json['emphasis'] as Map<String, dynamic>)
          : null,
      xmlMeta: json['xmlMeta'] != null
          ? XmlMeta.fromJson(json['xmlMeta'] as Map<String, dynamic>)
          : null,
      yamlMeta: json['yamlMeta'] != null
          ? YamlMeta.fromJson(json['yamlMeta'] as Map<String, dynamic>)
          : null,
      jsonMeta: json['jsonMeta'] != null
          ? JsonMeta.fromJson(json['jsonMeta'] as Map<String, dynamic>)
          : null,
      whitespace: json['whitespace'] != null
          ? WhitespaceMeta.fromJson(json['whitespace'] as Map<String, dynamic>)
          : null,
      children: json['children'] != null
          ? (json['children'] as Map<String, dynamic>).map(
              (k, v) =>
                  MapEntry(k, KeyMetadata.fromJson(v as Map<String, dynamic>)),
            )
          : null,
    );
  }

  /// Header level (1-6) for Markdown headers.
  final int? headerLevel;

  /// Divider/horizontal rule metadata.
  final DividerMeta? divider;

  /// Callout metadata (NOTE, WARNING, TIP, etc.).
  final CalloutMeta? callout;

  /// Code block metadata.
  final CodeBlockMeta? codeBlock;

  /// List formatting metadata.
  final ListMeta? listMeta;

  /// Table formatting metadata.
  final TableMeta? tableMeta;

  /// Text emphasis metadata (bold, italic, etc.).
  final EmphasisMeta? emphasis;

  /// XML-specific metadata (attributes, CDATA, comments, namespaces).
  final XmlMeta? xmlMeta;

  /// YAML-specific metadata (anchors, aliases, comments, styles).
  final YamlMeta? yamlMeta;

  /// JSON-specific metadata (indentation, trailing commas).
  final JsonMeta? jsonMeta;

  /// Whitespace preservation metadata.
  final WhitespaceMeta? whitespace;

  /// Nested key metadata for child keys.
  final Map<String, KeyMetadata>? children;

  /// Creates a copy with updated values.
  KeyMetadata copyWith({
    int? headerLevel,
    DividerMeta? divider,
    CalloutMeta? callout,
    CodeBlockMeta? codeBlock,
    ListMeta? listMeta,
    TableMeta? tableMeta,
    EmphasisMeta? emphasis,
    XmlMeta? xmlMeta,
    YamlMeta? yamlMeta,
    JsonMeta? jsonMeta,
    WhitespaceMeta? whitespace,
    Map<String, KeyMetadata>? children,
  }) {
    return KeyMetadata(
      headerLevel: headerLevel ?? this.headerLevel,
      divider: divider ?? this.divider,
      callout: callout ?? this.callout,
      codeBlock: codeBlock ?? this.codeBlock,
      listMeta: listMeta ?? this.listMeta,
      tableMeta: tableMeta ?? this.tableMeta,
      emphasis: emphasis ?? this.emphasis,
      xmlMeta: xmlMeta ?? this.xmlMeta,
      yamlMeta: yamlMeta ?? this.yamlMeta,
      jsonMeta: jsonMeta ?? this.jsonMeta,
      whitespace: whitespace ?? this.whitespace,
      children: children ?? this.children,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (headerLevel != null) 'headerLevel': headerLevel,
      if (divider != null) 'divider': divider!.toJson(),
      if (callout != null) 'callout': callout!.toJson(),
      if (codeBlock != null) 'codeBlock': codeBlock!.toJson(),
      if (listMeta != null) 'listMeta': listMeta!.toJson(),
      if (tableMeta != null) 'tableMeta': tableMeta!.toJson(),
      if (emphasis != null) 'emphasis': emphasis!.toJson(),
      if (xmlMeta != null) 'xmlMeta': xmlMeta!.toJson(),
      if (yamlMeta != null) 'yamlMeta': yamlMeta!.toJson(),
      if (jsonMeta != null) 'jsonMeta': jsonMeta!.toJson(),
      if (whitespace != null) 'whitespace': whitespace!.toJson(),
      if (children != null)
        'children': children!.map((k, v) => MapEntry(k, v.toJson())),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyMetadata &&
          runtimeType == other.runtimeType &&
          headerLevel == other.headerLevel &&
          divider == other.divider &&
          callout == other.callout &&
          codeBlock == other.codeBlock &&
          listMeta == other.listMeta &&
          tableMeta == other.tableMeta &&
          emphasis == other.emphasis &&
          xmlMeta == other.xmlMeta &&
          yamlMeta == other.yamlMeta &&
          jsonMeta == other.jsonMeta &&
          whitespace == other.whitespace &&
          _mapEquals(children, other.children);

  @override
  int get hashCode => Object.hash(
        headerLevel,
        divider,
        callout,
        codeBlock,
        listMeta,
        tableMeta,
        emphasis,
        xmlMeta,
        yamlMeta,
        jsonMeta,
        whitespace,
        _mapHash(children),
      );

  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  int _mapHash<K, V>(Map<K, V>? map) {
    if (map == null) return 0;
    return Object.hashAll(map.entries.map((e) => Object.hash(e.key, e.value)));
  }
}
