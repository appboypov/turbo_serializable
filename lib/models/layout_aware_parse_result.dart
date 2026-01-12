/// Result of parsing a document with layout awareness.
///
/// Contains both the parsed data and the extracted key-level metadata
/// for preserving layout information during format conversions.
class LayoutAwareParseResult {
  /// Creates a [LayoutAwareParseResult] instance.
  const LayoutAwareParseResult({
    required this.data,
    this.keyMeta,
  });

  /// Creates from JSON map.
  factory LayoutAwareParseResult.fromJson(Map<String, dynamic> json) {
    return LayoutAwareParseResult(
      data: Map<String, dynamic>.from(json['data'] as Map<String, dynamic>),
      keyMeta: json['keyMeta'] != null
          ? Map<String, dynamic>.from(json['keyMeta'] as Map<String, dynamic>)
          : null,
    );
  }

  /// The parsed data map.
  final Map<String, dynamic> data;

  /// The extracted key-level metadata.
  final Map<String, dynamic>? keyMeta;

  /// Creates a copy with updated values.
  LayoutAwareParseResult copyWith({
    Map<String, dynamic>? data,
    Map<String, dynamic>? keyMeta,
  }) {
    return LayoutAwareParseResult(
      data: data ?? this.data,
      keyMeta: keyMeta ?? this.keyMeta,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      if (keyMeta != null) 'keyMeta': keyMeta,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayoutAwareParseResult &&
          runtimeType == other.runtimeType &&
          _mapEquals(data, other.data) &&
          _mapEquals(keyMeta, other.keyMeta);

  @override
  int get hashCode => Object.hash(_mapHash(data), _mapHash(keyMeta));

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
