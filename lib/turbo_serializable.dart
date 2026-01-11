/// A serialization abstraction for the turbo ecosystem.
///
/// This library provides optional multi-format serialization through the
/// [TurboSerializable] class and its typed variant [TurboSerializableId].
/// Uses [TurboSerializableConfig] to specify callbacks for serialization methods,
/// with automatic conversion to all other supported formats.
library turbo_serializable;

export 'abstracts/has_to_json.dart';
export 'abstracts/turbo_serializable.dart';
export 'abstracts/turbo_serializable_id.dart';
export 'constants/turbo_constants.dart';
export 'converters/format_converters.dart';
export 'converters/xml_converter.dart';
export 'enums/case_style.dart';
export 'enums/serialization_format.dart';
export 'models/turbo_serializable_config.dart';
export 'converters/case_converter.dart' show convertCase;
