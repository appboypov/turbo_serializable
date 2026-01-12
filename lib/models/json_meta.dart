/// Metadata for JSON formatting.
///
/// Represents JSON-specific formatting information such as indentation
/// and trailing comma preferences.
class JsonMeta {
  /// Creates a [JsonMeta] instance.
  const JsonMeta({
    this.indentSpaces,
    this.useTabs,
    this.trailingComma,
  });

  /// Creates from JSON map.
  factory JsonMeta.fromJson(Map<String, dynamic> json) {
    return JsonMeta(
      indentSpaces: json['indentSpaces'] as int?,
      useTabs: json['useTabs'] as bool?,
      trailingComma: json['trailingComma'] as bool?,
    );
  }

  /// Number of spaces used for indentation.
  final int? indentSpaces;

  /// Whether tabs are used for indentation instead of spaces.
  final bool? useTabs;

  /// Whether trailing commas are allowed.
  final bool? trailingComma;

  /// Creates a copy with updated values.
  JsonMeta copyWith({
    int? indentSpaces,
    bool? useTabs,
    bool? trailingComma,
  }) {
    return JsonMeta(
      indentSpaces: indentSpaces ?? this.indentSpaces,
      useTabs: useTabs ?? this.useTabs,
      trailingComma: trailingComma ?? this.trailingComma,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (indentSpaces != null) 'indentSpaces': indentSpaces,
      if (useTabs != null) 'useTabs': useTabs,
      if (trailingComma != null) 'trailingComma': trailingComma,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonMeta &&
          runtimeType == other.runtimeType &&
          indentSpaces == other.indentSpaces &&
          useTabs == other.useTabs &&
          trailingComma == other.trailingComma;

  @override
  int get hashCode => Object.hash(indentSpaces, useTabs, trailingComma);
}
