/// Metadata for YAML formatting.
///
/// Represents YAML-specific formatting information including anchors,
/// aliases, comments, and scalar presentation styles.
class YamlMeta {
  /// Creates a [YamlMeta] instance.
  const YamlMeta({
    this.anchor,
    this.alias,
    this.comment,
    this.style = 'block',
    this.scalarStyle,
  });

  /// Creates from JSON map.
  factory YamlMeta.fromJson(Map<String, dynamic> json) {
    return YamlMeta(
      anchor: json['anchor'] as String?,
      alias: json['alias'] as String?,
      comment: json['comment'] as String?,
      style: json['style'] as String? ?? 'block',
      scalarStyle: json['scalarStyle'] as String?,
    );
  }

  /// The anchor name (e.g., '&name').
  final String? anchor;

  /// The alias reference (e.g., '*name').
  final String? alias;

  /// Comment text associated with this key.
  final String? comment;

  /// The style: 'block' or 'flow'.
  final String style;

  /// The scalar style: 'literal', 'folded', 'single-quoted', 'double-quoted'.
  final String? scalarStyle;

  /// Creates a copy with updated values.
  YamlMeta copyWith({
    String? anchor,
    String? alias,
    String? comment,
    String? style,
    String? scalarStyle,
  }) {
    return YamlMeta(
      anchor: anchor ?? this.anchor,
      alias: alias ?? this.alias,
      comment: comment ?? this.comment,
      style: style ?? this.style,
      scalarStyle: scalarStyle ?? this.scalarStyle,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (anchor != null) 'anchor': anchor,
      if (alias != null) 'alias': alias,
      if (comment != null) 'comment': comment,
      'style': style,
      if (scalarStyle != null) 'scalarStyle': scalarStyle,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YamlMeta &&
          runtimeType == other.runtimeType &&
          anchor == other.anchor &&
          alias == other.alias &&
          comment == other.comment &&
          style == other.style &&
          scalarStyle == other.scalarStyle;

  @override
  int get hashCode => Object.hash(
        anchor,
        alias,
        comment,
        style,
        scalarStyle,
      );
}
