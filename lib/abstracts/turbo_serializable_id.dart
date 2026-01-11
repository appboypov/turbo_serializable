import 'package:turbo_serializable/abstracts/turbo_serializable.dart';

/// Abstract class for serializable objects with a typed identifier.
///
/// Extends [TurboSerializable] with an [id] getter and [isLocalDefault] flag.
///
/// Type parameters:
/// - [T]: The type of the identifier (e.g., String, int)
/// - [M]: The type of optional metadata (e.g., frontmatter). Defaults to [dynamic].
abstract class TurboSerializableId<T extends Object, M>
    extends TurboSerializable<M> {
  /// Creates a [TurboSerializableId] instance.
  TurboSerializableId({
    required super.config,
    super.isLocalDefault = false,
    super.metaData,
  });

  /// The unique identifier for this object.
  T get id;
}
