/// Enumeration of supported serialization formats.
///
/// Used to specify the primary serialization format for a [TurboSerializable]
/// instance, indicating which serialization method is actually implemented.
enum SerializationFormat {
  /// JSON format (`Map<String, dynamic>`)
  json,

  /// YAML format (String)
  yaml,

  /// Markdown format (String)
  markdown,

  /// XML format (String)
  xml;

  /// Returns the name of the corresponding `to*()` method for this format.
  String get toMethodName {
    switch (this) {
      case SerializationFormat.json:
        return 'toJson';
      case SerializationFormat.yaml:
        return 'toYaml';
      case SerializationFormat.markdown:
        return 'toMarkdown';
      case SerializationFormat.xml:
        return 'toXml';
    }
  }

  /// Returns the name of the corresponding `from*()` method for this format.
  String get fromMethodName {
    switch (this) {
      case SerializationFormat.json:
        return 'fromJson';
      case SerializationFormat.yaml:
        return 'fromYaml';
      case SerializationFormat.markdown:
        return 'fromMarkdown';
      case SerializationFormat.xml:
        return 'fromXml';
    }
  }
}
