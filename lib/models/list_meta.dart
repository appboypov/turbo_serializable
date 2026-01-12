/// Metadata for list elements.
///
/// Represents list formatting information for unordered, ordered, or
/// task lists in Markdown documents.
class ListMeta {
  /// Creates a [ListMeta] instance.
  const ListMeta({
    required this.type,
    this.marker,
    this.startNumber,
  });

  /// Creates from JSON map.
  factory ListMeta.fromJson(Map<String, dynamic> json) {
    return ListMeta(
      type: json['type'] as String,
      marker: json['marker'] as String?,
      startNumber: json['startNumber'] as int?,
    );
  }

  /// The type of list: 'unordered', 'ordered', or 'task'.
  final String type;

  /// The marker used: '-', '*', '+', '1.', '1)', etc.
  final String? marker;

  /// The starting number for ordered lists.
  final int? startNumber;

  /// Creates a copy with updated values.
  ListMeta copyWith({
    String? type,
    String? marker,
    int? startNumber,
  }) {
    return ListMeta(
      type: type ?? this.type,
      marker: marker ?? this.marker,
      startNumber: startNumber ?? this.startNumber,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (marker != null) 'marker': marker,
      if (startNumber != null) 'startNumber': startNumber,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListMeta &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          marker == other.marker &&
          startNumber == other.startNumber;

  @override
  int get hashCode => Object.hash(type, marker, startNumber);
}
