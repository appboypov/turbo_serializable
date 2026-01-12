/// Metadata for JSON formatting.
///
/// Represents JSON-specific formatting information such as indentation
/// and trailing comma preferences.
class JsonMeta {
  /// Number of spaces used for indentation.
  final int? indentSpaces;

  /// Whether trailing commas are allowed.
  final bool? trailingComma;

  /// Creates a [JsonMeta] instance.
  const JsonMeta({
    this.indentSpaces,
    this.trailingComma,
  });

  /// Creates a copy with updated values.
  JsonMeta copyWith({
    int? indentSpaces,
    bool? trailingComma,
  }) {
    return JsonMeta(
      indentSpaces: indentSpaces ?? this.indentSpaces,
      trailingComma: trailingComma ?? this.trailingComma,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (indentSpaces != null) 'indentSpaces': indentSpaces,
      if (trailingComma != null) 'trailingComma': trailingComma,
    };
  }

  /// Creates from JSON map.
  factory JsonMeta.fromJson(Map<String, dynamic> json) {
    return JsonMeta(
      indentSpaces: json['indentSpaces'] as int?,
      trailingComma: json['trailingComma'] as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonMeta &&
          runtimeType == other.runtimeType &&
          indentSpaces == other.indentSpaces &&
          trailingComma == other.trailingComma;

  @override
  int get hashCode => Object.hash(indentSpaces, trailingComma);
}
