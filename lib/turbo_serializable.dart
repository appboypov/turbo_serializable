/// A serialization abstraction for the turbo ecosystem.
///
/// This library provides optional multi-format serialization through the
/// [TurboSerializable] class and its typed variant [TurboSerializableId].
/// Uses [TurboSerializableConfig] to specify callbacks for serialization methods,
/// with automatic conversion to all other supported formats.
library;

export 'abstracts/has_to_json.dart';
export 'abstracts/turbo_serializable.dart';
export 'abstracts/turbo_serializable_id.dart';
export 'constants/turbo_constants.dart';
export 'converters/format_converters.dart';
export 'converters/xml_converter.dart';
export 'enums/case_style.dart';
export 'enums/serialization_format.dart';
export 'models/turbo_serializable_config.dart';
export 'models/callout_meta.dart';
export 'models/code_block_meta.dart';
export 'models/divider_meta.dart';
export 'models/emphasis_meta.dart';
export 'models/json_meta.dart';
export 'models/key_metadata.dart';
export 'models/layout_aware_parse_result.dart';
export 'models/list_meta.dart';
export 'models/table_meta.dart';
export 'models/whitespace_meta.dart';
export 'models/xml_meta.dart';
export 'models/yaml_meta.dart';
export 'converters/case_converter.dart' show convertCase;
export 'generators/json_generator.dart' show JsonLayoutGenerator;
export 'generators/markdown_generator.dart' show MarkdownLayoutGenerator;
export 'generators/xml_generator.dart' show XmlLayoutGenerator;
export 'generators/yaml_generator.dart' show YamlLayoutGenerator;
export 'parsers/json_parser.dart' show JsonLayoutParser;
export 'parsers/markdown_parser.dart' show MarkdownLayoutParser;
export 'parsers/xml_parser.dart' show XmlLayoutParser;
export 'parsers/yaml_parser.dart' show YamlLayoutParser;
