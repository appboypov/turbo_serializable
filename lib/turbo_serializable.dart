/// A serialization abstraction for the turbo ecosystem.
///
/// This library provides optional multi-format serialization through the
/// [TurboSerializable] class and its typed variant [TurboSerializableId].
/// Requires specification of a primary format, with automatic conversion to
/// all other supported formats.
library turbo_serializable;

export 'src/turbo_serializable.dart';
export 'src/turbo_serializable_id.dart';
export 'src/serialization_format.dart';
export 'src/format_converters.dart';
export 'src/xml_converter.dart' show mapToXml, xmlToMap;
