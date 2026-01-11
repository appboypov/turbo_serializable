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
}
