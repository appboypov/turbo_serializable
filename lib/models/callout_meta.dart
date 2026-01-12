/// Metadata for Markdown callout elements.
///
/// Represents callouts (NOTE, WARNING, TIP, IMPORTANT, CAUTION) that appear
/// before or after a key's content in Markdown documents.
class CalloutMeta {
  /// Creates a [CalloutMeta] instance.
  const CalloutMeta({
    required this.type,
    required this.content,
    required this.position,
  });

  /// Creates from JSON map.
  factory CalloutMeta.fromJson(Map<String, dynamic> json) {
    return CalloutMeta(
      type: json['type'] as String,
      content: json['content'] as String,
      position: json['position'] as String,
    );
  }

  /// The type of callout: 'note', 'warning', 'tip', 'important', 'caution'.
  final String type;

  /// The content of the callout.
  final String content;

  /// The position of the callout: 'before' or 'after'.
  final String position;

  /// Creates a copy with updated values.
  CalloutMeta copyWith({
    String? type,
    String? content,
    String? position,
  }) {
    return CalloutMeta(
      type: type ?? this.type,
      content: content ?? this.content,
      position: position ?? this.position,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
      'position': position,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalloutMeta &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          content == other.content &&
          position == other.position;

  @override
  int get hashCode => Object.hash(type, content, position);
}
