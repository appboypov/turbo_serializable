import 'package:test/test.dart';
import 'package:turbo_serializable/turbo_serializable.dart';
import 'package:xml/xml.dart';

void main() {
  group('convertToPascalCase', () {
    test('converts camelCase', () {
      expect(convertToPascalCase('userName'), 'UserName');
      expect(convertToPascalCase('firstName'), 'FirstName');
      expect(convertToPascalCase('myVariableName'), 'MyVariableName');
    });

    test('converts snake_case', () {
      expect(convertToPascalCase('user_name'), 'UserName');
      expect(convertToPascalCase('first_name'), 'FirstName');
      expect(convertToPascalCase('my_variable_name'), 'MyVariableName');
    });

    test('converts kebab-case', () {
      expect(convertToPascalCase('user-name'), 'UserName');
      expect(convertToPascalCase('first-name'), 'FirstName');
      expect(convertToPascalCase('my-variable-name'), 'MyVariableName');
    });

    test('handles already PascalCase', () {
      expect(convertToPascalCase('UserName'), 'UserName');
      expect(convertToPascalCase('FirstName'), 'FirstName');
    });

    test('handles empty string', () {
      expect(convertToPascalCase(''), '');
    });

    test('handles single character', () {
      expect(convertToPascalCase('a'), 'A');
      expect(convertToPascalCase('A'), 'A');
    });

    test('handles all caps', () {
      expect(convertToPascalCase('API'), 'Api');
      expect(convertToPascalCase('HTML'), 'Html');
    });

    test('handles numbers', () {
      expect(convertToPascalCase('user123'), 'User123');
      expect(convertToPascalCase('user_123_name'), 'User123Name');
    });

    test('handles multiple separators', () {
      expect(convertToPascalCase('user__name'), 'UserName');
      expect(convertToPascalCase('user--name'), 'UserName');
      expect(convertToPascalCase('user_-name'), 'UserName');
    });

    test('handles mixed case input', () {
      expect(convertToPascalCase('XMLParser'), 'Xmlparser');
      expect(convertToPascalCase('parseXML'), 'ParseXml');
    });
  });

  group('buildXmlElement', () {
    test('builds null value', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(builder, null, includeNulls: false);
      });
      final doc = builder.buildDocument();
      expect(doc.rootElement.children, isEmpty);
    });

    test('builds null value when includeNulls is true', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(builder, null, includeNulls: true);
      });
      final doc = builder.buildDocument();
      expect(doc.rootElement.innerText, '');
    });

    test('builds simple map', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(builder, {'name': 'test', 'age': 30});
      });
      final doc = builder.buildDocument();
      expect(doc.rootElement.findElements('name').first.innerText, 'test');
      expect(doc.rootElement.findElements('age').first.innerText, '30');
    });

    test('builds nested maps', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(builder, {
          'user': {'name': 'test'}
        });
      });
      final doc = builder.buildDocument();
      final user = doc.rootElement.findElements('user').first;
      expect(user.findElements('name').first.innerText, 'test');
    });

    test('builds lists as multiple elements', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(builder, {
          'items': ['a', 'b', 'c']
        });
      });
      final doc = builder.buildDocument();
      final items = doc.rootElement.findElements('items').toList();
      expect(items.length, 3);
      expect(items[0].innerText, 'a');
      expect(items[1].innerText, 'b');
      expect(items[2].innerText, 'c');
    });

    test('skips null list items when includeNulls is false', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(builder, {
          'items': ['a', null, 'c']
        }, includeNulls: false);
      });
      final doc = builder.buildDocument();
      final items = doc.rootElement.findElements('items').toList();
      expect(items.length, 2);
    });

    test('uses PascalCase when requested', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(builder, {'user_name': 'test'}, usePascalCase: true);
      });
      final doc = builder.buildDocument();
      expect(doc.rootElement.findElements('UserName').length, 1);
    });

    test('builds empty values', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(builder, {'empty': ''});
      });
      final doc = builder.buildDocument();
      expect(doc.rootElement.findElements('empty').first.innerText, '');
    });
  });

  group('convertValueToXmlString', () {
    test('converts boolean true', () {
      expect(convertValueToXmlString(true), 'true');
    });

    test('converts boolean false', () {
      expect(convertValueToXmlString(false), 'false');
    });

    test('converts integer', () {
      expect(convertValueToXmlString(42), '42');
      expect(convertValueToXmlString(-100), '-100');
      expect(convertValueToXmlString(0), '0');
    });

    test('converts double', () {
      expect(convertValueToXmlString(3.14), '3.14');
      expect(convertValueToXmlString(-2.5), '-2.5');
      expect(convertValueToXmlString(0.0), '0.0');
    });

    test('converts string', () {
      expect(convertValueToXmlString('hello'), 'hello');
      expect(convertValueToXmlString(''), '');
    });
  });

  group('parseXmlElement', () {
    test('parses text-only element', () {
      final doc = XmlDocument.parse('<root>text content</root>');
      final result = parseXmlElement(doc.rootElement);
      expect(result, 'text content');
    });

    test('parses numeric text', () {
      final doc = XmlDocument.parse('<root>42</root>');
      final result = parseXmlElement(doc.rootElement);
      expect(result, 42);
    });

    test('parses boolean text', () {
      final docTrue = XmlDocument.parse('<root>true</root>');
      expect(parseXmlElement(docTrue.rootElement), true);

      final docFalse = XmlDocument.parse('<root>false</root>');
      expect(parseXmlElement(docFalse.rootElement), false);
    });

    test('parses element with children', () {
      final doc = XmlDocument.parse('<root><name>test</name><age>30</age></root>');
      final result = parseXmlElement(doc.rootElement) as Map<String, dynamic>;
      expect(result['name'], 'test');
      expect(result['age'], 30);
    });

    test('parses multiple elements with same name as list', () {
      final doc = XmlDocument.parse('<root><item>a</item><item>b</item><item>c</item></root>');
      final result = parseXmlElement(doc.rootElement) as Map<String, dynamic>;
      expect(result['item'], ['a', 'b', 'c']);
    });

    test('parses empty element', () {
      final doc = XmlDocument.parse('<root></root>');
      final result = parseXmlElement(doc.rootElement);
      expect(result, isNull);
    });

    test('parses mixed content', () {
      final doc = XmlDocument.parse('<root>text <child>nested</child></root>');
      final result = parseXmlElement(doc.rootElement) as Map<String, dynamic>;
      expect(result['_text'], 'text');
      expect(result['child'], 'nested');
    });

    test('parses nested structures', () {
      final doc = XmlDocument.parse('''
        <root>
          <user>
            <name>John</name>
            <email>john@example.com</email>
          </user>
        </root>
      ''');
      final result = parseXmlElement(doc.rootElement) as Map<String, dynamic>;
      expect(result['user']['name'], 'John');
      expect(result['user']['email'], 'john@example.com');
    });
  });

  group('parseXmlValue', () {
    test('parses empty string as null', () {
      expect(parseXmlValue(''), isNull);
    });

    test('parses true (case insensitive)', () {
      expect(parseXmlValue('true'), true);
      expect(parseXmlValue('TRUE'), true);
      expect(parseXmlValue('True'), true);
    });

    test('parses false (case insensitive)', () {
      expect(parseXmlValue('false'), false);
      expect(parseXmlValue('FALSE'), false);
      expect(parseXmlValue('False'), false);
    });

    test('parses integers', () {
      expect(parseXmlValue('42'), 42);
      expect(parseXmlValue('-100'), -100);
      expect(parseXmlValue('0'), 0);
    });

    test('parses doubles', () {
      expect(parseXmlValue('3.14'), 3.14);
      expect(parseXmlValue('-2.5'), -2.5);
      expect(parseXmlValue('0.0'), 0.0);
    });

    test('returns string for non-numeric text', () {
      expect(parseXmlValue('hello'), 'hello');
      expect(parseXmlValue('hello world'), 'hello world');
    });

    test('returns string for invalid numbers', () {
      expect(parseXmlValue('12.34.56'), '12.34.56');
      expect(parseXmlValue('1,234'), '1,234');
    });
  });

  group('mapToXml', () {
    test('creates XML with root element', () {
      final result = mapToXml({'name': 'test'});
      expect(result, contains('<?xml'));
      expect(result, contains('<root>'));
      expect(result, contains('<name>test</name>'));
      expect(result, contains('</root>'));
    });

    test('uses custom root element name', () {
      final result = mapToXml({'name': 'test'}, rootElementName: 'user');
      expect(result, contains('<user>'));
      expect(result, contains('</user>'));
    });

    test('uses PascalCase root and elements', () {
      final result = mapToXml({'user_name': 'test'}, usePascalCase: true);
      expect(result, contains('<Root>'));
      expect(result, contains('<UserName>'));
    });

    test('includes metadata', () {
      final result = mapToXml(
        {'data': 'value'},
        metaData: {'version': '1.0'},
      );
      expect(result, contains('<_meta>'));
      expect(result, contains('<version>1.0</version>'));
    });

    test('PascalCase with metadata', () {
      final result = mapToXml(
        {'data': 'value'},
        usePascalCase: true,
        metaData: {'version': '1.0'},
      );
      expect(result, contains('<_Meta>'));
      expect(result, contains('<Version>1.0</Version>'));
    });

    test('handles null values', () {
      final resultExclude = mapToXml({'key': null}, includeNulls: false);
      expect(resultExclude, isNot(contains('<key>')));

      final resultInclude = mapToXml({'key': null}, includeNulls: true);
      expect(resultInclude, contains('<key>'));
    });

    test('creates minified XML when prettyPrint is false', () {
      final result = mapToXml({'name': 'test'}, prettyPrint: false);
      expect(result, isNot(contains('\n  ')));
    });
  });

  group('xmlToMap', () {
    test('parses simple XML', () {
      final result = xmlToMap('<root><name>test</name></root>');
      expect(result['name'], 'test');
    });

    test('parses nested XML', () {
      final result = xmlToMap('<root><user><name>test</name></user></root>');
      expect(result['user']['name'], 'test');
    });

    test('parses repeated elements as list', () {
      final result = xmlToMap('<root><item>a</item><item>b</item></root>');
      expect(result['item'], ['a', 'b']);
    });

    test('throws on invalid XML', () {
      expect(
        () => xmlToMap('<invalid>'),
        throwsA(isA<FormatException>()),
      );
    });

    test('parses numeric values', () {
      final result = xmlToMap('<root><count>42</count><price>9.99</price></root>');
      expect(result['count'], 42);
      expect(result['price'], 9.99);
    });

    test('parses boolean values', () {
      final result = xmlToMap('<root><active>true</active><deleted>false</deleted></root>');
      expect(result['active'], true);
      expect(result['deleted'], false);
    });
  });
}
