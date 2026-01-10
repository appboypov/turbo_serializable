import 'package:test/test.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

class TestSerializable extends TurboSerializable<Object?> {
  final String name;

  TestSerializable(this.name);

  @override
  Map<String, dynamic>? toJson() => {'name': name};
}

class TestSerializableId extends TurboSerializableId<String, Object?> {
  final String testId;

  TestSerializableId(this.testId, {super.isLocalDefault});

  @override
  String get id => testId;
}

void main() {
  test('TurboSerializable can be imported and extended', () {
    final obj = TestSerializable('test');
    expect(obj.toJson(), {'name': 'test'});
    expect(obj.validate(), isNull);
    expect(obj.fromJson({}), isNull);
    expect(obj.toYaml(), isNull);
    expect(obj.fromYaml(''), isNull);
    expect(obj.toMarkdown(), isNull);
    expect(obj.fromMarkdown(''), isNull);
    expect(obj.metaData, isNull);
  });

  test('TurboSerializableId can be imported and extended', () {
    final obj = TestSerializableId('123');
    expect(obj.id, '123');
    expect(obj.isLocalDefault, false);
    expect(obj.metaData, isNull);

    final localObj = TestSerializableId('456', isLocalDefault: true);
    expect(localObj.id, '456');
    expect(localObj.isLocalDefault, true);
  });
}
