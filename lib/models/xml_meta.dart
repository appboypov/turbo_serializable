/// Metadata for XML formatting.
///
/// Represents XML-specific formatting information including attributes,
/// CDATA sections, comments, and namespace declarations.
class XmlMeta {
  /// Creates an [XmlMeta] instance.
  const XmlMeta({
    this.attributes,
    this.isCdata = false,
    this.comment,
    this.namespace,
    this.prefix,
  });

  /// Creates from JSON map.
  factory XmlMeta.fromJson(Map<String, dynamic> json) {
    return XmlMeta(
      attributes: json['attributes'] != null
          ? Map<String, String>.from(json['attributes'] as Map<String, dynamic>)
          : null,
      isCdata: json['isCdata'] as bool? ?? false,
      comment: json['comment'] as String?,
      namespace: json['namespace'] as String?,
      prefix: json['prefix'] as String?,
    );
  }

  /// XML attributes as key-value pairs.
  final Map<String, String>? attributes;

  /// Whether this content is wrapped in CDATA.
  final bool isCdata;

  /// Comment text associated with this element.
  final String? comment;

  /// The namespace URI.
  final String? namespace;

  /// The namespace prefix.
  final String? prefix;

  /// Creates a copy with updated values.
  XmlMeta copyWith({
    Map<String, String>? attributes,
    bool? isCdata,
    String? comment,
    String? namespace,
    String? prefix,
  }) {
    return XmlMeta(
      attributes: attributes ?? this.attributes,
      isCdata: isCdata ?? this.isCdata,
      comment: comment ?? this.comment,
      namespace: namespace ?? this.namespace,
      prefix: prefix ?? this.prefix,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (attributes != null) 'attributes': attributes,
      'isCdata': isCdata,
      if (comment != null) 'comment': comment,
      if (namespace != null) 'namespace': namespace,
      if (prefix != null) 'prefix': prefix,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XmlMeta &&
          runtimeType == other.runtimeType &&
          _mapEquals(attributes, other.attributes) &&
          isCdata == other.isCdata &&
          comment == other.comment &&
          namespace == other.namespace &&
          prefix == other.prefix;

  @override
  int get hashCode => Object.hash(
        _mapHash(attributes),
        isCdata,
        comment,
        namespace,
        prefix,
      );

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
