/// Metadata for whitespace preservation.
///
/// Represents exact whitespace information including leading/trailing
/// newlines and raw whitespace strings for 100% round-trip fidelity.
class WhitespaceMeta {
  /// Creates a [WhitespaceMeta] instance.
  const WhitespaceMeta({
    this.leadingNewlines = 0,
    this.trailingNewlines = 0,
    this.rawLeading,
    this.rawTrailing,
    this.lineEnding = '\n',
  });

  /// Creates from JSON map.
  factory WhitespaceMeta.fromJson(Map<String, dynamic> json) {
    return WhitespaceMeta(
      leadingNewlines: json['leadingNewlines'] as int? ?? 0,
      trailingNewlines: json['trailingNewlines'] as int? ?? 0,
      rawLeading: json['rawLeading'] as String?,
      rawTrailing: json['rawTrailing'] as String?,
      lineEnding: json['lineEnding'] as String? ?? '\n',
    );
  }

  /// Number of leading newlines before this key's content.
  final int leadingNewlines;

  /// Number of trailing newlines after this key's content.
  final int trailingNewlines;

  /// Exact raw leading whitespace string.
  final String? rawLeading;

  /// Exact raw trailing whitespace string.
  final String? rawTrailing;

  /// Line ending style: '\n' or '\r\n'.
  final String lineEnding;

  /// Creates a copy with updated values.
  WhitespaceMeta copyWith({
    int? leadingNewlines,
    int? trailingNewlines,
    String? rawLeading,
    String? rawTrailing,
    String? lineEnding,
  }) {
    return WhitespaceMeta(
      leadingNewlines: leadingNewlines ?? this.leadingNewlines,
      trailingNewlines: trailingNewlines ?? this.trailingNewlines,
      rawLeading: rawLeading ?? this.rawLeading,
      rawTrailing: rawTrailing ?? this.rawTrailing,
      lineEnding: lineEnding ?? this.lineEnding,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'leadingNewlines': leadingNewlines,
      'trailingNewlines': trailingNewlines,
      if (rawLeading != null) 'rawLeading': rawLeading,
      if (rawTrailing != null) 'rawTrailing': rawTrailing,
      'lineEnding': lineEnding,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WhitespaceMeta &&
          runtimeType == other.runtimeType &&
          leadingNewlines == other.leadingNewlines &&
          trailingNewlines == other.trailingNewlines &&
          rawLeading == other.rawLeading &&
          rawTrailing == other.rawTrailing &&
          lineEnding == other.lineEnding;

  @override
  int get hashCode => Object.hash(
        leadingNewlines,
        trailingNewlines,
        rawLeading,
        rawTrailing,
        lineEnding,
      );
}
