import 'package:turbo_response/turbo_response.dart';

/// Base abstract class for serializable objects in the turbo ecosystem.
///
/// All serialization methods are optional and return null by default.
/// Subclasses override only the methods they need.
///
/// The type parameter [M] represents optional metadata (e.g., frontmatter).
/// Defaults to [dynamic] when not specified.
abstract class TurboSerializable<M> {
  /// Creates a [TurboSerializable] instance with optional [metaData].
  TurboSerializable({this.metaData});

  /// Optional metadata associated with this object.
  ///
  /// Useful for frontmatter, annotations, or other auxiliary data
  /// that should travel with the serializable object.
  final M? metaData;

  /// Validates the object's state.
  ///
  /// Returns null if valid, or a [TurboResponse.fail] if invalid.
  TurboResponse<T>? validate<T>() => null;

  /// Converts this object to a JSON map.
  ///
  /// Returns null if not implemented.
  Map<String, dynamic>? toJson() => null;

  /// Creates an instance from a JSON map.
  ///
  /// Returns null if not implemented.
  T? fromJson<T>(Map<String, dynamic> json) => null;

  /// Converts this object to a YAML string.
  ///
  /// Returns null if not implemented.
  String? toYaml() => null;

  /// Creates an instance from a YAML string.
  ///
  /// Returns null if not implemented.
  T? fromYaml<T>(String yaml) => null;

  /// Converts this object to a Markdown string.
  ///
  /// Returns null if not implemented.
  String? toMarkdown() => null;

  /// Creates an instance from a Markdown string.
  ///
  /// Returns null if not implemented.
  T? fromMarkdown<T>(String markdown) => null;

  /// Converts this object to an XML string.
  ///
  /// Returns null if not implemented.
  String? toXml() => null;

  /// Creates an instance from an XML string.
  ///
  /// Returns null if not implemented.
  T? fromXml<T>(String xml) => null;
}
