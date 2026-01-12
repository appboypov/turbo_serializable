/// Metadata for table elements.
///
/// Represents table formatting information including column alignment
/// and header row presence in Markdown documents.
class TableMeta {
  /// Creates a [TableMeta] instance.
  const TableMeta({
    required this.alignment,
    this.hasHeader = true,
  });

  /// Creates from JSON map.
  factory TableMeta.fromJson(Map<String, dynamic> json) {
    return TableMeta(
      alignment: (json['alignment'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      hasHeader: json['hasHeader'] as bool? ?? true,
    );
  }

  /// The alignment for each column: 'left', 'center', or 'right'.
  final List<String> alignment;

  /// Whether the table has a header row.
  final bool hasHeader;

  /// Creates a copy with updated values.
  TableMeta copyWith({
    List<String>? alignment,
    bool? hasHeader,
  }) {
    return TableMeta(
      alignment: alignment ?? this.alignment,
      hasHeader: hasHeader ?? this.hasHeader,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'alignment': alignment,
      'hasHeader': hasHeader,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableMeta &&
          runtimeType == other.runtimeType &&
          _listEquals(alignment, other.alignment) &&
          hasHeader == other.hasHeader;

  @override
  int get hashCode => Object.hash(_listHash(alignment), hasHeader);

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  int _listHash<T>(List<T> list) {
    return Object.hashAll(list);
  }
}
