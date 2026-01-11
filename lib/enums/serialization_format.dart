/// Enumeration of supported serialization formats.
///
/// Used to specify the primary serialization format for a [TurboSerializable]
/// instance, indicating which serialization method is actually implemented.
enum SerializationFormat {
  /// JSON format (`Map<String, dynamic>`)
  jsonMap,

  /// YAML format (String)
  yamlString,

  /// Markdown format (String)
  markdownString,

  /// XML format (String)
  xmlString;
}
