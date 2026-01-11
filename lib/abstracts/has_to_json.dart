/// Interface for objects that can be serialized to JSON.
///
/// Used to constrain metadata types that have a `toJson()` method.
abstract interface class HasToJson {
  /// Converts this object to a JSON map.
  Map<String, dynamic> toJson();
}
