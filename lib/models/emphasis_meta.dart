/// Metadata for text emphasis elements.
///
/// Represents text formatting such as bold, italic, strikethrough,
/// or inline code in Markdown documents.
class EmphasisMeta {
  /// Creates an [EmphasisMeta] instance.
  const EmphasisMeta({
    this.style,
  });

  /// Creates from JSON map.
  factory EmphasisMeta.fromJson(Map<String, dynamic> json) {
    return EmphasisMeta(
      style: json['style'] as String?,
    );
  }

  /// The emphasis style: 'bold', 'italic', 'strikethrough', or 'code'.
  final String? style;

  /// Creates a copy with updated values.
  EmphasisMeta copyWith({
    String? style,
  }) {
    return EmphasisMeta(
      style: style ?? this.style,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (style != null) 'style': style,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmphasisMeta &&
          runtimeType == other.runtimeType &&
          style == other.style;

  @override
  int get hashCode => style.hashCode;
}
