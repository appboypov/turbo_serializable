import 'package:test/test.dart';
import 'package:turbo_serializable/models/callout_meta.dart';
import 'package:turbo_serializable/models/code_block_meta.dart';
import 'package:turbo_serializable/models/divider_meta.dart';
import 'package:turbo_serializable/models/emphasis_meta.dart';
import 'package:turbo_serializable/models/json_meta.dart';
import 'package:turbo_serializable/models/key_metadata.dart';
import 'package:turbo_serializable/models/layout_aware_parse_result.dart';
import 'package:turbo_serializable/models/list_meta.dart';
import 'package:turbo_serializable/models/table_meta.dart';
import 'package:turbo_serializable/models/whitespace_meta.dart';
import 'package:turbo_serializable/models/xml_meta.dart';
import 'package:turbo_serializable/models/yaml_meta.dart';

void main() {
  group('DividerMeta', () {
    test('creates instance with default values', () {
      const meta = DividerMeta();
      expect(meta.before, false);
      expect(meta.after, false);
      expect(meta.style, null);
    });

    test('creates instance with all values', () {
      const meta = DividerMeta(
        before: true,
        after: true,
        style: '---',
      );
      expect(meta.before, true);
      expect(meta.after, true);
      expect(meta.style, '---');
    });

    test('toJson includes all non-null values', () {
      const meta = DividerMeta(before: true, after: false, style: '***');
      final json = meta.toJson();
      expect(json['before'], true);
      expect(json['after'], false);
      expect(json['style'], '***');
    });

    test('toJson omits null style', () {
      const meta = DividerMeta(before: true, after: false);
      final json = meta.toJson();
      expect(json.containsKey('style'), false);
    });

    test('fromJson creates instance correctly', () {
      final json = {'before': true, 'after': false, 'style': '___'};
      final meta = DividerMeta.fromJson(json);
      expect(meta.before, true);
      expect(meta.after, false);
      expect(meta.style, '___');
    });

    test('fromJson uses defaults for missing values', () {
      final json = <String, dynamic>{};
      final meta = DividerMeta.fromJson(json);
      expect(meta.before, false);
      expect(meta.after, false);
      expect(meta.style, null);
    });

    test('copyWith updates values', () {
      const meta = DividerMeta(before: false, after: false);
      final updated = meta.copyWith(before: true, style: '---');
      expect(updated.before, true);
      expect(updated.after, false);
      expect(updated.style, '---');
    });

    test('equality works correctly', () {
      const meta1 = DividerMeta(before: true, after: false, style: '---');
      const meta2 = DividerMeta(before: true, after: false, style: '---');
      const meta3 = DividerMeta(before: false, after: false, style: '---');
      expect(meta1 == meta2, true);
      expect(meta1 == meta3, false);
    });

    test('hashCode is consistent', () {
      const meta1 = DividerMeta(before: true, after: false, style: '---');
      const meta2 = DividerMeta(before: true, after: false, style: '---');
      expect(meta1.hashCode, meta2.hashCode);
    });
  });

  group('CalloutMeta', () {
    test('creates instance correctly', () {
      const meta = CalloutMeta(
        type: 'note',
        content: 'This is a note',
        position: 'before',
      );
      expect(meta.type, 'note');
      expect(meta.content, 'This is a note');
      expect(meta.position, 'before');
    });

    test('toJson includes all values', () {
      const meta = CalloutMeta(
        type: 'warning',
        content: 'Warning message',
        position: 'after',
      );
      final json = meta.toJson();
      expect(json['type'], 'warning');
      expect(json['content'], 'Warning message');
      expect(json['position'], 'after');
    });

    test('fromJson creates instance correctly', () {
      final json = {
        'type': 'tip',
        'content': 'Tip content',
        'position': 'before',
      };
      final meta = CalloutMeta.fromJson(json);
      expect(meta.type, 'tip');
      expect(meta.content, 'Tip content');
      expect(meta.position, 'before');
    });

    test('copyWith updates values', () {
      const meta = CalloutMeta(
        type: 'note',
        content: 'Old',
        position: 'before',
      );
      final updated = meta.copyWith(content: 'New');
      expect(updated.type, 'note');
      expect(updated.content, 'New');
      expect(updated.position, 'before');
    });
  });

  group('CodeBlockMeta', () {
    test('creates instance with defaults', () {
      const meta = CodeBlockMeta();
      expect(meta.language, null);
      expect(meta.filename, null);
      expect(meta.isInline, false);
    });

    test('toJson omits null values', () {
      const meta = CodeBlockMeta(isInline: true);
      final json = meta.toJson();
      expect(json.containsKey('language'), false);
      expect(json.containsKey('filename'), false);
      expect(json['isInline'], true);
    });

    test('fromJson uses defaults', () {
      final json = <String, dynamic>{};
      final meta = CodeBlockMeta.fromJson(json);
      expect(meta.isInline, false);
    });
  });

  group('ListMeta', () {
    test('creates instance correctly', () {
      const meta = ListMeta(
        type: 'unordered',
        marker: '-',
        startNumber: null,
      );
      expect(meta.type, 'unordered');
      expect(meta.marker, '-');
      expect(meta.startNumber, null);
    });

    test('toJson includes startNumber when present', () {
      const meta = ListMeta(type: 'ordered', startNumber: 5);
      final json = meta.toJson();
      expect(json['startNumber'], 5);
    });
  });

  group('TableMeta', () {
    test('creates instance correctly', () {
      const meta = TableMeta(
        alignment: ['left', 'center', 'right'],
        hasHeader: true,
      );
      expect(meta.alignment, ['left', 'center', 'right']);
      expect(meta.hasHeader, true);
    });

    test('fromJson handles empty alignment', () {
      final json = {'hasHeader': false};
      final meta = TableMeta.fromJson(json);
      expect(meta.alignment, []);
      expect(meta.hasHeader, false);
    });
  });

  group('EmphasisMeta', () {
    test('creates instance correctly', () {
      const meta = EmphasisMeta(style: 'bold');
      expect(meta.style, 'bold');
    });

    test('toJson omits null style', () {
      const meta = EmphasisMeta();
      final json = meta.toJson();
      expect(json.isEmpty, true);
    });
  });

  group('WhitespaceMeta', () {
    test('creates instance with defaults', () {
      const meta = WhitespaceMeta();
      expect(meta.leadingNewlines, 0);
      expect(meta.trailingNewlines, 0);
      expect(meta.lineEnding, '\n');
    });

    test('fromJson uses defaults', () {
      final json = <String, dynamic>{};
      final meta = WhitespaceMeta.fromJson(json);
      expect(meta.lineEnding, '\n');
    });
  });

  group('JsonMeta', () {
    test('toJson omits null values', () {
      const meta = JsonMeta();
      final json = meta.toJson();
      expect(json.isEmpty, true);
    });
  });

  group('YamlMeta', () {
    test('creates instance with default style', () {
      const meta = YamlMeta();
      expect(meta.style, 'block');
    });

    test('fromJson uses default style', () {
      final json = <String, dynamic>{};
      final meta = YamlMeta.fromJson(json);
      expect(meta.style, 'block');
    });
  });

  group('XmlMeta', () {
    test('creates instance correctly', () {
      const meta = XmlMeta(
        attributes: {'id': '123', 'class': 'test'},
        isCdata: true,
      );
      expect(meta.attributes, {'id': '123', 'class': 'test'});
      expect(meta.isCdata, true);
    });

    test('fromJson handles attributes map', () {
      final json = {
        'attributes': {'id': '123'},
        'isCdata': false,
      };
      final meta = XmlMeta.fromJson(json);
      expect(meta.attributes, {'id': '123'});
      expect(meta.isCdata, false);
    });
  });

  group('KeyMetadata', () {
    test('creates instance with all properties', () {
      const divider = DividerMeta(before: true);
      const callout = CalloutMeta(
        type: 'note',
        content: 'Test',
        position: 'before',
      );
      const meta = KeyMetadata(
        headerLevel: 2,
        divider: divider,
        callout: callout,
      );
      expect(meta.headerLevel, 2);
      expect(meta.divider, divider);
      expect(meta.callout, callout);
    });

    test('toJson includes nested meta objects', () {
      const divider = DividerMeta(before: true, style: '---');
      const meta = KeyMetadata(divider: divider);
      final json = meta.toJson();
      expect(json['divider'], isA<Map<String, dynamic>>());
      expect(json['divider']['before'], true);
      expect(json['divider']['style'], '---');
    });

    test('toJson includes children map', () {
      const childMeta = KeyMetadata(headerLevel: 3);
      const meta = KeyMetadata(
        headerLevel: 2,
        children: {'child': childMeta},
      );
      final json = meta.toJson();
      expect(json['children'], isA<Map<String, dynamic>>());
      expect(json['children']['child']['headerLevel'], 3);
    });

    test('fromJson creates nested meta objects', () {
      final json = {
        'headerLevel': 2,
        'divider': {'before': true, 'after': false, 'style': '---'},
        'callout': {
          'type': 'warning',
          'content': 'Warning',
          'position': 'before',
        },
      };
      final meta = KeyMetadata.fromJson(json);
      expect(meta.headerLevel, 2);
      expect(meta.divider?.before, true);
      expect(meta.divider?.style, '---');
      expect(meta.callout?.type, 'warning');
    });

    test('fromJson creates nested children', () {
      final json = {
        'headerLevel': 2,
        'children': {
          'child1': {'headerLevel': 3},
          'child2': {'headerLevel': 4},
        },
      };
      final meta = KeyMetadata.fromJson(json);
      expect(meta.children?.length, 2);
      expect(meta.children?['child1']?.headerLevel, 3);
      expect(meta.children?['child2']?.headerLevel, 4);
    });

    test('copyWith updates values', () {
      const meta = KeyMetadata(headerLevel: 2);
      final updated = meta.copyWith(headerLevel: 3);
      expect(updated.headerLevel, 3);
    });

    test('equality works with nested children', () {
      const child1 = KeyMetadata(headerLevel: 3);
      const child2 = KeyMetadata(headerLevel: 3);
      const meta1 = KeyMetadata(
        headerLevel: 2,
        children: {'child': child1},
      );
      const meta2 = KeyMetadata(
        headerLevel: 2,
        children: {'child': child2},
      );
      expect(meta1 == meta2, true);
    });
  });

  group('LayoutAwareParseResult', () {
    test('creates instance correctly', () {
      const result = LayoutAwareParseResult(
        data: {'key': 'value'},
        keyMeta: {
          'key': {'headerLevel': 2}
        },
      );
      expect(result.data['key'], 'value');
      expect(result.keyMeta?['key']['headerLevel'], 2);
    });

    test('toJson includes data and keyMeta', () {
      const result = LayoutAwareParseResult(
        data: {'test': 'value'},
        keyMeta: {'test': {}},
      );
      final json = result.toJson();
      expect(json['data'], {'test': 'value'});
      expect(json['keyMeta'], {'test': {}});
    });

    test('toJson omits null keyMeta', () {
      const result = LayoutAwareParseResult(data: {'key': 'value'});
      final json = result.toJson();
      expect(json.containsKey('keyMeta'), false);
    });

    test('fromJson creates instance correctly', () {
      final json = {
        'data': {'key': 'value'},
        'keyMeta': {
          'key': {'headerLevel': 2}
        },
      };
      final result = LayoutAwareParseResult.fromJson(json);
      expect(result.data['key'], 'value');
      expect(result.keyMeta?['key']['headerLevel'], 2);
    });

    test('copyWith updates values', () {
      const result = LayoutAwareParseResult(data: {'old': 'value'});
      final updated = result.copyWith(data: {'new': 'value'});
      expect(updated.data['new'], 'value');
    });
  });

  group('Round-trip serialization', () {
    test('DividerMeta round-trip', () {
      const original = DividerMeta(before: true, after: true, style: '***');
      final json = original.toJson();
      final restored = DividerMeta.fromJson(json);
      expect(restored, original);
    });

    test('KeyMetadata round-trip with nested children', () {
      const original = KeyMetadata(
        headerLevel: 2,
        divider: DividerMeta(before: true),
        children: {
          'child': KeyMetadata(
            headerLevel: 3,
            emphasis: EmphasisMeta(style: 'bold'),
          ),
        },
      );
      final json = original.toJson();
      final restored = KeyMetadata.fromJson(json);
      expect(restored.headerLevel, original.headerLevel);
      expect(restored.divider?.before, original.divider?.before);
      expect(restored.children?['child']?.headerLevel, 3);
      expect(restored.children?['child']?.emphasis?.style, 'bold');
    });

    test('LayoutAwareParseResult round-trip', () {
      const original = LayoutAwareParseResult(
        data: {'key': 'value'},
        keyMeta: {
          'key': {
            'headerLevel': 2,
            'divider': {'before': true},
          },
        },
      );
      final json = original.toJson();
      final restored = LayoutAwareParseResult.fromJson(json);
      expect(restored.data, original.data);
      expect(restored.keyMeta, original.keyMeta);
    });
  });
}
