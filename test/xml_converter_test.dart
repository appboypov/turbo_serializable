import 'package:test/test.dart';
import 'package:turbo_serializable/turbo_serializable.dart';
import 'package:xml/xml.dart';

void main() {
  group('convertCase - PascalCase', () {
    test('converts camelCase', () {
      expect(convertCase('userName', CaseStyle.pascalCase), 'UserName');
      expect(convertCase('firstName', CaseStyle.pascalCase), 'FirstName');
      expect(convertCase('myVariableName', CaseStyle.pascalCase),
          'MyVariableName');
    });

    test('converts snake_case', () {
      expect(convertCase('user_name', CaseStyle.pascalCase), 'UserName');
      expect(convertCase('first_name', CaseStyle.pascalCase), 'FirstName');
      expect(convertCase('my_variable_name', CaseStyle.pascalCase),
          'MyVariableName');
    });

    test('converts kebab-case', () {
      expect(convertCase('user-name', CaseStyle.pascalCase), 'UserName');
      expect(convertCase('first-name', CaseStyle.pascalCase), 'FirstName');
      expect(convertCase('my-variable-name', CaseStyle.pascalCase),
          'MyVariableName');
    });

    test('handles already PascalCase', () {
      expect(convertCase('UserName', CaseStyle.pascalCase), 'UserName');
      expect(convertCase('FirstName', CaseStyle.pascalCase), 'FirstName');
    });

    test('handles empty string', () {
      expect(convertCase('', CaseStyle.pascalCase), '');
    });

    test('handles single character', () {
      expect(convertCase('a', CaseStyle.pascalCase), 'A');
      expect(convertCase('A', CaseStyle.pascalCase), 'A');
    });

    test('handles all caps', () {
      expect(convertCase('API', CaseStyle.pascalCase), 'Api');
      expect(convertCase('HTML', CaseStyle.pascalCase), 'Html');
    });

    test('handles numbers', () {
      expect(convertCase('user123', CaseStyle.pascalCase), 'User123');
      expect(convertCase('user_123_name', CaseStyle.pascalCase), 'User123Name');
    });

    test('handles multiple separators', () {
      expect(convertCase('user__name', CaseStyle.pascalCase), 'UserName');
      expect(convertCase('user--name', CaseStyle.pascalCase), 'UserName');
      expect(convertCase('user_-name', CaseStyle.pascalCase), 'UserName');
    });

    test('handles mixed case input', () {
      expect(convertCase('XMLParser', CaseStyle.pascalCase), 'XmlParser');
      expect(convertCase('parseXML', CaseStyle.pascalCase), 'ParseXml');
    });
  });

  group('convertCase - camelCase', () {
    test('converts PascalCase', () {
      expect(convertCase('UserName', CaseStyle.camelCase), 'userName');
      expect(convertCase('FirstName', CaseStyle.camelCase), 'firstName');
      expect(
          convertCase('MyVariableName', CaseStyle.camelCase), 'myVariableName');
    });

    test('converts snake_case', () {
      expect(convertCase('user_name', CaseStyle.camelCase), 'userName');
      expect(convertCase('first_name', CaseStyle.camelCase), 'firstName');
      expect(convertCase('my_variable_name', CaseStyle.camelCase),
          'myVariableName');
    });

    test('converts kebab-case', () {
      expect(convertCase('user-name', CaseStyle.camelCase), 'userName');
      expect(convertCase('first-name', CaseStyle.camelCase), 'firstName');
      expect(convertCase('my-variable-name', CaseStyle.camelCase),
          'myVariableName');
    });

    test('handles already camelCase', () {
      expect(convertCase('userName', CaseStyle.camelCase), 'userName');
      expect(convertCase('firstName', CaseStyle.camelCase), 'firstName');
    });

    test('handles empty string', () {
      expect(convertCase('', CaseStyle.camelCase), '');
    });

    test('handles single character', () {
      expect(convertCase('a', CaseStyle.camelCase), 'a');
      expect(convertCase('A', CaseStyle.camelCase), 'a');
    });

    test('handles all caps', () {
      expect(convertCase('API', CaseStyle.camelCase), 'api');
      expect(convertCase('HTML', CaseStyle.camelCase), 'html');
    });

    test('handles numbers', () {
      expect(convertCase('user123', CaseStyle.camelCase), 'user123');
      expect(convertCase('user_123_name', CaseStyle.camelCase), 'user123Name');
    });

    test('handles multiple separators', () {
      expect(convertCase('user__name', CaseStyle.camelCase), 'userName');
      expect(convertCase('user--name', CaseStyle.camelCase), 'userName');
      expect(convertCase('user_-name', CaseStyle.camelCase), 'userName');
    });
  });

  group('convertCase - snakeCase', () {
    test('converts camelCase', () {
      expect(convertCase('userName', CaseStyle.snakeCase), 'user_name');
      expect(convertCase('firstName', CaseStyle.snakeCase), 'first_name');
      expect(convertCase('myVariableName', CaseStyle.snakeCase),
          'my_variable_name');
    });

    test('converts PascalCase', () {
      expect(convertCase('UserName', CaseStyle.snakeCase), 'user_name');
      expect(convertCase('FirstName', CaseStyle.snakeCase), 'first_name');
      expect(convertCase('MyVariableName', CaseStyle.snakeCase),
          'my_variable_name');
    });

    test('converts kebab-case', () {
      expect(convertCase('user-name', CaseStyle.snakeCase), 'user_name');
      expect(convertCase('first-name', CaseStyle.snakeCase), 'first_name');
      expect(convertCase('my-variable-name', CaseStyle.snakeCase),
          'my_variable_name');
    });

    test('handles already snake_case', () {
      expect(convertCase('user_name', CaseStyle.snakeCase), 'user_name');
      expect(convertCase('first_name', CaseStyle.snakeCase), 'first_name');
    });

    test('handles empty string', () {
      expect(convertCase('', CaseStyle.snakeCase), '');
    });

    test('handles single character', () {
      expect(convertCase('a', CaseStyle.snakeCase), 'a');
      expect(convertCase('A', CaseStyle.snakeCase), 'a');
    });

    test('handles all caps', () {
      expect(convertCase('API', CaseStyle.snakeCase), 'api');
      expect(convertCase('HTML', CaseStyle.snakeCase), 'html');
    });

    test('handles numbers', () {
      expect(convertCase('user123', CaseStyle.snakeCase), 'user123');
      expect(convertCase('userName123', CaseStyle.snakeCase), 'user_name123');
    });

    test('handles multiple separators', () {
      expect(convertCase('user__name', CaseStyle.snakeCase), 'user_name');
      expect(convertCase('user--name', CaseStyle.snakeCase), 'user_name');
    });
  });

  group('convertCase - kebabCase', () {
    test('converts camelCase', () {
      expect(convertCase('userName', CaseStyle.kebabCase), 'user-name');
      expect(convertCase('firstName', CaseStyle.kebabCase), 'first-name');
      expect(convertCase('myVariableName', CaseStyle.kebabCase),
          'my-variable-name');
    });

    test('converts PascalCase', () {
      expect(convertCase('UserName', CaseStyle.kebabCase), 'user-name');
      expect(convertCase('FirstName', CaseStyle.kebabCase), 'first-name');
      expect(convertCase('MyVariableName', CaseStyle.kebabCase),
          'my-variable-name');
    });

    test('converts snake_case', () {
      expect(convertCase('user_name', CaseStyle.kebabCase), 'user-name');
      expect(convertCase('first_name', CaseStyle.kebabCase), 'first-name');
      expect(convertCase('my_variable_name', CaseStyle.kebabCase),
          'my-variable-name');
    });

    test('handles already kebab-case', () {
      expect(convertCase('user-name', CaseStyle.kebabCase), 'user-name');
      expect(convertCase('first-name', CaseStyle.kebabCase), 'first-name');
    });

    test('handles empty string', () {
      expect(convertCase('', CaseStyle.kebabCase), '');
    });

    test('handles single character', () {
      expect(convertCase('a', CaseStyle.kebabCase), 'a');
      expect(convertCase('A', CaseStyle.kebabCase), 'a');
    });

    test('handles all caps', () {
      expect(convertCase('API', CaseStyle.kebabCase), 'api');
      expect(convertCase('HTML', CaseStyle.kebabCase), 'html');
    });

    test('handles numbers', () {
      expect(convertCase('user123', CaseStyle.kebabCase), 'user123');
      expect(convertCase('userName123', CaseStyle.kebabCase), 'user-name123');
    });

    test('handles multiple separators', () {
      expect(convertCase('user__name', CaseStyle.kebabCase), 'user-name');
      expect(convertCase('user--name', CaseStyle.kebabCase), 'user-name');
    });
  });

  group('convertCase - none', () {
    test('returns original string unchanged', () {
      expect(convertCase('userName', CaseStyle.none), 'userName');
      expect(convertCase('user_name', CaseStyle.none), 'user_name');
      expect(convertCase('user-name', CaseStyle.none), 'user-name');
      expect(convertCase('UserName', CaseStyle.none), 'UserName');
    });

    test('handles empty string', () {
      expect(convertCase('', CaseStyle.none), '');
    });

    test('handles special characters', () {
      expect(convertCase('user@name', CaseStyle.none), 'user@name');
      expect(convertCase('user.name', CaseStyle.none), 'user.name');
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
        buildXmlElement(
            builder,
            {
              'items': ['a', null, 'c']
            },
            includeNulls: false);
      });
      final doc = builder.buildDocument();
      final items = doc.rootElement.findElements('items').toList();
      expect(items.length, 2);
    });

    test('uses PascalCase when requested', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(builder, {'user_name': 'test'},
            caseStyle: CaseStyle.pascalCase);
      });
      final doc = builder.buildDocument();
      expect(doc.rootElement.findElements('UserName').length, 1);
    });

    test('uses camelCase when requested', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(builder, {'user_name': 'test'},
            caseStyle: CaseStyle.camelCase);
      });
      final doc = builder.buildDocument();
      expect(doc.rootElement.findElements('userName').length, 1);
    });

    test('uses snakeCase when requested', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(builder, {'userName': 'test'},
            caseStyle: CaseStyle.snakeCase);
      });
      final doc = builder.buildDocument();
      expect(doc.rootElement.findElements('user_name').length, 1);
    });

    test('uses kebabCase when requested', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(builder, {'userName': 'test'},
            caseStyle: CaseStyle.kebabCase);
      });
      final doc = builder.buildDocument();
      expect(doc.rootElement.findElements('user-name').length, 1);
    });

    test('uses none case style when requested', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(builder, {'userName': 'test', 'user_name': 'test2'},
            caseStyle: CaseStyle.none);
      });
      final doc = builder.buildDocument();
      expect(doc.rootElement.findElements('userName').length, 1);
      expect(doc.rootElement.findElements('user_name').length, 1);
    });

    test('camelCase with nested maps', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(
            builder,
            {
              'user_info': {'first_name': 'John'}
            },
            caseStyle: CaseStyle.camelCase);
      });
      final doc = builder.buildDocument();
      final userInfo = doc.rootElement.findElements('userInfo').first;
      expect(userInfo.findElements('firstName').first.innerText, 'John');
    });

    test('snakeCase with nested maps', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(
            builder,
            {
              'userInfo': {'firstName': 'John'}
            },
            caseStyle: CaseStyle.snakeCase);
      });
      final doc = builder.buildDocument();
      final userInfo = doc.rootElement.findElements('user_info').first;
      expect(userInfo.findElements('first_name').first.innerText, 'John');
    });

    test('kebabCase with nested maps', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(
            builder,
            {
              'userInfo': {'firstName': 'John'}
            },
            caseStyle: CaseStyle.kebabCase);
      });
      final doc = builder.buildDocument();
      final userInfo = doc.rootElement.findElements('user-info').first;
      expect(userInfo.findElements('first-name').first.innerText, 'John');
    });

    test('camelCase with lists', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(
            builder,
            {
              'user_items': ['a', 'b']
            },
            caseStyle: CaseStyle.camelCase);
      });
      final doc = builder.buildDocument();
      expect(doc.rootElement.findElements('userItems').length, 2);
    });

    test('snakeCase with lists', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(
            builder,
            {
              'userItems': ['a', 'b']
            },
            caseStyle: CaseStyle.snakeCase);
      });
      final doc = builder.buildDocument();
      expect(doc.rootElement.findElements('user_items').length, 2);
    });

    test('kebabCase with lists', () {
      final builder = XmlBuilder();
      builder.element('root', nest: () {
        buildXmlElement(
            builder,
            {
              'userItems': ['a', 'b']
            },
            caseStyle: CaseStyle.kebabCase);
      });
      final doc = builder.buildDocument();
      expect(doc.rootElement.findElements('user-items').length, 2);
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
      final doc =
          XmlDocument.parse('<root><name>test</name><age>30</age></root>');
      final result = parseXmlElement(doc.rootElement) as Map<String, dynamic>;
      expect(result['name'], 'test');
      expect(result['age'], 30);
    });

    test('parses multiple elements with same name as list', () {
      final doc = XmlDocument.parse(
          '<root><item>a</item><item>b</item><item>c</item></root>');
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

  group('jsonToXml', () {
    test('creates XML with root element', () {
      final result = jsonToXml({'name': 'test'});
      expect(result, contains('<?xml'));
      expect(result, contains('<root>'));
      expect(result, contains('<name>test</name>'));
      expect(result, contains('</root>'));
    });

    test('uses custom root element name', () {
      final result = jsonToXml({'name': 'test'}, rootElementName: 'user');
      expect(result, contains('<user>'));
      expect(result, contains('</user>'));
    });

    test('uses PascalCase root and elements', () {
      final result =
          jsonToXml({'user_name': 'test'}, caseStyle: CaseStyle.pascalCase);
      expect(result, contains('<Root>'));
      expect(result, contains('<UserName>'));
    });

    test('includes metadata', () {
      final result = jsonToXml(
        {'data': 'value'},
        metaData: {'version': '1.0'},
      );
      expect(result, contains('<_meta>'));
      expect(result, contains('<version>1.0</version>'));
    });

    test('PascalCase with metadata', () {
      final result = jsonToXml(
        {'data': 'value'},
        caseStyle: CaseStyle.pascalCase,
        metaData: {'version': '1.0'},
      );
      // Note: '_meta' converts to 'Meta' in PascalCase (leading underscore removed)
      expect(result, contains('<Meta>'));
      expect(result, contains('<Version>1.0</Version>'));
    });

    test('converts to camelCase XML', () {
      final result = jsonToXml(
        {'user_name': 'test', 'first_name': 'John'},
        caseStyle: CaseStyle.camelCase,
      );
      expect(result, contains('<root>'));
      expect(result, contains('<userName>test</userName>'));
      expect(result, contains('<firstName>John</firstName>'));
    });

    test('camelCase with metadata', () {
      final result = jsonToXml(
        {'data': 'value'},
        caseStyle: CaseStyle.camelCase,
        metaData: {'version': '1.0'},
      );
      // Note: '_meta' with leading underscore converts to 'Meta' in camelCase
      expect(result, contains('<Meta>'));
      expect(result, contains('<version>1.0</version>'));
    });

    test('camelCase with nested elements', () {
      final result = jsonToXml(
        {
          'user_info': {'first_name': 'John', 'last_name': 'Doe'}
        },
        caseStyle: CaseStyle.camelCase,
      );
      expect(result, contains('<userInfo>'));
      expect(result, contains('<firstName>John</firstName>'));
      expect(result, contains('<lastName>Doe</lastName>'));
    });

    test('camelCase with custom root element', () {
      final result = jsonToXml(
        {'user_name': 'test'},
        rootElementName: 'user_profile',
        caseStyle: CaseStyle.camelCase,
      );
      expect(result, contains('<userProfile>'));
      expect(result, contains('<userName>test</userName>'));
    });

    test('converts to snakeCase XML', () {
      final result = jsonToXml(
        {'userName': 'test', 'firstName': 'John'},
        caseStyle: CaseStyle.snakeCase,
      );
      expect(result, contains('<root>'));
      expect(result, contains('<user_name>test</user_name>'));
      expect(result, contains('<first_name>John</first_name>'));
    });

    test('snakeCase with metadata', () {
      final result = jsonToXml(
        {'data': 'value'},
        caseStyle: CaseStyle.snakeCase,
        metaData: {'version': '1.0'},
      );
      // Note: '_meta' stays as '_meta' in snakeCase
      expect(result, contains('<_meta>'));
      expect(result, contains('<version>1.0</version>'));
    });

    test('snakeCase with nested elements', () {
      final result = jsonToXml(
        {
          'userInfo': {'firstName': 'John', 'lastName': 'Doe'}
        },
        caseStyle: CaseStyle.snakeCase,
      );
      expect(result, contains('<user_info>'));
      expect(result, contains('<first_name>John</first_name>'));
      expect(result, contains('<last_name>Doe</last_name>'));
    });

    test('snakeCase with custom root element', () {
      final result = jsonToXml(
        {'userName': 'test'},
        rootElementName: 'userProfile',
        caseStyle: CaseStyle.snakeCase,
      );
      expect(result, contains('<user_profile>'));
      expect(result, contains('<user_name>test</user_name>'));
    });

    test('converts to kebabCase XML', () {
      final result = jsonToXml(
        {'userName': 'test', 'firstName': 'John'},
        caseStyle: CaseStyle.kebabCase,
      );
      expect(result, contains('<root>'));
      expect(result, contains('<user-name>test</user-name>'));
      expect(result, contains('<first-name>John</first-name>'));
    });

    test('kebabCase with metadata', () {
      final result = jsonToXml(
        {'data': 'value'},
        caseStyle: CaseStyle.kebabCase,
        metaData: {'version': '1.0'},
      );
      // Note: '_meta' converted to kebab-case becomes '-meta' (underscore becomes hyphen)
      expect(result, contains('<-meta>'));
      expect(result, contains('<version>1.0</version>'));
    });

    test('kebabCase with nested elements', () {
      final result = jsonToXml(
        {
          'userInfo': {'firstName': 'John', 'lastName': 'Doe'}
        },
        caseStyle: CaseStyle.kebabCase,
      );
      expect(result, contains('<user-info>'));
      expect(result, contains('<first-name>John</first-name>'));
      expect(result, contains('<last-name>Doe</last-name>'));
    });

    test('kebabCase with custom root element', () {
      final result = jsonToXml(
        {'userName': 'test'},
        rootElementName: 'userProfile',
        caseStyle: CaseStyle.kebabCase,
      );
      expect(result, contains('<user-profile>'));
      expect(result, contains('<user-name>test</user-name>'));
    });

    test('none case style preserves original keys', () {
      final result = jsonToXml(
        {'userName': 'test', 'first_name': 'John', 'last-name': 'Doe'},
        caseStyle: CaseStyle.none,
      );
      expect(result, contains('<root>'));
      expect(result, contains('<userName>test</userName>'));
      expect(result, contains('<first_name>John</first_name>'));
      expect(result, contains('<last-name>Doe</last-name>'));
    });

    test('none case style with metadata', () {
      final result = jsonToXml(
        {'data': 'value'},
        caseStyle: CaseStyle.none,
        metaData: {'version': '1.0'},
      );
      expect(result, contains('<_meta>'));
      expect(result, contains('<version>1.0</version>'));
    });

    test('handles null values', () {
      final resultExclude = jsonToXml({'key': null}, includeNulls: false);
      expect(resultExclude, isNot(contains('<key>')));

      final resultInclude = jsonToXml({'key': null}, includeNulls: true);
      expect(resultInclude, contains('<key>'));
    });

    test('creates minified XML when prettyPrint is false', () {
      final result = jsonToXml({'name': 'test'}, prettyPrint: false);
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
      final result =
          xmlToMap('<root><count>42</count><price>9.99</price></root>');
      expect(result['count'], 42);
      expect(result['price'], 9.99);
    });

    test('parses boolean values', () {
      final result = xmlToMap(
          '<root><active>true</active><deleted>false</deleted></root>');
      expect(result['active'], true);
      expect(result['deleted'], false);
    });
  });
}
