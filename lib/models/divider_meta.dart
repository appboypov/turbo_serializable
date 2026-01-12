/// Metadata for Markdown divider/horizontal rule elements.
///
/// Represents horizontal rules (`---`, `***`, `___`) that appear before
/// or after a key's content in Markdown documents.
class DividerMeta {
  /// Creates a [DividerMeta] instance.
  const DividerMeta({
    this.before = false,
    this.after = false,
    this.style,
  });

  /// Creates from JSON map.
  factory DividerMeta.fromJson(Map<String, dynamic> json) {
    return DividerMeta(
      before: json['before'] as bool? ?? false,
      after: json['after'] as bool? ?? false,
      style: json['style'] as String?,
    );
  }

  /// Whether a divider appears before this key's content.
  final bool before;

  /// Whether a divider appears after this key's content.
  final bool after;

  /// The style of the divider: `---`, `***`, or `___`.
  final String? style;

  /// Creates a copy with updated values.
  DividerMeta copyWith({
    bool? before,
    bool? after,
    String? style,
  }) {
    return DividerMeta(
      before: before ?? this.before,
      after: after ?? this.after,
      style: style ?? this.style,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'before': before,
      'after': after,
      if (style != null) 'style': style,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DividerMeta &&
          runtimeType == other.runtimeType &&
          before == other.before &&
          after == other.after &&
          style == other.style;

  @override
  int get hashCode => Object.hash(before, after, style);
}
