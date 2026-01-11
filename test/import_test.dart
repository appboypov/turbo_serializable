import 'package:test/test.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

class TestSerializable extends TurboSerializable<Object?> {
  final String name;

  TestSerializable(this.name)
      : super(config: TurboSerializableConfig(
          toJson: (instance) {
            final self = instance as TestSerializable;
            return {'name': self.name};
          },
        ));
}

class TestSerializableId extends TurboSerializableId<String, Object?> {
  final String testId;

  TestSerializableId(
    this.testId, {
    super.isLocalDefault,
  }) : super(
            config: TurboSerializableConfig(
          toJson: (_) => null,
        ));

  @override
  String get id => testId;
}

void main() {
  test('TurboSerializable can be imported and extended', () {
    final obj = TestSerializable('test');
    expect(obj.toJson(), {'name': 'test'});
    expect(obj.validate(), isNull);
    // toYaml converts from JSON when toJson is provided
    expect(obj.toYaml(), isNotNull);
    expect(obj.toYaml(), contains('name: test'));
    // toMarkdown converts from JSON
    expect(obj.toMarkdown(), isNotNull);
    // toXml converts from JSON
    expect(obj.toXml(), isNotNull);
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
