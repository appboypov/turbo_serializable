/// Metadata for code block elements.
///
/// Represents code blocks (fenced or inline) that appear in Markdown
/// documents, including language specification and optional filename.
class CodeBlockMeta {
  /// Creates a [CodeBlockMeta] instance.
  const CodeBlockMeta({
    this.language,
    this.filename,
    this.isInline = false,
  });

  /// Creates from JSON map.
  factory CodeBlockMeta.fromJson(Map<String, dynamic> json) {
    return CodeBlockMeta(
      language: json['language'] as String?,
      filename: json['filename'] as String?,
      isInline: json['isInline'] as bool? ?? false,
    );
  }

  /// The programming language of the code block.
  final String? language;

  /// An optional filename associated with the code block.
  final String? filename;

  /// Whether this is an inline code block (as opposed to a fenced block).
  final bool isInline;

  /// Creates a copy with updated values.
  CodeBlockMeta copyWith({
    String? language,
    String? filename,
    bool? isInline,
  }) {
    return CodeBlockMeta(
      language: language ?? this.language,
      filename: filename ?? this.filename,
      isInline: isInline ?? this.isInline,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (language != null) 'language': language,
      if (filename != null) 'filename': filename,
      'isInline': isInline,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeBlockMeta &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          filename == other.filename &&
          isInline == other.isInline;

  @override
  int get hashCode => Object.hash(language, filename, isInline);
}
